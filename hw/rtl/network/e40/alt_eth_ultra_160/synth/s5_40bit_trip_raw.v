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
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/pma/s5_40bit_trip_raw.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ______________________________________________________________________________

`timescale 1 ps / 1 ps

module s5_40bit_trip_raw #(
	parameter NUMC = 3,
	parameter REF_FREQ = "644.53125 MHz",
	parameter DATA_RATE = "10312.5 Mbps"
)(
		input  wire [NUMC-1:0]   pll_powerdown,            //            pll_powerdown.pll_powerdown
		input  wire [NUMC-1:0]   tx_analogreset,           //           tx_analogreset.tx_analogreset
		input  wire [NUMC-1:0]   tx_digitalreset,          //          tx_digitalreset.tx_digitalreset
		output wire [NUMC-1:0]   tx_pma_clkout,            //            tx_pma_clkout.tx_pma_clkout
		output wire [NUMC-1:0]   tx_serial_data,           //           tx_serial_data.tx_serial_data
		input  wire [NUMC*80-1:0] tx_pma_parallel_data,     //     tx_pma_parallel_data.tx_pma_parallel_data
		input  wire [NUMC-1:0]   ext_pll_clk,              //              ext_pll_clk.ext_pll_clk
		input  wire [NUMC-1:0]   rx_analogreset,           //           rx_analogreset.rx_analogreset
		input  wire [NUMC-1:0]   rx_digitalreset,          //          rx_digitalreset.rx_digitalreset
		input  wire [0:0]   rx_cdr_refclk,            //            rx_cdr_refclk.rx_cdr_refclk
		output wire [NUMC-1:0]   rx_pma_clkout,            //            rx_pma_clkout.rx_pma_clkout
		input  wire [NUMC-1:0]   rx_serial_data,           //           rx_serial_data.rx_serial_data
		output wire [NUMC*80-1:0] rx_pma_parallel_data,     //     rx_pma_parallel_data.rx_pma_parallel_data
		input  wire [NUMC-1:0]   rx_set_locktodata,        //        rx_set_locktodata.rx_set_locktodata
		input  wire [NUMC-1:0]   rx_set_locktoref,         //         rx_set_locktoref.rx_set_locktoref
		output wire [NUMC-1:0]   rx_is_lockedtoref,        //        rx_is_lockedtoref.rx_is_lockedtoref
		output wire [NUMC-1:0]   rx_is_lockedtodata,       //       rx_is_lockedtodata.rx_is_lockedtodata
		input  wire [NUMC*64-1:0] tx_parallel_data,         //         tx_parallel_data.tx_parallel_data
		output wire [NUMC*64-1:0] rx_parallel_data,         //         rx_parallel_data.rx_parallel_data
		input  wire [NUMC-1:0]   tx_10g_coreclkin,         //         tx_10g_coreclkin.tx_10g_coreclkin
		input  wire [NUMC-1:0]   rx_10g_coreclkin,         //         rx_10g_coreclkin.rx_10g_coreclkin
		output wire [NUMC-1:0]   tx_10g_clkout,            //            tx_10g_clkout.tx_10g_clkout
		output wire [NUMC-1:0]   rx_10g_clkout,            //            rx_10g_clkout.rx_10g_clkout
		input  wire [NUMC-1:0]   tx_10g_data_valid,        //        tx_10g_data_valid.tx_10g_data_valid
		output wire [NUMC-1:0]   tx_10g_fifo_full,         //         tx_10g_fifo_full.tx_10g_fifo_full
		output wire [NUMC-1:0]   tx_10g_fifo_pfull,        //        tx_10g_fifo_pfull.tx_10g_fifo_pfull
		output wire [NUMC-1:0]   tx_10g_fifo_empty,        //        tx_10g_fifo_empty.tx_10g_fifo_empty
		output wire [NUMC-1:0]   tx_10g_fifo_pempty,       //       tx_10g_fifo_pempty.tx_10g_fifo_pempty
		input  wire [NUMC-1:0]   rx_10g_fifo_rd_en,        //        rx_10g_fifo_rd_en.rx_10g_fifo_rd_en
		input  wire [NUMC-1:0]   rx_10g_fifo_align_clr,    //    rx_10g_fifo_align_clr.rx_10g_fifo_align_clr
		input  wire [NUMC-1:0]   rx_10g_bitslip,           //           rx_10g_bitslip.rx_10g_bitslip
		output wire [NUMC-1:0]   rx_10g_data_valid,        //        rx_10g_data_valid.rx_10g_data_valid
		output wire [NUMC-1:0]   rx_10g_fifo_full,         //         rx_10g_fifo_full.rx_10g_fifo_full
		output wire [NUMC-1:0]   rx_10g_fifo_pfull,        //        rx_10g_fifo_pfull.rx_10g_fifo_pfull
		output wire [NUMC-1:0]   rx_10g_fifo_empty,        //        rx_10g_fifo_empty.rx_10g_fifo_empty
		output wire [NUMC-1:0]   rx_10g_fifo_pempty,       //       rx_10g_fifo_pempty.rx_10g_fifo_pempty
		output wire [NUMC-1:0]   tx_cal_busy,              //              tx_cal_busy.tx_cal_busy
		output wire [NUMC-1:0]   rx_cal_busy,              //              rx_cal_busy.rx_cal_busy
		input  wire [NUMC-1:0]   rx_seriallpbken,
		output wire [NUMC-1:0]   rx_10g_clk33out,          //          rx_10g_clk33out.rx_10g_clk33out
		input  wire [NUMC*70-1:0] reconfig_to_xcvr,         //         reconfig_to_xcvr.reconfig_to_xcvr
		output wire [NUMC*46-1:0] reconfig_from_xcvr        //       reconfig_from_xcvr.reconfig_from_xcvr
);

// extra outputs
wire [NUMC*10-1:0]  rx_10g_control;           //           rx_10g_control.rx_10g_control

wire [NUMC-1:0]   tx_10g_fifo_del;          //          tx_10g_fifo_del.tx_10g_fifo_del
wire [NUMC-1:0]   tx_10g_fifo_insert;       //       tx_10g_fifo_insert.tx_10g_fifo_insert

wire [NUMC-1:0]   rx_10g_fifo_del;          //          rx_10g_fifo_del.rx_10g_fifo_del
wire [NUMC-1:0]   rx_10g_fifo_insert;       //       rx_10g_fifo_insert.rx_10g_fifo_insert
wire [NUMC-1:0]   rx_10g_align_val;         //         rx_10g_align_val.rx_10g_align_val
wire [NUMC-1:0]   rx_10g_blk_lock;          //          rx_10g_blk_lock.rx_10g_blk_lock
wire [NUMC-1:0]   rx_10g_blk_sh_err;        //        rx_10g_blk_sh_err.rx_10g_blk_sh_err
wire [NUMC-1:0]   rx_10g_scram_err;         //         rx_10g_scram_err.rx_10g_scram_err

wire [NUMC-1:0]   tx_10g_frame;             //             tx_10g_frame.tx_10g_frame
wire [NUMC-1:0]   rx_10g_frame;             //             rx_10g_frame.rx_10g_frame
wire [NUMC-1:0]   rx_10g_frame_lock;        //        rx_10g_frame_lock.rx_10g_frame_lock
wire [NUMC-1:0]   rx_10g_frame_mfrm_err;    //    rx_10g_frame_mfrm_err.rx_10g_frame_mfrm_err
wire [NUMC-1:0]   rx_10g_frame_sync_err;    //    rx_10g_frame_sync_err.rx_10g_frame_sync_err
wire [NUMC-1:0]   rx_10g_frame_skip_ins;    //    rx_10g_frame_skip_ins.rx_10g_frame_skip_ins
wire [NUMC-1:0]   rx_10g_frame_pyld_ins;    //    rx_10g_frame_pyld_ins.rx_10g_frame_pyld_ins
wire [NUMC-1:0]   rx_10g_frame_skip_err;    //    rx_10g_frame_skip_err.rx_10g_frame_skip_err
wire [NUMC-1:0]   rx_10g_frame_diag_err;    //    rx_10g_frame_diag_err.rx_10g_frame_diag_err
wire [NUMC*2-1:0]   rx_10g_frame_diag_status; // rx_10g_frame_diag_status.rx_10g_frame_diag_status
wire [NUMC-1:0]   rx_10g_crc32err;          //          rx_10g_crc32err.rx_10g_crc32err
wire [NUMC-1:0]   rx_10g_highber;           //           rx_10g_highber.rx_10g_highber

// extra inputs
wire [NUMC*9-1:0]  tx_10g_control = 0;           //           tx_10g_control.tx_10g_control
wire [NUMC-1:0]   rx_10g_fifo_align_en = {NUMC{1'b1}};     //     rx_10g_fifo_align_en.rx_10g_fifo_align_en
wire [NUMC*7-1:0]  tx_10g_bitslip = 0;           //           tx_10g_bitslip.tx_10g_bitslip
wire [NUMC-1:0]   tx_10g_burst_en = {NUMC{1'b0}};          //          tx_10g_burst_en.tx_10g_burst_en
wire [NUMC-1:0]   rx_10g_highber_clr_cnt = {NUMC{1'b0}};   //   rx_10g_highber_clr_cnt.rx_10g_highber_clr_cnt
wire [NUMC-1:0]   rx_10g_clr_errblk_count = {NUMC{1'b1}};  //  rx_10g_clr_errblk_count.rx_10g_clr_errblk_count
wire [NUMC*2-1:0]   tx_10g_diag_status = {(2*NUMC){1'b0}};       //       tx_10g_diag_status.tx_10g_diag_status
		
	altera_xcvr_native_sv #(
		.channels                           (NUMC),
		.tx_enable                          (1),
		.rx_enable                          (1),
		.data_path_select                   ("10G"),
		.bonded_mode                        ("non_bonded"),
		.data_rate                          (DATA_RATE),
		.pma_width                          (40),
		.tx_pma_clk_div                     (1),
		.pll_reconfig_enable                (0),
		.pll_external_enable                (1),
		.pll_data_rate                      (DATA_RATE),
		.pll_type                           ("ATX"),
		.plls                               (1),
		.pll_select                         (0),
		.pll_refclk_cnt                     (1),
		.pll_refclk_select                  ("0"),
		.pll_refclk_freq                    ("unused"),
		.pll_feedback_path                  ("internal"),
		.cdr_reconfig_enable                (0),
		.cdr_refclk_cnt                     (1),
		.cdr_refclk_select                  (0),
		.cdr_refclk_freq                    (REF_FREQ),
		.rx_ppm_detect_threshold            ("1000"),
		.rx_clkslip_enable                  (0),
		.enable_std                         (0),
		.std_protocol_hint                  ("basic"),
		.std_pld_pcs_width                  (10),
		.std_pcs_pma_width                  (10),
		.std_tx_8b10b_enable                (0),
		.std_tx_8b10b_user_disp_ctrl_enable (0),
		.std_rx_8b10b_enable                (0),
		.std_rx_word_aligner_mode           ("bit_slip"),
		.std_rx_word_aligner_ctrl           ("gige"),
		.std_rx_word_aligner_sm_data_cnt    (3),
		.std_rx_word_aligner_sm_pattern_cnt (3),
		.std_rx_word_aligner_sm_err_cnt     (3),
		.std_rx_word_aligner_pattern        ("0000000000"),
		.std_rx_word_aligner_pattern_len    (7),
		.std_tx_bitslip_enable              (0),
		.std_rx_run_length_en               (0),
		.std_rx_run_length_val              ("000000"),
		.std_tx_bitrev_enable               (0),
		.std_rx_bitrev_enable               (0),
		.std_tx_polinv_enable               (0),
		.std_rx_polinv_enable               (0),
		.std_rmfifo_enable                  (0),
		.std_rmfifo_pattern1                ("000000000000000000000"),
		.std_rmfifo_pattern2                ("000000000000000000000"),
		.std_coreclk_0ppm_enable            (1),
		.std_tx_pcfifo_mode                 ("low_latency"),
		.std_rx_pcfifo_mode                 ("low_latency"),
		.std_tx_byte_ser_enable             (0),
		.std_tx_byte_ser_mode               ("div2"),
		.std_rx_byte_deser_enable           (0),
		.std_rx_byte_deser_mode             ("div2"),
		.std_byte_order_enable              (0),
		.std_byte_order_mode                ("pld_8b"),
		.std_byte_order_pattern             ("0"),
		.std_byte_order_pad_pattern         ("0"),
		.std_low_latency_bypass_enable      (0),
		.enable_teng                        (1),
		.teng_protocol_hint                 ("basic"),
		.teng_pld_pcs_width                 (40),
		.teng_pcs_pma_width                 (40),
		.teng_txfifo_mode                   ("generic"),
		.teng_txfifo_full                   (31),
		.teng_txfifo_empty                  (0),
		.teng_txfifo_pfull                  (23),
		.teng_txfifo_pempty                 (7),
		.teng_rxfifo_mode                   ("generic"),
		.teng_rxfifo_full                   (31),
		.teng_rxfifo_empty                  (0),
		.teng_rxfifo_pfull                  (23),
		.teng_rxfifo_pempty                 (7),
		.teng_rxfifo_align_del              (0),
		.teng_rxfifo_control_del            (0),
		.teng_tx_frmgen_enable              (0),
		.teng_tx_frmgen_user_length         (2048),
		.teng_rx_frmsync_enable             (0),
		.teng_rx_frmsync_user_length        (2048),
		.teng_frmgensync_diag_word          ("6400000000000000"),
		.teng_frmgensync_scrm_word          ("2800000000000000"),
		.teng_frmgensync_skip_word          ("1e1e1e1e1e1e1e1e"),
		.teng_frmgensync_sync_word          ("78f678f678f678f6"),
		.teng_tx_frmgen_burst_enable        (0),
		.teng_tx_sh_err                     (0),
		.teng_tx_crcgen_enable              (0),
		.teng_rx_crcchk_enable              (0),
		.teng_tx_64b66b_enable              (0),
		.teng_rx_64b66b_enable              (0),
		.teng_tx_scram_enable               (0),
		.teng_rx_scram_enable               (0),
		.teng_scram_seed_mode               ("min"),
		.teng_scram_user_seed               ("000000000000000"),
		.teng_tx_dispgen_enable             (0),
		.teng_rx_dispchk_enable             (0),
		.teng_tx_polinv_enable              (0),
		.teng_rx_polinv_enable              (0),
		.teng_tx_bitslip_enable             (1),
		.teng_rx_bitslip_enable             (1),
		.teng_rx_blksync_enable             (0),
		.teng_rx_blksync_wait_user_cnt      (7),
		.teng_rx_blksync_wait_type          ("bitslip_cnt")
	) ngx (
		.pll_powerdown             (pll_powerdown),            //            pll_powerdown.pll_powerdown
		.tx_analogreset            (tx_analogreset),           //           tx_analogreset.tx_analogreset
		.tx_digitalreset           (tx_digitalreset),          //          tx_digitalreset.tx_digitalreset
		.tx_pma_clkout             (tx_pma_clkout),            //            tx_pma_clkout.tx_pma_clkout
		.tx_serial_data            (tx_serial_data),           //           tx_serial_data.tx_serial_data
		.tx_pma_parallel_data      (tx_pma_parallel_data),     //     tx_pma_parallel_data.tx_pma_parallel_data
		.ext_pll_clk               (ext_pll_clk),              //              ext_pll_clk.ext_pll_clk
		.rx_analogreset            (rx_analogreset),           //           rx_analogreset.rx_analogreset
		.rx_digitalreset           (rx_digitalreset),          //          rx_digitalreset.rx_digitalreset
		.rx_cdr_refclk             (rx_cdr_refclk),            //            rx_cdr_refclk.rx_cdr_refclk
		.rx_pma_clkout             (rx_pma_clkout),            //            rx_pma_clkout.rx_pma_clkout
		.rx_serial_data            (rx_serial_data),           //           rx_serial_data.rx_serial_data
		.rx_pma_parallel_data      (rx_pma_parallel_data),     //     rx_pma_parallel_data.rx_pma_parallel_data
		.rx_set_locktodata         (rx_set_locktodata),        //        rx_set_locktodata.rx_set_locktodata
		.rx_set_locktoref          (rx_set_locktoref),         //         rx_set_locktoref.rx_set_locktoref
		.rx_is_lockedtoref         (rx_is_lockedtoref),        //        rx_is_lockedtoref.rx_is_lockedtoref
		.rx_is_lockedtodata        (rx_is_lockedtodata),       //       rx_is_lockedtodata.rx_is_lockedtodata
		.tx_parallel_data          (tx_parallel_data),         //         tx_parallel_data.tx_parallel_data
		.rx_parallel_data          (rx_parallel_data),         //         rx_parallel_data.rx_parallel_data
		.tx_10g_coreclkin          (tx_10g_coreclkin),         //         tx_10g_coreclkin.tx_10g_coreclkin
		.rx_10g_coreclkin          (rx_10g_coreclkin),         //         rx_10g_coreclkin.rx_10g_coreclkin
		.tx_10g_clkout             (tx_10g_clkout),            //            tx_10g_clkout.tx_10g_clkout
		.rx_10g_clkout             (rx_10g_clkout),            //            rx_10g_clkout.rx_10g_clkout
		.rx_10g_clk33out           (rx_10g_clk33out),          //          rx_10g_clk33out.rx_10g_clk33out
		.tx_10g_control            (tx_10g_control),           //           tx_10g_control.tx_10g_control
		.rx_10g_control            (rx_10g_control),           //           rx_10g_control.rx_10g_control
		.tx_10g_data_valid         (tx_10g_data_valid),        //        tx_10g_data_valid.tx_10g_data_valid
		.tx_10g_diag_status        (tx_10g_diag_status),       //       tx_10g_diag_status.tx_10g_diag_status
		.tx_10g_fifo_full          (tx_10g_fifo_full),         //         tx_10g_fifo_full.tx_10g_fifo_full
		.tx_10g_fifo_pfull         (tx_10g_fifo_pfull),        //        tx_10g_fifo_pfull.tx_10g_fifo_pfull
		.tx_10g_fifo_empty         (tx_10g_fifo_empty),        //        tx_10g_fifo_empty.tx_10g_fifo_empty
		.tx_10g_fifo_pempty        (tx_10g_fifo_pempty),       //       tx_10g_fifo_pempty.tx_10g_fifo_pempty
		.tx_10g_fifo_del           (tx_10g_fifo_del),          //          tx_10g_fifo_del.tx_10g_fifo_del
		.tx_10g_fifo_insert        (tx_10g_fifo_insert),       //       tx_10g_fifo_insert.tx_10g_fifo_insert
		.rx_10g_fifo_rd_en         (rx_10g_fifo_rd_en),        //        rx_10g_fifo_rd_en.rx_10g_fifo_rd_en
		.rx_10g_data_valid         (rx_10g_data_valid),        //        rx_10g_data_valid.rx_10g_data_valid
		.rx_10g_fifo_full          (rx_10g_fifo_full),         //         rx_10g_fifo_full.rx_10g_fifo_full
		.rx_10g_fifo_pfull         (rx_10g_fifo_pfull),        //        rx_10g_fifo_pfull.rx_10g_fifo_pfull
		.rx_10g_fifo_empty         (rx_10g_fifo_empty),        //        rx_10g_fifo_empty.rx_10g_fifo_empty
		.rx_10g_fifo_pempty        (rx_10g_fifo_pempty),       //       rx_10g_fifo_pempty.rx_10g_fifo_pempty
		.rx_10g_fifo_del           (rx_10g_fifo_del),          //          rx_10g_fifo_del.rx_10g_fifo_del
		.rx_10g_fifo_insert        (rx_10g_fifo_insert),       //       rx_10g_fifo_insert.rx_10g_fifo_insert
		.rx_10g_align_val          (rx_10g_align_val),         //         rx_10g_align_val.rx_10g_align_val
		.rx_10g_fifo_align_clr     (rx_10g_fifo_align_clr),    //    rx_10g_fifo_align_clr.rx_10g_fifo_align_clr
		.rx_10g_fifo_align_en      (rx_10g_fifo_align_en),     //     rx_10g_fifo_align_en.rx_10g_fifo_align_en
		.tx_10g_bitslip            (tx_10g_bitslip),           //           tx_10g_bitslip.tx_10g_bitslip
		.rx_10g_bitslip            (rx_10g_bitslip),           //           rx_10g_bitslip.rx_10g_bitslip
		.rx_10g_blk_lock           (rx_10g_blk_lock),          //          rx_10g_blk_lock.rx_10g_blk_lock
		.rx_10g_blk_sh_err         (rx_10g_blk_sh_err),        //        rx_10g_blk_sh_err.rx_10g_blk_sh_err
		.rx_10g_scram_err          (rx_10g_scram_err),         //         rx_10g_scram_err.rx_10g_scram_err
		.tx_10g_frame              (tx_10g_frame),             //             tx_10g_frame.tx_10g_frame
		.rx_10g_frame              (rx_10g_frame),             //             rx_10g_frame.rx_10g_frame
		.rx_10g_frame_lock         (rx_10g_frame_lock),        //        rx_10g_frame_lock.rx_10g_frame_lock
		.rx_10g_frame_mfrm_err     (rx_10g_frame_mfrm_err),    //    rx_10g_frame_mfrm_err.rx_10g_frame_mfrm_err
		.rx_10g_frame_sync_err     (rx_10g_frame_sync_err),    //    rx_10g_frame_sync_err.rx_10g_frame_sync_err
		.rx_10g_frame_skip_ins     (rx_10g_frame_skip_ins),    //    rx_10g_frame_skip_ins.rx_10g_frame_skip_ins
		.rx_10g_frame_pyld_ins     (rx_10g_frame_pyld_ins),    //    rx_10g_frame_pyld_ins.rx_10g_frame_pyld_ins
		.rx_10g_frame_skip_err     (rx_10g_frame_skip_err),    //    rx_10g_frame_skip_err.rx_10g_frame_skip_err
		.rx_10g_frame_diag_err     (rx_10g_frame_diag_err),    //    rx_10g_frame_diag_err.rx_10g_frame_diag_err
		.rx_10g_frame_diag_status  (rx_10g_frame_diag_status), // rx_10g_frame_diag_status.rx_10g_frame_diag_status
		.tx_10g_burst_en           (tx_10g_burst_en),          //          tx_10g_burst_en.tx_10g_burst_en
		.rx_10g_crc32err           (rx_10g_crc32err),          //          rx_10g_crc32err.rx_10g_crc32err
		.rx_10g_highber            (rx_10g_highber),           //           rx_10g_highber.rx_10g_highber
		.rx_10g_highber_clr_cnt    (rx_10g_highber_clr_cnt),   //   rx_10g_highber_clr_cnt.rx_10g_highber_clr_cnt
		.rx_10g_clr_errblk_count   (rx_10g_clr_errblk_count),  //  rx_10g_clr_errblk_count.rx_10g_clr_errblk_count
		.tx_cal_busy               (tx_cal_busy),              //              tx_cal_busy.tx_cal_busy
		.rx_cal_busy               (rx_cal_busy),              //              rx_cal_busy.rx_cal_busy
		.reconfig_to_xcvr          (reconfig_to_xcvr),         //         reconfig_to_xcvr.reconfig_to_xcvr
		.reconfig_from_xcvr        (reconfig_from_xcvr),       //       reconfig_from_xcvr.reconfig_from_xcvr
		
		.rx_seriallpbken           (rx_seriallpbken),                   //              (terminated)
		
		.tx_pll_refclk             (1'b0),                     //              (terminated)
		.pll_locked                (),                         //              (terminated)
		.rx_clkslip                ({NUMC{1'b0}}),                   //              (terminated)
		.rx_clklow                 (),                         //              (terminated)
		.rx_fref                   (),                         //              (terminated)
		.rx_signaldetect           (),                         //              (terminated)
		.tx_std_coreclkin          ({NUMC{1'b0}}),                   //              (terminated)
		.rx_std_coreclkin          ({NUMC{1'b0}}),                   //              (terminated)
		.tx_std_clkout             (),                         //              (terminated)
		.rx_std_clkout             (),                         //              (terminated)
		.tx_std_elecidle           ({NUMC{1'b0}}),                   //              (terminated)
		.tx_std_pcfifo_full        (),                         //              (terminated)
		.tx_std_pcfifo_empty       (),                         //              (terminated)
		.rx_std_pcfifo_full        (),                         //              (terminated)
		.rx_std_pcfifo_empty       (),                         //              (terminated)
		.rx_std_byteorder_ena      ({NUMC{1'b0}}),                   //              (terminated)
		.rx_std_byteorder_flag     (),                         //              (terminated)
		.rx_std_bitrev_ena         ({NUMC{1'b0}}),                   //              (terminated)
		.rx_std_byterev_ena        ({NUMC{1'b0}}),                   //              (terminated)
		.tx_std_polinv             ({NUMC{1'b0}}),                   //              (terminated)
		.rx_std_polinv             ({NUMC{1'b0}}),                   //              (terminated)
		.tx_std_bitslipboundarysel (15'b000000000000000),      //              (terminated)
		.rx_std_bitslipboundarysel (),                         //              (terminated)
		.rx_std_bitslip            ({NUMC{1'b0}}),                   //              (terminated)
		.rx_std_comma_det_ena      ({NUMC{1'b0}}),                   //              (terminated)
		.rx_std_wa_a1a2size        ({NUMC{1'b0}}),                   //              (terminated)
		.rx_std_rmfifo_full        (),                         //              (terminated)
		.rx_std_rmfifo_empty       (),                         //              (terminated)
		.rx_std_run_len_err        (),                         //              (terminated)
		.rx_std_signaldetect       ()                          //              (terminated)
	);

endmodule
