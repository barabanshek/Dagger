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
    


// The final signal chain element generates generates a one-cycle
// pulse on finish_out when the copy it serves has finished and 
// the element before it in the chain generates a pulse
// on the finish_in input.

module acl_finish_signal_chain_element
(
	input clock,
	input resetn,
	input start,

	input kernel_copy_finished,

	input finish_in,
	output reg finish_out
);

	reg prev_has_finished;
	reg finish_out_asserted;

	always @(posedge clock or negedge resetn)
	begin
		if ( ~resetn )
		begin
			prev_has_finished <= 1'b0;
		end
		else if ( start ) 
		begin
			prev_has_finished <= 1'b0;
		end
		else if ( finish_in )
		begin
			prev_has_finished <= 1'b1;
		end
	end

	always @(posedge clock or negedge resetn)
	begin
		if ( ~resetn )
		begin
			finish_out <= 1'b0;
		end
		else
		begin
			finish_out <= kernel_copy_finished & prev_has_finished & ~finish_out_asserted;
		end
	end

	always @(posedge clock or negedge resetn)
	begin
		if ( ~resetn )
		begin
			finish_out_asserted <= 1'b0;
		end
		else if ( start )
		begin
			finish_out_asserted <= 1'b0;
		end
		else if ( finish_out )
		begin
			finish_out_asserted <= 1'b1;
		end
	end
endmodule
