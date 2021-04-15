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


// ______________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/pma/e40_io_frame_40.v#3 $
// $Revision: #3 $
// $Date: 2016/09/13 $
// $Author: yhu $
// ______________________________________________________________________________
// baeckler - 08-28-2012


module e40_io_frame_40 #(
    parameter PHY_REFCLK  = 1,
    parameter RST_CNTR    = 16,                         // nominal 16/20  or 6 for fast simulation of reset seq
    parameter TARGET_CHIP = 2,                          // CHIP 2: Stratix 5; CHIP 5: Arria 10
                         
    //-----  KR4 parameters
    parameter ENA_KR4       = 0,
    parameter ES_DEVICE     = 1,                        // select ES or PROD device, 1 is ES-DEVICE, 0 is device
    parameter KR_ADDR_PAGE  = 0,
    parameter FAKE_TX_SKEW  = 1'b0,                     // skew the TX data for simulation
    parameter SYNTH_AN      = 1,                        // Synthesize/include the AN logic
    parameter SYNTH_LT      = 1,                        // Synthesize/include the LT logic
    parameter SYNTH_SEQ     = 1,                        // Synthesize/include Sequencer logic
    parameter SYNTH_FEC     = 1,                        // Synthesize/include the FEC logic

    //----- Sequencer parameters not used in the AN block
    parameter LINK_TIMER_KR = 504,                      // Link Fail Timer for BASE-R PCS in ms

    //----- LT parameters
    parameter BERWIDTH      = 10,                       // Width (>4) of the Bit Error counter
    parameter TRNWTWIDTH    = 7,                        // Width (7,8) of Training Wait counter
    parameter MAINTAPWIDTH  = 5,                        // Width of the Main Tap control
    parameter POSTTAPWIDTH  = 6,                        // Width of the Post Tap control
    parameter PRETAPWIDTH   = 5,                        // Width of the Pre Tap control
    parameter VMAXRULE      = 5'd30,                    // VOD+Post+Pre <= Device Vmax 1200mv
    parameter VMINRULE      = 5'd6,                     // VOD-Post-Pre >= Device VMin 165mv
    parameter VODMINRULE    = 5'd14,                    // VOD >= IEEE VOD Vmin of 440mV
    parameter VPOSTRULE     = 6'd25,                    // Post_tap <= VPOST
    parameter VPRERULE      = 5'd16,                    // Pre_tap <= VPRE
    parameter PREMAINVAL    = 5'd30,                    // Preset Main tap value
    parameter PREPOSTVAL    = 6'd0,                     // Preset Post tap value
    parameter PREPREVAL     = 5'd0,                     // Preset Pre tap value
    parameter INITMAINVAL   = 5'd25,                    // Initialize Main tap value
    parameter INITPOSTVAL   = 6'd22,                    // Initialize Post tap value
    parameter INITPREVAL    = 5'd3,                     // Initialize Pre tap value
    parameter USE_DEBUG_CPU = 0,                        // Use the Debug version of the CPU
 
   //-----AN parameters
    parameter AN_CHAN       = 4'b0001,                  // "master" channel to run AN on (one-hot)
    parameter AN_PAUSE      = 3'b011,                   // Initial setting for Pause ability, depends upon MAC  
    parameter AN_TECH       = 6'b00_1000,               // Tech ability, only 40G-KR4 valid
                                                        // bit-0 = GigE, bit-1 = XAUI
                                                        // bit-2 = 10G , bit-3 = 40G BP
                                                        // bit 4 = 40G-CR4, bit 5 = 100G-CR10
    parameter AN_SELECTOR      = 5'b0_0001,             // AN selector field 802.3 = 5'd1
    parameter CAPABLE_FEC      = 0,                     // FEC ability on power on
    parameter ENABLE_FEC       = 0,                     // FEC request on power on
    parameter ERR_INDICATION   = 0,                     // Turn error indication on/off

    //----- PHY parameters
    parameter REF_CLK_FREQ_10G  = "644.53125 MHz",      // speed for clk_ref
    parameter STATUS_CLK_KHZ    = 100000                // clk_status rate in Mhz

)(
    input pll_refclk,
    output [3:0] tx_pin,
    input [3:0] rx_pin,

    // status and control
    input status_clk,
    input sys_rst,
    input [3:0] sloop,
    input [2:0] flag_sel,
    output reg [3:0] flag_mx,
    output [3:0] tx_pll_lock_status,
    output [3:0] freq_lock,
    input set_data_lock,
    input set_ref_lock,
    output txa_online,
    output mgmt_rc_busy,
                                
    // serif for KR4
    input slave_din,
    output slave_dout,
    
    // data stream to TX pins
    input din_clk,
    input din_clk_ready,
    input [40*4-1:0] din,    // lsbit first serial streams
    input din_valid,
    input [66*4-1:0] din_66, // for fec
    input [3:0] din_66_valid,
    output tx_online,
    output clk_tx_io,
    
    // data stream from RX pins
    input dout_clk,         // clk rx main
    input dout_clk_ready,
    output [40*4-1:0] dout, // lsbit first serial streams
    input dout_req,
    output rx_online,
    output rx_aclr_pcs_ready,
    output clk_rx_recovered,
    input lanes_deskewed,
        
    // Arria 10 40g phy signals to the top
    input  wire [0:0]   reconfig_clk,        // reconfig_clk.clk
    input  wire [0:0]   reconfig_reset,      // reconfig_reset.reset
    input  wire [0:0]   reconfig_write,      // reconfig_avmm.write
    input  wire [0:0]   reconfig_read,       // .read
    input  wire [11:0]  reconfig_address,    // .address
    input  wire [31:0]  reconfig_writedata,  // .writedata
    output wire [31:0]  reconfig_readdata,   // .readdata
    output wire [0:0]   reconfig_waitrequest,// .waitrequest
    input [3:0]         tx_serial_clk,
    input               tx_pll_locked,
    
    input  wire [559:0] reconfig_to_xcvr,    // reconfig_to_xcvr.reconfig_to_xcvr
    output wire [367:0] reconfig_from_xcvr,  // reconfig_from_xcvr.reconfig_from_xcvr

    input  wire rx_backup //in clk_rx_main domain, after a RX sclr backup the FIFOs a little bit
);


   
// status and resets
wire pll_powerdown;
wire tx_analogreset;
wire tx_digitalreset;
wire rx_analogreset;
wire rx_digitalreset;
wire cal_busy;   
wire tx_cal_busy;
wire rx_cal_busy;
   
// data and clock
wire  [3:0]   tx_10g_data_valid;
wire  [3:0]   rx_10g_fifo_rd_en;
wire  [3:0]   rx_10g_fifo_align_clr = {4{1'b0}}; // this only works in some modes
wire  [3:0]   tx_10g_clkout;
wire  [3:0]   rx_10g_clkout;
wire  [3:0]   rx_10g_data_valid;
wire [40*4-1:0] rxd_wires;
reg [40*4-1:0] tx_launch = 0 /* synthesis preserve */;

assign clk_tx_io = tx_10g_clkout[2];
assign clk_rx_recovered = rx_10g_clkout[2];

// fifo status
wire [3:0] tx_full,tx_empty,tx_pfull,tx_pempty;
wire [3:0] rx_full,rx_empty,rx_pfull,rx_pempty;

wire txlock;

genvar i;
generate

//////////////////////////////////////////////////////////////////////////////////////////////////
//   Arria 10 KR Generation   
//////////////////////////////////////////////////////////////////////////////////////////////////    
   
if (TARGET_CHIP == 5 && ENA_KR4) begin // Arria 10 KR4

    // serif slave for KR4 registers
    wire ss1_wr, ss1_rd;
    wire [7:0] ss1_addr;
    wire [31:0] ss1_wdata;
    wire [31:0] ss1_rdata;
    wire ss1_rdata_valid;

    serif_slave ss1 (
        .clk(status_clk),
        .din(slave_din),
        .dout(slave_dout),
        .wr(ss1_wr),
        .rd(ss1_rd),
        .addr(ss1_addr),
        .wdata(ss1_wdata),
        .rdata(ss1_rdata),
        .rdata_valid(ss1_rdata_valid)
    );
    defparam ss1 .ADDR_PAGE = KR_ADDR_PAGE;
    
    wire [4-1:0]    tx_10g_coreclkin;
    wire [4-1:0]    rx_10g_coreclkin;
    
    wire [40*4-1:0] rx_dataout;
    reg  [40*4-1:0] rxd_wires_2             /* synthesis preserve */;
    reg  [40*4-1:0] tx_launch_2 = 0         /* synthesis preserve */;
    reg  [3:0]      tx_10g_data_valid_2     /* synthesis preserve */;
    
    reg  [66*4-1:0] tx_fec_launch = 0       /* synthesis preserve */;
    reg  [3:0]      tx_fec_data_valid = 0   /* synthesis preserve */;
    reg  [66*4-1:0] tx_fec_launch_2 = 0     /* synthesis preserve */;
    reg  [3:0]      tx_fec_data_valid_2 = 0 /* synthesis preserve */;
    
    if(SYNTH_FEC) begin
        always @(posedge din_clk) begin
            tx_fec_launch <= din_66;
            tx_fec_data_valid <= din_66_valid;
        end
    end
    
    // pipeline with post-clock-mux
    for (i=0; i<4; i=i+1) begin : POST_MUX_PIPE
        always @(posedge tx_10g_coreclkin[i]) begin
            tx_launch_2[i*40 +: 40] <= tx_launch[i*40 +: 40];
            tx_10g_data_valid_2[i] <= tx_10g_data_valid[i];
        end
        if(SYNTH_FEC) begin
            always @(posedge din_clk) begin
                tx_fec_launch_2[i*66 +: 66] <= tx_fec_launch[i*66 +: 66];
                tx_fec_data_valid_2[i] <= tx_fec_data_valid[i];
            end
        end
        // compensated for by EARLY_REQ
          always @(posedge dout_clk) begin
            rxd_wires_2[i*40 +: 40] <= rx_dataout[i*40 +: 40];
        end
    end
    
    
    assign rxd_wires = rxd_wires_2;
    
    wire tx_ready, rx_ready;
    wire clk_rx_ready_s, clk_tx_ready_s;
    
    alt_aeu_40_pma_a10_kr4 pma (
        .pma_arst(sys_rst),                     // asynchronous reset for native PHY reset controllers & CSRs
        .usr_an_lt_reset(sys_rst),
        .usr_seq_reset(sys_rst),
        .clk_status(status_clk),                // management/csr clock (for status_ bus)
        .tx_serial_clk_10g(tx_serial_clk),      // high speed serial clock0
        .rx_cdr_ref_clk_10g(pll_refclk),        // cdr_ref_clk
        
        // to high speed IO pins
        .rx_serial(rx_pin),
        .tx_serial(tx_pin),
        
        // 40 bit data words on clk_tx
        .clk_tx(din_clk),                       // tx parallel data clock
        .tx_ready(tx_ready),                    // tx clocks stable (sync to clk_status)
        .tx_pll_lock(tx_pll_locked),            // plls locked (async signal)
        .tx_datain(tx_launch_2),
        .tx_fec_datain(tx_fec_launch_2),
        
        // 40 bit data words on clk_rx
        .clk_rx(dout_clk),                      // rx parallel data clock
        .rx_ready(rx_ready),                    // rx clocks stable (sync to clk_status)
        .rx_cdr_lock(freq_lock),                // cdr locked (async signal)
        .rx_dataout(rx_dataout),
        .lanes_deskewed(lanes_deskewed & rx_ready), // indicates RX lock in 40G data mode
        
        // raw hssi out (kr4 uses div33 clock because fec uses 64-bit pma not 40-bit)
        .tx_10g_clk33out(tx_10g_clkout),
        .rx_10g_clk33out(rx_10g_clkout),
        
        .tx_10g_coreclkin(tx_10g_coreclkin),
        .rx_10g_coreclkin(rx_10g_coreclkin),
        
        // fpll lock signals (sync to clk_status)
        .clk_rx_ready(clk_rx_ready_s),
        .clk_tx_ready(clk_tx_ready_s),
        
        // ultra access to hssi
        .tx_valid(tx_10g_data_valid_2[3:0]),
        .tx_fec_valid(tx_fec_data_valid_2[3:0]),
        .rx_rd_en(rx_10g_fifo_rd_en[3:0]),
        .rx_fifo_aclr(rx_10g_fifo_align_clr[3:0]),
        .rx_seriallpbken(sloop[3:0]),
        
        .tx_full(tx_full[3:0]),
        .tx_pfull(tx_pfull[3:0]),
        .tx_empty(tx_empty[3:0]),
        .tx_pempty(tx_pempty[3:0]),
        .rx_full(rx_full[3:0]),
        .rx_pfull(rx_pfull[3:0]),
        .rx_empty(rx_empty[3:0]),
        .rx_pempty(rx_pempty[3:0]),
        
        .set_lock_data(set_data_lock),
        .set_lock_ref(set_ref_lock),
        
        .tx_analogreset(tx_analogreset),
        .mgmt_rc_busy(mgmt_rc_busy),
        
        // avalon_mm (on clk_status)
        .status_read(ss1_rd),
        .status_write(ss1_wr),
        .status_addr(ss1_addr),
        .status_readdata(ss1_rdata),
        .status_writedata(ss1_wdata),
        .status_readdata_valid(ss1_rdata_valid),
        
        // hssi reconfig access (on clk_status, NOT reconfig_clk!!!)
        //.reconfig_clk(reconfig_clk),                  // input  wire [0:0]   
        .reconfig_reset(reconfig_reset),                // input  wire [0:0]   
        .reconfig_write(reconfig_write),                // input  wire [0:0]   
        .reconfig_read(reconfig_read),                  // input  wire [0:0]   
        .reconfig_address(reconfig_address),            // input  wire [11:0]  
        .reconfig_writedata(reconfig_writedata),        // input  wire [31:0]  
        .reconfig_readdata(reconfig_readdata),          // output wire [31:0]  
        .reconfig_waitrequest(reconfig_waitrequest)     // output wire [0:0]   


    );
         defparam pma.ES_DEVICE     = ES_DEVICE;
         defparam pma.FAKE_TX_SKEW      = FAKE_TX_SKEW;
         defparam pma.SYNTH_AN          = SYNTH_AN;
         defparam pma.SYNTH_LT          = SYNTH_LT;
         defparam pma.SYNTH_SEQ         = SYNTH_SEQ;
         defparam pma.SYNTH_FEC         = SYNTH_FEC;
         defparam pma.LINK_TIMER_KR     = LINK_TIMER_KR;
         defparam pma.BERWIDTH          = BERWIDTH;
         defparam pma.TRNWTWIDTH        = TRNWTWIDTH;
         defparam pma.MAINTAPWIDTH      = MAINTAPWIDTH;
         defparam pma.POSTTAPWIDTH      = POSTTAPWIDTH;
         defparam pma.PRETAPWIDTH       = PRETAPWIDTH;
         defparam pma.VMAXRULE          = VMAXRULE;
         defparam pma.VMINRULE          = VMINRULE;
         defparam pma.VODMINRULE        = VODMINRULE;
         defparam pma.VPOSTRULE         = VPOSTRULE;
         defparam pma.VPRERULE          = VPRERULE;
         defparam pma.PREMAINVAL        = PREMAINVAL;
         defparam pma.PREPOSTVAL        = PREPOSTVAL;
         defparam pma.PREPREVAL         = PREPREVAL;
         defparam pma.INITMAINVAL       = INITMAINVAL;
         defparam pma.INITPOSTVAL       = INITPOSTVAL;
         defparam pma.INITPREVAL        = INITPREVAL;
         defparam pma.USE_DEBUG_CPU     = USE_DEBUG_CPU;
         defparam pma.AN_CHAN           = AN_CHAN;
         defparam pma.AN_PAUSE          = AN_PAUSE;
         defparam pma.AN_TECH           = AN_TECH;
         defparam pma.AN_SELECTOR       = AN_SELECTOR;
         defparam pma.CAPABLE_FEC       = CAPABLE_FEC;
         defparam pma.ENABLE_FEC        = ENABLE_FEC;
         defparam pma.ERR_INDICATION    = ERR_INDICATION;
         defparam pma.MGMT_CLK_IN_KHZ   = STATUS_CLK_KHZ;
         defparam pma.REF_CLK_FREQ_10G  = REF_CLK_FREQ_10G;
         
    assign tx_pll_lock_status = {4{tx_pll_locked}};
    assign txa_online = !tx_analogreset;
    
    sync_regs sr0 (
        .clk(din_clk),
        .din(tx_ready),
        .dout(tx_online)
    );
    defparam sr0 .WIDTH = 1;
    
    sync_regs sr1 (
        .clk(dout_clk),
        .din(rx_ready),
        .dout(rx_online)
    );
    defparam sr1 .WIDTH = 1;
   
   aclr_filter f1(   // synchronizing deassertion
        .clk(dout_clk),
        .aclr(!rx_ready),
        .aclr_sync(rx_aclr_pcs_ready)
   );


    reset_delay rd0 (
        .clk(status_clk),
        .ready_in(din_clk_ready),
        .ready_out(clk_tx_ready_s)
    );
    defparam rd0 .CNTR_BITS = RST_CNTR;
    
    reset_delay rd1 (
        .clk(status_clk),
        .ready_in(dout_clk_ready),
        .ready_out(clk_rx_ready_s)
    );
    defparam rd1 .CNTR_BITS = RST_CNTR;

end // A10 KR4
   
//////////////////////////////////////////////////////////////////////////////////////////////////
//   Stratix V Generation   
//////////////////////////////////////////////////////////////////////////////////////////////////    
else if (TARGET_CHIP == 2) begin // Stratix V
    s5_40bit_4pack #(
        .PHY_REFCLK (PHY_REFCLK)
    ) fp (
        .pll_refclk(pll_refclk),
        
        .pll_pd(pll_powerdown),
        .rst_txa(tx_analogreset),
        .rst_txd(tx_digitalreset),
        .rst_rxa(rx_analogreset),
        .rst_rxd(rx_digitalreset),
        .tx_pll_locked(txlock),

        .tx_clkout(tx_10g_clkout[3:0]),
        .rx_clkout(rx_10g_clkout[3:0]),
        .clk_tx_common(din_clk),
        .clk_rx_common(dout_clk),
                        
        .tx_pin(tx_pin[3:0]),
        .rx_pin(rx_pin[3:0]),

        .tx_din(tx_launch[4*40-1:0]),
        .rx_dout(rxd_wires[4*40-1:0]),
        
        .tx_valid(tx_10g_data_valid[3:0]),
        .rx_ready(rx_10g_fifo_rd_en[3:0]),
        .rx_fifo_aclr(rx_10g_fifo_align_clr[3:0]),
        .rx_bitslip(4'b0),
        .rx_valid(),
        .rx_datalocked(freq_lock[3:0]),
        .rx_seriallpbken(sloop[3:0]),
                                
        .tx_full(tx_full[3:0]),
        .tx_pfull(tx_pfull[3:0]),
        .tx_empty(tx_empty[3:0]),
        .tx_pempty(tx_pempty[3:0]),
        .rx_full(rx_full[3:0]),
        .rx_pfull(rx_pfull[3:0]),
        .rx_empty(rx_empty[3:0]),
        .rx_pempty(rx_pempty[3:0]),

        .tx_cal_busy(tx_cal_busy),      
        .rx_cal_busy(rx_cal_busy),
              
        .set_lock_data(set_data_lock),
        .set_lock_ref(set_ref_lock),
        .reconfig_to_xcvr(reconfig_to_xcvr),
        .reconfig_from_xcvr(reconfig_from_xcvr) 
    );
    assign tx_pll_lock_status = {4{txlock}};
    assign slave_dout = 1'b1;
    assign mgmt_rc_busy = 1'b0;
end //Stratix V

//////////////////////////////////////////////////////////////////////////////////////////////////
//   Arria10-none KR Generation   
//////////////////////////////////////////////////////////////////////////////////////////////////       
else if (TARGET_CHIP == 5) begin // Arria 10
    a10_40bit_4pack # (
        .PHY_REFCLK (PHY_REFCLK)
    ) fp (
        .pll_refclk(pll_refclk),
        
        .pll_pd(pll_powerdown),
        .rst_txa(tx_analogreset),
        .rst_txd(tx_digitalreset),
        .rst_rxa(rx_analogreset),
        .rst_rxd(rx_digitalreset),

        .tx_clkout(tx_10g_clkout[3:0]),
        .rx_clkout(rx_10g_clkout[3:0]),
        .clk_tx_common(din_clk),
        .clk_rx_common(dout_clk),
                        
        .tx_pin(tx_pin[3:0]),
        .rx_pin(rx_pin[3:0]),

        .tx_din(tx_launch[4*40-1:0]),
        .rx_dout(rxd_wires[4*40-1:0]),
        
        .tx_valid(tx_10g_data_valid[3:0]),
        .rx_ready(rx_10g_fifo_rd_en[3:0]),
        .rx_fifo_aclr(rx_10g_fifo_align_clr[3:0]),
        .rx_bitslip(4'b0),
        .rx_valid(),
        .rx_datalocked(freq_lock[3:0]),
        .rx_seriallpbken(sloop[3:0]),
                                
        .tx_full(tx_full[3:0]),
        .tx_pfull(tx_pfull[3:0]),
        .tx_empty(tx_empty[3:0]),
        .tx_pempty(tx_pempty[3:0]),
        .rx_full(rx_full[3:0]),
        .rx_pfull(rx_pfull[3:0]),
        .rx_empty(rx_empty[3:0]),
        .rx_pempty(rx_pempty[3:0]),

        .tx_cal_busy(tx_cal_busy),
        .rx_cal_busy(rx_cal_busy),
        
        .reconfig_clk(reconfig_clk),                    // input  wire [0:0]   
        .reconfig_reset(reconfig_reset),                // input  wire [0:0]   
        .reconfig_write(reconfig_write),                // input  wire [0:0]   
        .reconfig_read(reconfig_read),                  // input  wire [0:0]   
        .reconfig_address(reconfig_address),            // input  wire [11:0]  
        .reconfig_writedata(reconfig_writedata),        // input  wire [31:0]  
        .reconfig_readdata(reconfig_readdata),          // output wire [31:0]  
        .reconfig_waitrequest(reconfig_waitrequest),    // output wire [0:0]   
        .tx_serial_clk(tx_serial_clk),

        .set_lock_data(set_data_lock),
        .set_lock_ref(set_ref_lock)     
    );
    assign tx_pll_lock_status = {4{tx_pll_locked}};
    assign slave_dout = 1'b1;
    assign reconfig_from_xcvr = 368'd0;
end
endgenerate
                
                
////////////////////////////////////////////
// data pipes
////////////////////////////////////////////

reg [3:0] tx_valid = 0 /* synthesis preserve */;

// always @(negedge din_clk) begin

always @(posedge din_clk) begin
        tx_launch <= din;
        tx_valid <= {4{din_valid}};
end
assign tx_10g_data_valid = tx_valid;

reg [40*4-1:0] rx_capture = 0;
reg [3:0] rx_req = 0 /* synthesis preserve */;

always @(posedge dout_clk) begin
        rx_capture <= rxd_wires;        
end

always @(posedge dout_clk) begin
	rx_req <= {4{dout_req}};
end


assign rx_10g_fifo_rd_en = rx_req;
assign  dout = rx_capture;

////////////////////////////////////////////
// combine some of the flags
////////////////////////////////////////////
   
reg [9:0] flag_mx_meta = 0 /* synthesis preserve dont_replicate */
        /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *io_frame*flag_mx_meta\[*\]]\" " */;

always @(posedge status_clk) begin
        case (flag_sel)
                3'h0 : flag_mx_meta <= tx_full;
                3'h1 : flag_mx_meta <= tx_empty;
                3'h2 : flag_mx_meta <= tx_pfull;
                3'h3 : flag_mx_meta <= tx_pempty;
                3'h4 : flag_mx_meta <= rx_full;
                3'h5 : flag_mx_meta <= rx_empty;
                3'h6 : flag_mx_meta <= rx_pfull;
                3'h7 : flag_mx_meta <= rx_pempty;
        endcase
        flag_mx <= flag_mx_meta[3:0];
end

////////////////////////////////////////////
// reset control: for NONE_KR4
////////////////////////////////////////////
   
generate
if (TARGET_CHIP != 5 || !ENA_KR4) //A10 kr4 does its own reset control 
begin

    // FSM for Rx FIFO health moniter    
    localparam               
              ST_FIFO_DEAD          = 2'd0,
              ST_FIFO_PURGING       = 2'd1,
              ST_FIFO_GRACE_PERIOD  = 2'd2,
              ST_FIFO_HEALTHY       = 2'd3; 
    
    reg [1:0]  state_r = 2'd0 /* synthesis preserve */;     
    reg [1:0]  state_nx       /* synthesis preserve */;    
    wire rx_fifo_bad          /* synthesis preserve */;
    wire rx_full_1bit_s;
    wire rx_empty_1bit_s;   


    assign cal_busy = tx_cal_busy | rx_cal_busy;
    wire rd0_ready;
    reset_delay rd0 (
            .clk(status_clk),
            .ready_in((!sys_rst) & (!cal_busy)),
            .ready_out(rd0_ready)
    );
    defparam rd0 .CNTR_BITS = RST_CNTR;
    assign pll_powerdown = !sys_rst && !rd0_ready && (!cal_busy);
    
    wire rd1_ready;
    reset_delay rd1 (
            .clk(status_clk),
            .ready_in(rd0_ready & (&tx_pll_lock_status)),
            .ready_out(rd1_ready)
    );
    defparam rd1 .CNTR_BITS = RST_CNTR;
    assign tx_analogreset = !rd1_ready & (!cal_busy); //no analog reset when cal_busy
    assign txa_online = !tx_analogreset;
    
    wire rd2_ready;
    reset_delay rd2 (
            .clk(status_clk),
            .ready_in(rd1_ready),
            .ready_out(rd2_ready)
    );
    defparam rd2 .CNTR_BITS = RST_CNTR;
    assign rx_analogreset = (!rd2_ready) & (!cal_busy) ; //no analog reset when cal_busy
    
    wire rd3_ready;
    reset_delay rd3 (
            .clk(status_clk),
        .ready_in(rd2_ready & din_clk_ready),
            .ready_out(rd3_ready)
    );
    defparam rd3 .CNTR_BITS = RST_CNTR;
    assign tx_digitalreset = !rd3_ready;
    
    wire rd4_ready;
    reset_delay rd4 (
            .clk(status_clk),
            .ready_in(rd3_ready & (&freq_lock) & dout_clk_ready  & (~rx_fifo_bad)),
            .ready_out(rd4_ready)
    );
    defparam rd4 .CNTR_BITS = RST_CNTR;
    assign rx_digitalreset = !rd4_ready;
    
    sync_regs sr0 (
            .clk(din_clk),
            .din(!tx_digitalreset),
            .dout(tx_online)
    );
    defparam sr0 .WIDTH = 1;
    
    sync_regs sr1 (
            .clk(dout_clk),
            .din(!rx_digitalreset),
            .dout(rx_online)
    );
    defparam sr1 .WIDTH = 1;

   aclr_filter f1(   // synchronizing deassertion
        .clk(dout_clk),
        .aclr(rx_digitalreset),
        .aclr_sync(rx_aclr_pcs_ready)
   );

    sync_regs sr2 (
            .clk(dout_clk),
            .din ({|rx_full,       |rx_empty      }),
            .dout({rx_full_1bit_s, rx_empty_1bit_s})
    );
    defparam sr2 .WIDTH = 2;

   //////////////////////////////////////////////
   // FSM - Rx PCS FIFO Flush 
   //       when overflow/underflow (full/empty) 
   //////////////////////////////////////////////
   always@(posedge dout_clk)begin
       state_r <= state_nx;
   end
   
   //state only
   always@(*)begin
     state_nx = state_r;
   
     if (!rx_online) state_nx = ST_FIFO_DEAD;
     else begin 
       case(state_r)
         ST_FIFO_DEAD:         if (rx_online)  state_nx = ST_FIFO_PURGING;
         ST_FIFO_PURGING:                      state_nx = ST_FIFO_GRACE_PERIOD;
         ST_FIFO_GRACE_PERIOD: if (!rx_backup) state_nx = ST_FIFO_HEALTHY;
         ST_FIFO_HEALTHY:      if(rx_full_1bit_s | rx_empty_1bit_s) state_nx = ST_FIFO_DEAD;     
       endcase // case (state_r)
     end   
   end
   
   //output
   assign rx_fifo_bad = (state_r == ST_FIFO_HEALTHY) & (rx_full_1bit_s | rx_empty_1bit_s);

end // if !ENA_KR4
endgenerate

endmodule
    
    
