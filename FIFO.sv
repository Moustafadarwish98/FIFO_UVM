//vcover report top.ucdb -all -details -output coverage_fifo.txt
module FIFO(FIFO_interface.DUT inter);

  // Write Logic
  always @(posedge inter.clk or negedge inter.rst_n) begin
    if (!inter.rst_n) begin
      inter.wr_ptr <= 0;
      // Bug reset of signals
      inter.wr_ack <= 0;
      inter.overflow <= 0;
    end else if (inter.wr_en && inter.count < inter.FIFO_DEPTH) begin
      // Write operation
      inter.mem[inter.wr_ptr] <= inter.data_in;
      inter.wr_ack <= 1;
      inter.wr_ptr <= inter.wr_ptr + 1;
      // Bug successful write inter.overflow not handled
      inter.overflow <= 0;
    end else begin
      // Bug Reset inter.wr_ack when no write occurs
      inter.wr_ack <= 0;
      if (inter.full && inter.wr_en) begin
        inter.overflow <= 1;  
      end else begin
        inter.overflow <= 0;  
      end
    end
  end

  // Read Logic
  always @(posedge inter.clk or negedge inter.rst_n) begin
    if (!inter.rst_n) begin
      inter.rd_ptr <= 0;
      // Bug inter.underflow handling not included
      inter.underflow <= 0;
    end else if (inter.rd_en && inter.count != 0) begin
      // Read operation
      inter.data_out <= inter.mem[inter.rd_ptr];
      inter.rd_ptr <= inter.rd_ptr + 1;
      inter.underflow <= 0;
    end else begin
      if (inter.empty && inter.rd_en) begin
        inter.underflow <= 1;
      end else begin
        inter.underflow <= 0;
      end
    end
  end

  // inter.count Management
  always @(posedge inter.clk or negedge inter.rst_n) begin
    if (!inter.rst_n) begin
      inter.count <= 0;
    end else begin
      // Handling simultaneous read and write
      if ({inter.wr_en, inter.rd_en} == 2'b11) begin
        if (inter.empty) begin
          inter.count <= inter.count + 1;
        end else if (inter.full) begin
          inter.count <= inter.count - 1;
        end
        else
          inter.count <= inter.count;
      end
      // Handle individual write
      else if ({inter.wr_en, inter.rd_en} == 2'b10 && !inter.full ) begin
        inter.count = inter.count + 1;
      end
      // Handle individual read
      else if ({inter.wr_en, inter.rd_en} == 2'b01 && !inter.empty) begin
        inter.count = inter.count - 1;
      end
    end
  end

  // Status Flags
  assign inter.full = (inter.count == inter.FIFO_DEPTH) ? 1 : 0;
  assign inter.empty = (inter.count == 0) ? 1 : 0;
  // Bug almost inter.full -1 not -2
  assign inter.almostfull = (inter.count == inter.FIFO_DEPTH - 1) ? 1 : 0;
  assign inter.almostempty = (inter.count == 1) ? 1 : 0;


endmodule