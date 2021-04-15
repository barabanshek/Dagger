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


// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/hsl18/ecrc_4.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
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
// baeckler - 11-11-2009

// to cut down pins for testing -
// set_instance_assignment -name VIRTUAL_PIN ON -to din
// set_instance_assignment -name VIRTUAL_PIN ON -to din_last_data
// set_instance_assignment -name VIRTUAL_PIN ON -to crc_out

module ecrc_4 #(
        parameter REDUCE_LATENCY = 1'b1,
        parameter TARGET_CHIP = 2
)(
        input clk,
        
        input din_valid,
        input [4*64-1:0] din,  // read bytes left to right, lsbit first
        input [4-1:0] din_first_data, // left to right, is this word the 1st frame data?
        input [4*8-1:0] din_last_data, // left to right, is this byte the last before FCS?
        
        output crc_valid,
        output [31:0] crc_out
);

localparam WORDS = 4;

// simulation only sanity check
// synthesis translate_off
genvar k;
generate
        for (k=0; k<WORDS; k=k+1) begin : san
                reg [63:0] tmp_word;
                reg [7:0] tmp_end;
                always @(posedge clk) begin
                        if (din_valid) begin
                                tmp_word = din[(k+1)*64-1:k*64];
                                tmp_end = din_last_data[(k+1)*8-1:k*8];
                                if (|tmp_end) begin
                                        if ( (tmp_end[7] && ((tmp_word & 64'h00ffffffffffffff) != 0)) ||
                                                 (tmp_end[6] && ((tmp_word & 64'h0000ffffffffffff) != 0)) ||
                                                 (tmp_end[5] && ((tmp_word & 64'h000000ffffffffff) != 0)) ||
                                                 (tmp_end[4] && ((tmp_word & 64'h00000000ffffffff) != 0)) ||
                                                 (tmp_end[3] && ((tmp_word & 64'h0000000000ffffff) != 0)) ||
                                                 (tmp_end[2] && ((tmp_word & 64'h000000000000ffff) != 0)) ||
                                                 (tmp_end[1] && ((tmp_word & 64'h00000000000000ff) != 0))) begin
                                        
                                                // the CRC and any remaining bytes in that word need
                                                // to be zero for proper computation
                                                $display ("Warning : CRC not properly zero'd at time %d",$time);
                                                $display ("  End word is %x",tmp_word);                                                  
                                                $display ("  Last data flag is %x",tmp_end);
                                                #100
//                                              $stop();
                                                $finish();
                                        end
                                end             
                        end
                end
        end
endgenerate
// synthesis translate_on

/////////////////////////////////////////////
// squash 64 bit data to 32 bit signatures
//   makes it easier to P+R
/////////////////////////////////////////////

wire [63:0] din0, din1, din2, din3;
assign {din0, din1, din2, din3} = din;

wire [31:0] sig0,sig1,sig2,sig3;
crc32_d64_sig sg0 (
        .clk(clk),
        .d(din0), // used left to right, lsbit first per byte
        .c(sig0)
);
defparam sg0. TARGET_CHIP = TARGET_CHIP;

crc32_d64_sig sg1 (
        .clk(clk),
        .d(din1), // used left to right, lsbit first per byte
        .c(sig1)
);
defparam sg1. TARGET_CHIP = TARGET_CHIP;

crc32_d64_sig sg2 (
        .clk(clk),
        .d(din2), // used left to right, lsbit first per byte
        .c(sig2)
);
defparam sg2. TARGET_CHIP = TARGET_CHIP;

crc32_d64_sig sg3 (
        .clk(clk),
        .d(din3), // used left to right, lsbit first per byte
        .c(sig3)
);
defparam sg3. TARGET_CHIP = TARGET_CHIP;

////////////////////////////////////////
// components of no-stop, or starting at (n) and going all through
////////////////////////////////////////

wire [31:0] sig2x1,sig1x2,sig0x3;

crc32_z64_xn #(.NUM_EVOS(1),.TARGET_CHIP(TARGET_CHIP),.REDUCE_LATENCY(REDUCE_LATENCY)) e2x1 (
    .clk(clk),
    .blank(1'b0),     // zero out, latency 1
        .d(sig2), 
    .c(sig2x1) 
);

crc32_z64_xn #(.NUM_EVOS(2),.TARGET_CHIP(TARGET_CHIP),.REDUCE_LATENCY(REDUCE_LATENCY)) e1x2 (
    .clk(clk),
    .blank(1'b0),     // zero out, latency 1
        .d(sig1), 
    .c(sig1x2) 
);

crc32_z64_xn #(.NUM_EVOS(3),.TARGET_CHIP(TARGET_CHIP),.REDUCE_LATENCY(REDUCE_LATENCY)) e0x3 (
    .clk(clk),
    .blank(1'b0),     // zero out, latency 1
        .d(sig0), 
    .c(sig0x3) 
);

////////////////////////////////////////
// components of stopping short of #3
////////////////////////////////////////

wire  [31:0] sig1x1, sig0x2;

crc32_z64_xn #(.NUM_EVOS(1),.TARGET_CHIP(TARGET_CHIP),.REDUCE_LATENCY(REDUCE_LATENCY)) e1x1 (
    .clk(clk),
    .blank(1'b0),     // zero out, latency 1
        .d(sig1), 
    .c(sig1x1) 
);

crc32_z64_xn #(.NUM_EVOS(2),.TARGET_CHIP(TARGET_CHIP),.REDUCE_LATENCY(REDUCE_LATENCY)) e0x2 (
    .clk(clk),
    .blank(1'b0),     // zero out, latency 1
        .d(sig0), 
    .c(sig0x2) 
);

////////////////////////////////////////
// components of stopping short of #2
////////////////////////////////////////

wire  [31:0] sig0x1;

crc32_z64_xn #(
    .NUM_EVOS(1),.TARGET_CHIP(TARGET_CHIP),.REDUCE_LATENCY(REDUCE_LATENCY)
) e0x1 (
    .clk(clk),
    .blank(1'b0),     // zero out, latency 1
        .d(sig0), 
    .c(sig0x1) 
);

// pipe regs for no evolution
reg [31:0] sig3x0 = 0, sig2x0 = 0, sig1x0 = 0, sig0x0 = 0;
reg [31:0] sig3d = 0, sig2d = 0, sig1d = 0, sig0d = 0;

always @(posedge clk) begin
        sig3d <= sig3;
        sig2d <= sig2;
        sig1d <= sig1;
        sig0d <= sig0;
        sig3x0 <= REDUCE_LATENCY ? sig3 : sig3d;
        sig2x0 <= REDUCE_LATENCY ? sig2 : sig2d;
        sig1x0 <= REDUCE_LATENCY ? sig1 : sig1d;
        sig0x0 <= REDUCE_LATENCY ? sig0 : sig0d;
end

/////////////////////////////////////////////
// combine evolved sigs
/////////////////////////////////////////////

reg [31:0] full = 0,s1 = 0,s2 = 0,s3 = 0,e0 = 0,e1 = 0,e2 = 0;

always @(posedge clk) begin
        full <= sig0x3 ^ sig1x2 ^ sig2x1 ^ sig3x0;  

        s1 <= sig1x2 ^ sig2x1 ^ sig3x0;
        s2 <= sig2x1 ^ sig3x0;
        s3 <= sig3x0;

        e0 <= sig0x0;
        e1 <= sig0x1 ^ sig1x0;
        e2 <= sig0x2 ^ sig1x1 ^ sig2x0;
end


////////////////////////////////
// deliver start_idx

reg [WORDS-1:0] din_first_data_r = 0;
always @(posedge clk) begin
        din_first_data_r <= din_first_data;
end

// start decoding the positions
// there should never be more than one first, but if there are anyway 
// go with the rightmost
reg [2:0] dstart = 0;
always @(posedge clk) begin
        if (din_first_data_r[0]) dstart <= 3'h4;
        else if (din_first_data_r[1]) dstart <= 3'h3;
        else if (din_first_data_r[2]) dstart <= 3'h2;
        else if (din_first_data_r[3]) dstart <= 3'h1;
        else dstart <= 3'h0;    
end

// wait
wire [2:0] start_idx;
delay_regs dr1 (
        .clk(clk),
        .din(dstart),
        .dout(start_idx)
);
defparam dr1 .WIDTH = 3;
defparam dr1 .LATENCY = REDUCE_LATENCY ? 2 : 3;


/////////////////////////////
// deliver end_idx

reg [WORDS*8-1:0] din_last_data_r = 0;
always @(posedge clk) begin
        din_last_data_r <= din_last_data;
end

reg [WORDS-1:0] dlast_or = 0;
reg [WORDS*8-1:0] din_last_data_rr = 0;
always @(posedge clk) begin
        dlast_or[0] <= |din_last_data_r[7:0];
        dlast_or[1] <= |din_last_data_r[15:8];
        dlast_or[2] <= |din_last_data_r[23:16];
        dlast_or[3] <= |din_last_data_r[31:24];
        din_last_data_rr <= din_last_data_r;
end

reg [2:0] dlast = 3'h6 /* synthesis preserve */;
reg [7:0] residue_mask = 0;

always @(posedge clk) begin
        if (dlast_or[3]) begin
                dlast <= 3'h1;
                residue_mask <= din_last_data_rr[31:24];        
        end
        else if (dlast_or[2]) begin
                dlast <= 3'h2;
                residue_mask <= din_last_data_rr[23:16];        
        end
        else if (dlast_or[1]) begin
                dlast <= 3'h3;
                residue_mask <= din_last_data_rr[15:8];
        end     
        else if (dlast_or[0]) begin
                dlast <= 3'h4;
                residue_mask <= din_last_data_rr[7:0];
        end
        else begin
                dlast <= 3'h5;  
                residue_mask <= 0;
        end
end

// wait
wire [2:0] end_idx;
delay_regs dr2 (
        .clk(clk),
        .din(dlast),
        .dout(end_idx)
);
defparam dr2 .WIDTH = 3;
defparam dr2 .LATENCY = REDUCE_LATENCY ? 1 : 2;

/////////////////////////////
// deliver roll back

reg [2:0] roll = 3'b0;
reg [7:0] residue_mask_r = 8'b0;
always @(posedge clk) begin
        residue_mask_r <= residue_mask; 
end

reg [2:0] pre_roll = 3'b0, pre2_roll = 3'b0, pre3_roll = 3'b0;
always @(posedge clk) begin
        pre3_roll <= residue_mask_r[7] ? 3'h7 :
                        residue_mask_r[6] ? 3'h6 :
                        residue_mask_r[5] ? 3'h5 :
                        residue_mask_r[4] ? 3'h4 :
                        residue_mask_r[3] ? 3'h3 :
                        residue_mask_r[2] ? 3'h2 :
                        residue_mask_r[1] ? 3'h1 :
                        3'h0;                           
        pre2_roll <= pre3_roll;
        pre_roll <= REDUCE_LATENCY ? pre3_roll : pre2_roll;
        roll <= pre_roll;
end

/////////////////////////////////////////////
// select appro factors, deferring the prev
/////////////////////////////////////////////

reg [31:0] start_term = 0, end_term = 0;

reg incl_prev = 0;
reg [2:0] last_end_idx = 3'h5 /* synthesis preserve */;

always @(posedge clk) begin
        case (start_idx) 
                // the funny constants are evolved 0xffffffff init states
                3'h0 : start_term <= full;  // all the data, including prev
                3'h1 : start_term <= full ^ 32'h4a55af67; // all the data, not including prev
                3'h2 : start_term <= s1 ^ 32'hfbac7c3a;  // skip the 1st data word...
                3'h3 : start_term <= s2 ^ 32'h552d22c8;
                3'h4 : start_term <= s3 ^ 32'h6904bb59; // just the final data word
                3'h5 : start_term <= 32'hffffffff;      
                3'h6 : start_term <= 32'hffffffff;
                3'h7 : start_term <= 32'hffffffff;              
        endcase

        case (end_idx) 
                3'h0 : end_term <= 32'h0; // exactly the prev - this isn't used
                3'h1 : end_term <= e0; // prev with first data
                3'h2 : end_term <= e1; //   1st and 2nd data
                3'h3 : end_term <= e2; // 
                3'h4 : end_term <= full; // prev with all data (and this is the end)
                3'h5 : end_term <= full; // prev with all data (and not stopping)
                3'h6 : end_term <= 0;           
                3'h7 : end_term <= 0;           
        endcase
        
        incl_prev <= ~|start_idx;
        last_end_idx <= end_idx;
end

// bring the valid down to here
wire start_term_valid;
delay_regs dr0 (
        .clk(clk),
        .din(din_valid),
        .dout(start_term_valid)
); 
defparam dr0 .WIDTH = 1;
//defparam dr0 .LATENCY = REDUCE_LATENCY ? 5 : 6; // MPE's fix, not right for ultra
defparam dr0 .LATENCY = REDUCE_LATENCY ? 4 : 5;

/////////////////////////////////////////////
// CRC accumulator 
/////////////////////////////////////////////

reg [31:0] prev_crc = 0;
wire [31:0] prev_x1_r,prev_x2_r,prev_x3_r,prev_x4;
reg [31:0] prev_x0_r = 0;

//////////////////////////////////
// evolutions of the previous CRC

crc32_z64_x1 p1 (
    .clk(clk),
    .ena(1'b1),
        .pc(prev_crc), 
    .c(prev_x1_r) 
);

crc32_z64_x2 p2 (
    .clk(clk),
    .ena(1'b1),
        .pc(prev_crc), 
    .c(prev_x2_r) 
);

crc32_z64_x3 p3 (
    .clk(clk),
    .ena(1'b1),
        .pc(prev_crc), 
    .c(prev_x3_r) 
);

// the max distance evo is unregistered
crc32_z64_x4 p4 (
    .pc(prev_crc), 
    .c(prev_x4) 
);

reg [31:0] last_end_term = 0;
reg [2:0] last2_end_idx = 3'h5 /* synthesis preserve */;
reg [31:0] prev_x4_r = 0;

always @(posedge clk) begin
        if (start_term_valid) begin
                // crc accum register
                prev_crc <= (incl_prev ? prev_x4 : 32'h0) ^ start_term;
        end
end

always @(posedge clk) begin
        prev_x0_r <= prev_crc;  
        prev_x4_r <= prev_x4;
        
        // zero this out when not needed for power / sanity
        last_end_term <= (last_end_idx == 3'h5) ? 32'h0 : end_term;
        last2_end_idx <= last_end_idx;          
end

/////////////////////////////////////////////
// combine the output CRC
//   evolved up to 7 bytes of 0 too far 
/////////////////////////////////////////////

reg [31:0] within_7_crc = 0;
reg [31:0] prev_part;

always @(*) begin
        case (last2_end_idx)
                3'h0 : prev_part = prev_x0_r; // exactly the prev
                3'h1 : prev_part = prev_x1_r; // prev with first data
                3'h2 : prev_part = prev_x2_r; 
                3'h3 : prev_part = prev_x3_r; 
                3'h4 : prev_part = prev_x4_r; 
                3'h5 : prev_part = 32'h0; 
                3'h6 : prev_part = 32'h0; 
                3'h7 : prev_part = 32'h0;               
        endcase
end

wire prev_part_valid;
delay_regs dr7 (
        .clk(clk),
        .din(start_term_valid),
        .dout(prev_part_valid)
); 
defparam dr7 .WIDTH = 1;
//defparam dr7 .LATENCY = 1; // MPE's fix, nor right for ultra
defparam dr7 .LATENCY = 2;


reg within_7_valid = 0;
always @(posedge clk) begin
        within_7_crc <= (prev_part ^ last_end_term);
        within_7_valid <= (last2_end_idx != 3'h5) & prev_part_valid;    
end


///////////////////////////////////////////////
// finish off the byte roll

wire [31:0] real_crc;
crc32_byte_roll cbr (
    .clk(clk),
    .roll_bytes(roll),
    .pc(within_7_crc), // previous CRC
    .c(real_crc) 
);
defparam cbr .REDUCE_LATENCY = REDUCE_LATENCY;
defparam cbr .TARGET_CHIP = TARGET_CHIP;

delay_regs dr4 (
        .clk(clk),
        .din(within_7_valid),
        .dout(crc_valid)
);
defparam dr4 .WIDTH = 1;
defparam dr4 .LATENCY = REDUCE_LATENCY ? 3 : 6;

//////////////////////////////////////////////
// invert and reverse per Ethernet rules
//    just some wiring
//////////////////////////////////////////////

genvar i;
generate
        for (i=0; i<32; i=i+1) begin : inv_rev
                assign crc_out[31-i] = real_crc[i] ^ 1'b1;
        end
endgenerate 

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  3.0 LUTs
// BENCHMARK INFO :  Total registers : 1906
// BENCHMARK INFO :  Total pins : 7
// BENCHMARK INFO :  Total virtual pins : 320
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 2,790           ;       ;
// BENCHMARK INFO :  ALMs : 1,844 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.326 ns, From prev_crc[7], To crc32_z64_x1:p1|c[3]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.279 ns, From prev_crc[30]~DUPLICATE, To crc32_z64_x3:p3|c[16]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.391 ns, From prev_crc[5]~DUPLICATE, To prev_x4_r[25]}
