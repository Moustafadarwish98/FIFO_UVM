package fifo_agent_pkg;
import uvm_pkg::*;
//import shared_pkg::*;
import fifo_driver_pkg::*;
import fifo_config_obj_pkg::*;
import fifo_monitor_pkg::*;
import MySequencer_pkg::*;
import fifo_sequence_item_pkg::*;
`include "uvm_macros.svh"
class fifo_agent extends uvm_agent ;
`uvm_component_utils(fifo_agent)

MySequencer sqr;
fifo_driver drv;
fifo_monitor mon;
fifo_config_obj fifo_cfg;
uvm_analysis_port #(fifo_seq_item) agt_ap; 

function  new (string name = "fifo_agent", uvm_component parent = null);
    super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
//uvm_config_db #(fifo_config_obj)::set(this,"*","CFG",fifo_cfg);
if(!uvm_config_db #(fifo_config_obj)::get(this,"", "CFG", fifo_cfg))
    `uvm_fatal("build_phase", "Unable to get configuration object")
sqr = MySequencer::type_id::create("sqr",this) ;
drv = fifo_driver::type_id::create("drv",this) ;
mon = fifo_monitor::type_id::create("mon",this); 
agt_ap = new("agt_ap", this);
endfunction

function void connect_phase(uvm_phase phase);
drv.fifo_driver_vif = fifo_cfg.fifo_config_vif;
mon.fifo_monitor_vif = fifo_cfg.fifo_config_vif;
drv.seq_item_port.connect(sqr.seq_item_export);
mon.mon_ap.connect(agt_ap);  
endfunction
  
endclass //fifo_agent
    
endpackage