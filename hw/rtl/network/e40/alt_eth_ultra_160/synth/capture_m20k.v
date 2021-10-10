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

`timescale 1 ps / 1 ps
// capture samples around the first trigger after sclr

module capture_m20k #(
        parameter TARGET_CHIP = 2,
        parameter ADDR_WIDTH = 7,
        parameter WIDTH = 16        
) (
	input clk,
	input sclr,
	input trigger,
	input [WIDTH-1:0] din_reg,
	
	input [ADDR_WIDTH-1:0] raddr,
	output [WIDTH-1:0] dout		
);

reg [ADDR_WIDTH-1:0] addr = 0;
reg wena = 1'b0;
reg [ADDR_WIDTH-1:0] center = 0;
reg [ADDR_WIDTH-1:0] stop_cnt = 0;
reg triggered = 1'b0;
wire [WIDTH-1:0] dout_w;

// recenter read requests
reg [ADDR_WIDTH-1:0] raddr_adj = 0;
always @(posedge clk) begin
	raddr_adj <= center + raddr;
end

// black out data if the capture hasn't triggered
reg [WIDTH-1:0] dout_r = 0;
always @(posedge clk) begin
	dout_r <= dout_w & {WIDTH{stop_cnt[ADDR_WIDTH-1]}}; 
end
assign dout = dout_r;

altsyncram      altsyncram_component (
                                .address_a (addr[ADDR_WIDTH-1:0]),
                                .clock0 (clk),
                                .data_a (din_reg[WIDTH-1:0]),
                                .wren_a (wena),
                                .address_b (raddr_adj[ADDR_WIDTH-1:0]),
                                .q_b (dout_w[WIDTH-1:0]),
                                .aclr0 (1'b0),
                                .aclr1 (1'b0),
                                .addressstall_a (1'b0),
                                .addressstall_b (1'b0),
                                .byteena_a (1'b1),
                                .byteena_b (1'b1),
                                .clock1 (1'b1),
                                .clocken0 (1'b1),
                                .clocken1 (1'b1),
                                .clocken2 (1'b1),
                                .clocken3 (1'b1),
                                .data_b ({WIDTH{1'b1}}),
                                .eccstatus (),
                                .q_a (),
                                .rden_a (1'b1),
                                .rden_b (1'b1),
                                .wren_b (1'b0));
        defparam
                altsyncram_component.address_aclr_b = "NONE",
                altsyncram_component.address_reg_b = "CLOCK0",
                altsyncram_component.clock_enable_input_a = "BYPASS",
                altsyncram_component.clock_enable_input_b = "BYPASS",
                altsyncram_component.clock_enable_output_b = "BYPASS",
                altsyncram_component.enable_ecc = "FALSE",
                altsyncram_component.intended_device_family = "Stratix V",
                altsyncram_component.lpm_type = "altsyncram",
                altsyncram_component.numwords_a = (1 << ADDR_WIDTH),
                altsyncram_component.numwords_b =  (1 << ADDR_WIDTH),
                altsyncram_component.operation_mode = "DUAL_PORT",
                altsyncram_component.outdata_aclr_b = "NONE",
                //altsyncram_component.outdata_reg_b = "UNREGISTERED",
                altsyncram_component.outdata_reg_b = "CLOCK0",
                altsyncram_component.power_up_uninitialized = "FALSE",
                altsyncram_component.ram_block_type = "M20K",
                altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
                altsyncram_component.widthad_a = ADDR_WIDTH,
                altsyncram_component.widthad_b = ADDR_WIDTH,
                altsyncram_component.width_a = WIDTH,
                altsyncram_component.width_b = WIDTH,
                altsyncram_component.width_byteena_a = 1;

// control
always @(posedge clk) begin
	if (sclr) begin
		wena <= 1'b1;
		addr <= {ADDR_WIDTH{1'b0}};
		center <= {ADDR_WIDTH{1'b0}};
		stop_cnt <= {ADDR_WIDTH{1'b0}};
		triggered <= 1'b0;
	end
	else begin
		addr <= addr + 1'b1;
		if (trigger && !triggered) begin
			center <= addr;
			triggered <= 1'b1;
		end
		if (triggered) begin
			if (stop_cnt[ADDR_WIDTH-1]) wena <= 1'b0;
			else stop_cnt <= stop_cnt + 1'b1;
		end				
	end
end

endmodule
