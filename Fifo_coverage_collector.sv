package fifo_coverage_pkg;
//import shared_pkg::*;
import uvm_pkg::*;
import fifo_sequence_item_pkg::*;
`include "uvm_macros.svh"

class fifo_coverage extends uvm_component;
  `uvm_component_utils(fifo_coverage)

  uvm_tlm_analysis_fifo #(fifo_seq_item) cov_fifo;
  uvm_analysis_export #(fifo_seq_item) cov_export;
  fifo_seq_item seq_item_cov;

  covergroup cvr_group;
  reset_cover:
  coverpoint seq_item_cov.rst_n {
    bins seq_item_cov_rst_n_0_1[] = {0, 1};
  }
    write_cover:
      coverpoint seq_item_cov.wr_en {
        bins seq_item_cov_wr_en_0_1[] = {0, 1};
      }
    read_cover:
      coverpoint seq_item_cov.rd_en {
        bins seq_item_cov_rd_en_0_1[] = {0, 1};
      }
    overflow_cover:
      coverpoint seq_item_cov.overflow {
        bins overflow_0_1[] = {0, 1};
      }
    underflow_cover:
      coverpoint seq_item_cov.underflow {
        bins underflow_0_1[] = {0, 1};
      }
    full_cover:
      coverpoint seq_item_cov.full {
        bins full_0_1[] = {0, 1};
      }
    seq_item_cov_almostfull_cover:
      coverpoint seq_item_cov.almostfull {
        bins seq_item_cov_almostfull_0_1[] = {0, 1};
      }
    empty_cover:
      coverpoint seq_item_cov.empty {
        bins empty_0_1[] = {0, 1};
      }
    seq_item_cov_almostempty_cover:
      coverpoint seq_item_cov.almostempty {
        bins seq_item_cov_almostempty_0_1[] = {0, 1};
      }
    write_acknowledge_cover:
      coverpoint seq_item_cov.wr_ack {
        bins wr_ack_0_1[] = {0, 1};
      }

    // Cross Coverage for Write and Read enables with flags
    write_cross_cov:
      cross write_cover, write_acknowledge_cover, overflow_cover, underflow_cover, full_cover, empty_cover, seq_item_cov_almostempty_cover, seq_item_cov_almostfull_cover {
        option.cross_auto_bin_max = 0;
        bins wr_full = binsof(write_cover) && binsof(full_cover);
        bins wr_empty = binsof(write_cover) && binsof(empty_cover);
        bins wr_seq_item_cov_almostempty = binsof(write_cover) && binsof(seq_item_cov_almostempty_cover);
        bins wr_seq_item_cov_almostfull = binsof(write_cover) && binsof(seq_item_cov_almostfull_cover);
        bins wr_wr_ack = binsof(write_cover) && binsof(write_acknowledge_cover);
        bins wr_seq_item_cov_overflow = binsof(write_cover) && binsof(overflow_cover);
        bins wr_under = binsof(write_cover) && binsof(underflow_cover);
      }

    read_cross_cov:
      cross read_cover, write_acknowledge_cover, overflow_cover, underflow_cover, full_cover, empty_cover, seq_item_cov_almostempty_cover, seq_item_cov_almostfull_cover {
        option.cross_auto_bin_max = 0;
        bins rd_full = binsof(read_cover) && binsof(full_cover);
        bins rd_empty = binsof(read_cover) && binsof(empty_cover);
        bins rd_seq_item_cov_almostempty = binsof(read_cover) && binsof(seq_item_cov_almostempty_cover);
        bins rd_seq_item_cov_almostfull = binsof(read_cover) && binsof(seq_item_cov_almostfull_cover);
        bins rd_wr_ack = binsof(read_cover) && binsof(write_acknowledge_cover);
        bins rd_seq_item_cov_overflow = binsof(read_cover) && binsof(overflow_cover);
        bins rd_under = binsof(read_cover) && binsof(underflow_cover);
      }

    // Invalid Cross Coverage for Illegal Cases
    invalid_cross:
      cross read_cover,write_cover, write_acknowledge_cover, overflow_cover, underflow_cover, full_cover, empty_cover, seq_item_cov_almostempty_cover, seq_item_cov_almostfull_cover {
        option.cross_auto_bin_max = 0;
        bins wr_rd_full = binsof(read_cover) && binsof(full_cover) && binsof(write_cover);
        bins write_rd_empty = binsof(read_cover) && binsof(empty_cover) && binsof(write_cover);
        bins rd_seq_item_cov_almostempty = binsof(read_cover) && binsof(seq_item_cov_almostempty_cover);
        bins rd_seq_item_cov_almostfull = binsof(read_cover) && binsof(seq_item_cov_almostfull_cover);
        bins rdd_wr_ack = binsof(read_cover) && binsof(write_acknowledge_cover);
        bins rd_seq_item_cov_overflow = binsof(read_cover) && binsof(overflow_cover);
        bins rd_under = binsof(read_cover) && binsof(underflow_cover);
      }

    // Additional Invalid Bin (wr_en = 1 and empty = 1 without reset)
    cross write_cover, empty_cover,reset_cover {
      bins wr_empty_invalid = binsof(write_cover[1]) && binsof(empty_cover[1]) && binsof(reset_cover[1]) ;
    }

  endgroup

  function new(string name = "fifo_coverage", uvm_component parent = null);
    super.new(name, parent);
    cvr_group = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cov_export = new("cov_export", this);
    cov_fifo = new("cov_fifo", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    cov_export.connect(cov_fifo.analysis_export);
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      cov_fifo.get(seq_item_cov);
      cvr_group.sample();
    end
  endtask : run_phase

endclass // fifo_coverage

endpackage
