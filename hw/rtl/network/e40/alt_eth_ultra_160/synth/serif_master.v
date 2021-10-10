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

// baeckler 01-07-2012
// take in avalon, drive slaves around serial ring

module serif_master #(
	parameter READ_TIMEOUT = 8,
	parameter MAX_BASES = 16,
	parameter INVALID_BASES = 0
)(
	input clk,
	input sclr,
	input din,
	output dout,
	
	output wire busy,
	output reg read_timeout,
	input wr,
	input rd,
	input [15:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata,
	output reg rdata_valid	
);

////////////////////////////////////////////
// bit to byte interface

wire [7:0] rx_byte;
wire rx_byte_valid;

reg [7:0] tx_byte = 8'h0;
reg tx_byte_valid = 1'b0;
wire tx_byte_ack;

serif_tap stp (
	.clk(clk),
	.din(din),
	.dout(dout),
	
	.rx_byte(rx_byte),
	.rx_byte_valid(rx_byte_valid),
	
	.tx_byte_valid(tx_byte_valid),
	.tx_byte(tx_byte),
	.tx_byte_ack(tx_byte_ack)
);


////////////////////////////////////////////
// stream bytes to do 32 bit read + write

localparam 
	ST_IDLE = 4'h0,
	ST_ADDR = 4'h1,
	ST_ADDR2 = 4'h2,
	ST_ADDR3 = 4'h3,
	ST_WDATA = 4'h4,
	ST_WDATA2 = 4'h5,
	ST_WDATA3 = 4'h6,
	ST_WDATA4 = 4'h7,
	ST_FINISH = 4'h8,
	ST_READ = 4'h9,
	ST_READ2 = 4'ha,
	ST_READ3 = 4'hb,
	ST_READ4 = 4'hc,
	ST_READ_TIMEOUT = 4'hd,
	ST_DONE = 4'he,
	ST_ERR = 4'hf;

reg [3:0] st = 4'h0 /* synthesis preserve */;

reg [15:0] addr_r = 16'h0;
reg [31:0] wdata_r = 16'h0;
reg wr_r = 1'b0;
reg expecting_rx = 1'b0;
wire read_expired;

// ____________________________________________________
//	do not wait for the timeout for unpopulated bases
//	terminate the transaction and return a known value
// ____________________________________________________
  reg[32+MAX_BASES-1:0] base_invalid = {{MAX_BASES{1'b0}},INVALID_BASES}; 

  wire[MAX_BASES-1:0] invalid_base_address;

  genvar i;
  generate for (i =0; i< MAX_BASES; i=i+1) 
           begin:geninval
                 assign invalid_base_address[i]  = (rd|wr) && (addr[15:8] === i) && base_invalid[i];
           end
  endgenerate
// ____________________________________________________
//	busy must be asserted in cycle-0 per avalon-MM
//	specification
// ____________________________________________________
  reg r_busy;
  wire new_wr = wr && (st == ST_IDLE);
  wire new_rd = rd && (st == ST_IDLE);
  assign busy = r_busy | new_rd | new_wr;

always @(posedge clk) begin
	expecting_rx <= 1'b0;
	rdata_valid <= 1'b0;
	read_timeout <= 1'b0;
	
	case (st) 
		ST_IDLE : begin
			tx_byte_valid <= 1'b0;
			r_busy <= 1'b0;
			if (wr && (|invalid_base_address)) begin
			      rdata <= 32'hdeadc0de;
			      st <= ST_DONE;	
			      r_busy <= 1'b0; 
			      rdata_valid <= 1'b0; // 1'b1;
			end
			else if (rd && (|invalid_base_address)) begin
			      rdata <= 32'hdeadc0de;
			      st <= ST_DONE;	
			      r_busy <= 1'b0; 
			      rdata_valid <= 1'b1;
			end
			else if (rd || wr) begin
				r_busy <= 1'b1;
				addr_r <= addr;
				wdata_r <= wdata;
				wr_r <= wr;
				st <= ST_ADDR;
			end	
		end
		ST_ADDR : begin
			if (wr && (|invalid_base_address)) begin
			      rdata <= 32'hdeadc0de;
			      st <= ST_DONE;	
			      r_busy <= 1'b0; 
			      rdata_valid <= 1'b0; // 1'b1;
			end
			else if (rd && (|invalid_base_address)) begin
			      rdata <= 32'hdeadc0de;
			      st <= ST_DONE;	
			      r_busy <= 1'b0; 
			      rdata_valid <= 1'b1;
			end
			else begin
			tx_byte <= addr_r[15:8];
			addr_r [15:8] <= addr_r[7:0];
			tx_byte_valid <= 1'b1;
			st <= ST_ADDR2;						
			end
		end
		ST_ADDR2 : begin
			if (tx_byte_ack) begin
				tx_byte <= addr_r[15:8];
				st <= ST_ADDR3;
			end
		end
		ST_ADDR3 : begin
			if (tx_byte_ack) begin
				if (wr_r) begin
					tx_byte <= 8'h55;
					st <= ST_WDATA;
				end
				else begin
					tx_byte <= 8'hcc;
					st <= ST_READ;
				end
			end
		end
		ST_WDATA : begin
			if (tx_byte_ack) begin
				tx_byte <= wdata_r[31:24];
				wdata_r <= wdata_r << 8;
				st <= ST_WDATA2;
			end			
		end
		ST_WDATA2 : begin
			if (tx_byte_ack) begin
				tx_byte <= wdata_r[31:24];
				wdata_r <= wdata_r << 8;
				st <= ST_WDATA3;
			end			
		end
		ST_WDATA3 : begin
			if (tx_byte_ack) begin
				tx_byte <= wdata_r[31:24];
				wdata_r <= wdata_r << 8;
				st <= ST_WDATA4;
			end			
		end
		ST_WDATA4 : begin
			if (tx_byte_ack) begin
				tx_byte <= wdata_r[31:24];
				wdata_r <= wdata_r << 8;
				st <= ST_FINISH;
			end			
		end
		ST_FINISH : begin
			if (tx_byte_ack) 
			   begin 
				r_busy <= 1'b0; 
				st <= ST_DONE; 
			   end // edit insert single cycle state to de-assert wait where no request is sampled
		end
		ST_DONE: 	// edit 
			begin
			    rdata_valid <= 1'b0;
			    st <= ST_IDLE; //edit
			end

		ST_READ : begin
			expecting_rx <= 1'b1;
			if (tx_byte_ack) tx_byte_valid <= 1'b0;
			if (rx_byte_valid) begin
				rdata <= {rdata [23:0],rx_byte};
				st <= ST_READ2;
			end
		end
		ST_READ2 : begin
			expecting_rx <= 1'b1;
			if (rx_byte_valid) begin
				rdata <= {rdata [23:0],rx_byte};
				st <= ST_READ3;
			end
		end
		ST_READ3 : begin
			expecting_rx <= 1'b1;
			if (rx_byte_valid) begin
				rdata <= {rdata [23:0],rx_byte};
				st <= ST_READ4;
			end
		end
		ST_READ4 : begin
			expecting_rx <= 1'b1;
			if (rx_byte_valid) begin
				rdata <= {rdata [23:0],rx_byte};
				st <= ST_DONE;	// edit
				r_busy <= 1'b0; 
				rdata_valid <= 1'b1;
			end
		end		
		ST_READ_TIMEOUT : begin
			read_timeout <= 1'b1;
			st <= ST_ERR;
		end
		ST_ERR : begin
			st <= ST_IDLE;
		end
	endcase
	
	
	if (read_expired) st <= ST_READ_TIMEOUT;
	if (sclr) st <= ST_IDLE;
end

////////////////////////////////////////////
// make sure slave reads don't wait forever

watchdog_timer wd (
	.clk(clk),
	.srst(!expecting_rx || rx_byte_valid),
	.expired(read_expired)
);
defparam wd .CNTR_BITS = READ_TIMEOUT;


endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  2.8 LUTs
// BENCHMARK INFO :  Total registers : 130
// BENCHMARK INFO :  Total pins : 88
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 77              ;       ;
// BENCHMARK INFO :  ALMs : 70 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.837 ns, From st[2], To busy~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.876 ns, From st[0], To rdata[26]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.773 ns, From st[0], To rdata[11]~reg0}
