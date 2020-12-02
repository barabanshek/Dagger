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
    



// This module detects when a task kernel copy has finished. It asserts
// kernel_copy_finished when valid_out for the copy has been higher and
// the copy has no pending writes.


module acl_task_copy_finish_detector
(
	input clock,
	input start,
	input resetn,
	input kernel_copy_valid_out,
	input kernel_copy_has_pending_write,

	output reg kernel_copy_finished
);
	// Stores whether or not valid_out has been high in the past
	reg valid_out_has_been_high;

	always @ (posedge clock or negedge resetn) 
	begin
		if (~resetn)
		begin
			valid_out_has_been_high <= 1'b0;
		end
		else if (start)
		begin
			valid_out_has_been_high <= 1'b0;
		end
		else if (kernel_copy_valid_out)
		begin
			valid_out_has_been_high <= 1'b1;
		end
	end

	always @ (posedge clock or negedge resetn) 
	begin
		if (~resetn)
		begin
			kernel_copy_finished <= 1'b0;
		end
		else if (start)
		begin
			kernel_copy_finished <= 1'b0;
		end
		else if ((kernel_copy_valid_out | valid_out_has_been_high) & ~kernel_copy_has_pending_write)
		begin
			kernel_copy_finished <= 1'b1;
		end
	end

endmodule
