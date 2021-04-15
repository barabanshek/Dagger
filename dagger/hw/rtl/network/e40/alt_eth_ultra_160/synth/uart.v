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

// baeckler - 02-16-2007
////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////

module uart (clk,rst,
			tx_data,tx_data_valid,tx_data_ack,txd,
			rx_data,rx_data_fresh,rxd);

parameter CLK_HZ = 50_000_000;
parameter BAUD = 115200;
parameter BAUD_DIVISOR = CLK_HZ / BAUD;

initial begin
	if (BAUD_DIVISOR > 16'hffff) begin
		// This rate is too slow for the TX and RX sample 
		// counter resolution
		$display ("Error - Increase the size of the sample counters");
		$stop();
	end
end

output txd;
input clk, rst, rxd;
input [7:0] tx_data;
input tx_data_valid;
output tx_data_ack;
output [7:0] rx_data;
output rx_data_fresh;

uart_tx utx (
	.clk(clk),.rst(rst),
	.tx_data(tx_data),
	.tx_data_valid(tx_data_valid),
	.tx_data_ack(tx_data_ack),
	.txd(txd));

defparam utx .BAUD_DIVISOR = BAUD_DIVISOR;

uart_rx urx (
	.clk(clk),.rst(rst),
	.rx_data(rx_data),
	.rx_data_fresh(rx_data_fresh),
	.rxd(rxd));

defparam urx .BAUD_DIVISOR = BAUD_DIVISOR;

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  3.0 LUTs
// BENCHMARK INFO :  Total registers : 73
// BENCHMARK INFO :  Total pins : 23
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 70              ;       ;
// BENCHMARK INFO :  ALMs : 58 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.912 ns, From uart_tx:utx|sample_cntr[5], To uart_tx:utx|sample_cntr[5]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.849 ns, From uart_rx:urx|sample_now, To uart_rx:urx|rx_shift[0]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.854 ns, From uart_rx:urx|sample_cntr[1], To uart_rx:urx|sample_cntr[1]}
