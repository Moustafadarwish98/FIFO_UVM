interface FIFO_interface(clk);
  parameter FIFO_WIDTH = 16;
  parameter  FIFO_DEPTH = 8;
  localparam max_fifo_addr = $clog2(FIFO_DEPTH);

  reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

  reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
  reg [max_fifo_addr:0] count;

  input  bit clk;
  logic [FIFO_WIDTH-1:0] data_in;
  logic rst_n, wr_en, rd_en;
  logic [FIFO_WIDTH-1:0] data_out;
  logic wr_ack, overflow, underflow;
  logic full, empty, almostfull, almostempty;

  modport DUT (input clk,data_in,rst_n,wr_en,rd_en,mem,wr_ptr,rd_ptr,count,
               output data_out,wr_ack,overflow,underflow,full,empty,almostempty,almostfull);
  modport TEST (input clk,data_out,wr_ack,overflow,underflow,full,empty,almostempty,almostfull,
                output data_in,rst_n,wr_en,rd_en);
  modport MONITOR (input clk,data_out,wr_ack,overflow,underflow,full,empty,almostempty,
                   almostfull,data_in,rst_n,wr_en,rd_en);

endinterface