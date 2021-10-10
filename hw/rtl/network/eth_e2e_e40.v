// *****************************************************************************
//
//                            INTEL CONFIDENTIAL
//
//           Copyright (C) 2017 Intel Corporation All Rights Reserved.
//
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned  by  Intel  Corporation  or its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets  and  proprietary  and  confidential  information  of  Intel or its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// used,   copied,   reproduced,   modified,   published,   uploaded,  posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
//
// No license under any patent,  copyright, trade secret or other intellectual
// property  right  is  granted  to  or  conferred  upon  you by disclosure or
// delivery  of  the  Materials, either expressly, by implication, inducement,
// estoppel or otherwise.  Any license under such intellectual property rights
// must be express and approved by Intel in writing.
//
// *****************************************************************************
// baeckler - 05-10-2016
// maguirre - Feb/2017
//          - Edited for ETH E2E validation project
// ecustodi - Edited for 4-Channel A10 DCP
//
// *****************************************************************************
//
// Modified by: Cornell University
//
// Module Name :    eth_e2e_e40
// Project :        F-NIC
// Description :    Ethernet MAC
//

module eth_e2e_e40 #(
    parameter NUM_LN = 4   // no override
)(
	pr_hssi_if.to_fiu hssi,

    // ETH CSR ports
    input  [31:0] eth_ctrl_addr,
    input  [31:0] eth_wr_data, 
    output [31:0] eth_rd_data,   
    input         csr_init_start,
    output        csr_init_done,

    // Ethernet MAC streams
    // TX Avalon-ST interface
    output         tx_clk_out      ,// Avalon-ST TX clk
    output         tx_reset_out    ,// Avalon-ST TX reset
    output         tx_ready_out    ,// Avalon-ST TX ready
    input  [255:0] tx_data_in     ,// Avalon-ST TX data
    input          tx_valid_in    ,// Avalon-ST TX data valid
    input          tx_sop_in      ,// Avalon-ST TX start-of-packet
    input          tx_eop_in      ,// Avalon-ST TX end-of-packet
    input    [4:0] tx_empty_in    ,// Avalon-ST TX empty
    input          tx_error_in    ,// Avalon-ST TX error

    // RX Avalon-ST interface
    output           rx_clk_out      ,// Avalon-ST RX clk
    output           rx_reset_out    ,// Avalon-ST RX reset
    output   [255:0] rx_data_out     ,// Avalon-ST RX data
    output           rx_valid_out    ,// Avalon-ST RX data valid
    output           rx_sop_out      ,// Avalon-ST RX start-of-packet
    output           rx_eop_out      ,// Avalon-ST RX end-of-packet
    output     [4:0] rx_empty_out    ,// Avalon-ST RX empty
    output     [5:0] rx_error_out    ,// Avalon-ST RX error
    input            rx_ready_in     // Avalon-ST RX ready
);

localparam [23:0] GBS_ID = "E2E";
localparam  [7:0] GBS_VER = 8'h40;

reg [31:0] scratch = {GBS_ID, GBS_VER};
reg [31:0] prmgmt_dout_r = 32'h0;

wire          l4_tx_sop_0;
wire          l4_tx_eop_0;
wire          l4_tx_valid_0;
wire    [4:0] l4_tx_empty_0;
wire  [255:0] l4_tx_data_0;
wire          l4_tx_ready_0;
wire    [5:0] l4_tx_error_0;

wire          l4_rx_sop_0;
wire          l4_rx_eop_0;
wire          l4_rx_valid_0;
wire    [4:0] l4_rx_empty_0;
wire  [255:0] l4_rx_data_0;
wire    [5:0] l4_rx_error_0;
wire          l4_rx_ready_0;


////////////////////////////////////////////////////////////////////////////////
// MUX for HSSI PR MGMT bus access 
////////////////////////////////////////////////////////////////////////////////

reg  [15:0] prmgmt_cmd;
reg  [15:0] prmgmt_addr;   
reg  [31:0] prmgmt_din;   

always @(posedge hssi.f2a_prmgmt_ctrl_clk)
begin
    // RD/WR request from AFU CSR
	prmgmt_cmd <= 16'b0;
	
	if (hssi.f2a_prmgmt_cmd != 16'b0)
    begin
        prmgmt_cmd  <= hssi.f2a_prmgmt_cmd;
        prmgmt_addr <= hssi.f2a_prmgmt_addr;
        prmgmt_din  <= hssi.f2a_prmgmt_din;
    end
	
    if (eth_ctrl_addr[17] | eth_ctrl_addr[16])
    begin
        prmgmt_cmd  <= eth_ctrl_addr[31:16];
        prmgmt_addr <= eth_ctrl_addr[15: 0];
        prmgmt_din  <= eth_wr_data;
    end

end

assign eth_rd_data   = prmgmt_dout_r;
assign csr_init_done = hssi.f2a_init_done;

////////////////////////////////////////////////////////////////////////////////
// PRMGMT registers for I2C controllers
////////////////////////////////////////////////////////////////////////////////

reg  [15:0] i2c_ctrl_wdata_r;
reg  [15:0] i2c_stat_rdata  ;
wire [15:0] i2c_stat_rdata_0;
reg  [ 1:0] i2c_inst_sel_r  ;

////////////////////////////////////////////////////////////////////////////////
// PRMGMT registers for Packet generators/checkers
////////////////////////////////////////////////////////////////////////////////

reg  [15:0] eth_traff_addr   ;
reg         eth_traff_wr     ;
reg         eth_traff_rd     ;
reg  [31:0] eth_traff_wdata  ;
reg  [31:0] eth_traff_rdata  ;
wire [31:0] eth_traff_rdata_0;

reg  [0:0] status_write = 0 /* synthesis preserve */;
reg  [0:0] status_read = 0 /* synthesis preserve */;
reg  [15:0] status_addr = 0 /* synthesis preserve */;
reg  [31:0] status_writedata = 0 /* synthesis preserve */;
wire  [31:0] status_readdata ;
wire  [0:0] status_readdata_valid;
wire  [0:0] status_waitrequest;
wire  [0:0] status_read_timeout;

////////////////////////////////////////////////////////////////////////////////
// MACs signals
////////////////////////////////////////////////////////////////////////////////

reg [1:0] e40_arst = 2'b11;
wire [0:0] reset_async = e40_arst[0];
wire [0:0] reset_status = e40_arst[1];

wire  [0:0] rx_pcs_ready;

wire  [0:0] tx_lanes_stable;

reg  [31:0] tx_time2ready;
reg  [31:0] rx_time2ready;

////////////////////////////////////
// Ethernet MAC and PCS digital
////////////////////////////////////

// digital ethernet to serdes
wire [7:0] eio_sloop;
wire set_data_lock;
wire set_ref_lock;

// txdata
wire [8*40-1:0] eio_din;
wire eio_tx_online;
wire eio_din_valid;

// external plls converting serdes to mac rates
wire rxp_rst_0;
wire rxp_lock;
wire txp_rst_0;
wire txp_lock;


// serdes to digital ethernet
wire [7:0] eio_freq_lock;

// rxdata
wire [8*40-1:0] eio_dout;
wire eio_dout_req;

localparam PHY_REFCLK = 1;

wire tx_digitalreset_i;
wire rx_digitalreset_i;
wire tx_analogreset_i;
wire rx_analogreset_i;

reg [3:0] tx_analogreset_r = 4'b0 /* synthesis preserve dont_replicate */;
reg [3:0] rx_analogreset_r = 4'b0 /* synthesis preserve dont_replicate */;
reg [3:0] tx_digitalreset_r = 4'b0 /* synthesis preserve dont_replicate */;
reg [3:0] rx_digitalreset_r = 4'b0 /* synthesis preserve dont_replicate */;

always @(posedge hssi.f2a_prmgmt_ctrl_clk) begin
    tx_analogreset_r <= {4{tx_analogreset_i}};
    rx_analogreset_r <= {4{rx_analogreset_i}};
end

always @(posedge hssi.f2a_tx_clk) begin
    tx_digitalreset_r <= {4{tx_digitalreset_i}};
end

always @(posedge hssi.f2a_rx_clk_ln0) begin
    rx_digitalreset_r <= {4{rx_digitalreset_i}};
end


assign hssi.a2f_tx_digitalreset = {12'b0, tx_digitalreset_r};
assign hssi.a2f_rx_digitalreset = {12'b0, rx_digitalreset_r};
assign hssi.a2f_tx_analogreset = {12'b0, tx_analogreset_r};
assign hssi.a2f_rx_analogreset = {12'b0, rx_analogreset_r};

wire stacker_ram_ena_s_0;
alt_sync_regs_m2 #(.WIDTH(1)) ssr_0 (
    .clk(hssi.f2a_rx_clk_ln0),
    .din(hssi.f2a_prmgmt_ram_ena),
    .dout(stacker_ram_ena_s_0)
);

alt_aeu_40_top #(
    .SYNOPT_AVALON        (1),
    .PHY_REFCLK           (PHY_REFCLK),
    .SYNOPT_PAUSE_TYPE    (0),
    .SYNOPT_LINK_FAULT    (1),
    .SYNOPT_TXCRC_INS     (1),
    .SYNOPT_MAC_DIC       (1),
    .SYNOPT_PREAMBLE_PASS (0),
    .SYNOPT_ALIGN_FCSEOP  (1),
    .SYNOPT_MAC_TXSTATS   (1),
    .SYNOPT_MAC_RXSTATS   (1),
    .TARGET_CHIP          (5)
) alt_eth_ultra_0 (
    .clk_ref                                        (1'b0),
    .reset_async                                    (reset_async),
    .clk_status                                     (hssi.f2a_prmgmt_ctrl_clk),
    .reset_status                                   (reset_status),
    .status_write                                   (status_write),
    .status_read                                    (status_read),
    .status_addr                                    (status_addr),
    .status_writedata                               (status_writedata),
    .status_readdata                                (status_readdata),
    .status_readdata_valid                          (status_readdata_valid),
    .status_waitrequest                             (status_waitrequest),
    .status_read_timeout                            (status_read_timeout),
    .tx_lanes_stable                                (tx_lanes_stable),
    .rx_pcs_ready                                   (rx_pcs_ready),
    .tx_pll_locked                                  (hssi.f2a_tx_pll_locked),
    .din_sop                                        (2'b0),
    .din_eop                                        (2'b0),
    .din_idle                                       (2'b0),
    .din_eop_empty                                  (6'b0),
    .din                                            (128'b0),
    .din_req                                        (),
    .dout_valid                                     (),
    .tx_error                                       (2'b0),
    .clk_txmac_in                                   (1'b0),
    .l4_tx_startofpacket                            (l4_tx_sop_0),
    .l4_tx_endofpacket                              (l4_tx_eop_0),
    .l4_tx_valid                                    (l4_tx_valid_0),
    .l4_tx_ready                                    (l4_tx_ready_0),
    .l4_tx_empty                                    (l4_tx_empty_0),
    .l4_tx_data                                     (l4_tx_data_0),
    .l4_rx_error                                    (l4_rx_error_0),
    .l4_rx_status                                   (),
    .l4_rx_valid                                    (l4_rx_valid_0),
    .l4_rx_startofpacket                            (l4_rx_sop_0),
    .l4_rx_endofpacket                              (l4_rx_eop_0),
    .l4_rx_data                                     (l4_rx_data_0),
    .l4_rx_empty                                    (l4_rx_empty_0),
    .l4_rx_fcs_error                                (),
    .l4_rx_fcs_valid                                (),
    .pause_insert_tx                                (1'b0),
    .pause_receive_rx                               (),
    .unidirectional_en                              (),
    .link_fault_gen_en                              (),
    .remote_fault_status                            (),
    .local_fault_status                             (),
    .tx_in_ptp_asm                                  (1'b0),
    .tod_exit_cust                                  (),
    .ts_out_cust                                    (),
    .ts_out_cust_asm                                (),
    .tod_cust_in                                    (96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    .RX_CORE_CLK                                    (1'b0),
    .TX_CORE_CLK                                    (1'b0),
    .l4_tx_error                                    (1'b0),
    .rx_time_of_day_96b_data                        (96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    .rx_time_of_day_64b_data                        (64'b0000000000000000000000000000000000000000000000000000000000000000),
    .tx_time_of_day_96b_data                        (96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    .tx_time_of_day_64b_data                        (64'b0000000000000000000000000000000000000000000000000000000000000000),
    .rx_ingress_timestamp_96b_data                  (),
    .rx_ingress_timestamp_96b_valid                 (),
    .tx_egress_timestamp_96b_data                   (),
    .tx_etstamp_ins_ctrl_ingress_timestamp_96b      (96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    .tx_egress_timestamp_96b_valid                  (),
    .tx_egress_timestamp_96b_fingerprint            (),
    .rx_ingress_timestamp_64b_data                  (),
    .rx_ingress_timestamp_64b_valid                 (),
    .tx_egress_timestamp_64b_data                   (),
    .tx_etstamp_ins_ctrl_ingress_timestamp_64b      (64'b0000000000000000000000000000000000000000000000000000000000000000),
    .tx_egress_timestamp_64b_valid                  (),
    .tx_egress_timestamp_64b_fingerprint            (),
    .tx_egress_timestamp_request_valid              (1'b0),
    .tx_egress_timestamp_request_fingerprint        (1'b0),
    .tx_egress_asymmetry_update                     (1'b0),
    .tx_etstamp_ins_ctrl_timestamp_insert           (1'b0),
    .tx_etstamp_ins_ctrl_timestamp_format           (1'b0),
    .tx_etstamp_ins_ctrl_residence_time_update      (1'b0),
    .tx_etstamp_ins_ctrl_residence_time_calc_format (1'b0),
    .tx_etstamp_ins_ctrl_checksum_zero              (1'b0),
    .tx_etstamp_ins_ctrl_checksum_correct           (1'b0),
    .tx_etstamp_ins_ctrl_offset_timestamp           (16'b0000000000000000),
    .tx_etstamp_ins_ctrl_offset_correction_field    (16'b0000000000000000),
    .tx_etstamp_ins_ctrl_offset_checksum_field      (16'b0000000000000000),
    .tx_etstamp_ins_ctrl_offset_checksum_correction (16'b0000000000000000) ,

    .pll_powerdown (),
    .tx_analogreset (tx_analogreset_i),
    .tx_digitalreset (tx_digitalreset_i),
    .rx_analogreset (rx_analogreset_i),
    .rx_digitalreset (rx_digitalreset_i),

    .rxp_rst (rxp_rst_0),
    .rxp_lock (hssi.f2a_rx_locked_ln0),
    .txp_rst (txp_rst_0),
    .txp_lock (hssi.f2a_tx_locked),

    .eio_tx_clkout(4'b0),
    .eio_rx_clkout(4'b0),

    .clk_tx_main(hssi.f2a_tx_clk),
    .clk_rx_main(hssi.f2a_rx_clk_ln0),

    .eio_din(eio_din[40*4-1:0]),
    .eio_tx_online(eio_tx_online),
    .eio_din_valid(eio_din_valid),

    .eio_dout(eio_dout[40*4-1:0]),
    .eio_dout_req(eio_dout_req),

    .eio_freq_lock(eio_freq_lock[3:0]),
    .eio_sloop(eio_sloop[3:0]),

    // fifo status
    .tx_full(hssi.f2a_tx_enh_fifo_full[3:0]),
    .tx_empty(hssi.f2a_tx_enh_fifo_empty[3:0]),
    .tx_pfull(hssi.f2a_tx_enh_fifo_pfull[3:0]),
    .tx_pempty(hssi.f2a_tx_enh_fifo_pempty[3:0]),
    .rx_full(hssi.f2a_rx_enh_fifo_full[3:0]),
    .rx_empty(hssi.f2a_rx_enh_fifo_empty[3:0]),
    .rx_pfull(hssi.f2a_rx_enh_fifo_pfull[3:0]),
    .rx_pempty(hssi.f2a_rx_enh_fifo_pempty[3:0]),

    .tx_cal_busy(hssi.f2a_tx_cal_busy),
    .rx_cal_busy(hssi.f2a_rx_cal_busy),
    .set_data_lock(set_data_lock),
    .set_ref_lock(set_ref_lock),

    // debug text terminal
    .byte_to_jtag(),
    .byte_from_jtag(8'b0),
    .byte_to_jtag_valid(),
    .byte_from_jtag_ack(),

    .stacker_ram_ena (stacker_ram_ena_s_0)
);

////////////////////////////////////
// serdes IO registers
////////////////////////////////////

wire [NUM_LN*40-1:0] active_rx_data;
wire [NUM_LN*40-1:0] active_tx_data;



reg [40*8-1:0] tx_launch = 0 /* synthesis preserve */;
reg [7:0] tx_valid = 0 /* synthesis preserve */;

always @(posedge hssi.f2a_tx_clk) begin
    tx_launch <= eio_din;
    tx_valid <= {{4{1'b0}}, 
                 {4{eio_din_valid  & eio_tx_online}}};
end

wire [7:0] eio_tx_data_valid = tx_valid;

reg [40*4-1:0] rx_capture_r_0 = 0 /* synthesis preserve */;
reg [40*4-1:0] rx_capture_r_4 = 0;

always @(posedge hssi.f2a_rx_clk_ln0) begin
    rx_capture_r_0 <= active_rx_data[40*4-1:0];
end

assign eio_dout = {rx_capture_r_4, rx_capture_r_0};

reg [3:0] rx_req_r_0 = 0 /* synthesis preserve */;

always @(posedge hssi.f2a_rx_clk_ln0) begin
    rx_req_r_0 <= {4{eio_dout_req}};
end

wire [7:0] eio_rx_rd_en = {4'b0, rx_req_r_0};

//////////////////////////////////////////////////////////////////
// pull the active subset of the wires for 40 bit basic stream


genvar i;
generate
    for (i=0; i<NUM_LN; i=i+1) begin : drf
        assign active_rx_data[(i+1)*40-1:i*40] = hssi.f2a_rx_parallel_data[i*128+39:i*128];
        assign hssi.a2f_tx_parallel_data[i*128+39:i*128] = active_tx_data[(i+1)*40-1:i*40];
        assign hssi.a2f_tx_parallel_data[(i+1)*128-1:i*128+40] = 88'b0;
    end
endgenerate

assign active_tx_data = tx_launch;

//////////////////////////////////////////////////////////////////
// rename some SERDES controls

assign hssi.a2f_tx_enh_data_valid = {NUM_LN{1'b0}} | eio_tx_data_valid;
assign hssi.a2f_rx_enh_fifo_rd_en = {NUM_LN{1'b0}} | eio_rx_rd_en;
assign eio_freq_lock = hssi.f2a_rx_is_lockedtodata;
assign hssi.a2f_rx_seriallpbken   = {NUM_LN{1'b0}} | eio_sloop;
assign hssi.a2f_rx_set_locktodata = {NUM_LN{set_data_lock}};
assign hssi.a2f_rx_set_locktoref  = {NUM_LN{set_ref_lock}};

////////////////////////////////////////////////////////////////////////////////
// Time To Link counters
////////////////////////////////////////////////////////////////////////////////

always @(posedge hssi.f2a_prmgmt_ctrl_clk or posedge reset_async) 
begin
    if (reset_async)
    begin
        tx_time2ready <= 'b0;
        rx_time2ready <= 'b0;
    end
    else
    begin
        if (!tx_lanes_stable)
            tx_time2ready <= tx_time2ready + 1'b1 ;
        if (!rx_pcs_ready)
            rx_time2ready <= rx_time2ready + 1'b1;
    end
end

////////////////////////////////////////////////////////////////////////////////
// hook up to the management port
////////////////////////////////////////////////////////////////////////////////

reg  [31:0] status_readdata_r = 32'h0 ;
reg  [31:0] status_readdata2_r = 32'h0 ;

always @(posedge hssi.f2a_prmgmt_ctrl_clk) begin
    case (prmgmt_addr[3:0])
        4'h0 : prmgmt_dout_r <= 32'h0 | scratch;
        4'h1 : prmgmt_dout_r <= 32'h0 | e40_arst;
        
        4'h2 : prmgmt_dout_r <= 32'h0 | {status_read,status_write,status_addr};
        4'h3 : prmgmt_dout_r <= status_writedata;
        4'h4 : prmgmt_dout_r <= status_readdata_r;
        
        //4'h5 : prmgmt_dout_r <= 32'h0 | {status_read2,status_write2,status_addr2};
        //4'h6 : prmgmt_dout_r <= status_writedata2;
        //4'h7 : prmgmt_dout_r <= status_readdata2_r;

        4'h8 : prmgmt_dout_r <= 32'h0 | {i2c_inst_sel_r,i2c_ctrl_wdata_r};
        4'h9 : prmgmt_dout_r <= 32'h0 | i2c_stat_rdata;
        
        4'ha : prmgmt_dout_r <= 32'h0 | {eth_traff_rd,eth_traff_wr,eth_traff_addr};
        4'hb : prmgmt_dout_r <= eth_traff_wdata;
        4'hc : prmgmt_dout_r <= eth_traff_rdata;
        
        4'hd : prmgmt_dout_r <= 32'h0 | 
                                {//l4_tx_ready_1, l4_rx_ready_1, tx_lanes_stable2, rx_pcs_ready2,
                                 l4_tx_ready_0, l4_rx_ready_0, tx_lanes_stable, rx_pcs_ready,
                                 2'b0, hssi.a2f_prmgmt_fatal_err, hssi.f2a_init_done};

        4'he : prmgmt_dout_r <= 32'h0 | tx_time2ready;
        4'hf : prmgmt_dout_r <= 32'h0 | rx_time2ready;

        default : prmgmt_dout_r <= 32'h0;
    endcase
end

assign hssi.a2f_prmgmt_dout = prmgmt_dout_r;

always @(posedge hssi.f2a_prmgmt_ctrl_clk) begin
    if (status_readdata_valid) begin
        status_readdata_r <= status_readdata;
    end
end

always @(posedge hssi.f2a_prmgmt_ctrl_clk) begin
    if (prmgmt_cmd[0])
        case (prmgmt_addr[3:0])
            4'h0 : scratch <= prmgmt_din;
            4'h1 : e40_arst <= prmgmt_din[1:0];

            4'h2 : {status_read,status_write,status_addr} <= prmgmt_din[17:0];
            4'h3 : status_writedata <= prmgmt_din;
            
            //4'h5 : {status_read2,status_write2,status_addr2} <= prmgmt_din[17:0];
            //4'h6 : status_writedata2 <= prmgmt_din;
            
            4'h8 : {i2c_inst_sel_r,i2c_ctrl_wdata_r} <= prmgmt_din[17:0];
            
            4'ha : {eth_traff_rd,eth_traff_wr,eth_traff_addr} <= prmgmt_din[17:0];
            4'hb : eth_traff_wdata <= prmgmt_din;            
            
            4'hd : hssi.a2f_prmgmt_fatal_err <= prmgmt_din[1];
        endcase
    
    // Self-clearing RD/WR requests based on wait_request status
    if (status_read & ~status_waitrequest) status_read <= 1'b0;
    if (status_write & ~status_waitrequest) status_write <= 1'b0;
    //if (status_read2 & ~status_waitrequest2) status_read2 <= 1'b0;
    //if (status_write2 & ~status_waitrequest2) status_write2 <= 1'b0;
    if (eth_traff_rd) eth_traff_rd <= 1'b0;
    if (eth_traff_wr) eth_traff_wr <= 1'b0;

    // This is the Configuration Trigger for I2C controllers
    if (i2c_ctrl_wdata_r[8]) 
        i2c_ctrl_wdata_r[8] <= 1'b0;
    
    if (hssi.f2a_prmgmt_arst) begin
        scratch <= {GBS_ID, GBS_VER};
        e40_arst <= 2'b11;
        hssi.a2f_prmgmt_fatal_err <= 1'b0;
        status_read <= 1'b0;
        //status_read2 <= 1'b0;
        status_write <= 1'b0;
        //status_write2 <= 1'b0;
        eth_traff_rd <= 1'b0;
        eth_traff_wr <= 1'b0;
        i2c_ctrl_wdata_r <= 'b0;
    end
end

assign hssi.a2f_init_start = csr_init_start;

////////////////////////////////////////////////////////////////////////////////
// Ethernet traffic controller Instance 0
////////////////////////////////////////////////////////////////////////////////

// Synchronyzing MAC txp_rst (100MHz) to MAC tx clock.
wire tx_reset_0;
sync_regs #(.WIDTH(1))
inst_sync_rst_tx0
(
    .clk  (hssi.f2a_tx_clk),
    .din  (txp_rst_0),
    .dout (tx_reset_0)
);

// Synchronyzing MAC rxp_rst (100MHz) to MAC rx clock.
wire rx_reset_0;
sync_regs #(.WIDTH(1)) 
inst_sync_rst_rx0
(
    .clk  (hssi.f2a_rx_clk_ln0),
    .din  (rxp_rst_0),
    .dout (rx_reset_0)
);

// Assign input stream
assign tx_clk_out = hssi.f2a_tx_clk;
assign tx_reset_out = tx_reset_0;
assign tx_ready_out = l4_tx_ready_0;
assign l4_tx_data_0 = tx_data_in;
assign l4_tx_valid_0 = tx_valid_in;
assign l4_tx_sop_0 = tx_sop_in;
assign l4_tx_eop_0 = tx_eop_in;
assign l4_tx_empty_0 = tx_empty_in;
assign l4_tx_error_0 = tx_error_in;

// Assing output stream
assign rx_clk_out = hssi.f2a_rx_clk_ln0;
assign rx_reset_out = rx_reset_0;
assign rx_data_out = l4_rx_data_0;
assign rx_valid_out = l4_rx_valid_0;
assign rx_sop_out = l4_rx_sop_0;
assign rx_eop_out = l4_rx_eop_0;
assign rx_empty_out = l4_rx_empty_0;
assign rx_error_out = l4_rx_error_0;
assign l4_rx_ready_0 = rx_ready_in;

endmodule
