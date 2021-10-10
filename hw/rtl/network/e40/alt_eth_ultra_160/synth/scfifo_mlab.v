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

// baeckler - 02-19-2012

`timescale 1ps/1ps

module scfifo_mlab #(
	parameter TARGET_CHIP = 1, // 1 S4, 2 S5,
	parameter SIM_EMULATE = 1'b0,  // simulation equivalent, only for S5 right now
	parameter WIDTH = 80, // typical 20,40,60,80
	parameter PREVENT_OVERFLOW = 1'b1,	// ignore requests that would cause overflow
	parameter PREVENT_UNDERFLOW = 1'b1,	// ignore requests that would cause underflow
	parameter RAM_GROUPS = (WIDTH < 20) ? 1 : (WIDTH / 20), // min 1, WIDTH must be divisible by RAM_GROUPS
	parameter GROUP_RADDR = (WIDTH < 20) ? 1'b0 : 1'b1,  // 1 to duplicate RADDR per group as well as WADDR
	parameter FLAG_DUPES = 1, // if > 1 replicate full / empty flags for fanout balancing
	parameter ADDR_WIDTH = 5, // 4 or 5
	parameter DISABLE_USED = 1'b0	
)(
	input clk,
	input sclr,
	
	input [WIDTH-1:0] wdata,
	input wreq,
	output [FLAG_DUPES-1:0] full,	// optional duplicates for loading
	
	output [WIDTH-1:0] rdata,
	input rreq,
	output [FLAG_DUPES-1:0] empty,	// optional duplicates for loading

	output [ADDR_WIDTH-1:0] used	
);

// synthesis translate_off
initial begin
	if (WIDTH > 20 && (RAM_GROUPS * 20 != WIDTH)) begin
		$display ("Error in scfifo_mlab parameters - the physical width is a multiple of 20, this needs to match");
		$stop();
	end 
end
// synthesis translate_on


////////////////////////////////////
// rereg sclr
////////////////////////////////////

reg sclr_int = 1'b1 /* synthesis preserve */;
always @(posedge clk) begin
	sclr_int <= sclr;
end

////////////////////////////////////
// addr pointers 
////////////////////////////////////

wire winc;
wire rinc;

wire [RAM_GROUPS*ADDR_WIDTH-1:0] rptr;
reg [ADDR_WIDTH-1:0] wcntr = {ADDR_WIDTH{1'b0}} /* synthesis preserve */;
reg [ADDR_WIDTH-1:0] rcntr = {ADDR_WIDTH{1'b0}} /* synthesis preserve */;

always @(posedge clk) begin
	if (sclr_int) wcntr <= {ADDR_WIDTH{1'b0}} | 1'b1;
	else if (winc) wcntr <= wcntr + 1'b1;
	
	if (sclr_int) rcntr <= {ADDR_WIDTH{1'b0}} | (GROUP_RADDR ? 2'd2 : 2'd1);
	else if (rinc) rcntr <= rcntr + 1'b1;	
end

// optional duplication of the read address 	
generate 
	if (GROUP_RADDR) begin : gr
		reg [RAM_GROUPS*ADDR_WIDTH-1:0] rptr_r = {RAM_GROUPS{{ADDR_WIDTH{1'b0}} | 1'b1}} 
			/* synthesis preserve */;
		always @(posedge clk) begin
			if (sclr_int) rptr_r <= {RAM_GROUPS{{ADDR_WIDTH{1'b0}} | 1'b1}} ;
			else if (rinc) rptr_r <= {RAM_GROUPS{rcntr}};			
		end		
		assign rptr = rptr_r;
	end
	else begin : ngr
		assign rptr = {RAM_GROUPS{rcntr}};
	end
endgenerate

//////////////////////////////////////////////////
// adjust pointers for RAM latency
//////////////////////////////////////////////////

reg [ADDR_WIDTH-1:0] rptr_completed_1 = {ADDR_WIDTH{1'b0}} /* synthesis keep */;
reg [ADDR_WIDTH-1:0] rptr_completed_2 = {ADDR_WIDTH{1'b0}} /* synthesis keep */;
reg [ADDR_WIDTH-1:0] rptr_completed_3 = {ADDR_WIDTH{1'b0}} /* synthesis keep */;

always @(posedge clk) begin
	if (sclr_int) begin
		rptr_completed_1 <= {ADDR_WIDTH{1'b0}};
		rptr_completed_2 <= {ADDR_WIDTH{1'b0}};
		rptr_completed_3 <= {ADDR_WIDTH{1'b0}};
	end
	else begin
		if (rinc) rptr_completed_1 <= rptr[ADDR_WIDTH-1:0];
		if (rinc) rptr_completed_2 <= rptr[ADDR_WIDTH-1:0];
		if (rinc) rptr_completed_3 <= rptr[ADDR_WIDTH-1:0];
	end
end

reg [ADDR_WIDTH-1:0] wptr_d = {ADDR_WIDTH{1'b0}};
reg [ADDR_WIDTH-1:0] wptr_completed_f1 = {ADDR_WIDTH{1'b0}} /* synthesis keep */;
reg [ADDR_WIDTH-1:0] wptr_completed_f2 = {ADDR_WIDTH{1'b0}} /* synthesis keep */;

wire [ADDR_WIDTH-1:0] wptr_d_w = winc ? wcntr : wptr_d;

always @(posedge clk) begin
	if (sclr_int) begin
		wptr_d <= {ADDR_WIDTH{1'b0}};
		wptr_completed_f1 <= {ADDR_WIDTH{1'b0}};		
		wptr_completed_f2 <= {ADDR_WIDTH{1'b0}};	
	end
	else begin
		wptr_d <= wptr_d_w;			
		wptr_completed_f1 <= wptr_d;
		wptr_completed_f2 <= wptr_d;
	end
end

//////////////////////////////////////////////////
// compare pointers
//////////////////////////////////////////////////

genvar i;
generate
	for (i=0; i<FLAG_DUPES; i=i+1) begin : fg
		
		//assign full[i] = ~|(rptr_completed ^ wcntr); 
		//assign empty[i] = ~|(rptr_completed ^ wptr_completed);

		eq_5_ena eq0 (
			.da(5'h0 | rptr_completed_1),
			.db(5'h0 | wcntr),
			.ena(1'b1),
			.eq(full[i])
		);
		defparam eq0 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5
		
		eq_5_ena eq1 (
			.da(5'h0 | rptr_completed_2),
			.db(5'h0 | wptr_completed_f1),
			.ena(1'b1),
			.eq(empty[i])
		);
		defparam eq1 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5		
		
	end
endgenerate

//////////////////////////////////////////////////
// storage array - split in addr reg groups
//////////////////////////////////////////////////

reg [ADDR_WIDTH*RAM_GROUPS-1:0] waddr_reg = {(RAM_GROUPS*ADDR_WIDTH){1'b0}} /* synthesis preserve */;
reg [WIDTH-1:0] wdata_reg = {WIDTH{1'b0}} /* synthesis preserve */;
wire [WIDTH-1:0] ram_q;
reg [WIDTH-1:0] rdata_reg = {WIDTH{1'b0}};

wire [ADDR_WIDTH-1:0] wptr_inv = wcntr ^ 1'b1;
always @(posedge clk) begin
	waddr_reg <= {RAM_GROUPS{wptr_inv}};
	wdata_reg <= wdata;
end

generate
	for (i=0; i<RAM_GROUPS;i=i+1) begin : sm
		if (TARGET_CHIP == 1) begin : tc1
			s4mlab sm0 (
				.wclk(clk),
				.wena(1'b1),
				.waddr_reg(waddr_reg[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH]),
				.wdata_reg(wdata_reg[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)]),
				.raddr(rptr[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH] ^ 1'b1),
				.rdata(ram_q[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)])		
			);
			defparam sm0 .WIDTH = WIDTH / RAM_GROUPS;
			defparam sm0 .ADDR_WIDTH = ADDR_WIDTH;
		end
		else if (TARGET_CHIP == 2) begin : tc2
			s5mlab sm0 (
				.wclk(clk),
				.wena(1'b1),
				.waddr_reg(waddr_reg[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH]),
				.wdata_reg(wdata_reg[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)]),
				.raddr(rptr[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH] ^ 1'b1),
				.rdata(ram_q[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)])		
			);		
			defparam sm0 .WIDTH = WIDTH / RAM_GROUPS;
			defparam sm0 .ADDR_WIDTH = ADDR_WIDTH;
			defparam sm0 .SIM_EMULATE = SIM_EMULATE;
		end
		else if (TARGET_CHIP == 5) begin : tc5
			a10mlab sm0 (
				.wclk(clk),
				.wena(1'b1),
				.waddr_reg(waddr_reg[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH]),
				.wdata_reg(wdata_reg[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)]),
				.raddr(rptr[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH] ^ 1'b1),
				.rdata(ram_q[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)])		
			);		
			defparam sm0 .WIDTH = WIDTH / RAM_GROUPS;
			defparam sm0 .ADDR_WIDTH = ADDR_WIDTH;
			defparam sm0 .SIM_EMULATE = SIM_EMULATE;
		end
                else begin
                        // synthesis translate_off
                        initial begin
                                $display ("Fatal %m : Unknown target chip");
                                $stop();
                        end
                        // synthesis translate_on
                end

	end
endgenerate

// output reg - don't defeat clock enable (?) Works really well on S5
wire [WIDTH-1:0] rdata_mx = rinc ? ram_q: rdata_reg ;		
always @(posedge clk) begin
	rdata_reg <= rdata_mx;
end
assign rdata = rdata_reg;

//////////////////////////////////////////////////
// used words
//////////////////////////////////////////////////

generate
	if (DISABLE_USED) begin : nwu
		assign used = {ADDR_WIDTH{1'b0}};
	end
	else begin : wu
		reg [ADDR_WIDTH-1:0] used_r = {ADDR_WIDTH{1'b0}} /* synthesis preserve */;
		always @(posedge clk) begin
			used_r <= wptr_completed_f2 - rptr_completed_3;
		end
		assign used = used_r;
	end
endgenerate

////////////////////////////////////
// qualified requests
////////////////////////////////////

//wire winc = wreq & (~full[0] | ~PREVENT_OVERFLOW);
//wire rinc = rreq & (~empty[0] | ~PREVENT_UNDERFLOW);

generate
	if (PREVENT_OVERFLOW) begin

        reg [ADDR_WIDTH-1:0] rptr_completed_4 = {ADDR_WIDTH{1'b0}} /* synthesis keep */;
        always @(posedge clk) begin
            if (sclr_int) begin
                rptr_completed_4 <= {ADDR_WIDTH{1'b0}};
            end
            else begin
                if (rinc) rptr_completed_4 <= rptr[ADDR_WIDTH-1:0];
            end
        end

		neq_5_ena eq2 (
			.da(5'h0 | rptr_completed_4),
			.db(5'h0 | wcntr),
			.ena(wreq),
			.eq(winc)
		);
		defparam eq2 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5
	end
	else assign winc = wreq;
endgenerate
	
generate 
	if (PREVENT_UNDERFLOW) begin

        reg [ADDR_WIDTH-1:0] rptr_completed_5 = {ADDR_WIDTH{1'b0}} /* synthesis keep */;
        reg [ADDR_WIDTH-1:0] wptr_completed_f3 = {ADDR_WIDTH{1'b0}} /* synthesis keep */;
        always @(posedge clk) begin
            if (sclr_int) begin
                rptr_completed_5 <= {ADDR_WIDTH{1'b0}};
                wptr_completed_f3 <= {ADDR_WIDTH{1'b0}};
            end
            else begin
                if (rinc) rptr_completed_5 <= rptr[ADDR_WIDTH-1:0];
                wptr_completed_f3 <= wptr_d;
            end
        end

		neq_5_ena eq3 (
			.da(5'h0 | rptr_completed_5),
			.db(5'h0 | wptr_completed_f3),
			.ena(rreq),
			.eq(rinc)
		);
		defparam eq3 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5		
	end
	else assign rinc = rreq;
endgenerate

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  3.0 LUTs
// BENCHMARK INFO :  Total registers : 231
// BENCHMARK INFO :  Total pins : 171
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 40              ;       ;
// BENCHMARK INFO :  ALMs : 94 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.551 ns, From gr.rptr_r[14], To rdata_reg[56]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.654 ns, From wptr_completed[2], To s5mlab:sm[2].tc2.sm0|ml[0].lrm~ENA1REGOUT}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.625 ns, From rptr_completed[2], To wcntr[2]}
