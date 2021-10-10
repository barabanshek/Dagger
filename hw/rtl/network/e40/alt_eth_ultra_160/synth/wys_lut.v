// (C) 2001-2016 Altera Corporation. All rights reserved.
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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps
// Copyright 2013 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

module wys_lut #(
	parameter MASK = 64'h6996966996696996, // xor6
	parameter TARGET_CHIP = 2 // 0 generic, 1=S4, 2=S5, 3=A5, 4=C5, 5=A10
)
(
	input a,b,c,d,e,f,
	output out
);

// Handy masks - 
// 64'h8040201008040201 {a,b,c} == {d,e,f}
// 64'h6996966996696996 xor 6
// 64'h8020080200000000 ({b,c} == {d,e}) && a && f

generate
	if (TARGET_CHIP == 0) begin : c0
		// family neutral / simulation version
		wire [5:0] addr = {f,e,d,c,b,a};
		wire [63:0] tmp = MASK >> addr;
		assign out = tmp[0];
	end
	else if (TARGET_CHIP == 1) begin : c1
		stratixiv_lcell_comb s4c (
		  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
		  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
		  .combout(out));
		defparam s4c .lut_mask = MASK;
		defparam s4c .shared_arith = "off";
		defparam s4c .extended_lut = "off";

	end
	else if (TARGET_CHIP == 2) begin : c2
		stratixv_lcell_comb s5c (
		  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
		  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
		  .combout(out));
		defparam s5c .lut_mask = MASK;
		defparam s5c .shared_arith = "off";
		defparam s5c .extended_lut = "off";
	end
	else if (TARGET_CHIP == 3) begin : c3
		arriav_lcell_comb a5c (
		  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
		  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
		  .combout(out));
		defparam a5c .lut_mask = MASK;
		defparam a5c .shared_arith = "off";
		defparam a5c .extended_lut = "off";
	end
	else if (TARGET_CHIP == 4) begin : c4
		cyclonev_lcell_comb c5c (
		  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
		  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
		  .combout(out));
		defparam c5c .lut_mask = MASK;
		defparam c5c .shared_arith = "off";
		defparam c5c .extended_lut = "off";
	end
	else if (TARGET_CHIP == 5) begin : a10
		twentynm_lcell_comb a10c (
		  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
		  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
		  .combout(out));
		defparam a10c .lut_mask = MASK;
		defparam a10c .shared_arith = "off";
		defparam a10c .extended_lut = "off";
	end
	else begin
		// synthesis translate_off
		initial begin
			$display ("ERROR: Illegal TARGET_CHIP");
			$stop();
		end
		// synthesis translate_on
		assign out = 1'b0;
	end
endgenerate
	

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 0
// BENCHMARK INFO :  Total pins : 7
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 2               ;       ;
// BENCHMARK INFO :  ALMs : 2 / 234,720 ( < 1 % )
