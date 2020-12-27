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
    


// Generates global and local ids for given set of group ids.
// Need one of these for each kernel instance.

module acl_id_iterator
#(
  parameter WIDTH = 32,    // width of all the counters
  parameter LOCAL_WIDTH_X = 32,
  parameter LOCAL_WIDTH_Y = 32,
  parameter LOCAL_WIDTH_Z = 32,
  parameter ENABLE_TESSELLATION = 0
)

(
  input clock,
  input resetn,
  input start,
  
  // handshaking with work group dispatcher
  input valid_in,
  output stall_out,
  
  // handshaking with kernel instance
  input stall_in,
  output valid_out,
  
  // comes from group dispatcher
  input [WIDTH-1:0] group_id_in[2:0],
  input [WIDTH-1:0] global_id_base_in[2:0],
  
  // kernel parameters from the higher level
  input [WIDTH-1:0] local_size[2:0],
  input [WIDTH-1:0] global_size[2:0],
  
  // actual outputs
  output [WIDTH-1:0] local_id[2:0],
  output [WIDTH-1:0] global_id[2:0],
  output [WIDTH-1:0] group_id[2:0]
);

  // Storing group id vector and global id offsets vector.
  // Global id offsets help work item iterators calculate global
  // ids without using multipliers.
  localparam FIFO_WIDTH = 2 * 3 * WIDTH;
  localparam FIFO_DEPTH = 4;
  localparam TESSELLATION_STAGES = ENABLE_TESSELLATION ? 3 : 0;
  
  
  wire last_in_group;
  wire valid_out_wire;
  wire valid_out_wire_input;
  wire enable;
  wire issue = valid_out_wire & enable;
  wire issue_check = valid_out_wire;
  
  reg just_seen_last_in_group;
  wire [WIDTH-1:0] global_id_from_iter_wire[2:0];
  wire [WIDTH-1:0] global_id_base[2:0];
  wire [WIDTH-1:0] global_id_base_wire[2:0];


  wire [WIDTH-1:0] local_id_wire[2:0];
  wire [WIDTH-1:0] global_id_wire[2:0];
  wire [WIDTH-1:0] group_id_wire[2:0];

  assign enable = !valid_out |  !stall_in;
  genvar index;
  generate

  for ( index = 0; index < 3; index=index+1 ) 
  begin : register_block
  acl_shift_register #(
	  .WIDTH(WIDTH),
	  .STAGES(TESSELLATION_STAGES)
	  ) acl_gid(.clock(clock), .resetn(resetn), .clear(start), .enable(enable) , .Q(global_id_base[index]), .D(global_id_base_wire[index])
	  );
  acl_shift_register  #(
	  .WIDTH(WIDTH),
	  .STAGES(TESSELLATION_STAGES)
	  ) acl_lid(.clock(clock), .resetn(resetn), .clear(start), .enable(enable) , .Q(local_id[index]), .D(local_id_wire[index])
	  );
  acl_shift_register  #(
	  .WIDTH(WIDTH),
	  .STAGES(TESSELLATION_STAGES)
	  ) acl_grid(.clock(clock), .resetn(resetn), .clear(start), .enable(enable) , .Q(group_id[index]), .D(group_id_wire[index])
	  );

  end

  endgenerate

  acl_shift_register  #(
	  .WIDTH(1),
	  .STAGES(TESSELLATION_STAGES)
	  ) acl_valid(.clock(clock), .resetn(resetn), .clear(start), .enable(enable) , .Q(valid_out), .D(valid_out_wire)
	  );

  // takes one cycle for the work iterm iterator to register
  // global_id_base. During that cycle, just use global_id_base
  // directly.
  wire use_base_wire;
  wire use_base;
  wire [WIDTH-1:0] use_base_wide;
  assign use_base_wire = just_seen_last_in_group;
  acl_shift_register  #(
	  .WIDTH(1),
	  .STAGES(TESSELLATION_STAGES)
	  ) use_base_inst(.clock(clock), .resetn(resetn), .clear(start), .enable(enable) , .Q(use_base), .D(use_base_wire)
	  );
  assign global_id[0] = use_base ? global_id_base[0] : global_id_from_iter_wire[0];
  assign global_id[1] = use_base ? global_id_base[1] : global_id_from_iter_wire[1];
  assign global_id[2] = use_base ? global_id_base[2] : global_id_from_iter_wire[2];
  
  // Group ids (and global id offsets) are stored in a fifo.
  acl_fifo #(
    .DATA_WIDTH(FIFO_WIDTH),
    .DEPTH(FIFO_DEPTH)
  ) group_id_fifo (
    .clock(clock),
    .resetn(resetn),
    .data_in ( {group_id_in[2], group_id_in[1], group_id_in[0], 
                global_id_base_in[2], global_id_base_in[1], global_id_base_in[0]} ),
    .data_out( {group_id_wire[2], group_id_wire[1], group_id_wire[0], 
                global_id_base_wire[2], global_id_base_wire[1], global_id_base_wire[0]} ),
    .valid_in(valid_in),
    .stall_out(stall_out),
    .valid_out(valid_out_wire),
    .stall_in(!last_in_group | !issue)
  );
    
  
  acl_work_item_iterator #(
    .WIDTH(WIDTH),
    .LOCAL_WIDTH_X  (LOCAL_WIDTH_X ),
    .LOCAL_WIDTH_Y  (LOCAL_WIDTH_Y ),
    .LOCAL_WIDTH_Z  (LOCAL_WIDTH_Z ),
    .ENABLE_TESSELLATION (ENABLE_TESSELLATION)
  ) work_item_iterator (
    .clock(clock),
    .resetn(resetn),
    .start(start),
    .issue(issue),
    
    .local_size(local_size),
    .global_size(global_size),
    .global_id_base(global_id_base_wire),
    
    .local_id(local_id_wire),
    .global_id(global_id_from_iter_wire),
    .last_in_group(last_in_group),
    .input_enable(enable)
  );
  
  // goes high one cycle after last_in_group. stays high until
  // next cycle where 'issue' is high.
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
  
endmodule

// vim:set filetype=verilog:

