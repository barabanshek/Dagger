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
// Copyright 2012 Altera Corporation. All rights reserved.  
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

// baeckler - 01-25-2012
// force the decomposition of 5 bit FIFO pointer compare with enable

module eq_5_ena #(
 	parameter TARGET_CHIP = 1   // 0 generic, 1 S4, 2 S5
)(
	input [4:0] da,
	input [4:0] db,
	input ena,
	output eq
);

wire w0_o;
wys_lut w0 (
	.a(da[0]),
	.b(da[1]),
	.c(da[2]),
	.d(db[0]),
	.e(db[1]),
	.f(db[2]),
	.out (w0_o)
);
defparam w0 .TARGET_CHIP = TARGET_CHIP;
defparam w0 .MASK = 64'h8040201008040201; // {a,b,c} == {d,e,f}
	
wys_lut w1 (
	.a(ena),
	.b(da[3]),
	.c(da[4]),
	.d(db[3]),
	.e(db[4]),
	.f(w0_o),
	.out (eq)
);
defparam w1 .TARGET_CHIP = TARGET_CHIP;
defparam w1 .MASK = 64'h8020080200000000; // ({b,c} == {d,e}) && a && f
	

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  2.0 LUTs
// BENCHMARK INFO :  Total registers : 0
// BENCHMARK INFO :  Total pins : 12
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 3               ;       ;
// BENCHMARK INFO :  ALMs : 3 / 234,720 ( < 1 % )
