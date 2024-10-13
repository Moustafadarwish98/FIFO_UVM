package fifo_write_only_seq_pkg;
import uvm_pkg::*;
import fifo_sequence_item_pkg::*;
//import shared_pkg::*;
`include "uvm_macros.svh"
class fifo_write_only_seq extends uvm_sequence #(fifo_seq_item) ;
`uvm_object_utils(fifo_write_only_seq);
fifo_seq_item seq_item;

function new (string name = "fifo_write_only_seq");
    super.new(name);
endfunction

task  body;
repeat(100) begin
    `uvm_info("run_phase","main sequence",UVM_MEDIUM)
    seq_item = fifo_seq_item#()::type_id::create("seq_item");
    start_item(seq_item);
    seq_item.wr_en = 1; 
    seq_item.rd_en = 0;
    seq_item.wr_en.rand_mode(0);
    seq_item.rd_en.rand_mode(0);
    seq_item.data_in.rand_mode(1);
    seq_item.rst_n.rand_mode(1);
    assert(seq_item.randomize());
    finish_item(seq_item);
end
endtask
endclass //fifo_write_only_seq
endpackage