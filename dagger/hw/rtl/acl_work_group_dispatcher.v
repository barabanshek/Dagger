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
    


// This module dispatches group ids to possibly multiple work item iterators.
// Each work-item iterator should be separated by a fifo from the dispatcher.

module acl_work_group_dispatcher
#(
  parameter WIDTH = 32,       // width of all the counters
  parameter NUM_COPIES = 1,   // number of kernel copies to manage
  parameter RUN_FOREVER = 0   // flag for infinitely running kernel
)
(
   input clock,
   input resetn,
   input start,         // Assert to restart the iterators

   // Populated during kernel startup
   input [WIDTH-1:0] num_groups[2:0],
   input [WIDTH-1:0] local_size[2:0],
   
   // Handshaking with iterators for each kernel copy
   input [NUM_COPIES-1:0] stall_in,
   output [NUM_COPIES-1:0] valid_out,
   
   // Export group_id to iterators.
   output reg [WIDTH-1:0] group_id_out[2:0],
   output reg [WIDTH-1:0] global_id_base_out[2:0],
   output start_out,
   
   // High when all groups have been dispatched to id iterators
   output reg dispatched_all_groups
);


//////////////////////////////////
// Group id register updates.
reg started;         // one cycle delayed after start goes high. stays high
reg delayed_start;   // two cycles delayed after start goes high. stays high
reg [WIDTH-1:0] max_group_id[2:0];
reg [WIDTH-1:0] group_id[2:0];
wire last_group_id[2:0];
assign last_group_id[0] = (group_id[0] == max_group_id[0] );
assign last_group_id[1] = (group_id[1] == max_group_id[1] );
assign last_group_id[2] = (group_id[2] == max_group_id[2] );
wire last_group = last_group_id[0] & last_group_id[1] & last_group_id[2];
wire group_id_ready;

wire bump_group_id[2:0];
assign bump_group_id[0] = 1'b1;
assign bump_group_id[1] = last_group_id[0];
assign bump_group_id[2] = last_group_id[0] && last_group_id[1];

always @(posedge clock or negedge resetn) begin
   if ( ~resetn ) begin
      group_id[0] <= {WIDTH{1'b0}};
      group_id[1] <= {WIDTH{1'b0}};
      group_id[2] <= {WIDTH{1'b0}};
      global_id_base_out[0] <= {WIDTH{1'b0}};
      global_id_base_out[1] <= {WIDTH{1'b0}};
      global_id_base_out[2] <= {WIDTH{1'b0}};
      max_group_id[0] <= {WIDTH{1'b0}};
      max_group_id[1] <= {WIDTH{1'b0}};
      max_group_id[2] <= {WIDTH{1'b0}};
      started <= 1'b0;
      delayed_start <= 1'b0;
      dispatched_all_groups <= 1'b0;
   end else if ( start ) begin
      group_id[0] <= {WIDTH{1'b0}};
      group_id[1] <= {WIDTH{1'b0}};
      group_id[2] <= {WIDTH{1'b0}};
      global_id_base_out[0] <= {WIDTH{1'b0}};
      global_id_base_out[1] <= {WIDTH{1'b0}};
      global_id_base_out[2] <= {WIDTH{1'b0}};
      max_group_id[0] <= num_groups[0] - 2'b01;		
      max_group_id[1] <= num_groups[1] - 2'b01;		
      max_group_id[2] <= num_groups[2] - 2'b01;
      started <= 1'b1;
      delayed_start <= started;
      dispatched_all_groups <= 1'b0;
   end else // We presume that start and issue are mutually exclusive.
   begin
      if ( started & stall_in != {NUM_COPIES{1'b1}} & ~dispatched_all_groups ) begin
         if ( bump_group_id[0] ) group_id[0] <= last_group_id[0] ? {WIDTH{1'b0}} : (group_id[0] + 2'b01);
         if ( bump_group_id[1] ) group_id[1] <= last_group_id[1] ? {WIDTH{1'b0}} : (group_id[1] + 2'b01);
         if ( bump_group_id[2] ) group_id[2] <= last_group_id[2] ? {WIDTH{1'b0}} : (group_id[2] + 2'b01);
         
         // increment global_id_base here so it's always equal to 
         //     group_id x local_size.
         // without using any multipliers.
         if ( bump_group_id[0] ) global_id_base_out[0] <= last_group_id[0] ? {WIDTH{1'b0}} : (global_id_base_out[0] + local_size[0]);
         if ( bump_group_id[1] ) global_id_base_out[1] <= last_group_id[1] ? {WIDTH{1'b0}} : (global_id_base_out[1] + local_size[1]);
         if ( bump_group_id[2] ) global_id_base_out[2] <= last_group_id[2] ? {WIDTH{1'b0}} : (global_id_base_out[2] + local_size[2]);
         
         if ( last_group && RUN_FOREVER == 0 )
            dispatched_all_groups <= 1'b1;
      end
      
      // reset these registers so that next kernel invocation will work.
      if ( dispatched_all_groups ) begin
        started <= 1'b0;
        delayed_start <= 1'b0;
      end
   end
end


// will have 1 at the lowest position where stall_in has 0.
wire [NUM_COPIES-1:0] single_one_from_stall_in = ~stall_in & (stall_in + 1'b1);
assign group_id_ready = delayed_start & ~dispatched_all_groups;

assign start_out = start;
assign group_id_out = group_id;
assign valid_out = single_one_from_stall_in & {NUM_COPIES{group_id_ready}};


endmodule

// vim:set filetype=verilog:
