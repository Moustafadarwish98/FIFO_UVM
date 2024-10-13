//import shared_pkg::*;
import uvm_pkg::*;
import Fifo_test_pkg::*;
`include "uvm_macros.svh"

module top ();
bit clk;
initial begin
forever begin
    #1 clk = ~clk;
end 
end

FIFO_interface fifo_if(clk);
FIFO DUT (fifo_if);
initial begin
    uvm_config_db#(virtual FIFO_interface)::set(null, "uvm_test_top", "fifo_if", fifo_if);
    run_test("fifo_test");
end
bind FIFO fifo_sva fifo_sva_instance(fifo_if.DUT);
    
endmodule