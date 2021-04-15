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

// baeckler - 03-19-2013
// programmable pattern generator

// set_instance_assignment -name VIRTUAL_PIN ON -to rdata

module pgen #(
	parameter TARGET_CHIP = 2,
	parameter WORDS = 72,  // how many 16 bit words
	parameter LOG_WORDS = 7,
	parameter LOG_SLICES = 6,  // 2^this = RAM depth
	parameter SIM_EMULATE = 1'b0,  // emulate the RAM to make it simulate faster
	parameter SIM_FAKE_JTAG = 1'b0,  // use text file to mimic jtag input
	parameter MII_REV = 1'b1,  // if the pattern is lsbit first, setting this to 1 makes it left to right
	parameter PROG_NAME = "pgen.hex",
	parameter INIT_NAME = "pgen.init"
)(
	input cpu_clk,
	input cpu_sclr,
	
	input rclk,
	input rdinc,
	output [16*WORDS-1:0] rdata, // data format is software determined
	output rdata_valid
);


//////////////////////////////////////////////
// jtag byte stream
//////////////////////////////////////////////

reg [7:0] byte_to_jtag = 8'h0;
wire [7:0] byte_from_jtag;
reg byte_to_jtag_valid = 1'b0;
reg byte_from_jtag_ack = 1'b0;

generate
    if (SIM_FAKE_JTAG) begin
        // synthesis translate_off

        // load keystream from text file
        integer ifile = 0;
        integer ch = 0;
        initial begin
            ifile = $fopen ("pgen_in.txt","r");
            if (ifile == 0) begin
                $display ("Unable to read keystream data file");
                $stop();
            end
        end

        reg [7:0] file_byte = 8'h0;
        always @(posedge cpu_clk) begin
            if (byte_from_jtag_ack) begin
                if (ifile != 0) begin
                    ch = $fgetc (ifile);
                    if (ch == -1) begin
                        file_byte <= 0;
                        if (ifile != 0) begin
                            $display ("Info : input file exhausted, closing");
                            $fclose (ifile);
                            ifile = 0;
                        end
                    end
                    else file_byte <= ch[7:0];
                end
                else file_byte <= 0;
            end

            if (byte_to_jtag_valid) begin
                $write ("%c",byte_to_jtag);
            end
        end

        assign byte_from_jtag = file_byte;

	    // synthesis translate_on
    end
    else begin
        jtag_bytes jb (
            .clk(cpu_clk),
            .sclr(cpu_sclr),

            .byte_to_jtag(byte_to_jtag),
            .byte_to_jtag_valid(byte_to_jtag_valid),
			.to_jtag_pfull(),
			
            .byte_from_jtag(byte_from_jtag),
            .byte_from_jtag_ack(byte_from_jtag_ack)
        );
    end
endgenerate

///////////////////////////////////////////////////

wire [15:0] from_proc;
reg [15:0] to_proc = 0;
wire [11:0] from_addr;
wire from_proc_valid;

stacker2 st (
    .clk(cpu_clk),
    .sclr(cpu_sclr),

    .io_rdata(to_proc),
    .io_wdata(from_proc),
    .io_waddr(from_addr),
    .io_we(from_proc_valid)
);
defparam st .TARGET_CHIP = TARGET_CHIP;
defparam st .SIM_EMULATE = SIM_EMULATE;
defparam st .PROG_NAME = PROG_NAME;
defparam st .INIT_NAME = INIT_NAME;

///////////////////////////////////////////////////

reg [LOG_SLICES-1:0] waddr = {LOG_SLICES{1'b0}};
reg [LOG_WORDS-1:0] waddr_sub = {LOG_WORDS{1'b0}};
reg [15:0] wdata = 16'h0;	
reg wena = 1'b0;
wire [16*WORDS-1:0] rdata_i; // data format is software determined

pgen_ram pr (
	.wclk(cpu_clk),
	.wena(wena),
	.waddr(waddr),
	.waddr_sub(waddr_sub),
	.wdata(wdata),
	
	.rclk(rclk),
	.rdinc(rdinc),
	.rdata(rdata_i),
	.rdata_valid(rdata_valid)
);
defparam pr .WORD_SIZE = 16;
defparam pr .LOG_SLICES = LOG_SLICES; // 2^this is the RAM depth
defparam pr .LOG_WORDS = LOG_WORDS;
defparam pr .WORDS = WORDS;
defparam pr .SIM_EMULATE = SIM_EMULATE;


generate if (MII_REV) begin
	wire [(WORDS/9)*128-1:0] mii_d, rdata_d;
	wire [(WORDS/9)*16-1:0] mii_c, rdata_c;
	assign {mii_c,mii_d} = rdata_i;

	reverse_bytes rb (
		.din(mii_d),
		.dout(rdata_d)
	);
	defparam rb .NUM_BYTES = 16*(WORDS/9);
	
	reverse_bits rbt (
		.din(mii_c),
		.dout(rdata_c)
	);
	defparam rbt .WIDTH = 16*(WORDS/9);
	assign rdata = {rdata_c,rdata_d};	
end
else begin
	assign rdata = rdata_i;
end
endgenerate


// address map (hex)
// 1 get key
// 2 emit key
// 4 cpu halt notice

// 6 read ram width in words
// 7 read ram depth in slices
// 8 set waddr
// 9 set waddr_sub + pulse wena
// a set wdata 

reg [15:0] from_proc_r = 16'h0;
always @(posedge cpu_clk) from_proc_r <= from_proc;

always @(posedge cpu_clk) begin
    byte_to_jtag_valid <= 1'b0;
    byte_from_jtag_ack <= 1'b0;
    if (from_proc_valid && from_addr[3:0] == 4'h2) begin
        byte_to_jtag <= from_proc[7:0];
        byte_to_jtag_valid <= 1'b1;
    end
    if (from_proc_valid && from_addr[3:0] == 4'h1) begin
        to_proc <= 16'h0 | byte_from_jtag;
        byte_from_jtag_ack <= 1'b1;
    end    
    
    if (from_proc_valid && from_addr[3:0] == 4'h6) begin
		to_proc <= 16'h0 | WORDS[15:0]; 
	end
	if (from_proc_valid && from_addr[3:0] == 4'h7) begin
		to_proc <= 16'h0 | (16'h1 << LOG_SLICES); 
	end    
end

// load controls
reg load_waddr = 1'b0;
reg load_waddr_sub = 1'b0;
reg load_wdata = 1'b0;

always @(posedge cpu_clk) begin
    load_waddr <= (from_proc_valid && from_addr[3:0] == 4'h8);
    load_waddr_sub <= (from_proc_valid && from_addr[3:0] == 4'h9);
    load_wdata <= (from_proc_valid && from_addr[3:0] == 4'ha);
    
    wena <= 1'b0;
    if (load_waddr_sub) begin
		waddr_sub <= from_proc_r[LOG_WORDS-1:0];
		wena <= 1'b1;
	end
    if (load_waddr) waddr <= from_proc_r[LOG_SLICES-1:0];
    if (load_wdata) wdata <= from_proc_r[15:0];    
end

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  3.1 LUTs
// BENCHMARK INFO :  Total registers : 968
// BENCHMARK INFO :  Total pins : 5
// BENCHMARK INFO :  Total virtual pins : 1,152
// BENCHMARK INFO :  Total block memory bits : 172,032
// BENCHMARK INFO :  Comb ALUTs :                         ; 531                    ;       ;
// BENCHMARK INFO :  ALMs : 1,048 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.000 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|sld_shadow_jsm:shadow_jsm|state[4], To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.097 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|irsr_reg[1], To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : -0.039 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|irsr_reg[0]~DUPLICATE, To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
