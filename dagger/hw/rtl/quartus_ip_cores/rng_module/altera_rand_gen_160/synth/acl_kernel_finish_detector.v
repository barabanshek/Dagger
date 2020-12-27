// (C) 1992-2016 Altera Corporation. All rights reserved.                         
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
    
    


// This module generates the finish signal for the entire kernel.
// There are two main ports on this module:
//  1. From work-group dispatcher: to detect when a work-GROUP is issued
//     It is ASSUMED that the work-group dispatcher issues at most one work-group
//     per cycle.
//  2. From exit points of each kernel copy: to detect when a work-ITEM is completed.
module acl_kernel_finish_detector #(
  parameter integer NUM_COPIES = 1,     // >0
  parameter integer WG_SIZE_W = 1,      // >0
  parameter integer GLOBAL_ID_W = 32,    // >0, number of bits for one global id dimension
  parameter integer TESSELLATION_SIZE = 0
)
(
  input logic clock,
  input logic resetn,

  input logic start,
  input logic [WG_SIZE_W-1:0] wg_size,

  // From work-group dispatcher. It is ASSUMED that
  // at most one work-group is dispatched per cycle.
  input logic [NUM_COPIES-1:0] wg_dispatch_valid_out,
  input logic [NUM_COPIES-1:0] wg_dispatch_stall_in,
  input logic dispatched_all_groups,

  // From copies of the kernel pipeline.
  input logic [NUM_COPIES-1:0] kernel_copy_valid_out,
  input logic [NUM_COPIES-1:0] kernel_copy_stall_in,

  input logic pending_writes,

  // The finish signal is a single-cycle pulse.
  output logic finish
);
  localparam NUM_GLOBAL_DIMS = 3;
  localparam MAX_NDRANGE_SIZE_W = NUM_GLOBAL_DIMS * GLOBAL_ID_W;
  localparam SECTION_SIZE = (TESSELLATION_SIZE == 0) ? MAX_NDRANGE_SIZE_W : TESSELLATION_SIZE;
  
  function integer stage_count;
    input integer width;
    input integer size;
    integer temp,i;
    begin
      temp = width/size;
      if ((width % size) > 0) temp = temp+1;
      stage_count = temp;
    end
  endfunction
  
  function integer mymax;
    input integer a;
    input integer b;
    integer temp;
    begin
      if (a > b) temp = a; else temp = b;
      mymax = temp;
    end
  endfunction 

  // Count the total number of work-items in the entire ND-range. This count
  // is incremented as work-groups are issued.
  // This value is not final until dispatched_all_groups has been asserted.
  localparam COMPARISON_LATENCY = 2;
  localparam TOTAL_STAGES = COMPARISON_LATENCY + stage_count(MAX_NDRANGE_SIZE_W, SECTION_SIZE);
  
  logic [MAX_NDRANGE_SIZE_W-1:0] ndrange_items;
  logic wg_dispatched;
  
  // Here we ASSUME that at most one work-group is dispatched per cycle.
  // This depends on the acl_work_group_dispatcher.
  assign wg_dispatched = |(wg_dispatch_valid_out & ~wg_dispatch_stall_in);
  
  // Pipeline the dispatched_all_groups by the same amout as you pipeline the ndrange_items.
  reg [TOTAL_STAGES-1:0] pipelined_dispatched_all_groups;
  
  generate
  if (TOTAL_STAGES == 1)
  begin
    // This portion of the code should never be used unless someone changes
    // COMPARISON_LATENCY to 0, and correspondingly adjusts the logic for comparison of two numbers to
    // be latency 0. This is a possible optimization if we stop looking at such large ND ranges,
    // and optimize our code for smaller ones when appropriate.    
    always@(posedge clock or negedge resetn)
    begin
     if (~resetn)
     begin
       pipelined_dispatched_all_groups <= 1'bx;
     end
     else if (start)
     begin
       pipelined_dispatched_all_groups <= 1'b0;   
     end
     else
     begin
       pipelined_dispatched_all_groups <= dispatched_all_groups;
     end
   end
  end
  else
  begin
    always@(posedge clock or negedge resetn)
    begin
     if (~resetn)
     begin
       pipelined_dispatched_all_groups <= {{TOTAL_STAGES}{1'bx}};
     end
     else if (start)
     begin
       pipelined_dispatched_all_groups <= {{TOTAL_STAGES}{1'b0}};   
     end
     else
     begin
       pipelined_dispatched_all_groups[TOTAL_STAGES-1:1] <= pipelined_dispatched_all_groups[TOTAL_STAGES-2:0];
       pipelined_dispatched_all_groups[0] <= dispatched_all_groups;
     end
   end
  end  
  endgenerate
  
  // I am breaking up the computation of ndrange_items into several clock cycles. The wg_dispatched will
  // be pipelined as well to drive each stage of the computation as needed. Effectively I am tessellating the
  // adder by hand.
  // ASSUME: start and wg_dispatched are mutually exclusive
  acl_multistage_accumulator ndrange_sum(
    .clock(clock),
    .resetn(resetn),
    .clear(start),
    .result(ndrange_items),
    .increment(wg_size),
    .go(wg_dispatched));
    defparam ndrange_sum.ACCUMULATOR_WIDTH = MAX_NDRANGE_SIZE_W;
    defparam ndrange_sum.INCREMENT_WIDTH = WG_SIZE_W; 
    defparam ndrange_sum.SECTION_SIZE = SECTION_SIZE;    

  // Count the number of work-items that have exited all kernel pipelines.
  logic [NUM_COPIES-1:0] kernel_copy_item_exit;
  logic [MAX_NDRANGE_SIZE_W-1:0] completed_items;
  logic [$clog2(NUM_COPIES+1)-1:0] completed_items_incr_comb, completed_items_incr;
  
  // This is not the best representation, but hopefully synthesis will do something
  // intelligent here (e.g. use compressors?).
  always @(*)
  begin
    completed_items_incr_comb = '0;
    for( integer j = 0; j < NUM_COPIES; ++j )
      completed_items_incr_comb = completed_items_incr_comb + kernel_copy_item_exit[j];
  end
  
  always @(posedge clock or negedge resetn)
  begin
    if( ~resetn )
    begin
      kernel_copy_item_exit <= '0;
      completed_items_incr <= '0;
    end
    else
    begin
      kernel_copy_item_exit <= kernel_copy_valid_out & ~kernel_copy_stall_in;
      completed_items_incr <= completed_items_incr_comb;
    end
  end

  acl_multistage_accumulator ndrange_completed(
    .clock(clock),
    .resetn(resetn),
    .clear(start),
    .result(completed_items),
    .increment(completed_items_incr),
    .go(1'b1));
    defparam ndrange_completed.ACCUMULATOR_WIDTH = MAX_NDRANGE_SIZE_W;
    defparam ndrange_completed.INCREMENT_WIDTH = $clog2(NUM_COPIES+1); 
    defparam ndrange_completed.SECTION_SIZE = mymax(SECTION_SIZE, $clog2(NUM_COPIES+1));
   
  // Determine if the ND-range has completed. This is true when
  // the ndrange_items counter is complete (i.e. dispatched_all_groups)
  // and the completed_items counter is equal to the ndrang_items counter.
  logic ndrange_done;
  logic range_eq_completed;
  
  wire [((MAX_NDRANGE_SIZE_W/8)+1)*8: 0] ndr_wire = {{{((MAX_NDRANGE_SIZE_W/8)+1)*8 - MAX_NDRANGE_SIZE_W}{1'b0}},ndrange_items};
  wire [((MAX_NDRANGE_SIZE_W/8)+1)*8: 0] completed_wire = {{{((MAX_NDRANGE_SIZE_W/8)+1)*8 - MAX_NDRANGE_SIZE_W}{1'b0}},completed_items};
  
  genvar k;
  generate
    if (MAX_NDRANGE_SIZE_W <= 8)
    begin
      assign range_eq_completed = (ndrange_items == completed_items);
    end
    else
    begin
      reg [MAX_NDRANGE_SIZE_W/8 : 0] registered_ranges;
      
      for (k=0;k<=(MAX_NDRANGE_SIZE_W/8); k=k+1)
      begin: k_loop
        always@(posedge clock or negedge resetn)
        begin
          if (~resetn)
            registered_ranges[k] <= 1'b0;
          else if (start)
            registered_ranges[k] <= 1'b0;
          else
            registered_ranges[k] <= (ndr_wire[(k*8+7) : k*8] == completed_wire[(k*8+7):k*8]);
        end
      end
      
      reg cmp_result_reg;
      always@(posedge clock or negedge resetn)
      begin
        if (~resetn)
          cmp_result_reg <= 1'b0;
        else if (start)
          cmp_result_reg <= 1'b0;
        else
          cmp_result_reg <= &registered_ranges;
      end
      
      assign range_eq_completed = cmp_result_reg;
    end 
  endgenerate

  always @(posedge clock or negedge resetn)
  begin
    if( ~resetn )
      ndrange_done <= 1'b0;
    else if( start )
      ndrange_done <= 1'b0;
    else
    begin
      ndrange_done <= pipelined_dispatched_all_groups[TOTAL_STAGES-1] & (range_eq_completed);
    end  
  end

  // The finish output needs to be a one-cycle pulse when the ndrange is completed
  // AND there are no pending writes.
  logic finish_asserted;

  always @(posedge clock or negedge resetn)
  begin
    if( ~resetn )
      finish <= 1'b0;
    else
      finish <= ~finish_asserted & ndrange_done & ~pending_writes;
  end

  always @(posedge clock or negedge resetn)
  begin
    if( ~resetn )
      finish_asserted <= 1'b0;
    else if( start )
      finish_asserted <= 1'b0;
    else if( finish )
      finish_asserted <= 1'b1;
  end

endmodule

