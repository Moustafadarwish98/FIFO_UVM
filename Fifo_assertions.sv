module fifo_sva (FIFO_interface.DUT inter);

always_comb begin 
    if (!inter.rst_n) begin
        reset:assert final((!inter.wr_ptr)&&(!inter.rd_ptr)&&(!inter.count));
    end
    
  end
  // Combinational Assertions 
  always_comb begin
    fulla:assert final(inter.full == (inter.count == inter.FIFO_DEPTH)? 1:0);
    almostfulla:assert final(inter.almostfull == (inter.count == inter.FIFO_DEPTH - 1)? 1:0);
    emptya:assert final(inter.empty == (inter.count == 0)? 1:0);
    almostemptya:assert final(inter.almostempty == (inter.count == 1)? 1:0);
  end

  // Assertions for sequential logic
  property check_wr_ack;
    @(posedge inter.clk) disable iff (!inter.rst_n)
      ($past(inter.wr_en) && ($past(inter.count) < inter.FIFO_DEPTH) && $past(inter.rst_n)|-> inter.wr_ack == 1);
  endproperty
  assert property (check_wr_ack)
    else $error("WR_ACK failed: WR_EN should acknowledge write.");
  cover property (check_wr_ack);

  property check_overflow;
    @(posedge inter.clk) disable iff (!inter.rst_n)
      ($past(inter.wr_en) && $past(inter.full)&& $past(inter.rst_n)) |-> inter.overflow;
  endproperty
  assert property (check_overflow)
    else $error("Overflow failed: overflow should occur when writing to full FIFO.");
  cover property (check_overflow);

  property check_underflow;
    @(posedge inter.clk) disable iff (!inter.rst_n)
      ($past(inter.rd_en) && $past(inter.empty) && $past(inter.rst_n) |-> inter.underflow );
  endproperty
  assert property (check_underflow)
    else $error("Underflow failed: underflow should occur when reading from empty FIFO.");
  cover property (check_underflow);

  property check_count_stable;
    @(posedge inter.clk) disable iff (!inter.rst_n)
      ($past(inter.wr_en) && $past(inter.rd_en) && !$past(inter.full) && !$past(inter.empty) && $past(inter.rst_n)) |-> (inter.count == $past(inter.count));
  endproperty
  assert property (check_count_stable)
    else $error("inter.count stability failed: inter.count should remain the same when no read or write occurs.");
  cover property (check_count_stable);

  // Property to check that inter.count is incremented correctly when writing
  property check_count_increment;
    @(posedge inter.clk) disable iff (!inter.rst_n)
    ($past(inter.wr_en) && !$past(inter.rd_en) && !$past(inter.full) && $past(inter.rst_n)) |-> (inter.count == $past(inter.count)+ 1'b1);
  endproperty
  assert property (check_count_increment)
    else $error("inter.count increment failed: inter.count should increment by 1 when writing.");
  cover property (check_count_increment);

  // Property to check that inter.count is decremented correctly when reading
  property check_count_decrement;
    @(posedge inter.clk) disable iff (!inter.rst_n)
    (!$past(inter.wr_en) && $past(inter.rd_en) && !$past(inter.empty) && $past(inter.rst_n)) |-> (inter.count == $past(inter.count) - 1'b1);
  endproperty
  assert property (check_count_decrement)
    else $error("inter.count decrement failed: inter.count should decrement by 1 when reading.");
  cover property (check_count_decrement); 

  property check_wr_ptr_increment;
    @(posedge inter.clk) disable iff (!inter.rst_n)
    ($past(inter.wr_en) && ($past(inter.count) < inter.FIFO_DEPTH) && $past(inter.rst_n)|-> (inter.wr_ptr == $past(inter.wr_ptr) + 1'b1));
  endproperty
  assert property (check_wr_ptr_increment)
    else $error("inter.wr_ptr increment failed: inter.wr_ptr should increment on write.");
  cover property (check_wr_ptr_increment);

  property check_rd_ptr_increment;
    @(posedge inter.clk) disable iff (!inter.rst_n)
    ($past(inter.rd_en) && ($past(inter.count) != 0) && $past(inter.rst_n)|-> (inter.rd_ptr == $past(inter.rd_ptr) + 1'b1));
  endproperty
  assert property (check_rd_ptr_increment)
    else $error("inter.rd_ptr increment failed: inter.rd_ptr should increment on read.");
  cover property (check_rd_ptr_increment);
  
endmodule
