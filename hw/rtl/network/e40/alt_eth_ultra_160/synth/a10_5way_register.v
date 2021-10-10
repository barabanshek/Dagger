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
// baeckler - 08-21-2012
// treat me like a register, continually shifts through 5 slices

module a10_5way_register #(
        parameter WIDTH = 8
)(
        input clk,
        input [WIDTH-1:0] d_reg,
        output [WIDTH-1:0] q    
);

localparam ADDR_WIDTH = 3;

reg [ADDR_WIDTH-1:0] waddr_reg = 0 /* synthesis preserve */;
reg [ADDR_WIDTH-1:0] raddr = 0 /* synthesis preserve */;

always @(posedge clk) begin
        case (waddr_reg)
                3'h0 : begin waddr_reg <= 3'h1; raddr <= 3'h3; end
                3'h1 : begin waddr_reg <= 3'h2; raddr <= 3'h4; end
                3'h2 : begin waddr_reg <= 3'h3; raddr <= 3'h0; end
                3'h3 : begin waddr_reg <= 3'h4; raddr <= 3'h1; end
                3'h4 : begin waddr_reg <= 3'h0; raddr <= 3'h2; end
                
                // error
                3'h5 : begin waddr_reg <= 3'h0; raddr <= 3'h0; end
                3'h6 : begin waddr_reg <= 3'h0; raddr <= 3'h0; end
                3'h7 : begin waddr_reg <= 3'h0; raddr <= 3'h0; end              
        endcase
end

wire [WIDTH-1:0] rdata;
reg [WIDTH-1:0] q_r = 0;
always @(posedge clk) begin
        q_r <= rdata;
end
assign q = q_r;

wire wena = 1'b1;

genvar i;
generate
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        twentynm_mlab_cell lrm (
            .clk0(clk),
            .ena0(wena),

            // synthesis translate off
            .clk1(1'b0),
            .ena1(1'b1),
            .ena2(1'b1),
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate on

            .portabyteenamasks(1'b1),
            .portadatain(d_reg[i]),
            .portaaddr(waddr_reg),
            .portbaddr(raddr),
            .portbdataout(rdata[i])

        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
    end
endgenerate


endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 14
// BENCHMARK INFO :  Total pins : 17
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 7               ;       ;
// BENCHMARK INFO :  ALMs : 14 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.313 ns, From raddr[2], To q_r[6]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.290 ns, From raddr[0], To q_r[7]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.302 ns, From raddr[0], To q_r[6]}
