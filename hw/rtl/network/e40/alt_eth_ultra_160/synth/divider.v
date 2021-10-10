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

`timescale 1 ps / 1 ps

// baeckler - 04-13-2006
// unsigned iterative divider, 1 and 2 bit per clock
// tick versions

////////////////////////////////////////////////////
// 1 bit per tick version
////////////////////////////////////////////////////

module divider (clk,rst,load,n,d,q,r,ready) /* synthesis ALTERA_ATTRIBUTE = "-name MUX_RESTRUCTURE OFF" */;

function integer log2;
  input integer val;
  begin
	 log2 = 0;
	 while (val > 0) begin
	    val = val >> 1;
		log2 = log2 + 1;
	 end
  end
endfunction


parameter WIDTH_N = 32;
parameter WIDTH_D = 32;
localparam LOG2_WIDTH_N = log2(WIDTH_N);
localparam MIN_ND = (WIDTH_N <WIDTH_D ? WIDTH_N : WIDTH_D);

input clk,rst;

input load;					// load the numer and denominator
input [WIDTH_N-1:0] n;		// numerator
input [WIDTH_D-1:0] d;		// denominator
output [WIDTH_N-1:0] q;		// quotient
output [WIDTH_D-1:0] r;		// remainder
output ready;				// Q and R are valid now.

reg [WIDTH_N + MIN_ND : 0] working;
reg [WIDTH_D-1 : 0] denom;

wire [WIDTH_N-1:0] lower_working = working [WIDTH_N-1:0];
wire [MIN_ND:0] upper_working = working [WIDTH_N + MIN_ND : WIDTH_N];

wire [WIDTH_D:0] sub_result = upper_working - denom;
wire sub_result_neg = sub_result[WIDTH_D];

reg [LOG2_WIDTH_N:0] cntr = {(LOG2_WIDTH_N+1){1'b0}};
reg cntr_zero = 1'b0;
assign ready = cntr_zero;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		working <= 0;
		denom <= 0;
		cntr <= 0;
		cntr_zero <= 1'b1;
	end
	else begin
		if (load) begin
			working <= {{WIDTH_D{1'b0}},n,1'b0};
			cntr <= WIDTH_N[LOG2_WIDTH_N:0];
			cntr_zero <= 1'b0;
			denom <= d;
		end
		else begin
			if (!cntr_zero) begin
				cntr <= cntr - 1'b1;
				working <= sub_result_neg ? {working[WIDTH_N+MIN_ND-1:0],1'b0} :
						{sub_result[WIDTH_D-1:0],lower_working,1'b1};
				cntr_zero <= (cntr == {{LOG2_WIDTH_N{1'b0}},1'b1});
			end
			else begin
				cntr_zero <= 1'b1;
			end
		end
	end
end

assign q = lower_working;
assign r = upper_working[WIDTH_D:1];

endmodule


// PREVMARK INFO :  5SGXEA7N2F45C2ES
// PREVMARK INFO :  Total registers : 104
// PREVMARK INFO :  Total pins : 132
// PREVMARK INFO :  Total virtual pins : 0
// PREVMARK INFO :  Total block memory bits : 0
// PREVMARK INFO :  Worst setup path @ 468.75MHz : 0.068 ns, From working[46], To working[61]}
// PREVMARK INFO :  Worst setup path @ 468.75MHz : -0.103 ns, From working[52], To working[52]}
// PREVMARK INFO :  Worst setup path @ 468.75MHz : 0.250 ns, From working[47], To working[47]}

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  5.2 LUTs
// BENCHMARK INFO :  Total registers : 105
// BENCHMARK INFO :  Total pins : 132
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 110             ;       ;
// BENCHMARK INFO :  ALMs : 57 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.132 ns, From working[52], To working[34]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.349 ns, From working[52], To working[41]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.288 ns, From working[52], To working[34]}
