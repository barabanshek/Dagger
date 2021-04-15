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
// Copyright 2007 Altera Corporation. All rights reserved.  
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

// altera message_off 10230

module lfsr #(
	parameter WIDTH = 32
)
(
	input clk,
	input rst,
	input ena,
	output [WIDTH-1:0] out
);

reg [WIDTH-1:0] myreg;

// nice looking max period polys selected from
// the internet
wire [WIDTH-1:0] poly =
        (WIDTH == 4) ? 4'hc :
        (WIDTH == 5) ? 5'h1b :
        (WIDTH == 6) ? 6'h33 :
        (WIDTH == 7) ? 7'h65 :
        (WIDTH == 8) ? 8'hc3 :
        (WIDTH == 9) ? 9'h167 :
        (WIDTH == 10) ? 10'h309 :
        (WIDTH == 11) ? 11'h4ec :
        (WIDTH == 12) ? 12'hac9 :
        (WIDTH == 13) ? 13'h124d :
        (WIDTH == 14) ? 14'h2367 :
        (WIDTH == 15) ? 15'h42f9 :
        (WIDTH == 16) ? 16'h847d :
        (WIDTH == 17) ? 17'h101f5 :
        (WIDTH == 18) ? 18'h202c9 :
        (WIDTH == 19) ? 19'h402fa :
        (WIDTH == 20) ? 20'h805c1 :
        (WIDTH == 21) ? 21'h1003cb :
        (WIDTH == 22) ? 22'h20029f :
        (WIDTH == 23) ? 23'h4003da :
        (WIDTH == 24) ? 24'h800a23 :
        (WIDTH == 25) ? 25'h10001a5 :
        (WIDTH == 26) ? 26'h2000155 :
        (WIDTH == 27) ? 27'h4000227 :
        (WIDTH == 28) ? 28'h80007db :
        (WIDTH == 29) ? 29'h100004f3 :
        (WIDTH == 30) ? 30'h200003ab :
        (WIDTH == 31) ? 31'h40000169 :
        (WIDTH == 32) ? 32'h800007c3 : 32'h0;

// synthesis translate_off
initial begin
  // unsupported width?  Fatality.
  #100 if (poly == 0) begin
	 $display ("Illegal polynomial selected");
	 $stop;
	end
end
// synthesis translate_on

wire [WIDTH-1:0] feedback;
assign feedback = {WIDTH{myreg[WIDTH-1]}} & poly;

// the inverter on the LSB causes 000... to be a 
// sequence member rather than the frozen state
always @(posedge clk or posedge rst) begin
  if (rst) myreg <= 0;
  else if (ena) begin
     myreg <= ((myreg ^ feedback) << 1) | !myreg[WIDTH-1];
  end
end

assign out = myreg;

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 32
// BENCHMARK INFO :  Total pins : 34
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 9               ;       ;
// BENCHMARK INFO :  ALMs : 11 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.521 ns, From myreg[30]~DUPLICATE, To myreg[31]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.574 ns, From myreg[30], To myreg[31]~DUPLICATE}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.493 ns, From myreg[30]~DUPLICATE, To myreg[31]}
