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

`include "altera_rand_gen_function.v"

module altera_rand_gen_function_wrapper
	(
		input 		clock,
		input 		resetn,
		input 		start,
		output 		busy,
		input 		stall,
		output 		done,
		output [31:0] 		avst_local_bb1__rand_num_data,
		output 		avst_local_bb1__rand_num_valid,
		input 		avst_local_bb1__rand_num_ready,
		input 		avst_local_bb1__rand_num_almostfull,
		input 		avst_local_bb1__return_almostfull,
		input [63:0] 		input_do,
		input [63:0] 		input_rand_num,
		input [63:0] 		input_return,
		output 		has_a_write_pending,
		output 		has_a_lsu_active
	);


wire [7:0] avst_local_bb1__do_data;
wire avst_local_bb1__do_valid;
wire avst_local_bb1__do_ready;
wire [7:0] avst_local_bb1__return_data;
wire avst_local_bb1__return_valid;
wire avst_local_bb1__return_ready;

altera_rand_gen_function altera_rand_gen_function_inst (
	.clock(clock),
	.resetn(resetn),
	.stall_out(),
	.valid_in(1'b1),
	.stall_in(1'b0),
	.avst_local_bb1__do_data(avst_local_bb1__do_data),
	.avst_local_bb1__do_valid(avst_local_bb1__do_valid),
	.avst_local_bb1__do_ready(avst_local_bb1__do_ready),
	.avst_local_bb1__rand_num_data(avst_local_bb1__rand_num_data),
	.avst_local_bb1__rand_num_valid(avst_local_bb1__rand_num_valid),
	.avst_local_bb1__rand_num_ready(avst_local_bb1__rand_num_ready),
	.avst_local_bb1__rand_num_almostfull(avst_local_bb1__rand_num_almostfull),
	.avst_local_bb1__return_data(avst_local_bb1__return_data),
	.avst_local_bb1__return_valid(avst_local_bb1__return_valid),
	.avst_local_bb1__return_ready(avst_local_bb1__return_ready),
	.avst_local_bb1__return_almostfull(avst_local_bb1__return_almostfull),
	.start(1'b0),
	.input_do(input_do),
	.input_rand_num(input_rand_num),
	.input_return(input_return),
	.has_a_write_pending(has_a_write_pending),
	.has_a_lsu_active(has_a_lsu_active)
);


assign avst_local_bb1__do_valid = start;
assign busy = ~(avst_local_bb1__do_ready);
assign done = avst_local_bb1__return_valid;
assign avst_local_bb1__return_ready = ~(stall);
endmodule

