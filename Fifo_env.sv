package fifo_env_pkg;
import fifo_driver_pkg::*;
import MySequencer_pkg::*;
import fifo_agent_pkg::*;
//import shared_pkg::*;
import fifo_coverage_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class fifo_env extends uvm_env;
    `uvm_component_utils(fifo_env)

fifo_agent agent;
fifo_coverage cov;

function new(string name = "fifo_env",uvm_component parent = null);
super.new(name,parent);        
endfunction 

function void build_phase(uvm_phase phase);
super.build_phase(phase);
agent = fifo_agent::type_id::create("agent",this);
cov = fifo_coverage::type_id::create("cov",this);
endfunction

function void connect_phase(uvm_phase phase);
    agent.agt_ap.connect(cov.cov_export); 
endfunction
endclass 

endpackage