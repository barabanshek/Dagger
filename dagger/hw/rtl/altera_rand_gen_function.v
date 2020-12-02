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
    

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

// altera message_off 10036
// altera message_off 10230
// altera message_off 10858
module altera_rand_gen_function
	(
		input 		clock,
		input 		resetn,
		output 		stall_out,
		input 		valid_in,
		input 		stall_in,
		input [7:0] 		avst_local_bb1__do_data,
		input 		avst_local_bb1__do_valid,
		output 		avst_local_bb1__do_ready,
		output [31:0] 		avst_local_bb1__rand_num_data,
		output 		avst_local_bb1__rand_num_valid,
		input 		avst_local_bb1__rand_num_ready,
		input 		avst_local_bb1__rand_num_almostfull,
		output [7:0] 		avst_local_bb1__return_data,
		output 		avst_local_bb1__return_valid,
		input 		avst_local_bb1__return_ready,
		input 		avst_local_bb1__return_almostfull,
		input 		start,
		input [63:0] 		input_do,
		input [63:0] 		input_rand_num,
		input [63:0] 		input_return,
		output reg 		has_a_write_pending,
		output reg 		has_a_lsu_active
	);


wire [31:0] workgroup_size;
wire bb_0_stall_out;
wire bb_0_valid_out;
wire bb_0_feedback_stall_out_0;
wire bb_0_feedback_valid_out_0;
wire bb_0_feedback_data_out_0;
wire bb_1_stall_out_0;
wire bb_1_stall_out_1;
wire bb_1_valid_out;
wire bb_1_feedback_stall_out_1;
wire bb_1_feedback_stall_out_2;
wire bb_1_acl_pipelined_valid;
wire bb_1_acl_pipelined_exiting_valid;
wire bb_1_acl_pipelined_exiting_stall;
wire bb_1_feedback_valid_out_2;
wire bb_1_feedback_data_out_2;
wire bb_1_feedback_stall_out_5;
wire bb_1_feedback_valid_out_5;
wire [95:0] bb_1_feedback_data_out_5;
wire feedback_stall_0;
wire feedback_valid_0;
wire feedback_data_0;
wire feedback_stall_2;
wire feedback_valid_2;
wire feedback_data_2;
wire feedback_stall_5;
wire feedback_valid_5;
wire [95:0] feedback_data_5;
wire [0:0] writes_pending;
wire [0:0] lsus_active;

altera_rand_gen_basic_block_0 altera_rand_gen_basic_block_0 (
	.clock(clock),
	.resetn(resetn),
	.valid_in(valid_in),
	.stall_out(bb_0_stall_out),
	.valid_out(bb_0_valid_out),
	.stall_in(bb_1_stall_out_1),
	.workgroup_size(workgroup_size),
	.start(start),
	.feedback_valid_in_0(feedback_valid_0),
	.feedback_stall_out_0(feedback_stall_0),
	.feedback_data_in_0(feedback_data_0),
	.feedback_valid_out_0(feedback_valid_0),
	.feedback_stall_in_0(feedback_stall_0),
	.feedback_data_out_0(feedback_data_0)
);


altera_rand_gen_basic_block_1 altera_rand_gen_basic_block_1 (
	.clock(clock),
	.resetn(resetn),
	.input_do(input_do),
	.input_rand_num(input_rand_num),
	.input_return(input_return),
	.valid_in_0(bb_1_acl_pipelined_valid),
	.stall_out_0(bb_1_stall_out_0),
	.input_forked_0(1'b0),
	.valid_in_1(bb_0_valid_out),
	.stall_out_1(bb_1_stall_out_1),
	.input_forked_1(1'b1),
	.valid_out(bb_1_valid_out),
	.stall_in(1'b0),
	.workgroup_size(workgroup_size),
	.start(start),
	.avst_local_bb1__do_data(avst_local_bb1__do_data),
	.avst_local_bb1__do_valid(avst_local_bb1__do_valid),
	.avst_local_bb1__do_ready(avst_local_bb1__do_ready),
	.feedback_stall_out_1(bb_1_feedback_stall_out_1),
	.feedback_valid_in_2(feedback_valid_2),
	.feedback_stall_out_2(feedback_stall_2),
	.feedback_data_in_2(feedback_data_2),
	.acl_pipelined_valid(bb_1_acl_pipelined_valid),
	.acl_pipelined_stall(bb_1_stall_out_0),
	.acl_pipelined_exiting_valid(bb_1_acl_pipelined_exiting_valid),
	.acl_pipelined_exiting_stall(bb_1_acl_pipelined_exiting_stall),
	.feedback_valid_out_2(feedback_valid_2),
	.feedback_stall_in_2(feedback_stall_2),
	.feedback_data_out_2(feedback_data_2),
	.feedback_valid_in_5(feedback_valid_5),
	.feedback_stall_out_5(feedback_stall_5),
	.feedback_data_in_5(feedback_data_5),
	.feedback_valid_out_5(feedback_valid_5),
	.feedback_stall_in_5(feedback_stall_5),
	.feedback_data_out_5(feedback_data_5),
	.avst_local_bb1__rand_num_data(avst_local_bb1__rand_num_data),
	.avst_local_bb1__rand_num_valid(avst_local_bb1__rand_num_valid),
	.avst_local_bb1__rand_num_ready(avst_local_bb1__rand_num_ready),
	.avst_local_bb1__rand_num_almostfull(avst_local_bb1__rand_num_almostfull),
	.avst_local_bb1__return_data(avst_local_bb1__return_data),
	.avst_local_bb1__return_valid(avst_local_bb1__return_valid),
	.avst_local_bb1__return_ready(avst_local_bb1__return_ready),
	.avst_local_bb1__return_almostfull(avst_local_bb1__return_almostfull)
);


assign workgroup_size = 32'h1;
assign stall_out = bb_0_stall_out;
assign writes_pending = 1'b0;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		has_a_write_pending <= 1'b0;
		has_a_lsu_active <= 1'b0;
	end
	else
	begin
		has_a_write_pending <= (|writes_pending);
		has_a_lsu_active <= (|lsus_active);
	end
end

endmodule

