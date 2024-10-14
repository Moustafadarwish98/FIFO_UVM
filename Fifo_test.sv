package Fifo_test_pkg;
import fifo_env_pkg::*;
import fifo_config_obj_pkg::*;
import fifo_write_only_seq_pkg::*;
import fifo_read_only_seq_pkg::*;
import fifo_write_read_seq_pkg::*;
import fifo_reset_sequence_pkg::*;
import MySequencer_pkg::*;
//import shared_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh" 
class fifo_test extends uvm_test;
`uvm_component_utils(fifo_test)
    fifo_env env;
    fifo_config_obj fifo_cfg;
    fifo_reset_sequence reset_seq;
    fifo_write_read_seq write_read_seq;
    fifo_write_only_seq write_only_seq;
    fifo_read_only_seq read_only_seq;
    


    function new(string name = "fifo_test" , uvm_component parent = null);
    super.new(name, parent);        
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env",this);
        fifo_cfg = fifo_config_obj::type_id::create("fifo_cfg");
        write_read_seq = fifo_write_read_seq::type_id::create("write_read_seq",this);
        write_only_seq = fifo_write_only_seq::type_id::create("write_only_seq",this);
        read_only_seq = fifo_read_only_seq::type_id::create("read_only_seq",this);
        reset_seq = fifo_reset_sequence::type_id::create("reset_seq",this);
        if(!uvm_config_db #(virtual FIFO_interface)::get(this,"","fifo_if",fifo_cfg.fifo_config_vif)) 
        begin
        `uvm_fatal("build_phase","Test - Unable to get the virtual interface of the fifo from the uvm_config_db"); 
        end   
        uvm_config_db #(fifo_config_obj)::set(this,"*","CFG",fifo_cfg);
    endfunction

    task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    //reset sequence
    `uvm_info("run_phase","Reset Asserted",UVM_MEDIUM)
    reset_seq.start(env.agent.sqr);
    //write_only sequence
    `uvm_info("run_phase","Stimulus Generation started",UVM_MEDIUM)
    write_only_seq.start(env.agent.sqr);
    `uvm_info("run_phase","Stimulus Generation ended",UVM_MEDIUM)
    //read_only sequence
    `uvm_info("run_phase","Stimulus Generation started",UVM_MEDIUM)
    read_only_seq.start(env.agent.sqr);
    `uvm_info("run_phase","Stimulus Generation ended",UVM_MEDIUM)
    `uvm_info("run_phase","Reset Deasserted",UVM_MEDIUM)
    #1000
    //write_read sequence
    `uvm_info("run_phase","Stimulus Generation started",UVM_MEDIUM)
    write_read_seq.start(env.agent.sqr);
    `uvm_info("run_phase","Stimulus Generation ended",UVM_MEDIUM)
    phase.drop_objection(this);
    endtask
endclass 
endpackage