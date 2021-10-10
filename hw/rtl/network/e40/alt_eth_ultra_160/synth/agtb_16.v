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


// ___________________________________________________________________________
// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/mac/e100_hproc_4.v#15 $
// $Revision: #15 $
// $Date: 2013/08/30 $
// $Author: adubey $
// Credits: Gregg Baeckler
// This will take 3-LUT depths
// ___________________________________________________________________________


 module agtb_16 (
	 input wire clk
        ,input wire [15:0] inpa 
	,input wire [15:0] inpb 
        ,output reg out_agtb 
	 );

// break this troublesome compare in half
 wire [7:0] inpa_hi, inpa_lo;
 wire [7:0] inpb_hi, inpb_lo;

 assign {inpb_hi, inpb_lo} = inpb;
 assign {inpa_hi, inpa_lo} = inpa;

 reg inpa_gt_inpb_1 = 1'b0;
 reg inpa_gt_inpb_2 = 1'b0;
 reg inpa_gt_inpb_3 = 1'b0;
 always @(posedge clk) 
    begin
	inpa_gt_inpb_1 <= inpa_hi > inpb_hi;
	inpa_gt_inpb_2 <= inpa_hi== inpb_hi;
	inpa_gt_inpb_3 <= inpa_lo > inpb_lo;	
    end

always @(posedge clk) 
   begin
	out_agtb <= inpa_gt_inpb_1 || (inpa_gt_inpb_2 && inpa_gt_inpb_3);
   end

 // ____________________________________________________________________________________________________________
 //

endmodule

// BENCHMARK INFO : Date : Wed Oct  1 16:50:35 2014
// BENCHMARK INFO : Quartus version : /tools/acdskit/14.1/136/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 14 
// BENCHMARK INFO : benchmark path: /tools/ipd_tools/1.14/linux64/bin
// BENCHMARK INFO : Total registers : 4
// BENCHMARK INFO : Total pins : 34
// BENCHMARK INFO : Total virtual pins : 0
// BENCHMARK INFO : Total block memory bits : 0
// BENCHMARK INFO : Number of Fitter seeds : 3
// BENCHMARK INFO : Device: 10AX115K4F36I3SG
// BENCHMARK INFO : ALM usage: 10
// BENCHMARK INFO : Combinational ALUT usage: 14
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 500 MHz : 1.184 ns, From inpa_gt_inpb_2, To out_agtb~reg0 
// BENCHMARK INFO : Fitter seed 2234: Worst setup slack @ 500 MHz : 1.102 ns, From inpa_gt_inpb_3, To out_agtb~reg0 
// BENCHMARK INFO : Fitter seed 3468: Worst setup slack @ 500 MHz : 0.971 ns, From inpa_gt_inpb_2, To out_agtb~reg0 
// BENCHMARK INFO : Elapsed benchmark time: 980.3 seconds
