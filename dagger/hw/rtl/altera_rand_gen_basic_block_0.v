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
module altera_rand_gen_basic_block_0
	(
		input 		clock,
		input 		resetn,
		input 		valid_in,
		output 		stall_out,
		output 		valid_out,
		input 		stall_in,
		input [31:0] 		workgroup_size,
		input 		start,
		input 		feedback_valid_in_0,
		output 		feedback_stall_out_0,
		input 		feedback_data_in_0,
		output 		feedback_valid_out_0,
		input 		feedback_stall_in_0,
		output 		feedback_data_out_0
	);


// Values used for debugging.  These are swept away by synthesis.
wire _entry;
wire _exit;
 reg [31:0] _num_entry_NO_SHIFT_REG;
 reg [31:0] _num_exit_NO_SHIFT_REG;
wire [31:0] _num_live;

assign _entry = ((&valid_in) & ~((|stall_out)));
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
wire merge_stalled_by_successors;
 reg merge_block_selector_NO_SHIFT_REG;
 reg merge_node_valid_in_staging_reg_NO_SHIFT_REG;
 reg is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
 reg invariant_valid_NO_SHIFT_REG;

assign merge_stalled_by_successors = ((merge_node_stall_in_0 & merge_node_valid_out_0_NO_SHIFT_REG) | (merge_node_stall_in_1 & merge_node_valid_out_1_NO_SHIFT_REG));
assign stall_out = merge_node_valid_in_staging_reg_NO_SHIFT_REG;

always @(*)
begin
	if ((merge_node_valid_in_staging_reg_NO_SHIFT_REG | valid_in))
	begin
		merge_block_selector_NO_SHIFT_REG = 1'b0;
		is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b1;
	end
	else
	begin
		merge_block_selector_NO_SHIFT_REG = 1'b0;
		is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b0;
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		merge_node_valid_in_staging_reg_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (((merge_block_selector_NO_SHIFT_REG != 1'b0) | merge_stalled_by_successors))
		begin
			if (~(merge_node_valid_in_staging_reg_NO_SHIFT_REG))
			begin
				merge_node_valid_in_staging_reg_NO_SHIFT_REG <= valid_in;
			end
		end
		else
		begin
			merge_node_valid_in_staging_reg_NO_SHIFT_REG <= 1'b0;
		end
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (~(merge_stalled_by_successors))
		begin
			merge_node_valid_out_0_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_1_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
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


// This section implements a registered operation.
// 
wire local_bb0_wt_limiter_pop__inputs_ready;
 reg local_bb0_wt_limiter_pop__valid_out_NO_SHIFT_REG;
wire local_bb0_wt_limiter_pop__stall_in;
wire local_bb0_wt_limiter_pop__output_regs_ready;
wire local_bb0_wt_limiter_pop__result;
wire local_bb0_wt_limiter_pop__fu_valid_out;
wire local_bb0_wt_limiter_pop__fu_stall_out;
 reg local_bb0_wt_limiter_pop__NO_SHIFT_REG;
wire local_bb0_wt_limiter_pop__causedstall;

acl_pop local_bb0_wt_limiter_pop__feedback (
	.clock(clock),
	.resetn(resetn),
	.dir(1'b0),
	.predicate(1'b0),
	.data_in('x),
	.stall_out(local_bb0_wt_limiter_pop__fu_stall_out),
	.valid_in(local_bb0_wt_limiter_pop__inputs_ready),
	.valid_out(local_bb0_wt_limiter_pop__fu_valid_out),
	.stall_in(~(local_bb0_wt_limiter_pop__output_regs_ready)),
	.data_out(local_bb0_wt_limiter_pop__result),
	.feedback_in(feedback_data_in_0),
	.feedback_valid_in(feedback_valid_in_0),
	.feedback_stall_out(feedback_stall_out_0)
);

defparam local_bb0_wt_limiter_pop__feedback.COALESCE_DISTANCE = 1;
defparam local_bb0_wt_limiter_pop__feedback.DATA_WIDTH = 1;
defparam local_bb0_wt_limiter_pop__feedback.STYLE = "REGULAR";

assign local_bb0_wt_limiter_pop__inputs_ready = merge_node_valid_out_0_NO_SHIFT_REG;
assign local_bb0_wt_limiter_pop__output_regs_ready = (&(~(local_bb0_wt_limiter_pop__valid_out_NO_SHIFT_REG) | ~(local_bb0_wt_limiter_pop__stall_in)));
assign merge_node_stall_in_0 = (local_bb0_wt_limiter_pop__fu_stall_out | ~(local_bb0_wt_limiter_pop__inputs_ready));
assign local_bb0_wt_limiter_pop__causedstall = (local_bb0_wt_limiter_pop__inputs_ready && (local_bb0_wt_limiter_pop__fu_stall_out && !(~(local_bb0_wt_limiter_pop__output_regs_ready))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb0_wt_limiter_pop__NO_SHIFT_REG <= 'x;
		local_bb0_wt_limiter_pop__valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb0_wt_limiter_pop__output_regs_ready)
		begin
			local_bb0_wt_limiter_pop__NO_SHIFT_REG <= local_bb0_wt_limiter_pop__result;
			local_bb0_wt_limiter_pop__valid_out_NO_SHIFT_REG <= local_bb0_wt_limiter_pop__fu_valid_out;
		end
		else
		begin
			if (~(local_bb0_wt_limiter_pop__stall_in))
			begin
				local_bb0_wt_limiter_pop__valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// This section implements a registered operation.
// 
wire local_bb0_wt_limiter_push__inputs_ready;
wire local_bb0_wt_limiter_push__output_regs_ready;
wire local_bb0_wt_limiter_push__result;
wire local_bb0_wt_limiter_push__fu_valid_out;
wire local_bb0_wt_limiter_push__fu_stall_out;
 reg local_bb0_wt_limiter_push__NO_SHIFT_REG;
wire local_bb0_wt_limiter_push__causedstall;

acl_push local_bb0_wt_limiter_push__feedback (
	.clock(clock),
	.resetn(resetn),
	.dir(1'b0),
	.predicate(1'b0),
	.data_in('x),
	.stall_out(local_bb0_wt_limiter_push__fu_stall_out),
	.valid_in(local_bb0_wt_limiter_push__inputs_ready),
	.valid_out(local_bb0_wt_limiter_push__fu_valid_out),
	.stall_in(~(local_bb0_wt_limiter_push__output_regs_ready)),
	.data_out(local_bb0_wt_limiter_push__result),
	.feedback_out(feedback_data_out_0),
	.feedback_valid_out(feedback_valid_out_0),
	.feedback_stall_in(feedback_stall_in_0)
);

defparam local_bb0_wt_limiter_push__feedback.STALLFREE = 0;
defparam local_bb0_wt_limiter_push__feedback.ENABLED = 0;
defparam local_bb0_wt_limiter_push__feedback.DATA_WIDTH = 1;
defparam local_bb0_wt_limiter_push__feedback.FIFO_DEPTH = 1;
defparam local_bb0_wt_limiter_push__feedback.MIN_FIFO_LATENCY = 1;
defparam local_bb0_wt_limiter_push__feedback.STYLE = "TOKEN";
defparam local_bb0_wt_limiter_push__feedback.RAM_FIFO_DEPTH_INC = 1;

assign local_bb0_wt_limiter_push__inputs_ready = merge_node_valid_out_1_NO_SHIFT_REG;
assign local_bb0_wt_limiter_push__output_regs_ready = 1'b1;
assign merge_node_stall_in_1 = (local_bb0_wt_limiter_push__fu_stall_out | ~(local_bb0_wt_limiter_push__inputs_ready));
assign local_bb0_wt_limiter_push__causedstall = (local_bb0_wt_limiter_push__inputs_ready && (local_bb0_wt_limiter_push__fu_stall_out && !(~(local_bb0_wt_limiter_push__output_regs_ready))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb0_wt_limiter_push__NO_SHIFT_REG <= 'x;
	end
	else
	begin
		if (local_bb0_wt_limiter_push__output_regs_ready)
		begin
			local_bb0_wt_limiter_push__NO_SHIFT_REG <= local_bb0_wt_limiter_push__result;
		end
	end
end


// This section describes the behaviour of the BRANCH node.
wire branch_var__inputs_ready;
 reg branch_node_valid_out_NO_SHIFT_REG;
wire branch_var__output_regs_ready;
wire combined_branch_stall_in_signal;

assign branch_var__inputs_ready = local_bb0_wt_limiter_pop__valid_out_NO_SHIFT_REG;
assign branch_var__output_regs_ready = (~(stall_in) | ~(branch_node_valid_out_NO_SHIFT_REG));
assign local_bb0_wt_limiter_pop__stall_in = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
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

