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

// Copyright 2010 Altera Corporation. All rights reserved.  
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
module crc32_z64_x1 (
    input clk,
    input ena,
    input [31:0] pc, // previous CRC
    output reg [31:0] c // evolved through 64 bits of zero data x 1 rounds
);

initial c = 0;

wire [31:0] j;
always @(posedge clk) begin
    if (ena) c <= j;
end

assign j[0] = pc[0]  ^ pc[2]  ^ pc[5]  ^ pc[12]  ^ pc[13]  ^ pc[15] 
             ^ pc[16]  ^ pc[18]  ^ pc[21]  ^ pc[22]  ^ pc[23]  ^ pc[26] 
             ^ pc[28]  ^ pc[29]  ^ pc[31] ;
assign j[1] = pc[1]  ^ pc[2]  ^ pc[3]  ^ pc[5]  ^ pc[6]  ^ pc[12] 
             ^ pc[14]  ^ pc[15]  ^ pc[17]  ^ pc[18]  ^ pc[19]  ^ pc[21] 
             ^ pc[24]  ^ pc[26]  ^ pc[27]  ^ pc[28]  ^ pc[30]  ^ pc[31] 
            ;
assign j[2] = pc[0]  ^ pc[3]  ^ pc[4]  ^ pc[5]  ^ pc[6]  ^ pc[7] 
             ^ pc[12]  ^ pc[19]  ^ pc[20]  ^ pc[21]  ^ pc[23]  ^ pc[25] 
             ^ pc[26]  ^ pc[27] ;
assign j[3] = pc[0]  ^ pc[1]  ^ pc[4]  ^ pc[5]  ^ pc[6]  ^ pc[7] 
             ^ pc[8]  ^ pc[13]  ^ pc[20]  ^ pc[21]  ^ pc[22]  ^ pc[24] 
             ^ pc[26]  ^ pc[27]  ^ pc[28] ;
assign j[4] = pc[1]  ^ pc[6]  ^ pc[7]  ^ pc[8]  ^ pc[9]  ^ pc[12] 
             ^ pc[13]  ^ pc[14]  ^ pc[15]  ^ pc[16]  ^ pc[18]  ^ pc[25] 
             ^ pc[26]  ^ pc[27]  ^ pc[31] ;
assign j[5] = pc[5]  ^ pc[7]  ^ pc[8]  ^ pc[9]  ^ pc[10]  ^ pc[12] 
             ^ pc[14]  ^ pc[17]  ^ pc[18]  ^ pc[19]  ^ pc[21]  ^ pc[22] 
             ^ pc[23]  ^ pc[27]  ^ pc[29]  ^ pc[31] ;
assign j[6] = pc[6]  ^ pc[8]  ^ pc[9]  ^ pc[10]  ^ pc[11]  ^ pc[13] 
             ^ pc[15]  ^ pc[18]  ^ pc[19]  ^ pc[20]  ^ pc[22]  ^ pc[23] 
             ^ pc[24]  ^ pc[28]  ^ pc[30] ;
assign j[7] = pc[0]  ^ pc[2]  ^ pc[5]  ^ pc[7]  ^ pc[9]  ^ pc[10] 
             ^ pc[11]  ^ pc[13]  ^ pc[14]  ^ pc[15]  ^ pc[18]  ^ pc[19] 
             ^ pc[20]  ^ pc[22]  ^ pc[24]  ^ pc[25]  ^ pc[26]  ^ pc[28] 
            ;
assign j[8] = pc[0]  ^ pc[1]  ^ pc[2]  ^ pc[3]  ^ pc[5]  ^ pc[6] 
             ^ pc[8]  ^ pc[10]  ^ pc[11]  ^ pc[13]  ^ pc[14]  ^ pc[18] 
             ^ pc[19]  ^ pc[20]  ^ pc[22]  ^ pc[25]  ^ pc[27]  ^ pc[28] 
             ^ pc[31] ;
assign j[9] = pc[0]  ^ pc[1]  ^ pc[2]  ^ pc[3]  ^ pc[4]  ^ pc[6] 
             ^ pc[7]  ^ pc[9]  ^ pc[11]  ^ pc[12]  ^ pc[14]  ^ pc[15] 
             ^ pc[19]  ^ pc[20]  ^ pc[21]  ^ pc[23]  ^ pc[26]  ^ pc[28] 
             ^ pc[29] ;
assign j[10] = pc[0]  ^ pc[1]  ^ pc[3]  ^ pc[4]  ^ pc[7]  ^ pc[8] 
             ^ pc[10]  ^ pc[18]  ^ pc[20]  ^ pc[23]  ^ pc[24]  ^ pc[26] 
             ^ pc[27]  ^ pc[28]  ^ pc[30]  ^ pc[31] ;
assign j[11] = pc[1]  ^ pc[4]  ^ pc[8]  ^ pc[9]  ^ pc[11]  ^ pc[12] 
             ^ pc[13]  ^ pc[15]  ^ pc[16]  ^ pc[18]  ^ pc[19]  ^ pc[22] 
             ^ pc[23]  ^ pc[24]  ^ pc[25]  ^ pc[26]  ^ pc[27] ;
assign j[12] = pc[9]  ^ pc[10]  ^ pc[14]  ^ pc[15]  ^ pc[17]  ^ pc[18] 
             ^ pc[19]  ^ pc[20]  ^ pc[21]  ^ pc[22]  ^ pc[24]  ^ pc[25] 
             ^ pc[27]  ^ pc[29]  ^ pc[31] ;
assign j[13] = pc[0]  ^ pc[10]  ^ pc[11]  ^ pc[15]  ^ pc[16]  ^ pc[18] 
             ^ pc[19]  ^ pc[20]  ^ pc[21]  ^ pc[22]  ^ pc[23]  ^ pc[25] 
             ^ pc[26]  ^ pc[28]  ^ pc[30] ;
assign j[14] = pc[0]  ^ pc[1]  ^ pc[11]  ^ pc[12]  ^ pc[16]  ^ pc[17] 
             ^ pc[19]  ^ pc[20]  ^ pc[21]  ^ pc[22]  ^ pc[23]  ^ pc[24] 
             ^ pc[26]  ^ pc[27]  ^ pc[29]  ^ pc[31] ;
assign j[15] = pc[1]  ^ pc[2]  ^ pc[12]  ^ pc[13]  ^ pc[17]  ^ pc[18] 
             ^ pc[20]  ^ pc[21]  ^ pc[22]  ^ pc[23]  ^ pc[24]  ^ pc[25] 
             ^ pc[27]  ^ pc[28]  ^ pc[30] ;
assign j[16] = pc[0]  ^ pc[3]  ^ pc[5]  ^ pc[12]  ^ pc[14]  ^ pc[15] 
             ^ pc[16]  ^ pc[19]  ^ pc[24]  ^ pc[25] ;
assign j[17] = pc[1]  ^ pc[4]  ^ pc[6]  ^ pc[13]  ^ pc[15]  ^ pc[16] 
             ^ pc[17]  ^ pc[20]  ^ pc[25]  ^ pc[26] ;
assign j[18] = pc[0]  ^ pc[2]  ^ pc[5]  ^ pc[7]  ^ pc[14]  ^ pc[16] 
             ^ pc[17]  ^ pc[18]  ^ pc[21]  ^ pc[26]  ^ pc[27] ;
assign j[19] = pc[0]  ^ pc[1]  ^ pc[3]  ^ pc[6]  ^ pc[8]  ^ pc[15] 
             ^ pc[17]  ^ pc[18]  ^ pc[19]  ^ pc[22]  ^ pc[27]  ^ pc[28] 
            ;
assign j[20] = pc[1]  ^ pc[2]  ^ pc[4]  ^ pc[7]  ^ pc[9]  ^ pc[16] 
             ^ pc[18]  ^ pc[19]  ^ pc[20]  ^ pc[23]  ^ pc[28]  ^ pc[29] 
            ;
assign j[21] = pc[2]  ^ pc[3]  ^ pc[5]  ^ pc[8]  ^ pc[10]  ^ pc[17] 
             ^ pc[19]  ^ pc[20]  ^ pc[21]  ^ pc[24]  ^ pc[29]  ^ pc[30] 
            ;
assign j[22] = pc[2]  ^ pc[3]  ^ pc[4]  ^ pc[5]  ^ pc[6]  ^ pc[9] 
             ^ pc[11]  ^ pc[12]  ^ pc[13]  ^ pc[15]  ^ pc[16]  ^ pc[20] 
             ^ pc[23]  ^ pc[25]  ^ pc[26]  ^ pc[28]  ^ pc[29]  ^ pc[30] 
            ;
assign j[23] = pc[2]  ^ pc[3]  ^ pc[4]  ^ pc[6]  ^ pc[7]  ^ pc[10] 
             ^ pc[14]  ^ pc[15]  ^ pc[17]  ^ pc[18]  ^ pc[22]  ^ pc[23] 
             ^ pc[24]  ^ pc[27]  ^ pc[28]  ^ pc[30] ;
assign j[24] = pc[0]  ^ pc[3]  ^ pc[4]  ^ pc[5]  ^ pc[7]  ^ pc[8] 
             ^ pc[11]  ^ pc[15]  ^ pc[16]  ^ pc[18]  ^ pc[19]  ^ pc[23] 
             ^ pc[24]  ^ pc[25]  ^ pc[28]  ^ pc[29]  ^ pc[31] ;
assign j[25] = pc[1]  ^ pc[4]  ^ pc[5]  ^ pc[6]  ^ pc[8]  ^ pc[9] 
             ^ pc[12]  ^ pc[16]  ^ pc[17]  ^ pc[19]  ^ pc[20]  ^ pc[24] 
             ^ pc[25]  ^ pc[26]  ^ pc[29]  ^ pc[30] ;
assign j[26] = pc[6]  ^ pc[7]  ^ pc[9]  ^ pc[10]  ^ pc[12]  ^ pc[15] 
             ^ pc[16]  ^ pc[17]  ^ pc[20]  ^ pc[22]  ^ pc[23]  ^ pc[25] 
             ^ pc[27]  ^ pc[28]  ^ pc[29]  ^ pc[30] ;
assign j[27] = pc[0]  ^ pc[7]  ^ pc[8]  ^ pc[10]  ^ pc[11]  ^ pc[13] 
             ^ pc[16]  ^ pc[17]  ^ pc[18]  ^ pc[21]  ^ pc[23]  ^ pc[24] 
             ^ pc[26]  ^ pc[28]  ^ pc[29]  ^ pc[30]  ^ pc[31] ;
assign j[28] = pc[1]  ^ pc[8]  ^ pc[9]  ^ pc[11]  ^ pc[12]  ^ pc[14] 
             ^ pc[17]  ^ pc[18]  ^ pc[19]  ^ pc[22]  ^ pc[24]  ^ pc[25] 
             ^ pc[27]  ^ pc[29]  ^ pc[30]  ^ pc[31] ;
assign j[29] = pc[2]  ^ pc[9]  ^ pc[10]  ^ pc[12]  ^ pc[13]  ^ pc[15] 
             ^ pc[18]  ^ pc[19]  ^ pc[20]  ^ pc[23]  ^ pc[25]  ^ pc[26] 
             ^ pc[28]  ^ pc[30]  ^ pc[31] ;
assign j[30] = pc[0]  ^ pc[3]  ^ pc[10]  ^ pc[11]  ^ pc[13]  ^ pc[14] 
             ^ pc[16]  ^ pc[19]  ^ pc[20]  ^ pc[21]  ^ pc[24]  ^ pc[26] 
             ^ pc[27]  ^ pc[29]  ^ pc[31] ;
assign j[31] = pc[1]  ^ pc[4]  ^ pc[11]  ^ pc[12]  ^ pc[14]  ^ pc[15] 
             ^ pc[17]  ^ pc[20]  ^ pc[21]  ^ pc[22]  ^ pc[25]  ^ pc[27] 
             ^ pc[28]  ^ pc[30] ;
endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  3.0 LUTs
// BENCHMARK INFO :  Total registers : 32
// BENCHMARK INFO :  Total pins : 66
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 84              ;       ;
// BENCHMARK INFO :  ALMs : 46 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
