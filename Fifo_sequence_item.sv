package fifo_sequence_item_pkg;
import uvm_pkg::*;
//import shared_pkg::*;
`include "uvm_macros.svh"
class fifo_seq_item #(int RD_EN_ON_DIST = 30, int  WR_EN_ON_DIST = 70 ) extends uvm_sequence_item;
`uvm_object_utils(fifo_seq_item)

parameter FIFO_WIDTH = 16;
parameter  FIFO_DEPTH = 8;
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

rand logic rst_n,wr_en,rd_en;
rand logic [FIFO_WIDTH-1:0]data_in;

logic  [FIFO_WIDTH-1:0] data_out;
logic  wr_ack,full,empty,almostempty,almostfull;
logic underflow;
logic overflow;

//Constraints internals
constraint reset {
             rst_n dist {1 := 98, 0 := 2};
           }
           constraint write {
             wr_en dist {1 := WR_EN_ON_DIST, 0 := 100 - WR_EN_ON_DIST};
           }
           constraint read {
             rd_en dist {1 := RD_EN_ON_DIST, 0 := 100 - RD_EN_ON_DIST};
           }


function new (string name = "fifo_seq_item");
 super.new(name);
endfunction

function string convert2string();
return $sformatf ("%s data_in = 0h%0h, rst_n = 0h%0h, wr_en = 0h%0h, rd_en = 0h%0h, data_out = 0h%0h, wr_ack = 0h%0h,
 underflow = 0h%0h, overflow = 0h%0h, full = 0h%0h, almostfull = 0h%0h, almostempty = 0h%0h, empty = 0h%0h",
    super.convert2string(), data_in, rst_n, wr_en, rd_en, data_out, wr_ack, underflow, overflow, full, almostfull, almostempty, empty); 
endfunction

function string convert2string_stimulus();
return $sformatf ("%s data_in = 0h%0h ,rst_n = 0h%0h, wr_en = 0h%0h, rd_en = 0h%0h",  
 super.convert2string(),data_in,rst_n,wr_en,rd_en); 
endfunction


  
endclass //fifo_seq_item
endpackage