// // (C) 1992-2016 Altera Corporation. All rights reserved.                         
// Your use of Altera Corporation's design tools, logic functions and other       
// software and tools, and its AMPP partner logic functions, and any output       
// files any of the foregoing (including device programming or simulation         
// files), and any associated documentation or information are expressly subject  
// to the terms and conditions of the Altera Program License Subscription         
// Agreement, Altera MegaCore Function License Agreement, or other applicable     
// license agreement, including, without limitation, that your use is for the     
// sole purpose of programming logic devices manufactured by Altera and sold by   
// Altera or its authorized distributors.  Please refer to the applicable         
// agreement for further details.                                                 
    


// Work-group limiter. This module has two interface points: the entry point
// and the exit point. The purpose of the module is to ensure that there are
// no more than WG_LIMIT work-groups in the pipeline between the entry and
// exit points. The limiter also remaps the kernel-level work-group id into
// a local work-group id; this is needed because in general the kernel-level
// work-group id space is larger than the local work-group id space. It is 
// assumed that any work-item that passes through the entry point will pass 
// through the exit point at some point.
//
// The ordering of the work-groups affects the implementation. In particular,
// if the work-group order is the same through the entry point and the exit
// point, the implementation is simple. This is referred to as work-group FIFO
// (first-in-first-out) order. It remains a TODO to support work-group
// non-FIFO order (through the exit point).
//
// The work-group order does NOT matter if WG_LIMIT >= KERNEL_WG_LIMIT.
// In this configuration, the real limiter is at the kernel-level and this
// work-group limiter does not do anything useful. It does match the latency
// specifiction though so that the latency and capacity of the core is the
// same regardless of the configuration.
//
// Latency/capacity:
//  Through entry: 1 cycle
//  Through exit: 1 cycle
module acl_work_group_limiter #(
  parameter unsigned WG_LIMIT = 1,               // >0
  parameter unsigned KERNEL_WG_LIMIT = 1,        // >0
  parameter unsigned MAX_WG_SIZE = 1,            // >0
  parameter unsigned WG_FIFO_ORDER = 1,          // 0|1
  parameter string IMPL = "local"                // kernel|local
)
(
  clock,
  resetn,

  wg_size,

  // Limiter entry
  entry_valid_in,
  entry_k_wgid,
  entry_stall_out,
  entry_valid_out,
  entry_l_wgid,
  entry_stall_in,

  // Limiter exit
  exit_valid_in,
  exit_l_wgid,
  exit_stall_out,
  exit_valid_out,
  exit_stall_in

);
  input logic clock;
  input logic resetn;

  // check for overflow
  localparam MAX_WG_SIZE_WIDTH = $clog2({1'b0, MAX_WG_SIZE} + 1);
  input logic [MAX_WG_SIZE_WIDTH-1:0] wg_size;

  // Limiter entry
  input logic entry_valid_in;
  input logic [$clog2(KERNEL_WG_LIMIT)-1:0] entry_k_wgid; // not used if WG_FIFO_ORDER==1
  output logic entry_stall_out;
  output logic entry_valid_out;
  output logic [$clog2(WG_LIMIT)-1:0] entry_l_wgid;
  input logic entry_stall_in;

  // Limiter exit
  input logic exit_valid_in;
  input logic [$clog2(WG_LIMIT)-1:0] exit_l_wgid; // never used
  output logic exit_stall_out;
  output logic exit_valid_out;
  input logic exit_stall_in;


  generate
  // WG_FIFO_ORDER needs to be handled first because the limiter always needs
  // to generate the work-group
  if( WG_FIFO_ORDER == 1 ) begin
    // IMPLEMENTATION ASSUMPTION: complete work-groups are assumed to
    // pass-through work-group and therefore it is sufficient to declare
    // a work-group as done when wg_size work-items have appeared at one point

    logic [MAX_WG_SIZE_WIDTH-1:0] wg_size_limit /* synthesis preserve */;
    always @(posedge clock)
      wg_size_limit <= wg_size - 'd1; // this is a constant throughout the execution of an kernel, but register to limit fanout of source

    // Number of active work-groups that have (partially) entered the limiter and have not 
    // (completely) exited the limiter. Counts from 0 to WG_LIMIT.
    logic [$clog2(WG_LIMIT+1)-1:0] active_wg_count;
    logic incr_active_wg, decr_active_wg;
    logic active_wg_limit_reached;

    // Number of work-items seen in the currently-entering work-group.
    // Counts from 0 to MAX_WG_SIZE-1.
    logic [$clog2(MAX_WG_SIZE)-1:0] cur_entry_wg_wi_count;
    logic cur_entry_wg_wi_count_eq_zero;
    logic [$clog2(WG_LIMIT)-1:0] cur_entry_l_wgid;

    // Number of work-items seen in the currently-exiting work-group.
    // Counts from 0 to MAX_WG_SIZE-1.
    logic [$clog2(MAX_WG_SIZE)-1:0] cur_exit_wg_wi_count;

    always @( posedge clock or negedge resetn ) begin
      if( ~resetn ) begin
        active_wg_count <= '0;
        active_wg_limit_reached <= 1'b0;
      end
      else begin
        active_wg_count <= active_wg_count + incr_active_wg - decr_active_wg;
        if( (active_wg_count == WG_LIMIT - 1) & incr_active_wg & ~decr_active_wg )
          active_wg_limit_reached <= 1'b1;
        else if( (active_wg_count == WG_LIMIT) & decr_active_wg )
          active_wg_limit_reached <= 1'b0;
      end
    end

    //
    // Entry logic: latency = 1
    //

    logic accept_entry;
    logic entry_output_stall_out;

    always @( posedge clock or negedge resetn ) begin
      if( ~resetn ) begin
        cur_entry_wg_wi_count <= '0;
        cur_entry_wg_wi_count_eq_zero <= 1'b1;
        cur_entry_l_wgid <= '0;
      end
      else if( accept_entry ) begin
        if( cur_entry_wg_wi_count == wg_size_limit ) begin
          // The entering work-item is the last work-item of the current
          // work-group. Prepare for the next work-group.
          cur_entry_wg_wi_count <= '0;
          cur_entry_wg_wi_count_eq_zero <= 1'b1;

          if( cur_entry_l_wgid == WG_LIMIT - 1 )
            cur_entry_l_wgid <= '0;
          else
            cur_entry_l_wgid <= cur_entry_l_wgid + 'd1;
        end
        else begin
          // Increment work-item counter.
          cur_entry_wg_wi_count <= cur_entry_wg_wi_count + 'd1;
          cur_entry_wg_wi_count_eq_zero <= 1'b0;
        end
      end
    end

    assign incr_active_wg = cur_entry_wg_wi_count_eq_zero & accept_entry;
    assign accept_entry = entry_valid_in & ~entry_output_stall_out & ~(active_wg_limit_reached & cur_entry_wg_wi_count_eq_zero);

    // Register entry output.
    always @( posedge clock or negedge resetn ) begin
      if( ~resetn ) begin
        entry_valid_out <= 1'b0;
        entry_l_wgid <= 'x;
      end
      else if( ~entry_output_stall_out ) begin
        entry_valid_out <= accept_entry;
        entry_l_wgid <= cur_entry_l_wgid;
      end
    end

    assign entry_output_stall_out = entry_valid_out & entry_stall_in;
    assign entry_stall_out = entry_valid_in & ~accept_entry;

    //
    // Exit logic: latency = 1
    //

    always @( posedge clock or negedge resetn ) begin
      if( ~resetn ) begin
        cur_exit_wg_wi_count <= '0;
      end
      else if( exit_valid_in & ~exit_stall_out ) begin
        if( cur_exit_wg_wi_count == wg_size_limit )
        begin
          // The exiting work-item is the last work-item of the current
          // work-group. Entire work-group has cleared.
          cur_exit_wg_wi_count <= '0;
        end
        else begin
          // Increment work-item counter.
          cur_exit_wg_wi_count <= cur_exit_wg_wi_count + 'd1;
        end
      end
    end

    assign decr_active_wg = exit_valid_in & ~exit_stall_out & (cur_exit_wg_wi_count == wg_size_limit);

    // Register output.
    always @( posedge clock or negedge resetn ) begin
      if( ~resetn )
        exit_valid_out <= 1'b0;
      else if( ~exit_stall_out )
        exit_valid_out <= exit_valid_in;
    end

    assign exit_stall_out = exit_valid_out & exit_stall_in;
  end
  else if( IMPL == "local" && WG_LIMIT >= KERNEL_WG_LIMIT ) begin
    // In this scenario, this work-group limiter doesn't have to do anything
    // because the kernel-level limit is already sufficient.
    //
    // Simply use the kernel hwid as the local hwid.
    //
    // This particular implementation is suitable for any kind of
    // work-item ordering at entry and exit. Register to meet the latency
    // requirements.
    always @( posedge clock or negedge resetn ) begin
      if( ~resetn ) begin
        entry_valid_out <= 1'b0;
        entry_l_wgid <= 'x;
      end
      else if( ~entry_stall_out ) begin
        entry_valid_out <= entry_valid_in;
        entry_l_wgid <= entry_k_wgid;
      end
    end
    assign entry_stall_out = entry_valid_out & entry_stall_in;

    always @( posedge clock or negedge resetn ) begin
      if( ~resetn )
        exit_valid_out <= 1'b0;
      else if( ~exit_stall_out )
        exit_valid_out <= exit_valid_in;
    end
    assign exit_stall_out = exit_valid_out & exit_stall_in;  
  end
  else begin
    // synthesis translate off
    initial
      $fatal("%m: unsupported configuration (WG_LIMIT < KERNEL_WG_LIMIT and WG_FIFO_ORDER != 1)");
    // synthesis translate on
  end
  endgenerate
endmodule

