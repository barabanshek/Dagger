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
    


// This module defines an iterator over work item space.

// Semantics:
//
//    - Items for the same workgroup are issued contiguously.
//      That is, items from different workgroups are never interleaved.
//
//    - Subject to the previous constraint, we make the lower 
//      order ids (e.g. local_id[0]) iterate faster than 
//      higher order (e.g. local_id[2])
//
//    - Id values start at zero and only increase.
//
//    - Behaviour is unspecified if "issue" is asserted more than
//      global_id[0] * global_id[1] * global_id[2] times between times
//      that "start" is asserted.

module acl_work_item_iterator #(
   parameter WIDTH=32,
   parameter LOCAL_WIDTH_X = 32,
   parameter LOCAL_WIDTH_Y = 32,
   parameter LOCAL_WIDTH_Z = 32,
   parameter ENABLE_TESSELLATION=0
) (
   input clock,
   input resetn,
   input start,         // Assert to restart the iterators
   input issue,         // Assert to issue another item, i.e. advance the counters
   // We assume these values are steady while "start" is not asserted.
   input [WIDTH-1:0] local_size[2:0],
   input [WIDTH-1:0] global_size[2:0],
   
   // inputs from id_iterator
   input [WIDTH-1:0] global_id_base[2:0],
   
   // The counter values we export.
   output     [WIDTH-1:0] local_id[2:0],
   output reg [WIDTH-1:0] global_id[2:0],
   
   // output to id_iterator
   output last_in_group,

   input input_enable
);

reg [LOCAL_WIDTH_X-1:0] local_id_0;
reg [LOCAL_WIDTH_Y-1:0] local_id_1;
reg [LOCAL_WIDTH_Z-1:0] local_id_2;

assign local_id[0] = {{(WIDTH-LOCAL_WIDTH_X){1'b0}}, local_id_0};
assign local_id[1] = {{(WIDTH-LOCAL_WIDTH_Y){1'b0}}, local_id_1};
assign local_id[2] = {{(WIDTH-LOCAL_WIDTH_Z){1'b0}}, local_id_2};

// This is the invariant relationship between the various ids.
// Keep these around for debugging.
wire [WIDTH-1:0] global_total = global_id[0] + global_size[0] * ( global_id[1] + global_size[1] * global_id[2] );
wire [WIDTH-1:0] local_total = local_id[0] + local_size[0] * ( local_id[1] + local_size[1] * local_id[2] );



function [WIDTH-1:0] incr_lid ( input [WIDTH-1:0] old_lid, input to_incr, input last );
   if ( to_incr )
      if ( last )
         incr_lid = {WIDTH{1'b0}};
      else 
         incr_lid = old_lid + 2'b01;
   else 
      incr_lid = old_lid;
endfunction


//////////////////////////////////
// Handle local ids.
reg [LOCAL_WIDTH_X-1:0] max_local_id_0;
reg [LOCAL_WIDTH_Y-1:0] max_local_id_1;
reg [LOCAL_WIDTH_Z-1:0] max_local_id_2;

wire last_local_id[2:0];
assign last_local_id[0] = (local_id_0 == max_local_id_0);
assign last_local_id[1] = (local_id_1 == max_local_id_1);
assign last_local_id[2] = (local_id_2 == max_local_id_2);

assign last_in_group = last_local_id[0] & last_local_id[1] & last_local_id[2];

wire bump_local_id[2:0];
wire bump_local_id_reg[2:0];
assign bump_local_id[0] = (max_local_id_0 != 0);
assign bump_local_id[1] = (max_local_id_1 != 0) && last_local_id[0];
assign bump_local_id[2] = (max_local_id_2 != 0) && last_local_id[0] && last_local_id[1];

// Local id register updates.
always @(posedge clock or negedge resetn) begin
   if ( ~resetn ) begin
      local_id_0 <= {LOCAL_WIDTH_X{1'b0}};
      local_id_1 <= {LOCAL_WIDTH_Y{1'b0}};
      local_id_2 <= {LOCAL_WIDTH_Z{1'b0}};
      max_local_id_0 <= {LOCAL_WIDTH_X{1'b0}};
      max_local_id_1 <= {LOCAL_WIDTH_Y{1'b0}};
      max_local_id_2 <= {LOCAL_WIDTH_Z{1'b0}};		
   end else if ( start ) begin
      local_id_0 <= {LOCAL_WIDTH_X{1'b0}};
      local_id_1 <= {LOCAL_WIDTH_Y{1'b0}};
      local_id_2 <= {LOCAL_WIDTH_Z{1'b0}};
      max_local_id_0 <= local_size[0][LOCAL_WIDTH_X-1:0]- 1;
      max_local_id_1 <= local_size[1][LOCAL_WIDTH_Y-1:0]- 1;
      max_local_id_2 <= local_size[2][LOCAL_WIDTH_Z-1:0]- 1;		
   end else // We presume that start and issue are mutually exclusive.
   begin
      if ( issue ) begin
         local_id_0 <= incr_lid (local_id_0, bump_local_id[0], last_local_id[0]);
         local_id_1 <= incr_lid (local_id_1, bump_local_id[1], last_local_id[1]);
         local_id_2 <= incr_lid (local_id_2, bump_local_id[2], last_local_id[2]);
      end
   end
end


  
  // goes high one cycle after last_in_group. stays high until
  // next cycle where 'issue' is high.
  reg just_seen_last_in_group;
  always @(posedge clock or negedge resetn) begin
    if ( ~resetn )
      just_seen_last_in_group <= 1'b1;
    else if ( start )
      just_seen_last_in_group <= 1'b1;
    else if (last_in_group & issue)
      just_seen_last_in_group <= 1'b1;
    else if (issue)
      just_seen_last_in_group <= 1'b0;
    else
      just_seen_last_in_group <= just_seen_last_in_group;
  end
      
//////////////////////////////////
// Handle global ids.

wire [2:0] enable_mux;
wire [2:0] enable_mux_reg;
wire [WIDTH-1:0] global_id_mux[2:0];
wire [WIDTH-1:0] global_id_mux_reg[2:0];
wire [WIDTH-1:0] local_id_operand_mux[2:0];
wire [WIDTH-1:0] local_id_operand_mux_reg[2:0];
wire [WIDTH-1:0] bump_add[2:0];
wire [WIDTH-1:0] bump_add_reg[2:0];
wire just_seen_last_in_group_reg;
wire [WIDTH-1:0] global_id_base_reg[2:0];

wire [WIDTH-1:0] max_local_id[2:0];

assign max_local_id[0] = {{(WIDTH-LOCAL_WIDTH_X){1'b0}}, max_local_id_0};
assign max_local_id[1] = {{(WIDTH-LOCAL_WIDTH_Y){1'b0}}, max_local_id_1};
assign max_local_id[2] = {{(WIDTH-LOCAL_WIDTH_Z){1'b0}}, max_local_id_2};

genvar i;
generate

if (ENABLE_TESSELLATION) begin

acl_shift_register #(.WIDTH(WIDTH),.STAGES(3) )
   jsl ( .clock(clock),.resetn(resetn),.clear(start),.enable(input_enable),.Q(just_seen_last_in_group_reg), .D(just_seen_last_in_group) );

for (i=0;i<3;i = i+1) begin : tesilate_block
   assign enable_mux[i] = issue & !last_in_group & (just_seen_last_in_group | bump_local_id[i]);
      
   acl_shift_register #(.WIDTH(WIDTH),.STAGES(1) )
      global_id_base_sr ( .clock(clock),.resetn(resetn),.clear(start),.enable(input_enable),.Q(global_id_base_reg[i]), .D(global_id_base[i]) );
   acl_shift_register #(.WIDTH(1),.STAGES(1) )
      bump_local_id_sr ( .clock(clock),.resetn(resetn),.clear(start),.enable(input_enable),.Q(bump_local_id_reg[i]), .D( bump_local_id[i] ) );

   acl_multistage_adder #(.WIDTH(WIDTH) )
      bump_add_acl (.clock(clock),.resetn(resetn),.clear(start),.enable(input_enable),.add_sub(1'b0), .result(bump_add_reg[i]), .dataa(global_id_base_reg[i]), .datab( {{(WIDTH-1){1'b0}},{bump_local_id_reg[i]}} ) );
   acl_shift_register #(.WIDTH(WIDTH),.STAGES(3))
      local_id_op (.clock(clock),.resetn(resetn),.clear(start),.enable(input_enable),.Q(local_id_operand_mux_reg[i]), .D(local_id_operand_mux[i]) );
   acl_shift_register #(.WIDTH(1),.STAGES(3))
      enable_inst (.clock(clock),.resetn(resetn),.clear(start),.enable(input_enable),.Q(enable_mux_reg[i]), .D(enable_mux[i]) );

   assign local_id_operand_mux[i] = last_local_id[i] ?  -max_local_id[i] : 2'b01;
   assign global_id_mux[i] = just_seen_last_in_group_reg ? (bump_add_reg[i]) : (global_id[i] + local_id_operand_mux_reg[i]) ;

   always @(posedge clock or negedge resetn) begin
      if ( ~resetn ) begin
         global_id[i] <= {WIDTH{1'b0}};
      end else if ( start ) begin
         global_id[i] <= {WIDTH{1'b0}};
      end else if (enable_mux_reg[i] & input_enable)
      begin
         global_id[i] <= global_id_mux[i];
      end
   end

end

end else begin

always @(posedge clock or negedge resetn) begin
   if ( ~resetn ) begin
      global_id[0] <= {WIDTH{1'b0}};
      global_id[1] <= {WIDTH{1'b0}};
      global_id[2] <= {WIDTH{1'b0}};
   end else if ( start ) begin
      global_id[0] <= {WIDTH{1'b0}};
      global_id[1] <= {WIDTH{1'b0}};
      global_id[2] <= {WIDTH{1'b0}};
   end else // We presume that start and issue are mutually exclusive.
   begin
      if ( issue ) begin
         if ( !last_in_group ) begin
            if ( just_seen_last_in_group ) begin
               // get new global_id starting point from dispatcher.
               // global_id_base will be one cycle late, so get it on the next cycle
               // after encountering last element in previous group.
               // id iterator will know to ignore the global id value on that cycle.
               global_id[0] <= global_id_base[0] + bump_local_id[0];
               global_id[1] <= global_id_base[1] + bump_local_id[1];
               global_id[2] <= global_id_base[2] + bump_local_id[2];
            end else begin
               if ( bump_local_id[0] ) global_id[0] <= (last_local_id[0] ? (global_id[0] - max_local_id[0]) : (global_id[0] + 2'b01));
               if ( bump_local_id[1] ) global_id[1] <= (last_local_id[1] ? (global_id[1] - max_local_id[1]) : (global_id[1] + 2'b01));
               if ( bump_local_id[2] ) global_id[2] <= (last_local_id[2] ? (global_id[2] - max_local_id[2]) : (global_id[2] + 2'b01));
            end
         end
      end
   end
end


end

endgenerate

endmodule


// vim:set filetype=verilog:
