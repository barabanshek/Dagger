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

`include "acl_data_fifo.v"
`include "st_top.v"
`include "acl_pipeline.v"
`include "acl_push.v"
`include "acl_pop.v"
`include "acl_enable_sink.v"

module altera_rand_gen_basic_block_1
	(
		input 		clock,
		input 		resetn,
		input [63:0] 		input_do,
		input [63:0] 		input_rand_num,
		input [63:0] 		input_return,
		input 		valid_in_0,
		output 		stall_out_0,
		input 		input_forked_0,
		input 		valid_in_1,
		output 		stall_out_1,
		input 		input_forked_1,
		output 		valid_out,
		input 		stall_in,
		input [31:0] 		workgroup_size,
		input 		start,
		input [7:0] 		avst_local_bb1__do_data,
		input 		avst_local_bb1__do_valid,
		output 		avst_local_bb1__do_ready,
		output 		feedback_stall_out_1,
		input 		feedback_valid_in_2,
		output 		feedback_stall_out_2,
		input 		feedback_data_in_2,
		output 		acl_pipelined_valid,
		input 		acl_pipelined_stall,
		output 		acl_pipelined_exiting_valid,
		output 		acl_pipelined_exiting_stall,
		output 		feedback_valid_out_2,
		input 		feedback_stall_in_2,
		output 		feedback_data_out_2,
		input 		feedback_valid_in_5,
		output 		feedback_stall_out_5,
		input [95:0] 		feedback_data_in_5,
		output 		feedback_valid_out_5,
		input 		feedback_stall_in_5,
		output [95:0] 		feedback_data_out_5,
		output [31:0] 		avst_local_bb1__rand_num_data,
		output 		avst_local_bb1__rand_num_valid,
		input 		avst_local_bb1__rand_num_ready,
		input 		avst_local_bb1__rand_num_almostfull,
		output [7:0] 		avst_local_bb1__return_data,
		output 		avst_local_bb1__return_valid,
		input 		avst_local_bb1__return_ready,
		input 		avst_local_bb1__return_almostfull
	);


// Values used for debugging.  These are swept away by synthesis.
wire _entry;
wire _exit;
 reg [31:0] _num_entry_NO_SHIFT_REG;
 reg [31:0] _num_exit_NO_SHIFT_REG;
wire [31:0] _num_live;

assign _entry = ((valid_in_0 & valid_in_1) & ~((stall_out_0 | stall_out_1)));
assign _exit = ((&valid_out) & ~((|stall_in)));
assign _num_live = (_num_entry_NO_SHIFT_REG - _num_exit_NO_SHIFT_REG);

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		_num_entry_NO_SHIFT_REG <= 32'h0;
		_num_exit_NO_SHIFT_REG <= 32'h0;
	end
	else
	begin
		if (_entry)
		begin
			_num_entry_NO_SHIFT_REG <= (_num_entry_NO_SHIFT_REG + 2'h1);
		end
		if (_exit)
		begin
			_num_exit_NO_SHIFT_REG <= (_num_exit_NO_SHIFT_REG + 2'h1);
		end
	end
end



// This section defines the behaviour of the MERGE node
wire merge_node_stall_in_0;
 reg merge_node_valid_out_0_NO_SHIFT_REG;
wire merge_node_stall_in_1;
 reg merge_node_valid_out_1_NO_SHIFT_REG;
wire merge_node_stall_in_2;
 reg merge_node_valid_out_2_NO_SHIFT_REG;
wire merge_stalled_by_successors;
 reg merge_block_selector_NO_SHIFT_REG;
 reg merge_node_valid_in_0_staging_reg_NO_SHIFT_REG;
 reg input_forked_0_staging_reg_NO_SHIFT_REG;
 reg local_lvm_forked_NO_SHIFT_REG;
 reg merge_node_valid_in_1_staging_reg_NO_SHIFT_REG;
 reg input_forked_1_staging_reg_NO_SHIFT_REG;
 reg is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
 reg invariant_valid_NO_SHIFT_REG;

assign merge_stalled_by_successors = ((merge_node_stall_in_0 & merge_node_valid_out_0_NO_SHIFT_REG) | (merge_node_stall_in_1 & merge_node_valid_out_1_NO_SHIFT_REG) | (merge_node_stall_in_2 & merge_node_valid_out_2_NO_SHIFT_REG));
assign stall_out_0 = merge_node_valid_in_0_staging_reg_NO_SHIFT_REG;
assign stall_out_1 = merge_node_valid_in_1_staging_reg_NO_SHIFT_REG;

always @(*)
begin
	if ((merge_node_valid_in_0_staging_reg_NO_SHIFT_REG | valid_in_0))
	begin
		merge_block_selector_NO_SHIFT_REG = 1'b0;
		is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b1;
	end
	else
	begin
		if ((merge_node_valid_in_1_staging_reg_NO_SHIFT_REG | valid_in_1))
		begin
			merge_block_selector_NO_SHIFT_REG = 1'b1;
			is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b1;
		end
		else
		begin
			merge_block_selector_NO_SHIFT_REG = 1'b0;
			is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b0;
		end
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		input_forked_0_staging_reg_NO_SHIFT_REG <= 'x;
		merge_node_valid_in_0_staging_reg_NO_SHIFT_REG <= 1'b0;
		input_forked_1_staging_reg_NO_SHIFT_REG <= 'x;
		merge_node_valid_in_1_staging_reg_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (((merge_block_selector_NO_SHIFT_REG != 1'b0) | merge_stalled_by_successors))
		begin
			if (~(merge_node_valid_in_0_staging_reg_NO_SHIFT_REG))
			begin
				input_forked_0_staging_reg_NO_SHIFT_REG <= input_forked_0;
				merge_node_valid_in_0_staging_reg_NO_SHIFT_REG <= valid_in_0;
			end
		end
		else
		begin
			merge_node_valid_in_0_staging_reg_NO_SHIFT_REG <= 1'b0;
		end
		if (((merge_block_selector_NO_SHIFT_REG != 1'b1) | merge_stalled_by_successors))
		begin
			if (~(merge_node_valid_in_1_staging_reg_NO_SHIFT_REG))
			begin
				input_forked_1_staging_reg_NO_SHIFT_REG <= input_forked_1;
				merge_node_valid_in_1_staging_reg_NO_SHIFT_REG <= valid_in_1;
			end
		end
		else
		begin
			merge_node_valid_in_1_staging_reg_NO_SHIFT_REG <= 1'b0;
		end
	end
end

always @(posedge clock)
begin
	if (~(merge_stalled_by_successors))
	begin
		case (merge_block_selector_NO_SHIFT_REG)
			1'b0:
			begin
				if (merge_node_valid_in_0_staging_reg_NO_SHIFT_REG)
				begin
					local_lvm_forked_NO_SHIFT_REG <= input_forked_0_staging_reg_NO_SHIFT_REG;
				end
				else
				begin
					local_lvm_forked_NO_SHIFT_REG <= input_forked_0;
				end
			end

			1'b1:
			begin
				if (merge_node_valid_in_1_staging_reg_NO_SHIFT_REG)
				begin
					local_lvm_forked_NO_SHIFT_REG <= input_forked_1_staging_reg_NO_SHIFT_REG;
				end
				else
				begin
					local_lvm_forked_NO_SHIFT_REG <= input_forked_1;
				end
			end

			default:
			begin
			end

		endcase
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_2_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (~(merge_stalled_by_successors))
		begin
			merge_node_valid_out_0_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_1_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_2_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
		end
		else
		begin
			if (~(merge_node_stall_in_0))
			begin
				merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
			end
			if (~(merge_node_stall_in_1))
			begin
				merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
			end
			if (~(merge_node_stall_in_2))
			begin
				merge_node_valid_out_2_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		invariant_valid_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		invariant_valid_NO_SHIFT_REG <= (~(start) & (invariant_valid_NO_SHIFT_REG | is_merge_data_to_local_regs_valid_NO_SHIFT_REG));
	end
end


// This section implements an unregistered operation.
// 
wire local_bb1_c0_enter__valid_out_0;
wire local_bb1_c0_enter__stall_in_0;
wire local_bb1_c0_enter__valid_out_1;
wire local_bb1_c0_enter__stall_in_1;
wire local_bb1_c0_enter__valid_out_2;
wire local_bb1_c0_enter__stall_in_2;
wire local_bb1_c0_enter__inputs_ready;
wire local_bb1_c0_enter__stall_local;
wire local_bb1_c0_enter__input_accepted;
wire [7:0] local_bb1_c0_enter_;
wire local_bb1_c0_exit_c0_exi1_enable;
wire local_bb1_c0_exit_c0_exi1_entry_stall;
wire local_bb1_c0_enter__valid_bit;
wire local_bb1_c0_exit_c0_exi1_output_regs_ready;
wire local_bb1_c0_exit_c0_exi1_valid_in;
wire local_bb1_c0_exit_c0_exi1_phases;
wire local_bb1_c0_enter__inc_pipelined_thread;
wire local_bb1_c0_enter__dec_pipelined_thread;
wire local_bb1_c0_enter__fu_stall_out;

assign local_bb1_c0_enter__inputs_ready = merge_node_valid_out_0_NO_SHIFT_REG;
assign local_bb1_c0_enter_ = 'x;
assign local_bb1_c0_enter__input_accepted = (local_bb1_c0_enter__inputs_ready && !(local_bb1_c0_exit_c0_exi1_entry_stall));
assign local_bb1_c0_enter__valid_bit = local_bb1_c0_enter__input_accepted;
assign local_bb1_c0_enter__inc_pipelined_thread = 1'b1;
assign local_bb1_c0_enter__dec_pipelined_thread = ~(1'b0);
assign local_bb1_c0_enter__fu_stall_out = (~(local_bb1_c0_enter__inputs_ready) | local_bb1_c0_exit_c0_exi1_entry_stall);
assign local_bb1_c0_enter__stall_local = (local_bb1_c0_enter__stall_in_0 | local_bb1_c0_enter__stall_in_1 | local_bb1_c0_enter__stall_in_2);
assign local_bb1_c0_enter__valid_out_0 = local_bb1_c0_enter__inputs_ready;
assign local_bb1_c0_enter__valid_out_1 = local_bb1_c0_enter__inputs_ready;
assign local_bb1_c0_enter__valid_out_2 = local_bb1_c0_enter__inputs_ready;
assign merge_node_stall_in_0 = (|local_bb1_c0_enter__fu_stall_out);

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_1to2_input_do_0_valid_out_NO_SHIFT_REG;
 logic rnode_1to2_input_do_0_stall_in_NO_SHIFT_REG;
 logic rnode_1to2_input_do_0_reg_2_inputs_ready_NO_SHIFT_REG;
 logic rnode_1to2_input_do_0_valid_out_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_input_do_0_stall_in_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_input_do_0_stall_out_reg_2_NO_SHIFT_REG;

acl_data_fifo rnode_1to2_input_do_0_reg_2_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_1to2_input_do_0_reg_2_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_1to2_input_do_0_stall_in_reg_2_NO_SHIFT_REG),
	.valid_out(rnode_1to2_input_do_0_valid_out_reg_2_NO_SHIFT_REG),
	.stall_out(rnode_1to2_input_do_0_stall_out_reg_2_NO_SHIFT_REG),
	.data_in(),
	.data_out()
);

defparam rnode_1to2_input_do_0_reg_2_fifo.DEPTH = 1;
defparam rnode_1to2_input_do_0_reg_2_fifo.DATA_WIDTH = 0;
defparam rnode_1to2_input_do_0_reg_2_fifo.ALLOW_FULL_WRITE = 1;
defparam rnode_1to2_input_do_0_reg_2_fifo.IMPL = "ll_reg";

assign rnode_1to2_input_do_0_reg_2_inputs_ready_NO_SHIFT_REG = merge_node_valid_out_1_NO_SHIFT_REG;
assign merge_node_stall_in_1 = rnode_1to2_input_do_0_stall_out_reg_2_NO_SHIFT_REG;
assign rnode_1to2_input_do_0_stall_in_reg_2_NO_SHIFT_REG = rnode_1to2_input_do_0_stall_in_NO_SHIFT_REG;
assign rnode_1to2_input_do_0_valid_out_NO_SHIFT_REG = rnode_1to2_input_do_0_valid_out_reg_2_NO_SHIFT_REG;

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_1to2_forked_0_valid_out_0_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_stall_in_0_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_valid_out_1_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_stall_in_1_NO_SHIFT_REG;
 logic rnode_1to2_forked_1_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_reg_2_inputs_ready_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_valid_out_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_stall_in_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_forked_0_stall_out_reg_2_NO_SHIFT_REG;
 reg rnode_1to2_forked_0_consumed_0_NO_SHIFT_REG;
 reg rnode_1to2_forked_0_consumed_1_NO_SHIFT_REG;

acl_data_fifo rnode_1to2_forked_0_reg_2_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_1to2_forked_0_reg_2_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_1to2_forked_0_stall_in_0_reg_2_NO_SHIFT_REG),
	.valid_out(rnode_1to2_forked_0_valid_out_0_reg_2_NO_SHIFT_REG),
	.stall_out(rnode_1to2_forked_0_stall_out_reg_2_NO_SHIFT_REG),
	.data_in(local_lvm_forked_NO_SHIFT_REG),
	.data_out(rnode_1to2_forked_0_reg_2_NO_SHIFT_REG)
);

defparam rnode_1to2_forked_0_reg_2_fifo.DEPTH = 1;
defparam rnode_1to2_forked_0_reg_2_fifo.DATA_WIDTH = 1;
defparam rnode_1to2_forked_0_reg_2_fifo.ALLOW_FULL_WRITE = 1;
defparam rnode_1to2_forked_0_reg_2_fifo.IMPL = "ll_reg";

assign rnode_1to2_forked_0_reg_2_inputs_ready_NO_SHIFT_REG = merge_node_valid_out_2_NO_SHIFT_REG;
assign merge_node_stall_in_2 = rnode_1to2_forked_0_stall_out_reg_2_NO_SHIFT_REG;
assign rnode_1to2_forked_0_stall_in_0_reg_2_NO_SHIFT_REG = ((rnode_1to2_forked_0_stall_in_0_NO_SHIFT_REG & ~(rnode_1to2_forked_0_consumed_0_NO_SHIFT_REG)) | (rnode_1to2_forked_0_stall_in_1_NO_SHIFT_REG & ~(rnode_1to2_forked_0_consumed_1_NO_SHIFT_REG)));
assign rnode_1to2_forked_0_valid_out_0_NO_SHIFT_REG = (rnode_1to2_forked_0_valid_out_0_reg_2_NO_SHIFT_REG & ~(rnode_1to2_forked_0_consumed_0_NO_SHIFT_REG));
assign rnode_1to2_forked_0_valid_out_1_NO_SHIFT_REG = (rnode_1to2_forked_0_valid_out_0_reg_2_NO_SHIFT_REG & ~(rnode_1to2_forked_0_consumed_1_NO_SHIFT_REG));
assign rnode_1to2_forked_0_NO_SHIFT_REG = rnode_1to2_forked_0_reg_2_NO_SHIFT_REG;
assign rnode_1to2_forked_1_NO_SHIFT_REG = rnode_1to2_forked_0_reg_2_NO_SHIFT_REG;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		rnode_1to2_forked_0_consumed_0_NO_SHIFT_REG <= 1'b0;
		rnode_1to2_forked_0_consumed_1_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		rnode_1to2_forked_0_consumed_0_NO_SHIFT_REG <= (rnode_1to2_forked_0_valid_out_0_reg_2_NO_SHIFT_REG & (rnode_1to2_forked_0_consumed_0_NO_SHIFT_REG | ~(rnode_1to2_forked_0_stall_in_0_NO_SHIFT_REG)) & rnode_1to2_forked_0_stall_in_0_reg_2_NO_SHIFT_REG);
		rnode_1to2_forked_0_consumed_1_NO_SHIFT_REG <= (rnode_1to2_forked_0_valid_out_0_reg_2_NO_SHIFT_REG & (rnode_1to2_forked_0_consumed_1_NO_SHIFT_REG | ~(rnode_1to2_forked_0_stall_in_1_NO_SHIFT_REG)) & rnode_1to2_forked_0_stall_in_0_reg_2_NO_SHIFT_REG);
	end
end


// This section implements an unregistered operation.
// 
wire SFC_1_VALID_1_1_0_valid_out_0;
wire SFC_1_VALID_1_1_0_stall_in_0;
wire SFC_1_VALID_1_1_0_valid_out_1;
wire SFC_1_VALID_1_1_0_stall_in_1;
wire SFC_1_VALID_1_1_0_valid_out_2;
wire SFC_1_VALID_1_1_0_stall_in_2;
wire SFC_1_VALID_1_1_0_inputs_ready;
wire SFC_1_VALID_1_1_0_stall_local;
wire SFC_1_VALID_1_1_0;

assign SFC_1_VALID_1_1_0_inputs_ready = local_bb1_c0_enter__valid_out_2;
assign SFC_1_VALID_1_1_0 = local_bb1_c0_enter__valid_bit;
assign SFC_1_VALID_1_1_0_valid_out_0 = 1'b1;
assign SFC_1_VALID_1_1_0_valid_out_1 = 1'b1;
assign SFC_1_VALID_1_1_0_valid_out_2 = 1'b1;
assign local_bb1_c0_enter__stall_in_2 = 1'b0;

// This section implements a registered operation.
// 
wire local_bb1__do_inputs_ready;
 reg local_bb1__do_valid_out_0_NO_SHIFT_REG;
wire local_bb1__do_stall_in_0;
 reg local_bb1__do_valid_out_1_NO_SHIFT_REG;
wire local_bb1__do_stall_in_1;
wire local_bb1__do_output_regs_ready;
wire local_bb1__do_fu_stall_out;
wire local_bb1__do_fu_valid_out;
wire [7:0] local_bb1__do_st_dataout;
 reg local_bb1__do_NO_SHIFT_REG;
wire local_bb1__do_causedstall;

st_read st_local_bb1__do (
	.clock(clock),
	.resetn(resetn),
	.i_init(start),
	.o_stall(local_bb1__do_fu_stall_out),
	.i_valid(local_bb1__do_inputs_ready),
	.i_predicate(1'b0),
	.i_stall(~(local_bb1__do_output_regs_ready)),
	.o_valid(local_bb1__do_fu_valid_out),
	.o_data(local_bb1__do_st_dataout),
	.o_datavalid(),
	.i_fifovalid(avst_local_bb1__do_valid),
	.i_fifodata(avst_local_bb1__do_data),
	.o_fifoready(avst_local_bb1__do_ready),
	.i_fifosize(),
	.profile_i_valid(),
	.profile_i_stall(),
	.profile_o_stall(),
	.profile_total_req(),
	.profile_fifo_stall(),
	.profile_total_fifo_size(),
	.profile_total_fifo_size_incr()
);

defparam st_local_bb1__do.DATA_WIDTH = 8;
defparam st_local_bb1__do.FIFOSIZE_WIDTH = 32;

assign local_bb1__do_inputs_ready = rnode_1to2_input_do_0_valid_out_NO_SHIFT_REG;
assign local_bb1__do_output_regs_ready = ((~(local_bb1__do_valid_out_0_NO_SHIFT_REG) | ~(local_bb1__do_stall_in_0)) & (~(local_bb1__do_valid_out_1_NO_SHIFT_REG) | ~(local_bb1__do_stall_in_1)));
assign rnode_1to2_input_do_0_stall_in_NO_SHIFT_REG = (local_bb1__do_fu_stall_out | ~(local_bb1__do_inputs_ready));
assign local_bb1__do_causedstall = (local_bb1__do_inputs_ready && (local_bb1__do_fu_stall_out && !(~(local_bb1__do_output_regs_ready))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb1__do_NO_SHIFT_REG <= 'x;
		local_bb1__do_valid_out_0_NO_SHIFT_REG <= 1'b0;
		local_bb1__do_valid_out_1_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb1__do_output_regs_ready)
		begin
			local_bb1__do_NO_SHIFT_REG <= local_bb1__do_st_dataout;
			local_bb1__do_valid_out_0_NO_SHIFT_REG <= local_bb1__do_fu_valid_out;
			local_bb1__do_valid_out_1_NO_SHIFT_REG <= local_bb1__do_fu_valid_out;
		end
		else
		begin
			if (~(local_bb1__do_stall_in_0))
			begin
				local_bb1__do_valid_out_0_NO_SHIFT_REG <= 1'b0;
			end
			if (~(local_bb1__do_stall_in_1))
			begin
				local_bb1__do_valid_out_1_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// This section implements an unregistered operation.
// 
wire local_bb1_c1_eni1_valid_out;
wire local_bb1_c1_eni1_stall_in;
wire local_bb1_c1_eni1_inputs_ready;
wire local_bb1_c1_eni1_stall_local;
wire [15:0] local_bb1_c1_eni1;

assign local_bb1_c1_eni1_inputs_ready = rnode_1to2_forked_0_valid_out_0_NO_SHIFT_REG;
assign local_bb1_c1_eni1[7:0] = 8'bx;
assign local_bb1_c1_eni1[8] = rnode_1to2_forked_0_NO_SHIFT_REG;
assign local_bb1_c1_eni1[15:9] = 7'bx;
assign local_bb1_c1_eni1_valid_out = local_bb1_c1_eni1_inputs_ready;
assign local_bb1_c1_eni1_stall_local = local_bb1_c1_eni1_stall_in;
assign rnode_1to2_forked_0_stall_in_0_NO_SHIFT_REG = (|local_bb1_c1_eni1_stall_local);

// This section implements a registered operation.
// 
wire SFC_1_VALID_1_2_0_inputs_ready;
 reg SFC_1_VALID_1_2_0_valid_out_NO_SHIFT_REG;
wire SFC_1_VALID_1_2_0_stall_in;
wire SFC_1_VALID_1_2_0_output_regs_ready;
 reg SFC_1_VALID_1_2_0_NO_SHIFT_REG /* synthesis  preserve  */;
wire SFC_1_VALID_1_2_0_causedstall;

assign SFC_1_VALID_1_2_0_inputs_ready = 1'b1;
assign SFC_1_VALID_1_2_0_output_regs_ready = local_bb1_c0_exit_c0_exi1_enable;
assign SFC_1_VALID_1_1_0_stall_in_0 = 1'b0;
assign SFC_1_VALID_1_2_0_causedstall = (1'b1 && (1'b0 && !(~(local_bb1_c0_exit_c0_exi1_enable))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		SFC_1_VALID_1_2_0_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (SFC_1_VALID_1_2_0_output_regs_ready)
		begin
			SFC_1_VALID_1_2_0_NO_SHIFT_REG <= SFC_1_VALID_1_1_0;
		end
	end
end


// This section implements a registered operation.
// 
wire local_bb1_keep_going_acl_pipeline_1_inputs_ready;
 reg local_bb1_keep_going_acl_pipeline_1_valid_out_NO_SHIFT_REG;
wire local_bb1_keep_going_acl_pipeline_1_stall_in;
wire local_bb1_keep_going_acl_pipeline_1_output_regs_ready;
wire local_bb1_keep_going_acl_pipeline_1_keep_going;
wire local_bb1_keep_going_acl_pipeline_1_fu_valid_out;
wire local_bb1_keep_going_acl_pipeline_1_fu_stall_out;
 reg local_bb1_keep_going_acl_pipeline_1_NO_SHIFT_REG;
wire local_bb1_keep_going_acl_pipeline_1_feedback_pipelined;
wire local_bb1_keep_going_acl_pipeline_1_causedstall;

acl_pipeline local_bb1_keep_going_acl_pipeline_1_pipelined (
	.clock(clock),
	.resetn(resetn),
	.data_in(1'b1),
	.stall_out(local_bb1_keep_going_acl_pipeline_1_fu_stall_out),
	.valid_in(SFC_1_VALID_1_1_0),
	.valid_out(local_bb1_keep_going_acl_pipeline_1_fu_valid_out),
	.stall_in(~(local_bb1_c0_exit_c0_exi1_enable)),
	.data_out(local_bb1_keep_going_acl_pipeline_1_keep_going),
	.initeration_in(1'b0),
	.initeration_valid_in(1'b0),
	.initeration_stall_out(feedback_stall_out_1),
	.not_exitcond_in(feedback_data_in_2),
	.not_exitcond_valid_in(feedback_valid_in_2),
	.not_exitcond_stall_out(feedback_stall_out_2),
	.pipeline_valid_out(acl_pipelined_valid),
	.pipeline_stall_in(acl_pipelined_stall),
	.exiting_valid_out(acl_pipelined_exiting_valid)
);

defparam local_bb1_keep_going_acl_pipeline_1_pipelined.FIFO_DEPTH = 0;
defparam local_bb1_keep_going_acl_pipeline_1_pipelined.STYLE = "NON_SPECULATIVE";

assign local_bb1_keep_going_acl_pipeline_1_inputs_ready = 1'b1;
assign local_bb1_keep_going_acl_pipeline_1_output_regs_ready = local_bb1_c0_exit_c0_exi1_enable;
assign acl_pipelined_exiting_stall = acl_pipelined_stall;
assign local_bb1_c0_enter__stall_in_0 = 1'b0;
assign SFC_1_VALID_1_1_0_stall_in_1 = 1'b0;
assign local_bb1_keep_going_acl_pipeline_1_causedstall = (SFC_1_VALID_1_1_0 && (1'b0 && !(~(local_bb1_c0_exit_c0_exi1_enable))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb1_keep_going_acl_pipeline_1_NO_SHIFT_REG <= 'x;
		local_bb1_keep_going_acl_pipeline_1_valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb1_keep_going_acl_pipeline_1_output_regs_ready)
		begin
			local_bb1_keep_going_acl_pipeline_1_NO_SHIFT_REG <= local_bb1_keep_going_acl_pipeline_1_keep_going;
			local_bb1_keep_going_acl_pipeline_1_valid_out_NO_SHIFT_REG <= 1'b1;
		end
		else
		begin
			if (~(local_bb1_keep_going_acl_pipeline_1_stall_in))
			begin
				local_bb1_keep_going_acl_pipeline_1_valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// This section implements a registered operation.
// 
wire local_bb1_notexitcond_acl_push_i1_1_inputs_ready;
 reg local_bb1_notexitcond_acl_push_i1_1_valid_out_NO_SHIFT_REG;
wire local_bb1_notexitcond_acl_push_i1_1_stall_in;
wire local_bb1_notexitcond_acl_push_i1_1_output_regs_ready;
wire local_bb1_notexitcond_acl_push_i1_1_result;
wire local_bb1_notexitcond_acl_push_i1_1_fu_valid_out;
wire local_bb1_notexitcond_acl_push_i1_1_fu_stall_out;
 reg local_bb1_notexitcond_acl_push_i1_1_NO_SHIFT_REG;
wire local_bb1_notexitcond_acl_push_i1_1_causedstall;

acl_push local_bb1_notexitcond_acl_push_i1_1_feedback (
	.clock(clock),
	.resetn(resetn),
	.dir(1'b1),
	.predicate(1'b0),
	.data_in(1'b1),
	.stall_out(local_bb1_notexitcond_acl_push_i1_1_fu_stall_out),
	.valid_in(SFC_1_VALID_1_1_0),
	.valid_out(local_bb1_notexitcond_acl_push_i1_1_fu_valid_out),
	.stall_in(~(local_bb1_c0_exit_c0_exi1_enable)),
	.data_out(local_bb1_notexitcond_acl_push_i1_1_result),
	.feedback_out(feedback_data_out_2),
	.feedback_valid_out(feedback_valid_out_2),
	.feedback_stall_in(feedback_stall_in_2)
);

defparam local_bb1_notexitcond_acl_push_i1_1_feedback.STALLFREE = 1;
defparam local_bb1_notexitcond_acl_push_i1_1_feedback.ENABLED = 1;
defparam local_bb1_notexitcond_acl_push_i1_1_feedback.DATA_WIDTH = 1;
defparam local_bb1_notexitcond_acl_push_i1_1_feedback.FIFO_DEPTH = 0;
defparam local_bb1_notexitcond_acl_push_i1_1_feedback.MIN_FIFO_LATENCY = 0;
defparam local_bb1_notexitcond_acl_push_i1_1_feedback.STYLE = "REGULAR";
defparam local_bb1_notexitcond_acl_push_i1_1_feedback.RAM_FIFO_DEPTH_INC = 1;

assign local_bb1_notexitcond_acl_push_i1_1_inputs_ready = 1'b1;
assign local_bb1_notexitcond_acl_push_i1_1_output_regs_ready = local_bb1_c0_exit_c0_exi1_enable;
assign local_bb1_c0_enter__stall_in_1 = 1'b0;
assign SFC_1_VALID_1_1_0_stall_in_2 = 1'b0;
assign local_bb1_notexitcond_acl_push_i1_1_causedstall = (SFC_1_VALID_1_1_0 && (1'b0 && !(~(local_bb1_c0_exit_c0_exi1_enable))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb1_notexitcond_acl_push_i1_1_NO_SHIFT_REG <= 'x;
		local_bb1_notexitcond_acl_push_i1_1_valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb1_notexitcond_acl_push_i1_1_output_regs_ready)
		begin
			local_bb1_notexitcond_acl_push_i1_1_NO_SHIFT_REG <= local_bb1_notexitcond_acl_push_i1_1_result;
			local_bb1_notexitcond_acl_push_i1_1_valid_out_NO_SHIFT_REG <= 1'b1;
		end
		else
		begin
			if (~(local_bb1_notexitcond_acl_push_i1_1_stall_in))
			begin
				local_bb1_notexitcond_acl_push_i1_1_valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_3to4_bb1__do_0_valid_out_NO_SHIFT_REG;
 logic rnode_3to4_bb1__do_0_stall_in_NO_SHIFT_REG;
 logic rnode_3to4_bb1__do_0_NO_SHIFT_REG;
 logic rnode_3to4_bb1__do_0_reg_4_inputs_ready_NO_SHIFT_REG;
 logic rnode_3to4_bb1__do_0_reg_4_NO_SHIFT_REG;
 logic rnode_3to4_bb1__do_0_valid_out_reg_4_NO_SHIFT_REG;
 logic rnode_3to4_bb1__do_0_stall_in_reg_4_NO_SHIFT_REG;
 logic rnode_3to4_bb1__do_0_stall_out_reg_4_NO_SHIFT_REG;

acl_data_fifo rnode_3to4_bb1__do_0_reg_4_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_3to4_bb1__do_0_reg_4_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_3to4_bb1__do_0_stall_in_reg_4_NO_SHIFT_REG),
	.valid_out(rnode_3to4_bb1__do_0_valid_out_reg_4_NO_SHIFT_REG),
	.stall_out(rnode_3to4_bb1__do_0_stall_out_reg_4_NO_SHIFT_REG),
	.data_in(local_bb1__do_NO_SHIFT_REG),
	.data_out(rnode_3to4_bb1__do_0_reg_4_NO_SHIFT_REG)
);

defparam rnode_3to4_bb1__do_0_reg_4_fifo.DEPTH = 1;
defparam rnode_3to4_bb1__do_0_reg_4_fifo.DATA_WIDTH = 1;
defparam rnode_3to4_bb1__do_0_reg_4_fifo.ALLOW_FULL_WRITE = 1;
defparam rnode_3to4_bb1__do_0_reg_4_fifo.IMPL = "ll_reg";

assign rnode_3to4_bb1__do_0_reg_4_inputs_ready_NO_SHIFT_REG = local_bb1__do_valid_out_1_NO_SHIFT_REG;
assign local_bb1__do_stall_in_1 = rnode_3to4_bb1__do_0_stall_out_reg_4_NO_SHIFT_REG;
assign rnode_3to4_bb1__do_0_NO_SHIFT_REG = rnode_3to4_bb1__do_0_reg_4_NO_SHIFT_REG;
assign rnode_3to4_bb1__do_0_stall_in_reg_4_NO_SHIFT_REG = rnode_3to4_bb1__do_0_stall_in_NO_SHIFT_REG;
assign rnode_3to4_bb1__do_0_valid_out_NO_SHIFT_REG = rnode_3to4_bb1__do_0_valid_out_reg_4_NO_SHIFT_REG;

// This section implements an unregistered operation.
// 
wire local_bb1_c0_exi1_valid_out;
wire local_bb1_c0_exi1_stall_in;
wire local_bb1_c0_exi1_inputs_ready;
wire local_bb1_c0_exi1_stall_local;
wire [15:0] local_bb1_c0_exi1;

assign local_bb1_c0_exi1_inputs_ready = local_bb1_notexitcond_acl_push_i1_1_valid_out_NO_SHIFT_REG;
assign local_bb1_c0_exi1[7:0] = 8'bx;
assign local_bb1_c0_exi1[8] = local_bb1_notexitcond_acl_push_i1_1_NO_SHIFT_REG;
assign local_bb1_c0_exi1[15:9] = 7'bx;
assign local_bb1_c0_exi1_valid_out = 1'b1;
assign local_bb1_notexitcond_acl_push_i1_1_stall_in = 1'b0;

// This section implements an unregistered operation.
// 
wire local_bb1_c0_exit_c0_exi1_valid_out;
wire local_bb1_c0_exit_c0_exi1_stall_in;
wire local_bb1_c0_exit_c0_exi1_inputs_ready;
wire local_bb1_c0_exit_c0_exi1_stall_local;
wire [15:0] local_bb1_c0_exit_c0_exi1;
wire local_bb1_c0_exit_c0_exi1_valid;
wire local_bb1_c0_exit_c0_exi1_fu_stall_out;

acl_enable_sink local_bb1_c0_exit_c0_exi1_instance (
	.clock(clock),
	.resetn(resetn),
	.data_in(local_bb1_c0_exi1),
	.data_out(local_bb1_c0_exit_c0_exi1),
	.input_accepted(local_bb1_c0_enter__input_accepted),
	.valid_out(local_bb1_c0_exit_c0_exi1_valid),
	.stall_in(local_bb1_c0_exit_c0_exi1_stall_local),
	.enable(local_bb1_c0_exit_c0_exi1_enable),
	.valid_in(local_bb1_c0_exit_c0_exi1_valid_in),
	.stall_entry(local_bb1_c0_exit_c0_exi1_entry_stall),
	.inc_pipelined_thread(local_bb1_c0_enter__inc_pipelined_thread),
	.dec_pipelined_thread(local_bb1_c0_enter__dec_pipelined_thread)
);

defparam local_bb1_c0_exit_c0_exi1_instance.DATA_WIDTH = 16;
defparam local_bb1_c0_exit_c0_exi1_instance.PIPELINE_DEPTH = 1;
defparam local_bb1_c0_exit_c0_exi1_instance.SCHEDULEII = 1;
defparam local_bb1_c0_exit_c0_exi1_instance.IP_PIPELINE_LATENCY_PLUS1 = 1;

assign local_bb1_c0_exit_c0_exi1_inputs_ready = (local_bb1_c0_exi1_valid_out & local_bb1_keep_going_acl_pipeline_1_valid_out_NO_SHIFT_REG & SFC_1_VALID_1_2_0_valid_out_NO_SHIFT_REG);
assign local_bb1_c0_exit_c0_exi1_valid_in = SFC_1_VALID_1_2_0_NO_SHIFT_REG;
assign local_bb1_c0_exit_c0_exi1_fu_stall_out = ~(local_bb1_c0_exit_c0_exi1_enable);
assign local_bb1_c0_exit_c0_exi1_valid_out = local_bb1_c0_exit_c0_exi1_valid;
assign local_bb1_c0_exit_c0_exi1_stall_local = local_bb1_c0_exit_c0_exi1_stall_in;
assign local_bb1_c0_exi1_stall_in = 1'b0;
assign local_bb1_keep_going_acl_pipeline_1_stall_in = 1'b0;
assign SFC_1_VALID_1_2_0_stall_in = 1'b0;

// This section implements an unregistered operation.
// 
wire local_bb1_c0_exe1_valid_out;
wire local_bb1_c0_exe1_stall_in;
wire local_bb1_c0_exe1_inputs_ready;
wire local_bb1_c0_exe1_stall_local;
wire local_bb1_c0_exe1;

assign local_bb1_c0_exe1_inputs_ready = local_bb1_c0_exit_c0_exi1_valid_out;
assign local_bb1_c0_exe1 = local_bb1_c0_exit_c0_exi1[8];
assign local_bb1_c0_exe1_valid_out = local_bb1_c0_exe1_inputs_ready;
assign local_bb1_c0_exe1_stall_local = local_bb1_c0_exe1_stall_in;
assign local_bb1_c0_exit_c0_exi1_stall_in = (|local_bb1_c0_exe1_stall_local);

// This section implements an unregistered operation.
// 
wire local_bb1_c1_enter_c1_eni1_valid_out_0;
wire local_bb1_c1_enter_c1_eni1_stall_in_0;
wire local_bb1_c1_enter_c1_eni1_valid_out_1;
wire local_bb1_c1_enter_c1_eni1_stall_in_1;
wire local_bb1_c1_enter_c1_eni1_inputs_ready;
wire local_bb1_c1_enter_c1_eni1_stall_local;
wire local_bb1_c1_enter_c1_eni1_input_accepted;
wire [15:0] local_bb1_c1_enter_c1_eni1;
wire local_bb1_c1_exit_c1_exi1_enable;
wire local_bb1_c1_exit_c1_exi1_entry_stall;
wire local_bb1_c1_enter_c1_eni1_valid_bit;
wire local_bb1_c1_exit_c1_exi1_output_regs_ready;
wire local_bb1_c1_exit_c1_exi1_valid_in;
wire local_bb1_c1_exit_c1_exi1_phases;
wire local_bb1_c1_enter_c1_eni1_inc_pipelined_thread;
wire local_bb1_c1_enter_c1_eni1_dec_pipelined_thread;
wire local_bb1_c1_enter_c1_eni1_fu_stall_out;

assign local_bb1_c1_enter_c1_eni1_inputs_ready = (local_bb1_c1_eni1_valid_out & local_bb1_c0_exe1_valid_out & rnode_1to2_forked_0_valid_out_1_NO_SHIFT_REG);
assign local_bb1_c1_enter_c1_eni1 = local_bb1_c1_eni1;
assign local_bb1_c1_enter_c1_eni1_input_accepted = (local_bb1_c1_enter_c1_eni1_inputs_ready && !(local_bb1_c1_exit_c1_exi1_entry_stall));
assign local_bb1_c1_enter_c1_eni1_valid_bit = local_bb1_c1_enter_c1_eni1_input_accepted;
assign local_bb1_c1_enter_c1_eni1_inc_pipelined_thread = rnode_1to2_forked_1_NO_SHIFT_REG;
assign local_bb1_c1_enter_c1_eni1_dec_pipelined_thread = ~(local_bb1_c0_exe1);
assign local_bb1_c1_enter_c1_eni1_fu_stall_out = (~(local_bb1_c1_enter_c1_eni1_inputs_ready) | local_bb1_c1_exit_c1_exi1_entry_stall);
assign local_bb1_c1_enter_c1_eni1_stall_local = (local_bb1_c1_enter_c1_eni1_stall_in_0 | local_bb1_c1_enter_c1_eni1_stall_in_1);
assign local_bb1_c1_enter_c1_eni1_valid_out_0 = local_bb1_c1_enter_c1_eni1_inputs_ready;
assign local_bb1_c1_enter_c1_eni1_valid_out_1 = local_bb1_c1_enter_c1_eni1_inputs_ready;
assign local_bb1_c1_eni1_stall_in = (local_bb1_c1_enter_c1_eni1_fu_stall_out | ~(local_bb1_c1_enter_c1_eni1_inputs_ready));
assign local_bb1_c0_exe1_stall_in = (local_bb1_c1_enter_c1_eni1_fu_stall_out | ~(local_bb1_c1_enter_c1_eni1_inputs_ready));
assign rnode_1to2_forked_0_stall_in_1_NO_SHIFT_REG = (local_bb1_c1_enter_c1_eni1_fu_stall_out | ~(local_bb1_c1_enter_c1_eni1_inputs_ready));

// This section implements an unregistered operation.
// 
wire local_bb1_c1_ene1_valid_out;
wire local_bb1_c1_ene1_stall_in;
wire local_bb1_c1_ene1_inputs_ready;
wire local_bb1_c1_ene1_stall_local;
wire local_bb1_c1_ene1;

assign local_bb1_c1_ene1_inputs_ready = local_bb1_c1_enter_c1_eni1_valid_out_0;
assign local_bb1_c1_ene1 = local_bb1_c1_enter_c1_eni1[8];
assign local_bb1_c1_ene1_valid_out = 1'b1;
assign local_bb1_c1_enter_c1_eni1_stall_in_0 = 1'b0;

// This section implements an unregistered operation.
// 
wire SFC_2_VALID_2_2_0_valid_out;
wire SFC_2_VALID_2_2_0_stall_in;
wire SFC_2_VALID_2_2_0_inputs_ready;
wire SFC_2_VALID_2_2_0_stall_local;
wire SFC_2_VALID_2_2_0;

assign SFC_2_VALID_2_2_0_inputs_ready = local_bb1_c1_enter_c1_eni1_valid_out_1;
assign SFC_2_VALID_2_2_0 = local_bb1_c1_enter_c1_eni1_valid_bit;
assign SFC_2_VALID_2_2_0_valid_out = 1'b1;
assign local_bb1_c1_enter_c1_eni1_stall_in_1 = 1'b0;

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_2to3_bb1_c1_ene1_0_valid_out_0_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_stall_in_0_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_valid_out_1_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_stall_in_1_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_1_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_reg_3_inputs_ready_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_reg_3_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_valid_out_0_reg_3_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_stall_in_0_reg_3_NO_SHIFT_REG;
 logic rnode_2to3_bb1_c1_ene1_0_stall_out_reg_3_NO_SHIFT_REG;

acl_data_fifo rnode_2to3_bb1_c1_ene1_0_reg_3_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_2to3_bb1_c1_ene1_0_reg_3_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_2to3_bb1_c1_ene1_0_stall_in_0_reg_3_NO_SHIFT_REG),
	.valid_out(rnode_2to3_bb1_c1_ene1_0_valid_out_0_reg_3_NO_SHIFT_REG),
	.stall_out(rnode_2to3_bb1_c1_ene1_0_stall_out_reg_3_NO_SHIFT_REG),
	.data_in(local_bb1_c1_ene1),
	.data_out(rnode_2to3_bb1_c1_ene1_0_reg_3_NO_SHIFT_REG)
);

defparam rnode_2to3_bb1_c1_ene1_0_reg_3_fifo.DEPTH = 1;
defparam rnode_2to3_bb1_c1_ene1_0_reg_3_fifo.DATA_WIDTH = 1;
defparam rnode_2to3_bb1_c1_ene1_0_reg_3_fifo.ALLOW_FULL_WRITE = 1;
defparam rnode_2to3_bb1_c1_ene1_0_reg_3_fifo.IMPL = "shift_reg";

assign rnode_2to3_bb1_c1_ene1_0_reg_3_inputs_ready_NO_SHIFT_REG = 1'b1;
assign local_bb1_c1_ene1_stall_in = 1'b0;
assign rnode_2to3_bb1_c1_ene1_0_stall_in_0_reg_3_NO_SHIFT_REG = ~(local_bb1_c1_exit_c1_exi1_enable);
assign rnode_2to3_bb1_c1_ene1_0_valid_out_0_NO_SHIFT_REG = 1'b1;
assign rnode_2to3_bb1_c1_ene1_0_NO_SHIFT_REG = rnode_2to3_bb1_c1_ene1_0_reg_3_NO_SHIFT_REG;
assign rnode_2to3_bb1_c1_ene1_0_valid_out_1_NO_SHIFT_REG = 1'b1;
assign rnode_2to3_bb1_c1_ene1_1_NO_SHIFT_REG = rnode_2to3_bb1_c1_ene1_0_reg_3_NO_SHIFT_REG;

// This section implements a registered operation.
// 
wire SFC_2_VALID_2_3_0_inputs_ready;
 reg SFC_2_VALID_2_3_0_valid_out_0_NO_SHIFT_REG;
wire SFC_2_VALID_2_3_0_stall_in_0;
 reg SFC_2_VALID_2_3_0_valid_out_1_NO_SHIFT_REG;
wire SFC_2_VALID_2_3_0_stall_in_1;
 reg SFC_2_VALID_2_3_0_valid_out_2_NO_SHIFT_REG;
wire SFC_2_VALID_2_3_0_stall_in_2;
wire SFC_2_VALID_2_3_0_output_regs_ready;
 reg SFC_2_VALID_2_3_0_NO_SHIFT_REG /* synthesis  preserve  */;
wire SFC_2_VALID_2_3_0_causedstall;

assign SFC_2_VALID_2_3_0_inputs_ready = 1'b1;
assign SFC_2_VALID_2_3_0_output_regs_ready = local_bb1_c1_exit_c1_exi1_enable;
assign SFC_2_VALID_2_2_0_stall_in = 1'b0;
assign SFC_2_VALID_2_3_0_causedstall = (1'b1 && (1'b0 && !(~(local_bb1_c1_exit_c1_exi1_enable))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		SFC_2_VALID_2_3_0_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (SFC_2_VALID_2_3_0_output_regs_ready)
		begin
			SFC_2_VALID_2_3_0_NO_SHIFT_REG <= SFC_2_VALID_2_2_0;
		end
	end
end


// This section implements an unregistered operation.
// 
wire local_bb1_vectorpop5_insert0_stall_local;
wire [95:0] local_bb1_vectorpop5_insert0;

assign local_bb1_vectorpop5_insert0[31:0] = 32'h41CD285;
assign local_bb1_vectorpop5_insert0[95:32] = 64'bx;

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpop5_insert1_stall_local;
wire [95:0] local_bb1_vectorpop5_insert1;

assign local_bb1_vectorpop5_insert1[31:0] = local_bb1_vectorpop5_insert0[31:0];
assign local_bb1_vectorpop5_insert1[63:32] = 32'h41CD286;
assign local_bb1_vectorpop5_insert1[95:64] = local_bb1_vectorpop5_insert0[95:64];

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpop5_insert2_stall_local;
wire [95:0] local_bb1_vectorpop5_insert2;

assign local_bb1_vectorpop5_insert2[63:0] = local_bb1_vectorpop5_insert1[63:0];
assign local_bb1_vectorpop5_insert2[95:64] = 32'h41CD287;

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpop5_vectorpop5_insert2_stall_local;
wire [95:0] local_bb1_vectorpop5_vectorpop5_insert2;
wire local_bb1_vectorpop5_vectorpop5_insert2_fu_valid_out;
wire local_bb1_vectorpop5_vectorpop5_insert2_fu_stall_out;

acl_pop local_bb1_vectorpop5_vectorpop5_insert2_feedback (
	.clock(clock),
	.resetn(resetn),
	.dir(rnode_2to3_bb1_c1_ene1_1_NO_SHIFT_REG),
	.predicate(1'b0),
	.data_in(local_bb1_vectorpop5_insert2),
	.stall_out(local_bb1_vectorpop5_vectorpop5_insert2_fu_stall_out),
	.valid_in(SFC_2_VALID_2_3_0_NO_SHIFT_REG),
	.valid_out(local_bb1_vectorpop5_vectorpop5_insert2_fu_valid_out),
	.stall_in(local_bb1_vectorpop5_vectorpop5_insert2_stall_local),
	.data_out(local_bb1_vectorpop5_vectorpop5_insert2),
	.feedback_in(feedback_data_in_5),
	.feedback_valid_in(feedback_valid_in_5),
	.feedback_stall_out(feedback_stall_out_5)
);

defparam local_bb1_vectorpop5_vectorpop5_insert2_feedback.COALESCE_DISTANCE = 1;
defparam local_bb1_vectorpop5_vectorpop5_insert2_feedback.DATA_WIDTH = 96;
defparam local_bb1_vectorpop5_vectorpop5_insert2_feedback.STYLE = "REGULAR";

assign local_bb1_vectorpop5_vectorpop5_insert2_stall_local = ~(local_bb1_c1_exit_c1_exi1_enable);

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpop5_extract0_stall_local;
wire [31:0] local_bb1_vectorpop5_extract0;

assign local_bb1_vectorpop5_extract0[31:0] = local_bb1_vectorpop5_vectorpop5_insert2[31:0];

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpop5_extract1_stall_local;
wire [31:0] local_bb1_vectorpop5_extract1;

assign local_bb1_vectorpop5_extract1[31:0] = local_bb1_vectorpop5_vectorpop5_insert2[63:32];

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpop5_extract2_stall_local;
wire [31:0] local_bb1_vectorpop5_extract2;

assign local_bb1_vectorpop5_extract2[31:0] = local_bb1_vectorpop5_vectorpop5_insert2[95:64];

// This section implements an unregistered operation.
// 
wire local_bb1_shl_i_stall_local;
wire [31:0] local_bb1_shl_i;

assign local_bb1_shl_i = (local_bb1_vectorpop5_extract0 << 32'hD);

// This section implements an unregistered operation.
// 
wire local_bb1_and_i_stall_local;
wire [31:0] local_bb1_and_i;

assign local_bb1_and_i = (local_bb1_vectorpop5_extract0 << 32'hC);

// This section implements an unregistered operation.
// 
wire local_bb1_shl5_i_stall_local;
wire [31:0] local_bb1_shl5_i;

assign local_bb1_shl5_i = (local_bb1_vectorpop5_extract1 << 32'h2);

// This section implements an unregistered operation.
// 
wire local_bb1_and9_i_stall_local;
wire [31:0] local_bb1_and9_i;

assign local_bb1_and9_i = (local_bb1_vectorpop5_extract1 << 32'h4);

// This section implements an unregistered operation.
// 
wire local_bb1_shl14_i_stall_local;
wire [31:0] local_bb1_shl14_i;

assign local_bb1_shl14_i = (local_bb1_vectorpop5_extract2 << 32'h3);

// This section implements an unregistered operation.
// 
wire local_bb1_and18_i_stall_local;
wire [31:0] local_bb1_and18_i;

assign local_bb1_and18_i = (local_bb1_vectorpop5_extract2 << 32'h11);

// This section implements an unregistered operation.
// 
wire local_bb1_xor_i_stall_local;
wire [31:0] local_bb1_xor_i;

assign local_bb1_xor_i = ((local_bb1_shl_i & 32'hFFFFE000) ^ local_bb1_vectorpop5_extract0);

// This section implements an unregistered operation.
// 
wire local_bb1_shl1_i_stall_local;
wire [31:0] local_bb1_shl1_i;

assign local_bb1_shl1_i = ((local_bb1_and_i & 32'hFFFFF000) & 32'hFFFFE000);

// This section implements an unregistered operation.
// 
wire local_bb1_xor6_i_stall_local;
wire [31:0] local_bb1_xor6_i;

assign local_bb1_xor6_i = ((local_bb1_shl5_i & 32'hFFFFFFFC) ^ local_bb1_vectorpop5_extract1);

// This section implements an unregistered operation.
// 
wire local_bb1_shl10_i_stall_local;
wire [31:0] local_bb1_shl10_i;

assign local_bb1_shl10_i = ((local_bb1_and9_i & 32'hFFFFFFF0) & 32'hFFFFFF80);

// This section implements an unregistered operation.
// 
wire local_bb1_xor15_i_stall_local;
wire [31:0] local_bb1_xor15_i;

assign local_bb1_xor15_i = ((local_bb1_shl14_i & 32'hFFFFFFF8) ^ local_bb1_vectorpop5_extract2);

// This section implements an unregistered operation.
// 
wire local_bb1_shl19_i_stall_local;
wire [31:0] local_bb1_shl19_i;

assign local_bb1_shl19_i = ((local_bb1_and18_i & 32'hFFFE0000) & 32'hFFE00000);

// This section implements an unregistered operation.
// 
wire local_bb1_shr_i_stall_local;
wire [31:0] local_bb1_shr_i;

assign local_bb1_shr_i = (local_bb1_xor_i >> 32'h13);

// This section implements an unregistered operation.
// 
wire local_bb1_shr7_i_stall_local;
wire [31:0] local_bb1_shr7_i;

assign local_bb1_shr7_i = (local_bb1_xor6_i >> 32'h19);

// This section implements an unregistered operation.
// 
wire local_bb1_shr16_i_stall_local;
wire [31:0] local_bb1_shr16_i;

assign local_bb1_shr16_i = (local_bb1_xor15_i >> 32'hB);

// This section implements an unregistered operation.
// 
wire local_bb1_xor3_i1_stall_local;
wire [31:0] local_bb1_xor3_i1;

assign local_bb1_xor3_i1 = ((local_bb1_shr_i & 32'h1FFF) | (local_bb1_shl1_i & 32'hFFFFE000));

// This section implements an unregistered operation.
// 
wire local_bb1_xor12_i2_stall_local;
wire [31:0] local_bb1_xor12_i2;

assign local_bb1_xor12_i2 = ((local_bb1_shr7_i & 32'h7F) | (local_bb1_shl10_i & 32'hFFFFFF80));

// This section implements an unregistered operation.
// 
wire local_bb1_xor21_i3_stall_local;
wire [31:0] local_bb1_xor21_i3;

assign local_bb1_xor21_i3 = ((local_bb1_shr16_i & 32'h1FFFFF) | (local_bb1_shl19_i & 32'hFFE00000));

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpush5_insert0_stall_local;
wire [95:0] local_bb1_vectorpush5_insert0;

assign local_bb1_vectorpush5_insert0[31:0] = local_bb1_xor3_i1;
assign local_bb1_vectorpush5_insert0[95:32] = 64'bx;

// This section implements an unregistered operation.
// 
wire local_bb1_xor23_i_stall_local;
wire [31:0] local_bb1_xor23_i;

assign local_bb1_xor23_i = (local_bb1_xor12_i2 ^ local_bb1_xor3_i1);

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpush5_insert1_stall_local;
wire [95:0] local_bb1_vectorpush5_insert1;

assign local_bb1_vectorpush5_insert1[31:0] = local_bb1_vectorpush5_insert0[31:0];
assign local_bb1_vectorpush5_insert1[63:32] = local_bb1_xor12_i2;
assign local_bb1_vectorpush5_insert1[95:64] = local_bb1_vectorpush5_insert0[95:64];

// This section implements an unregistered operation.
// 
wire local_bb1_xor24_i_stall_local;
wire [31:0] local_bb1_xor24_i;

assign local_bb1_xor24_i = (local_bb1_xor23_i ^ local_bb1_xor21_i3);

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpush5_insert2_stall_local;
wire [95:0] local_bb1_vectorpush5_insert2;

assign local_bb1_vectorpush5_insert2[63:0] = local_bb1_vectorpush5_insert1[63:0];
assign local_bb1_vectorpush5_insert2[95:64] = local_bb1_xor21_i3;

// This section implements an unregistered operation.
// 
wire local_bb1_vectorpush5_insert2_valid_out;
wire local_bb1_vectorpush5_insert2_stall_in;
wire local_bb1_c1_exi1_valid_out;
wire local_bb1_c1_exi1_stall_in;
wire local_bb1_c1_exi1_inputs_ready;
wire local_bb1_c1_exi1_stall_local;
wire [63:0] local_bb1_c1_exi1;

assign local_bb1_c1_exi1_inputs_ready = (rnode_2to3_bb1_c1_ene1_0_valid_out_0_NO_SHIFT_REG & SFC_2_VALID_2_3_0_valid_out_1_NO_SHIFT_REG & rnode_2to3_bb1_c1_ene1_0_valid_out_1_NO_SHIFT_REG);
assign local_bb1_c1_exi1[31:0] = 32'bx;
assign local_bb1_c1_exi1[63:32] = local_bb1_xor24_i;
assign local_bb1_vectorpush5_insert2_valid_out = 1'b1;
assign local_bb1_c1_exi1_valid_out = 1'b1;
assign rnode_2to3_bb1_c1_ene1_0_stall_in_0_NO_SHIFT_REG = 1'b0;
assign SFC_2_VALID_2_3_0_stall_in_1 = 1'b0;
assign rnode_2to3_bb1_c1_ene1_0_stall_in_1_NO_SHIFT_REG = 1'b0;

// This section implements a registered operation.
// 
wire local_bb1_vectorpush5_vectorpush5_insert2_inputs_ready;
wire local_bb1_vectorpush5_vectorpush5_insert2_output_regs_ready;
wire [95:0] local_bb1_vectorpush5_vectorpush5_insert2_result;
wire local_bb1_vectorpush5_vectorpush5_insert2_fu_valid_out;
wire local_bb1_vectorpush5_vectorpush5_insert2_fu_stall_out;
 reg [95:0] local_bb1_vectorpush5_vectorpush5_insert2_NO_SHIFT_REG;
wire local_bb1_vectorpush5_vectorpush5_insert2_causedstall;

acl_push local_bb1_vectorpush5_vectorpush5_insert2_feedback (
	.clock(clock),
	.resetn(resetn),
	.dir(1'b1),
	.predicate(1'b0),
	.data_in(local_bb1_vectorpush5_insert2),
	.stall_out(local_bb1_vectorpush5_vectorpush5_insert2_fu_stall_out),
	.valid_in(SFC_2_VALID_2_3_0_NO_SHIFT_REG),
	.valid_out(local_bb1_vectorpush5_vectorpush5_insert2_fu_valid_out),
	.stall_in(~(local_bb1_c1_exit_c1_exi1_enable)),
	.data_out(local_bb1_vectorpush5_vectorpush5_insert2_result),
	.feedback_out(feedback_data_out_5),
	.feedback_valid_out(feedback_valid_out_5),
	.feedback_stall_in(feedback_stall_in_5)
);

defparam local_bb1_vectorpush5_vectorpush5_insert2_feedback.STALLFREE = 1;
defparam local_bb1_vectorpush5_vectorpush5_insert2_feedback.ENABLED = 1;
defparam local_bb1_vectorpush5_vectorpush5_insert2_feedback.DATA_WIDTH = 96;
defparam local_bb1_vectorpush5_vectorpush5_insert2_feedback.FIFO_DEPTH = 1;
defparam local_bb1_vectorpush5_vectorpush5_insert2_feedback.MIN_FIFO_LATENCY = 1;
defparam local_bb1_vectorpush5_vectorpush5_insert2_feedback.STYLE = "REGULAR";
defparam local_bb1_vectorpush5_vectorpush5_insert2_feedback.RAM_FIFO_DEPTH_INC = 1;

assign local_bb1_vectorpush5_vectorpush5_insert2_inputs_ready = 1'b1;
assign local_bb1_vectorpush5_vectorpush5_insert2_output_regs_ready = local_bb1_c1_exit_c1_exi1_enable;
assign local_bb1_vectorpush5_insert2_stall_in = 1'b0;
assign SFC_2_VALID_2_3_0_stall_in_2 = 1'b0;
assign local_bb1_vectorpush5_vectorpush5_insert2_causedstall = (SFC_2_VALID_2_3_0_NO_SHIFT_REG && (1'b0 && !(~(local_bb1_c1_exit_c1_exi1_enable))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb1_vectorpush5_vectorpush5_insert2_NO_SHIFT_REG <= 'x;
	end
	else
	begin
		if (local_bb1_vectorpush5_vectorpush5_insert2_output_regs_ready)
		begin
			local_bb1_vectorpush5_vectorpush5_insert2_NO_SHIFT_REG <= local_bb1_vectorpush5_vectorpush5_insert2_result;
		end
	end
end


// This section implements an unregistered operation.
// 
wire local_bb1_c1_exit_c1_exi1_valid_out;
wire local_bb1_c1_exit_c1_exi1_stall_in;
wire local_bb1_c1_exit_c1_exi1_inputs_ready;
wire local_bb1_c1_exit_c1_exi1_stall_local;
wire [63:0] local_bb1_c1_exit_c1_exi1;
wire local_bb1_c1_exit_c1_exi1_valid;
wire local_bb1_c1_exit_c1_exi1_fu_stall_out;

acl_enable_sink local_bb1_c1_exit_c1_exi1_instance (
	.clock(clock),
	.resetn(resetn),
	.data_in(local_bb1_c1_exi1),
	.data_out(local_bb1_c1_exit_c1_exi1),
	.input_accepted(local_bb1_c1_enter_c1_eni1_input_accepted),
	.valid_out(local_bb1_c1_exit_c1_exi1_valid),
	.stall_in(local_bb1_c1_exit_c1_exi1_stall_local),
	.enable(local_bb1_c1_exit_c1_exi1_enable),
	.valid_in(local_bb1_c1_exit_c1_exi1_valid_in),
	.stall_entry(local_bb1_c1_exit_c1_exi1_entry_stall),
	.inc_pipelined_thread(local_bb1_c1_enter_c1_eni1_inc_pipelined_thread),
	.dec_pipelined_thread(local_bb1_c1_enter_c1_eni1_dec_pipelined_thread)
);

defparam local_bb1_c1_exit_c1_exi1_instance.DATA_WIDTH = 64;
defparam local_bb1_c1_exit_c1_exi1_instance.PIPELINE_DEPTH = 1;
defparam local_bb1_c1_exit_c1_exi1_instance.SCHEDULEII = 1;
defparam local_bb1_c1_exit_c1_exi1_instance.IP_PIPELINE_LATENCY_PLUS1 = 1;

assign local_bb1_c1_exit_c1_exi1_inputs_ready = (local_bb1_c1_exi1_valid_out & SFC_2_VALID_2_3_0_valid_out_0_NO_SHIFT_REG);
assign local_bb1_c1_exit_c1_exi1_valid_in = SFC_2_VALID_2_3_0_NO_SHIFT_REG;
assign local_bb1_c1_exit_c1_exi1_fu_stall_out = ~(local_bb1_c1_exit_c1_exi1_enable);
assign local_bb1_c1_exit_c1_exi1_valid_out = local_bb1_c1_exit_c1_exi1_valid;
assign local_bb1_c1_exit_c1_exi1_stall_local = local_bb1_c1_exit_c1_exi1_stall_in;
assign local_bb1_c1_exi1_stall_in = 1'b0;
assign SFC_2_VALID_2_3_0_stall_in_0 = 1'b0;

// This section implements an unregistered operation.
// 
wire local_bb1_c1_exe1_valid_out;
wire local_bb1_c1_exe1_stall_in;
wire local_bb1_c1_exe1_inputs_ready;
wire local_bb1_c1_exe1_stall_local;
wire [31:0] local_bb1_c1_exe1;

assign local_bb1_c1_exe1_inputs_ready = local_bb1_c1_exit_c1_exi1_valid_out;
assign local_bb1_c1_exe1[31:0] = local_bb1_c1_exit_c1_exi1[63:32];
assign local_bb1_c1_exe1_valid_out = local_bb1_c1_exe1_inputs_ready;
assign local_bb1_c1_exe1_stall_local = local_bb1_c1_exe1_stall_in;
assign local_bb1_c1_exit_c1_exi1_stall_in = (|local_bb1_c1_exe1_stall_local);

// This section implements a registered operation.
// 
wire local_bb1__rand_num_inputs_ready;
 reg local_bb1__rand_num_valid_out_NO_SHIFT_REG;
wire local_bb1__rand_num_stall_in;
wire local_bb1__rand_num_output_regs_ready;
wire local_bb1__rand_num_fu_stall_out;
wire local_bb1__rand_num_fu_valid_out;
 reg local_bb1__rand_num_NO_SHIFT_REG;
wire local_bb1__rand_num_causedstall;

st_write st_local_bb1__rand_num (
	.clock(clock),
	.resetn(resetn),
	.o_stall(local_bb1__rand_num_fu_stall_out),
	.i_valid(local_bb1__rand_num_inputs_ready),
	.i_predicate(1'b0),
	.i_data(local_bb1_c1_exe1),
	.i_stall(~(local_bb1__rand_num_output_regs_ready)),
	.o_ack(),
	.o_valid(local_bb1__rand_num_fu_valid_out),
	.o_fifovalid(avst_local_bb1__rand_num_valid),
	.o_fifodata(avst_local_bb1__rand_num_data),
	.i_fifoready(avst_local_bb1__rand_num_ready),
	.i_fifosize(),
	.profile_i_valid(),
	.profile_i_stall(),
	.profile_o_stall(),
	.profile_total_req(),
	.profile_fifo_stall(),
	.profile_total_fifo_size(),
	.profile_total_fifo_size_incr()
);

defparam st_local_bb1__rand_num.DATA_WIDTH = 32;
defparam st_local_bb1__rand_num.FIFOSIZE_WIDTH = 32;

assign local_bb1__rand_num_inputs_ready = (local_bb1_c1_exe1_valid_out & local_bb1__do_valid_out_0_NO_SHIFT_REG);
assign local_bb1__rand_num_output_regs_ready = (&(~(local_bb1__rand_num_valid_out_NO_SHIFT_REG) | ~(local_bb1__rand_num_stall_in)));
assign local_bb1_c1_exe1_stall_in = (local_bb1__rand_num_fu_stall_out | ~(local_bb1__rand_num_inputs_ready));
assign local_bb1__do_stall_in_0 = (local_bb1__rand_num_fu_stall_out | ~(local_bb1__rand_num_inputs_ready));
assign local_bb1__rand_num_causedstall = (local_bb1__rand_num_inputs_ready && (local_bb1__rand_num_fu_stall_out && !(~(local_bb1__rand_num_output_regs_ready))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb1__rand_num_valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb1__rand_num_output_regs_ready)
		begin
			local_bb1__rand_num_valid_out_NO_SHIFT_REG <= local_bb1__rand_num_fu_valid_out;
		end
		else
		begin
			if (~(local_bb1__rand_num_stall_in))
			begin
				local_bb1__rand_num_valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// This section implements an unregistered operation.
// 
wire local_bb1__or_valid_out;
wire local_bb1__or_stall_in;
wire local_bb1__or_inputs_ready;
wire local_bb1__or_stall_local;
wire local_bb1__or;

assign local_bb1__or_inputs_ready = (local_bb1__rand_num_valid_out_NO_SHIFT_REG & rnode_3to4_bb1__do_0_valid_out_NO_SHIFT_REG);
assign local_bb1__or = (rnode_3to4_bb1__do_0_NO_SHIFT_REG | local_bb1__rand_num_NO_SHIFT_REG);
assign local_bb1__or_valid_out = local_bb1__or_inputs_ready;
assign local_bb1__or_stall_local = local_bb1__or_stall_in;
assign local_bb1__rand_num_stall_in = (local_bb1__or_stall_local | ~(local_bb1__or_inputs_ready));
assign rnode_3to4_bb1__do_0_stall_in_NO_SHIFT_REG = (local_bb1__or_stall_local | ~(local_bb1__or_inputs_ready));

// This section implements a registered operation.
// 
wire local_bb1__return_inputs_ready;
 reg local_bb1__return_valid_out_NO_SHIFT_REG;
wire local_bb1__return_stall_in;
wire local_bb1__return_output_regs_ready;
wire local_bb1__return_fu_stall_out;
wire local_bb1__return_fu_valid_out;
 reg local_bb1__return_NO_SHIFT_REG;
wire local_bb1__return_causedstall;

st_write st_local_bb1__return (
	.clock(clock),
	.resetn(resetn),
	.o_stall(local_bb1__return_fu_stall_out),
	.i_valid(local_bb1__return_inputs_ready),
	.i_predicate(1'b0),
	.i_data('x),
	.i_stall(~(local_bb1__return_output_regs_ready)),
	.o_ack(),
	.o_valid(local_bb1__return_fu_valid_out),
	.o_fifovalid(avst_local_bb1__return_valid),
	.o_fifodata(avst_local_bb1__return_data),
	.i_fifoready(avst_local_bb1__return_ready),
	.i_fifosize(),
	.profile_i_valid(),
	.profile_i_stall(),
	.profile_o_stall(),
	.profile_total_req(),
	.profile_fifo_stall(),
	.profile_total_fifo_size(),
	.profile_total_fifo_size_incr()
);

defparam st_local_bb1__return.DATA_WIDTH = 8;
defparam st_local_bb1__return.FIFOSIZE_WIDTH = 32;

assign local_bb1__return_inputs_ready = local_bb1__or_valid_out;
assign local_bb1__return_output_regs_ready = (&(~(local_bb1__return_valid_out_NO_SHIFT_REG) | ~(local_bb1__return_stall_in)));
assign local_bb1__or_stall_in = (local_bb1__return_fu_stall_out | ~(local_bb1__return_inputs_ready));
assign local_bb1__return_causedstall = (local_bb1__return_inputs_ready && (local_bb1__return_fu_stall_out && !(~(local_bb1__return_output_regs_ready))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb1__return_valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb1__return_output_regs_ready)
		begin
			local_bb1__return_valid_out_NO_SHIFT_REG <= local_bb1__return_fu_valid_out;
		end
		else
		begin
			if (~(local_bb1__return_stall_in))
			begin
				local_bb1__return_valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// This section describes the behaviour of the BRANCH node.
wire branch_var__inputs_ready;
 reg branch_node_valid_out_NO_SHIFT_REG;
wire branch_var__output_regs_ready;
wire combined_branch_stall_in_signal;

assign branch_var__inputs_ready = local_bb1__return_valid_out_NO_SHIFT_REG;
assign branch_var__output_regs_ready = (~(stall_in) | ~(branch_node_valid_out_NO_SHIFT_REG));
assign local_bb1__return_stall_in = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign combined_branch_stall_in_signal = stall_in;
assign valid_out = branch_node_valid_out_NO_SHIFT_REG;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		branch_node_valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (branch_var__output_regs_ready)
		begin
			branch_node_valid_out_NO_SHIFT_REG <= branch_var__inputs_ready;
		end
		else
		begin
			if (~(combined_branch_stall_in_signal))
			begin
				branch_node_valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


endmodule

