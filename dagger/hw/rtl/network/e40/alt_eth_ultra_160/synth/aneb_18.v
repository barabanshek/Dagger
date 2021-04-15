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
// ___________________________________________________________________________


 module aneb_18 (
	 input wire clk
        ,input wire [17:0] inpa 
	,input wire [17:0] inpb 
        ,output reg out_aneb 
	 );

// break this troublesome compare in half
 wire [2:0] inpa_n5, inpa_n4, inpa_n3, inpa_n2, inpa_n1, inpa_n0;
 wire [2:0] inpb_n5, inpb_n4, inpb_n3, inpb_n2, inpb_n1, inpb_n0;

 assign {inpa_n5, inpa_n4, inpa_n3, inpa_n2, inpa_n1, inpa_n0} = inpa;
 assign {inpb_n5, inpb_n4, inpb_n3, inpb_n2, inpb_n1, inpb_n0} = inpb;

 reg ina_neq_inb_0 = 1'b0;
 reg ina_neq_inb_1 = 1'b0;
 reg ina_neq_inb_2 = 1'b0;
 reg ina_neq_inb_3 = 1'b0;
 reg ina_neq_inb_4 = 1'b0;
 reg ina_neq_inb_5 = 1'b0;
 always @(posedge clk) 
    begin
	ina_neq_inb_0 <= |(inpa_n0 ^ inpb_n0); 
	ina_neq_inb_1 <= |(inpa_n1 ^ inpb_n1); 
	ina_neq_inb_2 <= |(inpa_n2 ^ inpb_n2); 
	ina_neq_inb_3 <= |(inpa_n3 ^ inpb_n3); 
	ina_neq_inb_4 <= |(inpa_n4 ^ inpb_n4); 
	ina_neq_inb_5 <= |(inpa_n5 ^ inpb_n5); 
    end

always @(posedge clk) 
   begin
	out_aneb <= {ina_neq_inb_5|ina_neq_inb_4|ina_neq_inb_3|ina_neq_inb_2|ina_neq_inb_1|ina_neq_inb_0};
   end

 // ____________________________________________________________________________________________________________
 //

endmodule

// BENCHMARK INFO : Date : Wed Oct  1 18:08:34 2014
// BENCHMARK INFO : Quartus version : /tools/acdskit/14.1/136/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 14 
// BENCHMARK INFO : benchmark path: /tools/ipd_tools/1.14/linux64/bin
// BENCHMARK INFO : Total registers : 7
// BENCHMARK INFO : Total pins : 38
// BENCHMARK INFO : Total virtual pins : 0
// BENCHMARK INFO : Total block memory bits : 0
// BENCHMARK INFO : Number of Fitter seeds : 3
// BENCHMARK INFO : Device: 10AX115K4F36I3SG
// BENCHMARK INFO : ALM usage: 4
// BENCHMARK INFO : Combinational ALUT usage: 7
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 500 MHz : 0.916 ns, From ina_neq_inb_1, To out_aneb~reg0 
// BENCHMARK INFO : Fitter seed 2234: Worst setup slack @ 500 MHz : 0.858 ns, From ina_neq_inb_2, To out_aneb~reg0 
// BENCHMARK INFO : Fitter seed 3468: Worst setup slack @ 500 MHz : 0.831 ns, From ina_neq_inb_1, To out_aneb~reg0 
// BENCHMARK INFO : Elapsed benchmark time: 893.1 seconds
