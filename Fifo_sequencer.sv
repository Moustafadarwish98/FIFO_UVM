package MySequencer_pkg;
import uvm_pkg::*;
//import shared_pkg::*;
import fifo_sequence_item_pkg::*;
`include "uvm_macros.svh"
class MySequencer extends uvm_sequencer #(fifo_seq_item);
`uvm_component_utils(MySequencer)

function new ( string name = "MySequencer", uvm_component parent = null);
    super.new(name, parent);
endfunction
endclass //MySequencer
    
endpackage