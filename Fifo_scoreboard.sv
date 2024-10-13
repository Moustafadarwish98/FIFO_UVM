package fifo_scoreboard_pkg;
import uvm_pkg::*;
//import shared_pkg::*;
import fifo_sequence_item_pkg::*;
`include "uvm_macros.svh"
class fifo_scoreboard extends uvm_scoreboard;
`uvm_component_utils(fifo_scoreboard)
uvm_tlm_analysis_fifo #(fifo_seq_item) sb_fifo;
uvm_analysis_export #(fifo_seq_item) sb_export;
fifo_seq_item seq_item_sb;

parameter FIFO_WIDTH = 16;
parameter  FIFO_DEPTH = 8;
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

logic [FIFO_WIDTH-1:0] data_out_ref;
logic wr_ack_ref;
logic overflow_ref;
logic underflow_ref;
logic full_ref;
logic empty_ref;
logic almostempty_ref;
logic almostfull_ref;

// Internal memory and pointers for the reference model
logic [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
logic [max_fifo_addr:0] count;

integer correct_counter = 0;
integer error_counter = 0;

function new (string name = "fifo_scoreboard", uvm_component parent = null);
    super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_export = new("sb_export", this);
    sb_fifo = new("sb_fifo", this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sb_export.connect(sb_fifo.uvm_analysis_export);
endfunction
  

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
    sb_fifo.get(seq_item_sb);
    ref_model(seq_item_sb);
    if (seq_item_sb.out != data_out_ref) begin
        `uvm_error("run_phase", $sformatf("There is an error!!, Transacton received by the DUT is: %s whilethe refernce output is: 0b%0b",
         seq_item_sb.convert2string(), data_out_ref));
        error_counter++;
    end 
    else begin
        `uvm_info("run_phase", $sformatf("Correct Transacton received, Output is: %s",
                     seq_item_sb.convert2string()),UVM_HIGH)
        correct_counter++;
    end
end
endtask : run_phase
task ref_model(fifo_seq_item check);
// Handle reset behavior
if (!check.rst_n) begin
    wr_ptr = 0;               
    wr_ack_ref = 0;
    overflow_ref = 0;
    underflow_ref = 0;
    rd_ptr = 0;               
    count = 0;         
  end 
  
    // Handle Write Operation
    if (check.wr_en && !full_ref && check.rst_n) begin
      mem[wr_ptr] = check.data_in;
      wr_ack_ref = 1;
      wr_ptr = wr_ptr + 1;
      overflow_ref = 0;
    end 
    else begin
      wr_ack_ref = 0;
      if (full_ref && check.wr_en && check.rst_n ) begin
        overflow_ref = 1;
      end 
      else begin
        overflow_ref = 0;
      end
    end

    // Handle Read Operation
     if (check.rd_en && !empty_ref && check.rst_n) begin
      data_out_ref = mem[rd_ptr];
      rd_ptr = rd_ptr + 1;      
      underflow_ref = 0;
    end 
    else begin
      if (empty_ref && check.rd_en && check.rst_n) begin
        underflow_ref = 1;
      end 
      else begin
        underflow_ref = 0;
      end
    end

    // Manage FIFO Count
    if (({check.wr_en, check.rd_en} == 2'b10) && !full_ref && check.rst_n) begin
      count = count + 1;
    end 
    else if (({check.wr_en, check.rd_en} == 2'b01) && !empty_ref && check.rst_n) begin
      count = count - 1;
    end
    else if ({check.wr_en, check.rd_en} == 2'b11 && check.rst_n) begin
      // Simultaneous read and write
      if (empty_ref && check.rst_n) begin
        count = count + 1;
      end 
      else if (full_ref && check.rst_n) begin
        count = count - 1;
      end
    end 
    else
      count <= count;

    // Update Status Flags (Combinational logic)
    full_ref = (count == check.FIFO_DEPTH) ? 1 : 0;
    empty_ref = (count == 0) ? 1 : 0;
    almostfull_ref = (count == check.FIFO_DEPTH - 1) ? 1 : 0; 
    almostempty_ref = (count == 1) ? 1 : 0; 

endtask : ref_model

function void report_phase(uvm_phase phase);
super.report_phase(phase);
`uvm_info("report_phase", $sformatf("Total coorect counts is: 0d%0d",correct_counter),UVM_LOW)
`uvm_info("report_phase", $sformatf("Total error counts is: 0d%0d",error_counter),UVM_LOW)
endfunction : report_phase
endclass //fifo_scoreboard
    
endpackage