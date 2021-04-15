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


// (C) 2001-2015 Altera Corporation. All rights reserved.
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


// baeckler - 08-31-2012

module alt_aeu_40_pcs_assembly #(
    parameter TARGET_CHIP = 2,
    parameter PHY_REFCLK = 1,
    parameter SYNOPT_PTP = 0,
    parameter PTP_LATENCY = 52,
    parameter SYNOPT_FULL_SKEW = 0,
    parameter EN_LINK_FAULT = 0,
    parameter WORDS = 2,                   // no override
    parameter NUM_VLANE = 4,               // no override
    parameter ADDR_PAGE = 8'h1,            
    parameter REVID = 32'h04012014,        
    parameter SIM_FAKE_JTAG = 1'b0,        
    parameter AM_CNT_BITS = 14,            // nominal 14, 6 Ok for sim
    parameter RST_CNTR = 16,               // nominal 16/20  or 6 for fast simulation of reset seq
    parameter CREATE_TX_SKEW = 1'b0,       // debbug - insert TX side lane skew 
    parameter TIMING_MODE = 1'b0,          
    parameter EXT_TX_PLL = 1'b0,           // whether to use external fpll for TX core clocks
    //  KR4 parameters
    parameter ENA_KR4       = 0,
    parameter ES_DEVICE     = 1,            // select ES or PROD device, 1 is ES-DEVICE, 0 is device
    parameter KR_ADDR_PAGE  = 0,
    parameter SYNTH_AN      = 1,           // Synthesize/include the AN logic
    parameter SYNTH_LT      = 1,           // Synthesize/include the LT logic
    parameter SYNTH_SEQ     = 1,           // Synthesize/include Sequencer logic
    parameter SYNTH_FEC     = 1,           // Synthesize/include the FEC logic
    // Sequencer parameters not used in the AN block
    parameter LINK_TIMER_KR = 504,         // Link Fail Timer for BASE-R PCS in ms
    // LT parameters
    parameter BERWIDTH      = 10,          // Width (>4) of the Bit Error counter
    parameter TRNWTWIDTH    = 7,           // Width (7,8) of Training Wait counter
    parameter MAINTAPWIDTH  = 5,           // Width of the Main Tap control
    parameter POSTTAPWIDTH  = 6,           // Width of the Post Tap control
    parameter PRETAPWIDTH   = 5,           // Width of the Pre Tap control
    parameter VMAXRULE      = 5'd30,       // VOD+Post+Pre <= Device Vmax 1200mv
    parameter VMINRULE      = 5'd6,        // VOD-Post-Pre >= Device VMin 165mv
    parameter VODMINRULE    = 5'd14,       // VOD >= IEEE VOD Vmin of 440mV
    parameter VPOSTRULE     = 6'd25,       // Post_tap <= VPOST
    parameter VPRERULE      = 5'd16,       // Pre_tap <= VPRE
    parameter PREMAINVAL    = 5'd30,       // Preset Main tap value
    parameter PREPOSTVAL    = 6'd0,        // Preset Post tap value
    parameter PREPREVAL     = 5'd0,        // Preset Pre tap value
    parameter INITMAINVAL   = 5'd25,       // Initialize Main tap value
    parameter INITPOSTVAL   = 6'd22,       // Initialize Post tap value
    parameter INITPREVAL    = 5'd3,        // Initialize Pre tap value
    parameter USE_DEBUG_CPU = 0,           // Use the Debug version of the CPU
    // AN parameters
    parameter AN_CHAN       = 4'b0001,      // "master" channel to run AN on (one-hot)
    parameter AN_PAUSE      = 3'b011,       // Initial setting for Pause ability, depends upon MAC  
    parameter AN_TECH       = 6'b00_1000,   // Tech ability, only 40G-KR4 valid
                                            // bit-0 = GigE, bit-1 = XAUI
                                            // bit-2 = 10G , bit-3 = 40G BP
                                            // bit 4 = 40G-CR4, bit 5 = 100G-CR10
    parameter AN_SELECTOR      = 5'b0_0001, // AN selector field 802.3 = 5'd1
    parameter CAPABLE_FEC      = 0,         // FEC ability on power on
    parameter ENABLE_FEC       = 0,         // FEC request on power on
    parameter ERR_INDICATION   = 0,         // Turn error indication on/off
    // PHY parameters
    parameter REF_CLK_FREQ_10G  = "644.53125 MHz", // speed for clk_ref
    parameter STATUS_CLK_KHZ    = 100000           // clk_status rate in Mhz
)(
    input pll_ref,
    output [3:0] etx_pin,
    input [3:0] erx_pin,

    input RX_CORE_CLK,
    input TX_CORE_CLK,
    
    //Sync-E
    output clk_rx_recover,
    
    // status port
    input clk100,
    input rst100,               //global reset; async, no domain
    input slave_din,
    output slave_dout,

    // mii tx port
    input clk_txmac_in,         // used with EXT_TX_PLL, 312.5MHz derived from clk_ref
    output clk_tx_main,
    output srst_tx_main,
    output tx_lanes_stable,
    input tx_crc_ins_en,        // to be wired up (adubey 10.30.2013)
    input [WORDS*64-1:0] din_d, 
    input [WORDS*8-1:0] din_c, 
    output din_am,              // this din will be replaced with align marks
    output pre_din_am,          // leading indicator
                
    // mii rx port
    output clk_rx_main,
    output srst_rx_main,
    output reg rx_pcs_fully_aligned,
    output [WORDS*64-1:0] dout_d,
    output [WORDS*8-1:0] dout_c,
    //output [5*NUM_VLANE-1:0] wpos,
    output [9*NUM_VLANE-1:0] wpos,
    output dout_am,                             // dout is an alignment mark position, discard
    output [WORDS-1:0] tx_mii_start,            // to be wired up (adubey 10.30.2013)
    input  wire [0:0]   reconfig_clk,           // reconfig_clk.clk
    input  wire [0:0]   reconfig_reset,         // reconfig_reset.reset
    input  wire [0:0]   reconfig_write,         // reconfig_avmm.write
    input  wire [0:0]   reconfig_read,          // .read
    input  wire [11:0]  reconfig_address,       // .address
    input  wire [31:0]  reconfig_writedata,     // .writedata
    output wire [31:0]  reconfig_readdata,      // .readdata
    output wire [0:0]   reconfig_waitrequest,   // .waitrequest
    input [3:0]         tx_serial_clk,
    input               tx_pll_locked,
    
    input  wire [559:0] reconfig_to_xcvr,       // reconfig_to_xcvr.reconfig_to_xcvr
    output wire [367:0] reconfig_from_xcvr,     // reconfig_from_xcvr.reconfig_from_xcvr
    input  wire reconfig_busy
        
);
genvar i;

//////////////////////////////////////
// 4x10G pin array
//////////////////////////////////////

reg eio_sys_rst = 1'b0;
reg [3:0] eio_sloop = 4'b0;
reg [2:0] eio_flag_sel = 3'b0;
wire [3:0] eio_flags;
wire [3:0] eio_tx_pll_locked;
wire [3:0] eio_freq_lock;
wire rxp_lock, txp_lock;
reg set_data_lock = 1'b0;
reg set_ref_lock = 1'b0;


    
wire [4*40-1:0] eio_din, eio_dout, eio_din_sep, eio_dout_sep;
wire [4*66-1:0] eio_din_sep_66; // for fec
wire [3:0] eio_din_66_valid; // for fec
wire eio_din_valid;
wire [1:0] eio_dout_req;
wire eio_tx_online;
wire eio_rx_online;
wire eio_rx_soft_purge;
wire eio_rx_flush = !eio_rx_online | eio_rx_soft_purge;
wire clk_tx_io;
wire txa_online;
wire rx_hi_ber;
wire rx_hi_ber_raw;
wire rx_hi_ber_s;
   
wire rx_pcs_fully_aligned_raw;
wire rx_aclr_pcs_ready;
wire mgmt_rc_busy;

// reset syncer
wire rst_sync_sts; 
aclr_filter reset_syncer_sts(
        .aclr     (rst100), // global reset, async, no domain
        .clk      (clk100),     
        .aclr_sync(rst_sync_sts)
);
   
// synthesis translate_off
always @(posedge eio_tx_online) begin
        $display ("40G transmit IO now operating at time %d",$time);
end
always @(posedge eio_rx_online) begin
        $display ("40G receive IO now operating at time %d",$time);
end
// synthesis translate_on

// after a RX sclr backup the FIFOs a little bit
wire rx_backup;
reg post_flush = 1'b0;
reg last_eio_rx_flush = 1'b0;
always @(posedge clk_rx_main) begin
        last_eio_rx_flush <= eio_rx_flush;
        post_flush <= (last_eio_rx_flush && !eio_rx_flush);
end

grace_period_16 gp (
    .clk(clk_rx_main),
    .start_grace(post_flush),
    .grace(rx_backup)
);

defparam gp .TARGET_CHIP = TARGET_CHIP;

wire tx_10g_clk33out;
wire rx_pcs_fully_aligned_s;
wire slave_dout_kr4;
e40_io_frame_40 iof (
        .pll_refclk (pll_ref),
        .tx_pin(etx_pin),
        .rx_pin(erx_pin),

        // status and control
        .status_clk(clk100),
        .sys_rst(eio_sys_rst | rst_sync_sts | (rst100 && ENA_KR4 && (TARGET_CHIP==5))),
        .sloop(eio_sloop),
        .flag_sel(eio_flag_sel),
        .flag_mx(eio_flags),
        .tx_pll_lock_status(eio_tx_pll_locked),
        .freq_lock(eio_freq_lock),
        .set_data_lock(set_data_lock),
        .set_ref_lock(set_ref_lock),
        .txa_online(txa_online),
        .mgmt_rc_busy(mgmt_rc_busy),
                
    // serif for KR4
    .slave_din(slave_din),
    .slave_dout(slave_dout_kr4),
        // data stream to TX pins
        .din_clk(clk_tx_main),
        .din_clk_ready(txp_lock),
        .din(eio_din), // lsbit first serial streams
    .din_valid(eio_din_valid & eio_tx_online),
    .din_66(eio_din_sep_66), // for fec
    .din_66_valid(eio_din_66_valid & {4{eio_tx_online}}),
    .tx_online(eio_tx_online),
    .clk_tx_io(clk_tx_io),
    
    // data stream from RX pins
    .dout_clk(clk_rx_main),
    .dout_clk_ready(rxp_lock),
    .dout(eio_dout), // lsbit first serial streams
    .dout_req((eio_dout_req[0] | eio_rx_flush) & !rx_backup),
    .rx_online(eio_rx_online),
    .rx_aclr_pcs_ready(rx_aclr_pcs_ready),
    .clk_rx_recovered(clk_rx_recover),
    .lanes_deskewed(rx_pcs_fully_aligned_s),
        
    .reconfig_clk(reconfig_clk),                        // input  wire [0:0]   
    .reconfig_reset(reconfig_reset),                    // input  wire [0:0]   
    .reconfig_write(reconfig_write),                    // input  wire [0:0]   
    .reconfig_read(reconfig_read),                      // input  wire [0:0]   
    .reconfig_address(reconfig_address),                // input  wire [11:0]  
    .reconfig_writedata(reconfig_writedata),            // input  wire [31:0]  
    .reconfig_readdata(reconfig_readdata),              // output wire [31:0]  
    .reconfig_waitrequest(reconfig_waitrequest),        // output wire [0:0]   
    .tx_serial_clk(tx_serial_clk),
    .tx_pll_locked(tx_pll_locked),
    
    .reconfig_to_xcvr(reconfig_to_xcvr),
    .reconfig_from_xcvr(reconfig_from_xcvr),
    .rx_backup(rx_backup) 
);
defparam iof .RST_CNTR    = RST_CNTR;
defparam iof .TARGET_CHIP = TARGET_CHIP;
defparam iof .PHY_REFCLK  = PHY_REFCLK;
defparam iof.ENA_KR4       = ENA_KR4;
defparam iof.ES_DEVICE     = ES_DEVICE;
defparam iof.KR_ADDR_PAGE  = KR_ADDR_PAGE;
defparam iof.SYNTH_AN      = SYNTH_AN;
defparam iof.SYNTH_LT      = SYNTH_LT;
defparam iof.SYNTH_SEQ     = SYNTH_SEQ;
defparam iof.SYNTH_FEC     = SYNTH_FEC;
defparam iof.LINK_TIMER_KR = LINK_TIMER_KR;
defparam iof.BERWIDTH      = BERWIDTH;
defparam iof.TRNWTWIDTH    = TRNWTWIDTH;
defparam iof.MAINTAPWIDTH  = MAINTAPWIDTH;
defparam iof.POSTTAPWIDTH  = POSTTAPWIDTH;
defparam iof.PRETAPWIDTH   = PRETAPWIDTH;
defparam iof.VMAXRULE      = VMAXRULE;
defparam iof.VMINRULE      = VMINRULE;
defparam iof.VODMINRULE    = VODMINRULE;
defparam iof.VPOSTRULE     = VPOSTRULE;
defparam iof.VPRERULE      = VPRERULE;
defparam iof.PREMAINVAL    = PREMAINVAL;
defparam iof.PREPOSTVAL    = PREPOSTVAL;
defparam iof.PREPREVAL     = PREPREVAL;
defparam iof.INITMAINVAL   = INITMAINVAL;
defparam iof.INITPOSTVAL   = INITPOSTVAL;
defparam iof.INITPREVAL    = INITPREVAL;
defparam iof.USE_DEBUG_CPU = USE_DEBUG_CPU;
defparam iof.AN_CHAN       = AN_CHAN;
defparam iof.AN_PAUSE      = AN_PAUSE;
defparam iof.AN_TECH       = AN_TECH;
defparam iof.AN_SELECTOR   = AN_SELECTOR;
defparam iof.CAPABLE_FEC   = CAPABLE_FEC;
defparam iof.ENABLE_FEC    = ENABLE_FEC;
defparam iof.ERR_INDICATION = ERR_INDICATION;
defparam iof.STATUS_CLK_KHZ = STATUS_CLK_KHZ;
defparam iof.REF_CLK_FREQ_10G = REF_CLK_FREQ_10G;

//////////////////////////////////////
// analog reconfig
//////////////////////////////////////

reg [6:0] reco_addr = 7'h0;
reg reco_read = 1'b0;
reg reco_write = 1'b0;
reg [31:0] reco_wdata;
wire [31:0] reco_rdata;
assign reco_rdata = 32'b0;
 
// generate 
// if (TARGET_CHIP == 2) begin
        // e40_reco rc (
                // .reconfig_busy(reconfig_busy),             //      reconfig_busy.reconfig_busy
                // .mgmt_clk_clk(clk100),              //       mgmt_clk_clk.clk
                // .mgmt_rst_reset(rst100),            //     mgmt_rst_reset.reset
                // .reconfig_mgmt_address(reco_addr),     //      reconfig_mgmt.address
                // .reconfig_mgmt_read(reco_read),        //                   .read
                // .reconfig_mgmt_readdata(reco_rdata),    //                   .readdata
                // .reconfig_mgmt_waitrequest(), //                   .waitrequest
                // .reconfig_mgmt_write(reco_write),       //                   .write
                // .reconfig_mgmt_writedata(reco_wdata),   //                   .writedata
                // .reconfig_to_xcvr(eio_reconfig_to_xcvr),          //   reconfig_to_xcvr.reconfig_to_xcvr
                // .reconfig_from_xcvr(eio_reconfig_from_xcvr)         // reconfig_from_xcvr.reconfig_from_xcvr
        // );
// end
// endgenerate

//////////////////////////////////////
// MAC rate PLLs
//////////////////////////////////////

wire rxp_rst;
reg soft_rxp_rst = 1'b0;

reg rxp_ignore_freq = 1'b0;
wire rd4_ready;
reset_delay rd4 (
        .clk(clk100),
        .ready_in((&eio_freq_lock) | rxp_ignore_freq),
        .ready_out(rd4_ready)
);
defparam rd4 .CNTR_BITS = RST_CNTR;
assign rxp_rst = !rd4_ready;

wire txp_rst;
reg soft_txp_rst = 1'b0;

wire rd5_ready;
reset_delay rd5 (
        .clk(clk100),
        .ready_in(!soft_txp_rst),
        .ready_out(rd5_ready)
);
defparam rd5 .CNTR_BITS = RST_CNTR;
assign txp_rst = !rd5_ready;

generate
if (TIMING_MODE) begin
assign rxp_lock = 1'b1;
assign txp_lock = 1'b1;
assign clk_rx_main = RX_CORE_CLK;
assign clk_tx_main = TX_CORE_CLK;
end
else begin

if(ENA_KR4 && (TARGET_CHIP==5)) begin
e40_rx_pll_kr4 rxp (
                .refclk(clk_rx_recover),  
                .rst(rxp_rst & ~mgmt_rc_busy),     
                .outclk_0(clk_rx_main),
                .outclk_1(),   
                .locked(rxp_lock) 
);
end else begin
e40_rx_pll rxp (
                .refclk(clk_rx_recover),  
                .rst(rxp_rst),     
                .outclk_0(clk_rx_main),
                .outclk_1(),   
                .locked(rxp_lock) 
);
end

if(EXT_TX_PLL) begin
 assign txp_lock = 1'b1;
 assign clk_tx_main = clk_txmac_in;
end else begin
   if (PHY_REFCLK==1) begin : TX_PLL_644
     e40_tx_pll_644 txp (
                .refclk(pll_ref),  
                .rst(txp_rst),     
                .outclk_0(clk_tx_main),
                .outclk_1(),   
                .locked(txp_lock) 
     );
   end else begin : TX_PLL_322 
     e40_tx_pll_322 txp (
                .refclk(pll_ref),  
                .rst(txp_rst),     
                .outclk_0(clk_tx_main),
                .outclk_1(),   
                .locked(txp_lock) 
     );
   end 
end
end
endgenerate

//////////////////////////////////////////////
// clock monitor
//////////////////////////////////////////////

wire [19:0] khz_ref,khz_rx,khz_tx,khz_rx_rec,khz_tx_io;
frequency_monitor fm0 (
        .signal({pll_ref,clk_rx_main,clk_tx_main,clk_rx_recover,clk_tx_io}),
        .ref_clk(clk100),
        .khz_counters ({khz_ref,khz_rx,khz_tx,khz_rx_rec,khz_tx_io})
);
defparam fm0 .NUM_SIGNALS = 5;
defparam fm0 .REF_KHZ = STATUS_CLK_KHZ;

//////////////////////////////////////
// PCS
//////////////////////////////////////

wire [NUM_VLANE-1:0] frm_err_out;
wire [NUM_VLANE-1:0] opp_ping_out;
wire sclr_frm_err_s;
wire rx_pcs_soft_rst;

alt_aeu_40_rx_pcs_2 rpcs (
    .clk(clk_rx_main),
    .sclr(!eio_rx_online || rx_pcs_soft_rst),
    .rst_async(rst100),     //global reset; async, no domain, to reset link fault                            
    .din(eio_dout_sep),     // lsbit first serial streams
    .din_req(eio_dout_req), // 2 copies
    
    .sclr_frm_err(sclr_frm_err_s),
    .frm_err_out(frm_err_out),
    .opp_ping_out(opp_ping_out),
    .fully_aligned(rx_pcs_fully_aligned_raw),
    .hi_ber(rx_hi_ber_raw),
    
    .dout_d(dout_d),
    .dout_c(dout_c),
    //.wpos(wpos),
    .dsk_depths(wpos),
    .dout_am(dout_am)
);
defparam rpcs .TARGET_CHIP = TARGET_CHIP;
defparam rpcs .AM_CNT_BITS = AM_CNT_BITS;
defparam rpcs .EN_LINK_FAULT = EN_LINK_FAULT;
defparam rpcs .SIM_FAKE_JTAG = SIM_FAKE_JTAG;
defparam rpcs .EARLY_REQ = (ENA_KR4 && (TARGET_CHIP==5)) ? 4 : 2;
defparam rpcs .SYNOPT_FULL_SKEW = SYNOPT_FULL_SKEW;

alt_aeu_40_tx_pcs_2 tpcs (
    .clk(clk_tx_main),
    .sclr(!eio_tx_online),
    
    .din_d(din_d), 
    .din_c(din_c), 
    .din_am(din_am),  // this din_d/c will be replaced with align markers
    .pre_din_am(pre_din_am), // advance warning
        .tx_crc_ins_en(tx_crc_ins_en),
            
    .dout(eio_din_sep), // lsbit first serial streams
    .dout_valid(eio_din_valid),
        
    .dout_66(eio_din_sep_66), // for fec
    .dout_66_valid(eio_din_66_valid),
    .tx_mii_start(tx_mii_start)
);
defparam tpcs .TARGET_CHIP = TARGET_CHIP;
defparam tpcs .SYNOPT_PTP = SYNOPT_PTP;
defparam tpcs. PTP_LATENCY = PTP_LATENCY;
defparam tpcs .EN_LINK_FAULT = EN_LINK_FAULT;
defparam tpcs .AM_CNT_BITS = AM_CNT_BITS;
defparam tpcs .CREATE_TX_SKEW = CREATE_TX_SKEW;

// deal with odd-even bit interleaving
// no interleave for 40G
generate
        for (i=0; i<4; i=i+1) begin : lp
                //mix_odd_even moe (
                //      .din(eio_din_sep[(i+1)*32-1:i*32]),
                //      .dout(eio_din[(i+1)*32-1:i*32])
                //);
                //defparam moe .WIDTH = 32;
                assign eio_din[(i+1)*40-1:i*40] = eio_din_sep[(i+1)*40-1:i*40];
                
                //sep_odd_even soe (
                //      .din(eio_dout[(i+1)*32-1:i*32]),
                //      .dout(eio_dout_sep[(i+1)*32-1:i*32])
                //);
                //defparam soe .WIDTH = 32;
                assign eio_dout_sep[(i+1)*40-1:i*40] = eio_dout[(i+1)*40-1:i*40];
                
        end
endgenerate

wire [NUM_VLANE-1:0] frm_err_out_s;
sync_regs sr1 (
        .clk (clk100),
        .din(frm_err_out & {NUM_VLANE{rxp_lock}}),
        .dout(frm_err_out_s)
);
defparam sr1 .WIDTH = NUM_VLANE;

reg sclr_frm_err = 1'b0;
sync_regs sr2 (
        .clk (clk_rx_main),
        .din(sclr_frm_err),
        .dout(sclr_frm_err_s)
);
defparam sr2 .WIDTH = 1;

reg rx_pcs_soft_rst_s = 1'b0;
reg eio_rx_soft_purge_s = 1'b0;

sync_regs sr3(
        .clk(clk_rx_main),
        .din({eio_rx_soft_purge_s,rx_pcs_soft_rst_s}),
        .dout({eio_rx_soft_purge,rx_pcs_soft_rst})      
);
defparam sr3 .WIDTH = 2;
   
//assign rx_pcs_fully_aligned = rx_pcs_fully_aligned_raw && eio_rx_online;

initial rx_pcs_fully_aligned = 1'b0;
always @(posedge clk_rx_main or posedge rx_aclr_pcs_ready) begin
        if (rx_aclr_pcs_ready) rx_pcs_fully_aligned <= 1'b0;
        else                   rx_pcs_fully_aligned <= rx_pcs_fully_aligned_raw;
end


assign rx_hi_ber = rx_hi_ber_raw && eio_rx_online;
   
sync_regs sr4(
        .clk(clk100),
        .din({rx_hi_ber,    rx_pcs_fully_aligned}),
        .dout({rx_hi_ber_s, rx_pcs_fully_aligned_s})    
);
defparam sr4 .WIDTH = 2; // adubey (to add hi_ber)
   
//////////////////////////////////////////////
// status page - 40G IO pins
//////////////////////////////////////////////

wire ss1_wr, ss1_rd;
wire [7:0] ss1_addr;
wire [31:0] ss1_wdata;
reg [31:0] ss1_rdata = 32'h0;
reg ss1_rdata_valid = 1'b0;
wire ss1_dout;

wire slave_dout_phy;
assign slave_dout = slave_dout_kr4 & slave_dout_phy;
serif_slave ss1 (
    .clk(clk100),
    .din(slave_din),
    .dout(slave_dout_phy),

    .wr(ss1_wr),
    .rd(ss1_rd),
    .addr(ss1_addr),
    .wdata(ss1_wdata),
    .rdata(ss1_rdata),
    .rdata_valid(ss1_rdata_valid)
);
defparam ss1 .ADDR_PAGE = ADDR_PAGE;

reg [31:0] scratch1 = 32'h0;
wire [12*8-1:0] io_name = "40GE pcs    ";
always @(posedge clk100) begin
    ss1_rdata_valid <= 1'b0;
    if (ss1_rd) begin
        ss1_rdata_valid <= 1'b1;
        case (ss1_addr)
            8'h0 : ss1_rdata <= REVID;
            8'h1 : ss1_rdata <= 32'h0 | scratch1;
            8'h2 : ss1_rdata <= 32'h0 | io_name[8*12-1:8*8];
            8'h3 : ss1_rdata <= 32'h0 | io_name[8*8-1:8*4];
            8'h4 : ss1_rdata <= 32'h0 | io_name[8*4-1:0];
            
            8'h10 : ss1_rdata <= 32'h0 | {set_data_lock,set_ref_lock,rxp_ignore_freq,soft_rxp_rst,
                                                                                        soft_txp_rst,eio_sys_rst};
            8'h13 : ss1_rdata <= 32'h0 | eio_sloop;
                        8'h14 : ss1_rdata <= 32'h0 | eio_flag_sel;
                        8'h15 : ss1_rdata <= 32'h0 | eio_flags;
                        
                        8'h20 : ss1_rdata <= 32'h0 | eio_tx_pll_locked;
                        8'h21 : ss1_rdata <= 32'h0 | eio_freq_lock;
                        8'h22 : ss1_rdata <= 32'h0 | {rxp_lock,txp_lock,txa_online};
                        8'h23 : ss1_rdata <= 32'h0 | frm_err_out_s;
                        8'h24 : ss1_rdata <= 32'h0 | sclr_frm_err;
                        8'h25 : ss1_rdata <= 32'h0 | {eio_rx_soft_purge_s,rx_pcs_soft_rst_s};
                        8'h26 : ss1_rdata <= 32'h0 | {rx_hi_ber_s, rx_pcs_fully_aligned_s};
                        
                    8'h40 : ss1_rdata <= 32'h0 | khz_ref;
            8'h41 : ss1_rdata <= 32'h0 | khz_rx;
            8'h42 : ss1_rdata <= 32'h0 | khz_tx;
            8'h43 : ss1_rdata <= 32'h0 | khz_rx_rec;
            8'h44 : ss1_rdata <= 32'h0 | khz_tx_io;

                        8'h50 : ss1_rdata <= 32'h0 | reco_addr;
                        8'h51 : ss1_rdata <= 32'h0 | {reco_write,reco_read};
                        8'h52 : ss1_rdata <= 32'h0 | reco_wdata;
                        8'h53 : ss1_rdata <= 32'h0 | reco_rdata;
            
            default : ss1_rdata <= 32'hdeadc0de;
        endcase
    end

    if (ss1_wr) begin
        case (ss1_addr)
            8'h1 : scratch1 <= ss1_wdata;
            8'h10 : {set_data_lock,set_ref_lock,rxp_ignore_freq,soft_rxp_rst,
                                                soft_txp_rst,eio_sys_rst} <= ss1_wdata[5:0];
        
            8'h13 : eio_sloop <= ss1_wdata[3:0];             
            8'h14 : eio_flag_sel <= ss1_wdata[2:0];             
            
            8'h24 : sclr_frm_err <= ss1_wdata[0];
            8'h25 : {eio_rx_soft_purge_s,rx_pcs_soft_rst_s} <= ss1_wdata[1:0];
                        
            8'h50 : reco_addr <= ss1_wdata[6:0];
            8'h51 : {reco_write,reco_read} <= ss1_wdata[1:0];
            8'h52 : reco_wdata <= ss1_wdata;
                                
        endcase
    end
end

//////////////////////////////////////////////
// resets
//////////////////////////////////////////////
reg tx_lanes_stable_r = 1'b0;
always @(posedge clk_tx_main) begin
        tx_lanes_stable_r <= eio_tx_online;
end
assign tx_lanes_stable = tx_lanes_stable_r && txp_lock;

reg srst_tx_main_r = 1'b0;
always @(posedge clk_tx_main) begin
        srst_tx_main_r <= !eio_tx_online;
end
assign srst_tx_main = srst_tx_main_r;

reg srst_rx_main_r = 1'b0;
always @(posedge clk_rx_main) begin
        srst_rx_main_r <= !eio_rx_online;
end
assign srst_rx_main = srst_rx_main_r;
                
endmodule
