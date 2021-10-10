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

//------------------------------------------------------------------------------

`timescale 1ps/1ps

 module alt_aeu_40_top #(
        parameter REVID  = 32'h02062015,
        parameter TARGET_CHIP           = 5,
        parameter SYNOPT_AVALON         = 1,
        parameter PHY_REFCLK            = 1,
        parameter SYNOPT_CAUI4          = 0,
        parameter SYNOPT_C4_RSFEC       = 0,
        parameter SYNOPT_PTP            = 0,    // TBD: add in the 100G
    
		// new
        parameter PTP_LATENCY = 62,
    
        parameter SYNOPT_AVG_IPG        = 12,   // only 12 or 8 are supported
        parameter SYNOPT_LINK_FAULT     = 0,
        parameter SYNOPT_TXCRC_INS      = 1,
        parameter SYNOPT_MAC_DIC        = 1,
        parameter SYNOPT_MAC_RXSTATS    = 1, 
        parameter SYNOPT_MAC_TXSTATS    = 1, 
        parameter SYNOPT_PREAMBLE_PASS  = 0, 
        parameter SYNOPT_ALIGN_FCSEOP   = 1, 
        parameter SYNOPT_PAUSE_TYPE     = 0,    // 0:pause off, 1: pause on
        parameter SYNOPT_FULL_SKEW      = 1,    // 0:limited skew support, 1: IEEE spec skew support
        parameter SYNOPT_SYNC_E         = 0,    // 0:Sync-E Disable, 1: Sync-E Enable            
        parameter SYNOPT_96B_PTP        = 1,    // compile time option for timestamps, 96 bits or 64 bits
        parameter SYNOPT_64B_PTP        = 0,    // compile time option for timestamps, 96 bits or 64 bits
        parameter PTP_FP_WIDTH          = 1,   // width of fingerprint, ptp parameter

        parameter RXERRWIDTH            = 6,
        parameter RXSTATUSWIDTH         = 3,            
        parameter FCBITS                = 1,
        parameter WORDS                 = 4,
        parameter FASTSIM               = 0,
        parameter [139:0]FORCE_RO_SELS  = 0,      
        parameter [23:0]FORCE_BPOS      = 0,      
        parameter [35:0]FORCE_WPOS      = 0,
        parameter RST_CNTR              = 16,   // 6 for sim
        parameter AM_CNT_BITS           = 14,   // 6 for sim
        parameter SIM_FAKE_JTAG         = 1'b0,
        parameter CREATE_TX_SKEW = 1'b0, // debug skew the TX lanes
        parameter TIMING_MODE           = 1'b0,
        parameter EXT_TX_PLL            = 1'b0, // whether to use external fpll for TX core clocks
        //  KR4 parameters
        parameter ENA_KR4               = 0,
        parameter ES_DEVICE             = 1,    // select ES or PROD device, 1 is ES-DEVICE, 0 is device
        parameter KR_ADDR_PAGE          = 0,
        parameter SYNTH_AN              = 1,    // Synthesize/include the AN logic
        parameter SYNTH_LT              = 1,    // Synthesize/include the LT logic
        parameter SYNTH_SEQ             = 1,    // Synthesize/include Sequencer logic
        parameter SYNTH_FEC             = 0,    // Synthesize/include the FEC logic
        // Sequencer parameters not used in the AN block
        parameter LINK_TIMER_KR         = 504,  // Link Fail Timer for BASE-R PCS in ms
        // LT parameters
        parameter BERWIDTH              = 9,          // Width (>4) of the Bit Error counter
        parameter TRNWTWIDTH            = 7,           // Width (7,8) of Training Wait counter
        parameter MAINTAPWIDTH          = 5,           // Width of the Main Tap control
        parameter POSTTAPWIDTH          = 6,           // Width of the Post Tap control
        parameter PRETAPWIDTH           = 5,           // Width of the Pre Tap control
        parameter VMAXRULE              = 5'd30,       // VOD+Post+Pre <= Device Vmax 1200mv
        parameter VMINRULE              = 5'd6,        // VOD-Post-Pre >= Device VMin 165mv
        parameter VODMINRULE            = 5'd14,       // VOD >= IEEE VOD Vmin of 440mV
        parameter VPOSTRULE             = 6'd25,       // Post_tap <= VPOST
        parameter VPRERULE              = 5'd16,       // Pre_tap <= VPRE
        parameter PREMAINVAL            = 5'd30,       // Preset Main tap value
        parameter PREPOSTVAL            = 6'd0,        // Preset Post tap value
        parameter PREPREVAL             = 5'd0,        // Preset Pre tap value
        parameter INITMAINVAL           = 5'd25,       // Initialize Main tap value
        parameter INITPOSTVAL           = 6'd22,       // Initialize Post tap value
        parameter INITPREVAL            = 5'd3,        // Initialize Pre tap value
        parameter USE_DEBUG_CPU         = 0,           // Use the Debug version of the CPU
        // AN parameters
        parameter AN_CHAN               = 4'b0001,      // "master" channel to run AN on (one-hot)
        parameter AN_PAUSE              = 3'b011,       // Initial setting for Pause ability, depends upon MAC  
        parameter AN_TECH               = 6'b00_1000,   // Tech ability, only 40G-KR4 valid
                                                // bit-0 = GigE, bit-1 = XAUI
                                                // bit-2 = 10G , bit-3 = 40G BP
                                                // bit 4 = 40G-CR4, bit 5 = 100G-CR10
        parameter AN_SELECTOR           = 5'b0_0001,    // AN selector field 802.3 = 5'd1
        parameter CAPABLE_FEC           = 1,    // FEC ability on power on
        parameter ENABLE_FEC            = 1,    // FEC request on power on
        parameter ERR_INDICATION        = 0,    // Turn error indication on/off
        // PHY parameters
        parameter REF_CLK_FREQ_10G      = "644.53125 MHz", // speed for clk_ref
        parameter STATUS_CLK_KHZ        = 100000       // clk_status rate in Mhz
)(
        input wire              clk_ref,
        input wire              reset_async,
        
        input RX_CORE_CLK,
        input TX_CORE_CLK,

        input wire              clk_status,
        input wire              reset_status,
        input wire              status_write,
        input wire              status_read,
        input wire[15:0]        status_addr,
        input wire[31:0]        status_writedata,
        output wire[31:0]       status_readdata,
        output wire             status_readdata_valid,
        output wire             status_waitrequest,
        output wire             status_read_timeout,      
        
        input wire              clk_txmac_in, // used with EXT_TX_PLL, 312.5MHz derived from clk_ref
        output wire             tx_lanes_stable,
        input wire              l4_tx_startofpacket,
        input wire              l4_tx_endofpacket,
        input wire              l4_tx_error,
        input wire              l4_tx_valid,
        output wire             l4_tx_ready,
        input wire[4:0]         l4_tx_empty,
        input wire[WORDS*64-1:0] l4_tx_data,
        
        output wire             rx_pcs_ready,           // new
        output wire [RXERRWIDTH-1:0] l4_rx_error,               
        output wire [RXSTATUSWIDTH-1:0] l4_rx_status,                
        output wire             l4_rx_valid,
        output wire             l4_rx_startofpacket,
        output wire             l4_rx_endofpacket,
        output wire[WORDS*64-1:0] l4_rx_data,
        output wire[4:0]        l4_rx_empty,
        output wire             l4_rx_fcs_error,
        output wire             l4_rx_fcs_valid,
        
        input [2-1:0]     din_sop,        // word contains first data (on leftmost byte)
        input [2-1:0]     din_eop,        // byte position of last data
        input [2-1:0]     din_idle,       // bytes between EOP and SOP
        input [3*2-1:0]   din_eop_empty,  // byte position of last data
        input [2*64-1:0]  din,            // data, read left to right
        input [2-1:0]     tx_error,
        output                din_req,
        output                dout_valid,
        output [2*64-1:0] dout_d,
        output [2*8-1:0]  dout_c,
        output [2-1:0]    dout_sop,
        output [2-1:0]    dout_eop,
        output [2*3-1:0]  dout_eop_empty,
        output [2-1:0]    dout_idle,
        
                
        output wire [RXERRWIDTH-1:0] rx_error,  // referring to the non-zero last_data
        output wire [RXSTATUSWIDTH-1:0] rx_status,  // referring to the non-zero last_data 
        output wire rx_fcs_error,  // referring to the non-zero last_data
        output wire rx_fcs_valid,

        input wire[FCBITS-1:0]  pause_insert_tx,
        output wire[FCBITS-1:0] pause_receive_rx,
        output wire             unidirectional_en,
        output wire             link_fault_gen_en,
        output wire             remote_fault_status,
        output wire             local_fault_status,
 
        output wire             rx_inc_runt,
        output wire             rx_inc_64,
        output wire             rx_inc_127,
        output wire             rx_inc_255,
        output wire             rx_inc_511,
        output wire             rx_inc_1023,
        output wire             rx_inc_1518,
        output wire             rx_inc_max,
        output wire             rx_inc_over,
        output wire             rx_inc_mcast_data_err,
        output wire             rx_inc_mcast_data_ok,
        output wire             rx_inc_bcast_data_err,
        output wire             rx_inc_bcast_data_ok,
        output wire             rx_inc_ucast_data_err,
        output wire             rx_inc_ucast_data_ok,
        output wire             rx_inc_mcast_ctrl,
        output wire             rx_inc_bcast_ctrl,
        output wire             rx_inc_ucast_ctrl,
        output wire             rx_inc_pause,
        output wire             rx_inc_fcs_err,
        output wire             rx_inc_fragment,
        output wire             rx_inc_jabber,
        output wire             rx_inc_sizeok_fcserr,
        output wire             rx_inc_pause_ctrl_err,  // new.
        output wire             rx_inc_mcast_ctrl_err,  // new.
        output wire             rx_inc_bcast_ctrl_err,  // new.
        output wire             rx_inc_ucast_ctrl_err,  // new.
        output wire [15:0]      rx_inc_octetsOK,        // new.
        output wire             rx_inc_octetsOK_valid,  // new.

        output wire [15:0]      tx_inc_octetsOK,        // new.
        output wire             tx_inc_octetsOK_valid,  // new.
        output wire             tx_inc_64,
        output wire             tx_inc_127,
        output wire             tx_inc_255,
        output wire             tx_inc_511,
        output wire             tx_inc_1023,
        output wire             tx_inc_1518,
        output wire             tx_inc_max,
        output wire             tx_inc_over,
        output wire             tx_inc_mcast_data_err,
        output wire             tx_inc_mcast_data_ok,
        output wire             tx_inc_bcast_data_err,
        output wire             tx_inc_bcast_data_ok,
        output wire             tx_inc_ucast_data_err,
        output wire             tx_inc_ucast_data_ok,
        output wire             tx_inc_mcast_ctrl,
        output wire             tx_inc_bcast_ctrl,
        output wire             tx_inc_ucast_ctrl,
        output wire             tx_inc_pause,
        output wire             tx_inc_fcs_err,
        output wire             tx_inc_fragment,
        output wire             tx_inc_jabber,
        output wire             tx_inc_sizeok_fcserr,
   
        input  [95:0] tod_cust_in,
        output [95:0] tod_exit_cust,
        output [95:0] ts_out_cust,
        input tx_in_ptp_asm,
        output ts_out_cust_asm,
              
        input               tx_pll_locked,
           
         // begin ptp ports

         // tod ports
         input [95:0] rx_time_of_day_96b_data,
         input [63:0] rx_time_of_day_64b_data,
         input [95:0] tx_time_of_day_96b_data,
         input [63:0] tx_time_of_day_64b_data,
         
         // ports for 96 bit PTP synthesis option
         output [95:0] rx_ingress_timestamp_96b_data,
         output rx_ingress_timestamp_96b_valid,
         output [95:0] tx_egress_timestamp_96b_data,
         output tx_egress_timestamp_96b_valid,
         output [PTP_FP_WIDTH-1:0] tx_egress_timestamp_96b_fingerprint, // (width=n, max 16),
         input [95:0] tx_etstamp_ins_ctrl_ingress_timestamp_96b,
         // ports for 96 bit PTP synthesis option
         output [63:0] rx_ingress_timestamp_64b_data,
         output rx_ingress_timestamp_64b_valid,
         output [63:0] tx_egress_timestamp_64b_data,
         output tx_egress_timestamp_64b_valid,
         output [PTP_FP_WIDTH-1:0] tx_egress_timestamp_64b_fingerprint,   // (width=n, max 16),
         input [63:0] tx_etstamp_ins_ctrl_ingress_timestamp_64b,

         // ports for PTP for both options

         input tx_egress_timestamp_request_valid,
         input [PTP_FP_WIDTH-1:0] tx_egress_timestamp_request_fingerprint,
         input tx_egress_asymmetry_update,
         input tx_etstamp_ins_ctrl_timestamp_insert,
         input tx_etstamp_ins_ctrl_timestamp_format, // 1: ptp_v2, 0: ptpv1
         input tx_etstamp_ins_ctrl_residence_time_update,
         input tx_etstamp_ins_ctrl_residence_time_calc_format, // 1: ptp_v2, 0: ptpv1
         input tx_etstamp_ins_ctrl_checksum_zero,
         input tx_etstamp_ins_ctrl_checksum_correct,
         input [15:0] tx_etstamp_ins_ctrl_offset_timestamp,
         input [15:0] tx_etstamp_ins_ctrl_offset_correction_field,
         input [15:0] tx_etstamp_ins_ctrl_offset_checksum_field,
         input [15:0] tx_etstamp_ins_ctrl_offset_checksum_correction,

         // end PTP ports

		output pll_powerdown,
		output tx_analogreset,
		output tx_digitalreset,
		output rx_analogreset,
		output rx_digitalreset,
		
		output rxp_rst,
		input rxp_lock,
		output txp_rst,
		input txp_lock,
		
		input  [3:0]   eio_tx_clkout,
		input  [3:0]   eio_rx_clkout,

		input clk_tx_main,
		input clk_rx_main,

		output [4*40-1:0] eio_din,
		input [4*40-1:0] eio_dout,    
		output eio_tx_online,
		output eio_din_valid,
		output eio_dout_req,                 
		
		input [3:0] eio_freq_lock,
		output [3:0] eio_sloop,
		
		input [3:0] tx_full,
		input [3:0] tx_empty,
		input [3:0] tx_pfull,
		input [3:0] tx_pempty,
		
		input [3:0] rx_full,
		input [3:0] rx_empty,
		input [3:0] rx_pfull,
		input [3:0] rx_pempty,		

		input tx_cal_busy,
		input rx_cal_busy,
		output  set_data_lock,
		output set_ref_lock,
		
	   // debug text terminal
		output [7:0] byte_to_jtag,
		input [7:0] byte_from_jtag,
		output byte_to_jtag_valid,
		output byte_from_jtag_ack,
		
		input stacker_ram_ena			
  );
  
  wire clk_txmac;

   localparam SYNOPT_TOD_FMT = SYNOPT_96B_PTP ? (SYNOPT_64B_PTP ? 2:0):(SYNOPT_64B_PTP ? 1:0);
   
 // ____________________________________________________________________
 // 
    localparam EMPTYBITS        = 5 ;
    localparam TXDBGWIDTH       = 1;
    localparam RXDBGWIDTH       = 3;
    localparam CWORDS           = 2 ;
//    localparam PTPWIDTH         = 37;   
   localparam PTPWIDTH = PTP_FP_WIDTH + 1 +1 + 96 + 64 + 6 + 4*16 + 1;
   
    localparam DWIDTH           = WORDS*64+PTPWIDTH;    

 // ____________________________________________
 //     address map
 // ____________________________________________
    localparam BASE_GLB0        = 8'h0 ; // 02,03
    localparam BASE_GLB1        = 8'h1 ; // 02,03
    localparam BASE_TXPHY       = 8'h2 ; // 02,03
    localparam BASE_RXPHY       = 8'h3 ; // 02,03
    localparam BASE_TXMAC       = 8'h4 ; // 04,05
    localparam BASE_RXMAC       = 8'h5 ; // 06,07
    localparam BASE_TXFC        = 8'h6 ; // 12,13
    localparam BASE_RXFC        = 8'h7 ; // 14,15
    localparam BASE_TXSTAT      = 8'h8 ; // 08,09
    localparam BASE_RXSTAT      = 8'h9 ; // 10,11
    localparam BASE_TXPTP       = 8'ha ; // 16,17
    localparam BASE_RXPTP       = 8'hb ; // 18,19

    localparam MAX_BASES        = 16;
    localparam UNUSED_GLB0      = (ENA_KR4 == 0) ? 1'b1 : 1'b0;
    localparam UNUSED_GLB1      = 1'b1;
    localparam UNUSED_TXPHY     = 1'b1;
    localparam UNUSED_RXPHY     = 1'b0;
    localparam UNUSED_TXMAC     = 1'b0;
    localparam UNUSED_RXMAC     = 1'b0;
    localparam UNUSED_RXPAUSE   = (SYNOPT_PAUSE_TYPE == 0)      ? 1'b1 : 1'b0;
    localparam UNUSED_TXPAUSE   = (SYNOPT_PAUSE_TYPE == 0)      ? 1'b1 : 1'b0;
    localparam UNUSED_RXSTATS   = (SYNOPT_MAC_RXSTATS == 0)     ? 1'b1 : 1'b0;
    localparam UNUSED_TXSTATS   = (SYNOPT_MAC_TXSTATS == 0)     ? 1'b1 : 1'b0;
    localparam UNUSED_RXPTP     = (SYNOPT_PTP == 0)             ? 1'b1 : 1'b0;
    localparam UNUSED_TXPTP     = (SYNOPT_PTP == 0)             ? 1'b1 : 1'b0;

    localparam UNUSED_BASES     = {{4{1'b1}                             }       ,       // f,c
                                   {UNUSED_RXPTP        , UNUSED_TXPTP          ,       // b,a
                                    UNUSED_RXSTATS      , UNUSED_TXSTATS        ,       // 9,8
                                    UNUSED_RXPAUSE      , UNUSED_TXPAUSE        ,       // 7,6
                                    UNUSED_RXMAC        , UNUSED_TXMAC          ,       // 5,4
                                    UNUSED_RXPHY        , UNUSED_TXPHY          ,       // 3,2
                                    UNUSED_GLB1         , UNUSED_GLB0           }       // 1,0
                                  };    
 // ________________________________________________
    localparam BIT_FRAGMENTS            = 00; 
    localparam BIT_JABBERS              = 01; 
    localparam BIT_CRCERR               = 02; 
    localparam BIT_FCSERR_OKPKT         = 03; 
    localparam BIT_MCAST_DATA_ERR       = 04; 
    localparam BIT_BCAST_DATA_ERR       = 05; 
    localparam BIT_UCAST_DATA_ERR       = 06; 
    localparam BIT_MCAST_CTRL_ERR       = 07; 
    localparam BIT_BCAST_CTRL_ERR       = 08; 
    localparam BIT_UCAST_CTRL_ERR       = 09; 
    localparam BIT_PAUSE_ERR            = 10; 
    localparam BIT_64B                  = 11; 
    localparam BIT_65to127B             = 12; 
    localparam BIT_128to255B            = 13; 
    localparam BIT_256to511B            = 14; 
    localparam BIT_512to1023B           = 15; 
    localparam BIT_1024to1518B          = 16; 
    localparam BIT_1519toMAXB           = 17; 
    localparam BIT_OVERSIZE             = 18; 
    localparam BIT_MCAST_DATA_OK        = 19; 
    localparam BIT_BCAST_DATA_OK        = 20; 
    localparam BIT_UCAST_DATA_OK        = 21; 
    localparam BIT_MCAST_CTRL_OK        = 22; 
    localparam BIT_BCAST_CTRL_OK        = 23; 
    localparam BIT_UCAST_CTRL_OK        = 24; 
    localparam BIT_PAUSE                = 25; 
    localparam BIT_RNT                  = 26; 
 // _______________________________________________________
 // 
 
    wire [RXERRWIDTH-1:0]    adp_out_rx_error;
    wire [RXSTATUSWIDTH-1:0] adp_out_rx_status;                 
    wire [2-1:0]     din_sop_w;
    wire [2-1:0]     din_eop_w;
    wire [2-1:0]     din_error_w;
    wire [2-1:0]     din_idle_w;
    wire [3*2-1:0]   din_eop_empty_w;
    wire [2*64-1:0]  din_w;
    wire                din_req_w;
        wire                dout_valid_w;
    wire [2*64-1:0] dout_d_w;
    wire [2*8-1:0]  dout_c_w;
    wire [2-1:0]    dout_sop_w;
    wire [2-1:0]    dout_eop_w;
    wire [2*3-1:0]  dout_eop_empty_w;
    wire [2-1:0]    dout_idle_w;
 
 
    wire[31:0] out_tx_stats;
    wire[31:0] out_rx_stats;
	
    wire clk_tx_custom = clk_tx_main;
    wire clk_rx_custom = clk_rx_main;
    
    wire srst_tx_main;
    wire reset_tx_custom = srst_tx_main;
    
    wire srst_rx_main;
    wire reset_rx_custom = srst_rx_main;

    assign clk_txmac = clk_tx_custom;
    wire clk_tx_avalon  = clk_tx_custom;        // different in 100G (frequency differemnt)
    wire clk_rx_avalon  = clk_rx_custom;        // different in 100G (frequency differemnt)
    wire reset_tx_avalon= reset_tx_custom;      // different in 100G (frequency differemnt)
    wire reset_rx_avalon= reset_rx_custom;      // different in 100G (frequency differemnt)

   // e40_sync_arst reset_txavalon (clk_tx_avalon, reset_async, reset_tx_avalon);
   // e40_sync_arst reset_rxavalon (clk_rx_avalon, reset_async, reset_rx_avalon);

   //Tx avalon-st protocol filter
    wire         l4_tx_startofpacket_f;
    wire         l4_tx_endofpacket_f  ;
    wire [4:0]   l4_tx_empty_f        ;
    wire [3:0]   tx_avst_bus_err      ; 

 // ___________________________________________________________________________________________
 //     stats bits for the output
 // ___________________________________________________________________________________________
 //
   assign rx_inc_runt                   =  out_rx_stats [BIT_RNT        ];   
   assign rx_inc_64                     =  out_rx_stats [BIT_64B        ];   
   assign rx_inc_127                    =  out_rx_stats [BIT_65to127B   ];   
   assign rx_inc_255                    =  out_rx_stats [BIT_128to255B  ];   
   assign rx_inc_511                    =  out_rx_stats [BIT_256to511B  ];   
   assign rx_inc_1023                   =  out_rx_stats [BIT_512to1023B ];   
   assign rx_inc_1518                   =  out_rx_stats [BIT_1024to1518B];   
   assign rx_inc_max                    =  out_rx_stats [BIT_1519toMAXB ];   
   assign rx_inc_over                   =  out_rx_stats [BIT_OVERSIZE   ];   
   assign rx_inc_mcast_data_err         =  out_rx_stats [BIT_MCAST_DATA_ERR];   
   assign rx_inc_mcast_data_ok          =  out_rx_stats [BIT_MCAST_DATA_OK ];   
   assign rx_inc_bcast_data_err         =  out_rx_stats [BIT_BCAST_DATA_ERR];   
   assign rx_inc_bcast_data_ok          =  out_rx_stats [BIT_BCAST_DATA_OK ];   
   assign rx_inc_ucast_data_err         =  out_rx_stats [BIT_UCAST_DATA_ERR];   
   assign rx_inc_ucast_data_ok          =  out_rx_stats [BIT_UCAST_DATA_OK ];   
   assign rx_inc_mcast_ctrl             =  out_rx_stats [BIT_MCAST_CTRL_OK ];   
   assign rx_inc_bcast_ctrl             =  out_rx_stats [BIT_BCAST_CTRL_OK ];   
   assign rx_inc_ucast_ctrl             =  out_rx_stats [BIT_UCAST_CTRL_OK ];   
   assign rx_inc_pause                  =  out_rx_stats [BIT_PAUSE      ];   
   assign rx_inc_fcs_err                =  out_rx_stats [BIT_CRCERR     ];   
   assign rx_inc_fragment               =  out_rx_stats [BIT_FRAGMENTS  ];   
   assign rx_inc_jabber                 =  out_rx_stats [BIT_JABBERS    ];   
   assign rx_inc_sizeok_fcserr          =  out_rx_stats [BIT_FCSERR_OKPKT];   
   
   assign rx_inc_pause_ctrl_err         = out_rx_stats  [BIT_PAUSE_ERR  ];   
   assign rx_inc_mcast_ctrl_err         = out_rx_stats  [BIT_MCAST_CTRL_ERR];   
   assign rx_inc_bcast_ctrl_err         = out_rx_stats  [BIT_BCAST_CTRL_ERR];   
   assign rx_inc_ucast_ctrl_err         = out_rx_stats  [BIT_UCAST_CTRL_ERR];   
   
   
   assign tx_inc_64                     =  out_tx_stats [BIT_64B        ];   
   assign tx_inc_127                    =  out_tx_stats [BIT_65to127B   ];   
   assign tx_inc_255                    =  out_tx_stats [BIT_128to255B  ];   
   assign tx_inc_511                    =  out_tx_stats [BIT_256to511B  ];   
   assign tx_inc_1023                   =  out_tx_stats [BIT_512to1023B ];   
   assign tx_inc_1518                   =  out_tx_stats [BIT_1024to1518B];   
   assign tx_inc_max                    =  out_tx_stats [BIT_1519toMAXB ];   
   assign tx_inc_over                   =  out_tx_stats [BIT_OVERSIZE   ];   
   assign tx_inc_mcast_data_err         =  out_tx_stats [BIT_MCAST_DATA_ERR];   
   assign tx_inc_mcast_data_ok          =  out_tx_stats [BIT_MCAST_DATA_OK ];   
   assign tx_inc_bcast_data_err         =  out_tx_stats [BIT_BCAST_DATA_ERR];   
   assign tx_inc_bcast_data_ok          =  out_tx_stats [BIT_BCAST_DATA_OK ];   
   assign tx_inc_ucast_data_err         =  out_tx_stats [BIT_UCAST_DATA_ERR];   
   assign tx_inc_ucast_data_ok          =  out_tx_stats [BIT_UCAST_DATA_OK ];   
   assign tx_inc_mcast_ctrl             =  out_tx_stats [BIT_MCAST_CTRL_OK ];   
   assign tx_inc_bcast_ctrl             =  out_tx_stats [BIT_BCAST_CTRL_OK ];   
   assign tx_inc_ucast_ctrl             =  out_tx_stats [BIT_UCAST_CTRL_OK ];   
   assign tx_inc_pause                  =  out_tx_stats [BIT_PAUSE      ];   
   assign tx_inc_fcs_err                =  out_tx_stats [BIT_CRCERR     ];   
   assign tx_inc_fragment               =  out_tx_stats [BIT_FRAGMENTS  ];   
   assign tx_inc_jabber                 =  out_tx_stats [BIT_JABBERS    ];   
   assign tx_inc_sizeok_fcserr          =  out_tx_stats [BIT_FCSERR_OKPKT];   

 // ___________________________________________________________________________________
 //
  wire [1:0] rx_mii_start;
  wire [1:0] tx_mii_start;

  reg rx_pcs_fully_aligned = 1'b0;
  assign rx_pcs_ready = rx_pcs_fully_aligned;

 // ___________________________________________________________________________________
 //
 //     serial csr interface module
 // ___________________________________________________________________________________
 //
  wire efc_s_dout;
  wire e40_slave_dout; 
  wire serif_slave_out_ptp;
  wire          status_ser_din;
   
  wire serif_m_dout;
  reg serif_m_din=1;

  always @(posedge clk_status) begin serif_m_din  <= e40_slave_dout & efc_s_dout & serif_slave_out_ptp & status_ser_din; end
   assign status_ser_din                           = 1'b1;
   
   // synthesis translate_off
   generate if(FASTSIM == 1) begin
      initial begin
         force rpcs.ro_sels  = FORCE_RO_SELS;      
         force rpcs.bpos     = FORCE_BPOS;      
         force rpcs.wpos     = FORCE_WPOS;
         
         while(rxp_lock == 1'b0 || txp_lock == 1'b0) begin
            @(posedge clk_txmac);
            
         end
         repeat(11000) @(posedge clk_txmac);
         force rpcs.fully_aligned  = 1;
      end
   end
   endgenerate
   // synthesis translate_on   

    
 wire rst100;

  serif_master #(.INVALID_BASES( UNUSED_BASES), .MAX_BASES(MAX_BASES)) sm (
      .clk              (clk_status),
      .sclr		(rst100),
      .din              (serif_m_din),
      .dout             (serif_m_dout),
      .busy             (status_waitrequest),
      .read_timeout     (status_read_timeout),
      .wr               (status_write),
      .rd               (status_read),
      .addr             (status_addr),
      .wdata            (status_writedata),
      .rdata            (status_readdata),
      .rdata_valid      (status_readdata_valid)
  );

   // ptp port assignments


    wire [PTP_FP_WIDTH-1:0] fp_out_req;
    wire ts_out_req;
    wire [95:0] ing_ts_96;
    wire [63:0] ing_ts_64;
    wire ins_ts;
    wire ins_ts_format;
    wire tx_asym;
    wire upd_corr;
    wire chk_sum_zero;
    wire chk_sum_upd;
    wire corr_format;
    wire [15:0] ts_offset;
    wire [15:0] corr_offset;
    wire [15:0] chk_sum_zero_offset;
    wire [15:0] chk_sum_upd_offset;

    wire [PTP_FP_WIDTH-1:0] fp_out_req_adp;
    wire ts_out_req_adp;
    wire [95:0] ing_ts_96_adp;
    wire [63:0] ing_ts_64_adp;
    wire ins_ts_adp;
    wire ins_ts_format_adp;
    wire tx_asym_adp;
    wire upd_corr_adp;
    wire chk_sum_zero_adp;
    wire chk_sum_upd_adp;
    wire corr_format_adp;
    wire [15:0] ts_offset_adp;
    wire [15:0] corr_offset_adp;
    wire [15:0] chk_sum_zero_offset_adp;
    wire [15:0] chk_sum_upd_offset_adp;

    wire [160-1:0] ts_exit;
    wire ts_exit_valid;
    wire [PTP_FP_WIDTH-1:0] fp_out;

//   assign tod_txmac_in = SYNOPT_96B_PTP ? tx_time_of_day_96b_data : tx_time_of_day_64b_data;
//   assign tod_rxmac_in = SYNOPT_96B_PTP ? rx_time_of_day_96b_data : rx_time_of_day_64b_data;
   
   assign tx_egress_timestamp_96b_data = ts_exit[159:64];
   assign tx_egress_timestamp_64b_data = ts_exit[63:0];
   assign tx_egress_timestamp_96b_valid = ts_exit_valid;
   assign tx_egress_timestamp_64b_valid = ts_exit_valid;
   assign tx_egress_timestamp_96b_fingerprint = fp_out;
   assign tx_egress_timestamp_64b_fingerprint = fp_out;

   assign fp_out_req = tx_egress_timestamp_request_fingerprint;
   assign ts_out_req = tx_egress_timestamp_request_valid;

//   assign ing_ts = SYNOPT_96B_PTP ? tx_etstamp_ins_ctrl_ingress_timestamp_96b : tx_etstamp_ins_ctrl_ingress_timestamp_64b;
   assign ing_ts_96 = tx_etstamp_ins_ctrl_ingress_timestamp_96b;
   assign ing_ts_64 = tx_etstamp_ins_ctrl_ingress_timestamp_64b;
   assign ins_ts = tx_etstamp_ins_ctrl_timestamp_insert;
   assign ins_ts_format = tx_etstamp_ins_ctrl_timestamp_format;
   assign tx_asym = tx_egress_asymmetry_update;
   assign upd_corr = tx_etstamp_ins_ctrl_residence_time_update;
   assign chk_sum_zero = tx_etstamp_ins_ctrl_checksum_zero;
   assign chk_sum_upd = tx_etstamp_ins_ctrl_checksum_correct;

   assign ts_offset = tx_etstamp_ins_ctrl_offset_timestamp;
   assign corr_offset = tx_etstamp_ins_ctrl_offset_correction_field;
   assign corr_format = tx_etstamp_ins_ctrl_residence_time_calc_format;
   assign chk_sum_zero_offset = tx_etstamp_ins_ctrl_offset_checksum_field;
   assign chk_sum_upd_offset = tx_etstamp_ins_ctrl_offset_checksum_correction;

   wire [159:0]                                         rx_tod;                 // ts for a packet going to the system
   assign rx_ingress_timestamp_96b_data = rx_tod[159:64];
   assign rx_ingress_timestamp_96b_valid = l4_rx_startofpacket & l4_rx_valid;
   assign rx_ingress_timestamp_64b_data = rx_tod[63:0];
   assign rx_ingress_timestamp_64b_valid = l4_rx_startofpacket & l4_rx_valid;

   


 // ___________________________________________________________________________________
 //
 //     flow control module 
 // ___________________________________________________________________________________
 //
 

  wire ptp_out_tx_sop;
  wire ptp_out_tx_eop;
  wire ptp_out_tx_valid;
  wire ptp_out_tx_ready;
  wire [EMPTYBITS-1:0] ptp_out_tx_empty;
  wire [WORDS*64-1:0] ptp_out_tx_data;

  wire adp_in_tx_ready;
  wire adp_in_tx_sop;
  wire adp_in_tx_eop;
  wire adp_in_tx_valid;
  wire [EMPTYBITS-1:0] adp_in_tx_empty;
  wire [WORDS*64-1:0] adp_in_tx_data;

  wire adp_out_rx_valid;
  wire adp_out_rx_sop;
  wire adp_out_rx_eop;
  wire [WORDS*64-1:0] adp_out_rx_data;
  wire [EMPTYBITS-1:0] adp_out_rx_empty;

  wire efc_out_tx_eop;
  wire efc_out_tx_error;
  wire efc_out_tx_sop;
  wire efc_out_tx_valid;
  wire [WORDS*64-1:0]efc_out_tx_data;
  wire [EMPTYBITS-1:0] efc_out_tx_empty ;

  wire [PTPWIDTH-1:0] efc_out_txptp;                    //= {1'b0,1'b1, 12'd9}; // temporary
  wire efc_out_tx_ptp ;                                 //= 1'b0; // need to come out of efc100
  wire [1:0] efc_out_tx_overwrite ;                     //= 1'b1;// need to come out of efc100
  wire [15:0] efc_out_tx_offset ;                       //= 12'd9;// need to come out of efc100
  wire       efc_out_tx_ptp_asm;
  wire       efc_out_tx_zero_tcp;
  wire [15:0] efc_out_tx_tcp_offset;
//   assign {efc_out_tx_ptp,efc_out_tx_overwrite,efc_out_tx_offset,efc_out_tx_ptp_asm,efc_out_tx_zero_tcp,efc_out_tx_tcp_offset} = efc_out_txptp;
        assign                             {
                                                fp_out_req_adp,
                                                ts_out_req_adp,
                                                ing_ts_96_adp,
                                                ing_ts_64_adp,
                                                ins_ts_adp,
                                                ins_ts_format_adp,
                                                                                            tx_asym_adp,
                                                upd_corr_adp,
                                                chk_sum_zero_adp,
                                                chk_sum_upd_adp,
                                                corr_format_adp,
                                                ts_offset_adp,
                                                corr_offset_adp,
                                                chk_sum_zero_offset_adp,
                                                chk_sum_upd_offset_adp,
                                                efc_out_tx_ptp_asm
                                                } = efc_out_txptp;
   
//   wire [PTPWIDTH-1:0] tx_ptp_din = {tx_in_ptp, tx_in_ptp_overwrite, tx_in_ptp_offset,tx_in_ptp_asm,tx_in_zero_tcp,tx_in_tcp_offset};

   wire [PTPWIDTH-1:0] tx_ptp_din = 
                                           {
                                                fp_out_req,
                                                ts_out_req,
                                                ing_ts_96,
                                                ing_ts_64,
                                                ins_ts,
                                                ins_ts_format,
                                                                                            tx_asym,
                                                upd_corr,
                                                chk_sum_zero,
                                                chk_sum_upd,
                                                corr_format,
                                                ts_offset,
                                                corr_offset,
                                                chk_sum_zero_offset,
                                                chk_sum_upd_offset,
                                                tx_in_ptp_asm
                                                };
   

  wire[TXDBGWIDTH-1:0] efc_out_tx_debug;
  wire[RXDBGWIDTH-1:0] efc_out_rx_ptp;
  wire[TXDBGWIDTH-1:0] tx_in_debug = {TXDBGWIDTH{1'b0}};
  wire[RXDBGWIDTH-1:0] efc_in_rx_debug = {RXDBGWIDTH{1'b0}};

   wire                efc_out_rx_valid;
   wire                efc_out_rx_startofpacket;
   wire                efc_out_rx_endofpacket;
   wire [WORDS*64-1:0] efc_out_rx_data;
   wire [4:0]          efc_out_rx_empty;
   wire [RXERRWIDTH-1:0]    efc_out_rx_error ;
   wire [RXSTATUSWIDTH-1:0] efc_out_rx_status;
   wire                efc_out_rx_fcs_valid;
   wire                efc_out_rx_del_pkt;
   assign efc_out_rx_del_pkt = &efc_out_rx_ptp;
    wire efc_in_rx_ready;
    wire adp_out_rx_fcs_error_valid;

  alt_aeu_40_efc_top #( 
       .SYNOPT_PREAMBLE_PASS (SYNOPT_PREAMBLE_PASS),
       .SYNOPT_ALIGN_FCSEOP  (SYNOPT_ALIGN_FCSEOP),
       .SYNOPT_PAUSE_TYPE    (SYNOPT_PAUSE_TYPE),
       .TARGET_CHIP          (TARGET_CHIP),
       .BASE_TXFC            (BASE_TXFC),
       .BASE_RXFC            (BASE_RXFC),
       .REVID                (REVID),
       .DWIDTH               (DWIDTH),
       .RXERRWIDTH           (RXERRWIDTH),
       .TXDBGWIDTH           (TXDBGWIDTH),
       .RXDBGWIDTH           (RXDBGWIDTH),
       .WORDS                (WORDS),
       .FCBITS               (FCBITS),
       .EMPTYBITS            (EMPTYBITS))
  efc40 (
        .clk_mm             (clk_status),
        .reset_mm           (reset_status),  //this input has not logic connect to it
        .smm_slave_dout     (efc_s_dout),
        .smm_master_dout    (serif_m_dout),
                                         
        .clk_tx             (clk_tx_avalon),
        .reset_tx_n         (~reset_tx_avalon),
        .tx_in_ready        (l4_tx_ready),
        .tx_in_valid        (l4_tx_valid),
        .tx_in_sop          (l4_tx_startofpacket_f),
        .tx_in_eop          (l4_tx_endofpacket_f),
        .tx_in_empty        (l4_tx_empty_f),
        .tx_in_data         ({tx_ptp_din,l4_tx_data}),
        .tx_in_error        (l4_tx_error),
        .tx_in_debug        (tx_in_debug),
                                         
        .tx_out_ready       (adp_in_tx_ready),
        .tx_out_valid       (efc_out_tx_valid),
        .tx_out_sop         (efc_out_tx_sop),
        .tx_out_eop         (efc_out_tx_eop),
        .tx_out_data        ({efc_out_txptp,efc_out_tx_data}),
        .tx_out_empty       (efc_out_tx_empty),
        .tx_out_error       (efc_out_tx_error),
        .tx_out_debug       (efc_out_tx_debug),
                                         
        .clk_rx             (clk_rx_avalon),
        .reset_rx_n         (~reset_rx_avalon),
        .rx_in_ready        (efc_in_rx_ready),
        .rx_in_valid        (adp_out_rx_valid),
        .rx_in_sop          (adp_out_rx_sop),
        .rx_in_eop          (adp_out_rx_eop),
        .rx_in_data         (adp_out_rx_data),
        .rx_in_empty        (adp_out_rx_empty),
        .rx_in_error        (adp_out_rx_error),
        .rx_in_status       (adp_out_rx_status),  
        .rx_in_error_valid  (adp_out_rx_fcs_error_valid),
        .rx_in_debug        (efc_in_rx_debug),
                                         
        .rx_out_ready       (1'b1),
        .rx_out_valid       (efc_out_rx_valid),
        .rx_out_sop         (efc_out_rx_startofpacket),
        .rx_out_eop         (efc_out_rx_endofpacket),
        .rx_out_data        (efc_out_rx_data),
        .rx_out_empty       (efc_out_rx_empty),
        .rx_out_error       (efc_out_rx_error ),
        .rx_out_status      (efc_out_rx_status), 
        .rx_out_error_valid (efc_out_rx_fcs_valid),
        .rx_out_debug       (efc_out_rx_ptp),
                                         
        .tx_in_pause        (pause_insert_tx),
        .rx_out_pause       (pause_receive_rx)
  );


   
   // connections for ptp
   wire ptp_tx_pause_val; 
   wire pcs_din_am;      
   
   wire rx_mac_sop_out_m1;

   assign adp_in_tx_sop   = efc_out_tx_sop   ;
   assign adp_in_tx_eop   = efc_out_tx_eop   ;
   assign adp_in_tx_valid = efc_out_tx_valid ;
   assign adp_in_tx_empty = efc_out_tx_empty ;
   assign adp_in_tx_data  = efc_out_tx_data  ;

 // _____________________________________________________________________________      
 //     4word to 2word adapter interfacing the custom-st and 
 //     the avalon-st interfaces on the two sides of this module
 // _____________________________________________________________________________      
  wire dout_valid_adp;
  wire [CWORDS-1:0] dout_sop_adp;
  wire [CWORDS-1:0] dout_eop_adp;
  wire [CWORDS-1:0] dout_idle_adp;
  wire [CWORDS*64-1:0] dout_d_adp;
  wire [CWORDS*03-1:0] dout_eop_empty_adp;

  wire  din_req_adp;
  wire [CWORDS-1:0] din_sop_adp; // word contains first data (on leftmost byte)
  wire [CWORDS-1:0] din_eop_adp; // byte position of last data
  wire [CWORDS-1:0] din_error_adp; 
  wire [CWORDS-1:0] din_idle_adp;// bytes between EOP and SOP
  wire [CWORDS*64-1:0] din_adp;  // data, read left to right
  wire [CWORDS*03-1:0] din_eop_empty_adp;       // byte position of last data

generate
if (SYNOPT_AVALON) begin
  alt_aeu_40_adapter_2#(
        .TARGET_CHIP            (TARGET_CHIP)
       ,.SYNOPT_ALIGN_FCSEOP    (SYNOPT_ALIGN_FCSEOP) 
       ,.RXERRWIDTH             (RXERRWIDTH)
       ,.RXSTATUSWIDTH          (RXSTATUSWIDTH)                 
                                
        )ast_inst (
        .l4_tx_ready            (adp_in_tx_ready     ),
        .l4_tx_valid            (adp_in_tx_valid    ),
        .l4_tx_startofpacket    (adp_in_tx_sop      ),
        .l4_tx_endofpacket      (adp_in_tx_eop      ),
        .l4_tx_data             (adp_in_tx_data     ),
        .l4_tx_empty            (adp_in_tx_empty    ),
        .l4_tx_error            (efc_out_tx_error   ),

        .clk_txmac              (clk_tx_custom       ),
        .tx_arst                (reset_tx_custom|reset_async),
        .tx2l_d                 (din_adp                     ),
        .tx2l_sop               (din_sop_adp         ),
        .tx2l_eop               (din_eop_adp         ),
        .tx2l_idle              (din_idle_adp        ),
        .tx2l_ack               (din_req_adp         ),
        .tx2l_eop_empty         (din_eop_empty_adp           ),
        .tx2l_error             (din_error_adp       ),

        .l4_rx_valid            (adp_out_rx_valid    ),
        .l4_rx_startofpacket    (adp_out_rx_sop      ),
        .l4_rx_endofpacket      (adp_out_rx_eop      ),
        .l4_rx_data             (adp_out_rx_data     ),
        .l4_rx_empty            (adp_out_rx_empty    ),
        .l4_rx_error            (adp_out_rx_error),
        .l4_rx_status           (adp_out_rx_status),   
        .l4_rx_fcs_valid        (adp_out_rx_fcs_error_valid),

        .clk_rxmac              (clk_rx_custom       ),         // MAC + PCS clock - at least 312.5Mhz
        .rx_arst                (reset_async | reset_rx_custom | ~rx_pcs_fully_aligned),
        .rx2l_d                 (dout_d_adp                   ),        // 4 lane payload to send
        .rx2l_sop               (dout_sop_adp        ),         // 4 lane start position
        .rx2l_idle              (dout_idle_adp       ),         // 4 lane idle position
        .rx2l_eop               (dout_eop_adp        ),         // 4 lane end position any byte
        .rx2l_error             (rx_error            ),
        .rx2l_status            (rx_status           ),            
        .rx2l_fcs_valid         (rx_fcs_valid        ),         // payload is accepted
        .rx2l_valid             (dout_valid_adp      ),         // payload is accepted
        .rx2l_eop_empty         (dout_eop_empty_adp          )          // 4 lane # of empty bytes
        );
end
assign din_sop_w           = (SYNOPT_AVALON)  ? din_sop_adp                : din_sop;
assign din_eop_w           = (SYNOPT_AVALON)  ? din_eop_adp                : din_eop;   
assign din_error_w         = (SYNOPT_AVALON)  ? din_error_adp              : tx_error;   
assign din_idle_w          = (SYNOPT_AVALON)  ? din_idle_adp               : din_idle;  
assign din_eop_empty_w     = (SYNOPT_AVALON)  ? din_eop_empty_adp          : din_eop_empty;     
assign din_w               = (SYNOPT_AVALON)  ? din_adp                    : din;
assign din_req_adp         = (SYNOPT_AVALON)  ? din_req_w                  : 1'b0;
assign din_req             = (SYNOPT_AVALON == 0)  ? din_req_w                  : 1'b0;
assign dout_valid_adp      = (SYNOPT_AVALON)  ? dout_valid_w               : 1'b0;
assign dout_d_adp          = (SYNOPT_AVALON)  ? dout_d_w                   : 128'b0;
assign dout_sop_adp        = (SYNOPT_AVALON)  ? dout_sop_w                 : 2'b0;
assign dout_eop_adp        = (SYNOPT_AVALON)  ? dout_eop_w                 : 2'b0;
assign dout_eop_empty_adp  = (SYNOPT_AVALON)  ? dout_eop_empty_w           : 6'b0;
assign dout_idle_adp       = (SYNOPT_AVALON)  ? dout_idle_w                : 2'b0;
assign dout_valid          = (SYNOPT_AVALON == 0) ? dout_valid_w               : 1'b0;
assign dout_d              = (SYNOPT_AVALON == 0) ? dout_d_w                   : 128'b0;
assign dout_c              = (SYNOPT_AVALON == 0) ? dout_c_w                   : 16'b0;
assign dout_sop            = (SYNOPT_AVALON == 0) ? dout_sop_w                 : 2'b0;
assign dout_eop            = (SYNOPT_AVALON == 0) ? dout_eop_w                 : 2'b0;
assign dout_eop_empty      = (SYNOPT_AVALON == 0) ? dout_eop_empty_w           : 6'b0;
assign dout_idle           = (SYNOPT_AVALON == 0) ? dout_idle_w                : 2'b0;
endgenerate

   wire                ptp_v2;
   wire                ptp_s2;
   wire [31:0]         ext_lat;
//   wire [95:0]         tod_txmclk;
   wire [95:0]         tod_rxmclk;
   wire [19:0]         txmclk_period;
   wire [18:0]             tx_asym_delay;
   wire [31:0]             tx_pma_delay;
   wire                cust_mode;
   wire [19:0]         rxmclk_period;
   wire [31:0]             rx_pma_delay;
   
   
   defparam eck. TARGET_CHIP = TARGET_CHIP;
   defparam eck. SYNOPT_PTP = SYNOPT_PTP;
   defparam eck. CSRADDRSIZE = 8;
   defparam eck. BASE_TXPTP = BASE_TXPTP;
   defparam eck. BASE_RXPTP = BASE_RXPTP;
   defparam eck. REVID = REVID;
   
   alt_aeu_clks_40 eck 
     (
      .reset_csr(reset_status),
      .clk_csr(clk_status),
      .serif_master_din(serif_m_dout),
      .serif_slave_out_ptp(serif_slave_out_ptp),
      .rst_txmac(reset_tx_custom),
      .rst_rxmac(reset_rx_custom),
      
      .ptp_v2(ptp_v2),
      .ptp_s2(ptp_s2),
      .ext_lat(ext_lat),
      .txmclk_period(txmclk_period),
      .rxmclk_period(rxmclk_period),
      .tx_asym_delay(tx_asym_delay),
      .tx_pma_delay(tx_pma_delay),
      .cust_mode(cust_mode),
      .rx_pma_delay(rx_pma_delay),
      
      .clk_txmac(clk_tx_custom), // mac tx clk
      .clk_rxmac(clk_rx_custom)  // mac rx clk
      );
   
   defparam ptr.TARGET_CHIP = TARGET_CHIP;
   defparam ptr.SYNOPT_PTP = SYNOPT_PTP;
   defparam ptr.WORDS = 4;
   defparam ptr.EMPTYBITS = 5;
   defparam ptr.SYNOPT_TOD_FMT = SYNOPT_TOD_FMT;

   wire [35:0]         wpos;
   wire [8:0]          dsk_av_depth;

alt_aeu_fifo_depth_40 dsk
  (
   .clk(clk_rx_custom),
   .wpos(wpos[35:0]),
   .en (4'b1111),
   .av_depth(dsk_av_depth)
   );

  defparam dsk.SYNOPT_FULL_SKEW = SYNOPT_FULL_SKEW;
   

   defparam ptr.SYNOPT_PTP = SYNOPT_PTP;
   defparam ptr.TARGET_CHIP = TARGET_CHIP;
   defparam ptr.RXERRWIDTH = RXERRWIDTH;

alt_aeu_ptp_rx_40 ptr
     (
      .rst_rxmac(reset_rx_custom),
      .rxmclk_period(rxmclk_period),
          .rx_pma_delay(rx_pma_delay),
      .tod_rxmclk(tod_rxmclk),
         .tod_96b_rxmac_in(rx_time_of_day_96b_data),
         .tod_64b_rxmac_in(rx_time_of_day_64b_data),
      .rxmac_sop_in(|rx_mii_start),
      .dsk_av_depth(dsk_av_depth),
      .din_valid(efc_out_rx_valid),
      .din(efc_out_rx_data),
      .din_sop(efc_out_rx_startofpacket),
      .din_eop(efc_out_rx_endofpacket),
      .din_empty(efc_out_rx_empty),
      .din_fcs_error(efc_out_rx_error ),
      .din_rx_status(efc_out_rx_status),
      .din_fcs_valid(efc_out_rx_fcs_valid),
      .dbg_in(),
      .din_pkt_del(efc_out_rx_del_pkt),
      .dout_valid(l4_rx_valid),
      .dout(l4_rx_data),
      .dout_sop(l4_rx_startofpacket),
      .dout_eop(l4_rx_endofpacket),
      .dout_empty(l4_rx_empty),
      .dout_fcs_error(l4_rx_error ),
      .dout_rx_status(l4_rx_status), 
      .dout_fcs_valid(l4_rx_fcs_valid),
      .dbg_out(),
      .rx_tod(rx_tod),
      .clk_rxmac(clk_rx_custom)
 );
   
   
   wire e40_slave_dout_m;
   wire e40_slave_dout_p;
   assign e40_slave_dout = e40_slave_dout_m & e40_slave_dout_p;
   
//------------------------------------------------------------------------------         
//      100G Ethernet module including MAC and PHY submodules
//------------------------------------------------------------------------------         
  
// between the PCS and the TXMAC
wire pre_pcs_din_am;
wire [CWORDS*8-1:0]  pcs_din_c;
wire [CWORDS*64-1:0] pcs_din_d;
wire tx_crc_ins_en;

// between the PCS and the RXMAC
wire [CWORDS*64-1:0] pcs_dout_d; 
wire [CWORDS*8-1:0] pcs_dout_c;      
wire pcs_dout_am; 
  
   alt_aeu_40_eth_2 #( 
       .TARGET_CHIP            (TARGET_CHIP),
       .SYNOPT_PTP             (SYNOPT_PTP), 
       .SYNOPT_TOD_FMT         (SYNOPT_TOD_FMT),
       .REVID                  (REVID),
       .PHY_REFCLK             (PHY_REFCLK),
       .SYNOPT_CAUI4           (SYNOPT_CAUI4), 
       .SYNOPT_C4_RSFEC        (SYNOPT_C4_RSFEC), 
       .SYNOPT_AVG_IPG         (SYNOPT_AVG_IPG), 
       .SYNOPT_MAC_RXSTATS     (SYNOPT_MAC_RXSTATS), 
       .SYNOPT_MAC_TXSTATS     (SYNOPT_MAC_TXSTATS), 
       .SYNOPT_ALIGN_FCSEOP    (SYNOPT_ALIGN_FCSEOP), 
       .SYNOPT_PREAMBLE_PASS   (SYNOPT_PREAMBLE_PASS), 
       .SYNOPT_LINK_FAULT      (SYNOPT_LINK_FAULT),
       .SYNOPT_TXCRC_INS       (SYNOPT_TXCRC_INS),
       .SYNOPT_MAC_DIC         (SYNOPT_MAC_DIC),
       .SYNOPT_FULL_SKEW       (SYNOPT_FULL_SKEW),
       .BASE_PHY               (BASE_RXPHY), 
       .BASE_TXMAC             (BASE_TXMAC),
       .BASE_RXMAC             (BASE_RXMAC),
       .BASE_TXSTAT            (BASE_TXSTAT),
       .BASE_RXSTAT            (BASE_RXSTAT),
       .WORDS                  (CWORDS),
       .SIM_FAKE_JTAG          (SIM_FAKE_JTAG),
       .AM_CNT_BITS            (AM_CNT_BITS),           // 14 nom, 6 Ok for sim
       .RST_CNTR               (RST_CNTR),              // nominal 16/20  or 6 for fast simulation of reset seq
       .CREATE_TX_SKEW         (CREATE_TX_SKEW),
       .TIMING_MODE        (TIMING_MODE),
       .EXT_TX_PLL         (EXT_TX_PLL),
       .ENA_KR4            (ENA_KR4),
       .ES_DEVICE          (ES_DEVICE),
       .KR_ADDR_PAGE       (BASE_GLB0),
       .SYNTH_AN           (SYNTH_AN),
       .SYNTH_LT           (SYNTH_LT),
       .SYNTH_SEQ          (SYNTH_SEQ),
       .SYNTH_FEC          (SYNTH_FEC),
       .LINK_TIMER_KR      (LINK_TIMER_KR),
       .BERWIDTH           (BERWIDTH),
       .TRNWTWIDTH         (TRNWTWIDTH),
       .MAINTAPWIDTH       (MAINTAPWIDTH),
       .POSTTAPWIDTH       (POSTTAPWIDTH),
       .PRETAPWIDTH        (PRETAPWIDTH),
       .VMAXRULE           (VMAXRULE),
       .VMINRULE           (VMINRULE),
       .VODMINRULE         (VODMINRULE),
       .VPOSTRULE          (VPOSTRULE),
       .VPRERULE           (VPRERULE),
       .PREMAINVAL         (PREMAINVAL),
       .PREPOSTVAL         (PREPOSTVAL),
       .PREPREVAL          (PREPREVAL),
       .INITMAINVAL        (INITMAINVAL),
       .INITPOSTVAL        (INITPOSTVAL),
       .INITPREVAL         (INITPREVAL),
       .USE_DEBUG_CPU      (USE_DEBUG_CPU),
       .AN_CHAN            (AN_CHAN),
       .AN_PAUSE           (AN_PAUSE),
       .AN_TECH            (AN_TECH),
       .CAPABLE_FEC        (CAPABLE_FEC),
       .ENABLE_FEC         (ENABLE_FEC),
       .AN_SELECTOR        (AN_SELECTOR),
       .ERR_INDICATION     (ERR_INDICATION),
       .REF_CLK_FREQ_10G   (REF_CLK_FREQ_10G),
       .STATUS_CLK_KHZ     (STATUS_CLK_KHZ),
       .PTP_FP_WIDTH(PTP_FP_WIDTH)
//         ,.PTP_TS_WIDTH(PTP_TS_WIDTH)
                                           
  )e40_inst (
        .RX_CORE_CLK(RX_CORE_CLK),
        .TX_CORE_CLK(TX_CORE_CLK),
        
        //Sync-E
        .clk_rx_recover (), 
             
        // CSR access
        .avmm_clk               (clk_status),
        .avmm_reset             (reset_status|reset_async),  //global reset, async, syncer in submodule      
        .e40_slave_dout         (e40_slave_dout_m),
        .pcs_slave_din          (serif_m_dout),

        // no connect tx cgmii interface                
        .pcs_din_am             (),   
		.pre_pcs_din_am (pre_pcs_din_am),
        .pcs_din_c              (pcs_din_c),     
        .pcs_din_d              (pcs_din_d),
        .tx_crc_ins_en  (tx_crc_ins_en),
        .wpos (),

		.pcs_dout_c (pcs_dout_c),
		.pcs_dout_d (pcs_dout_d),
		.pcs_dout_am (pcs_dout_am),

        // from the adapter                
        .srst_tx_main           (reset_tx_custom),
        .tx_lanes_stable        (),
        .clk_txmac_in           (clk_txmac_in),
        .clk_tx_main            (clk_tx_custom),                
        .din_sop                (din_sop_w),            
        .din_eop                (din_eop_w),   
        .din_error              (din_error_w),
        .din_idle               (din_idle_w),   
        .din_eop_empty          (din_eop_empty_w), 
        .din                    (din_w),                
        .din_req                (din_req_w),            
        .din_bus_error          (),
                 
        .clk_rx_main            (clk_rx_custom),
        .srst_rx_main           (reset_rx_custom),
        .dout_valid             (dout_valid_w),
        .dout_d                 (dout_d_w),
        .dout_c                 (dout_c_w),
        .dout_sop               (dout_sop_w),
        .dout_eop               (dout_eop_w),
        .dout_eop_empty         (dout_eop_empty_w),
        .dout_idle              (dout_idle_w),
        .rx_error               (rx_error),
        .rx_status              (rx_status),     
        .rx_fcs_error           (rx_fcs_error),  // referring to the non-zero last_data
        .rx_fcs_valid           (rx_fcs_valid),
        .rx_pcs_fully_aligned   (rx_pcs_fully_aligned),
        .unidirectional_en      (unidirectional_en),
        .link_fault_gen_en      (link_fault_gen_en),
        .remote_fault_status    (remote_fault_status),
        .local_fault_status     (local_fault_status),
        .rx_mii_start           (rx_mii_start),
        
		.tod_96b_txmac_in(tx_time_of_day_96b_data),
		.tod_64b_txmac_in(tx_time_of_day_64b_data),
		.txmclk_period(txmclk_period),
		.tx_asym_delay(tx_asym_delay),
		.tx_pma_delay(tx_pma_delay),
		.cust_mode(cust_mode),

		.ext_lat(ext_lat),
		.din_ptp_dbg_adp(efc_out_tx_debug),
		.din_sop_adp((|efc_out_tx_sop) & adp_in_tx_ready & efc_out_tx_valid),
		.ts_offset_adp(ts_offset_adp),
		.corr_offset_adp(corr_offset_adp),
		.chk_sum_zero_offset_adp(chk_sum_zero_offset_adp),
		.chk_sum_upd_offset_adp(chk_sum_upd_offset_adp),
		.ts_out_cust_asm(ts_out_cust_asm),
		.tod_cust_in(tod_cust_in),
		.tod_exit_cust(tod_exit_cust),
		.ts_out_cust(ts_out_cust),
		.ts_exit(ts_exit),
		.ts_exit_valid(ts_exit_valid),
		.fp_out(fp_out),

		.fp_out_req_adp(fp_out_req_adp),
		.ts_out_req_adp(ts_out_req_adp),
		.ing_ts_96_adp(ing_ts_96_adp),
		.ing_ts_64_adp(ing_ts_64_adp),
		.ins_ts_adp(ins_ts_adp),
		.ins_ts_format_adp(ins_ts_format_adp),
		.tx_asym_adp(tx_asym_adp),
		.upd_corr_adp(upd_corr_adp),
		.chk_sum_zero_adp(chk_sum_zero_adp),
		.chk_sum_upd_adp(chk_sum_upd_adp),
		.corr_format_adp(corr_format_adp),
		.din_ptp_asm_adp(efc_out_tx_ptp_asm),


      // no connect             (),
        .rx_data_out_valid      (),                     
        .rx_data_out            (),
        .rx_ctl_out             (),
        .rx_first_data          (),
        .rx_last_data           (),

        .out_tx_stats           (out_tx_stats),
        .out_rx_stats           (out_rx_stats),
        .tx_inc_octetsOK        (tx_inc_octetsOK      ),
        .tx_inc_octetsOK_valid  (tx_inc_octetsOK_valid),
        .rx_inc_octetsOK        (rx_inc_octetsOK      ),
        .rx_inc_octetsOK_valid  (rx_inc_octetsOK_valid),
                
        .din_ptp_adp            (),
        .din_overwrite_adp      (),
        .din_offset_adp         (),
        .din_zero_tcp_adp       (),
        .din_zero_offset_adp    ()
  );

/////////////////////////////////////////
// inlined PCS assembly

wire clk100 = clk_status;
wire rst100_a = reset_status | reset_async;

sync_regs_m2 ss8 (
	.clk(clk100),
	.din(rst100_a),
	.dout(rst100)
);
defparam ss8 .WIDTH = 1;


localparam NUM_VLANE = 4;

genvar i;

//////////////////////////////////////
// 4x10G pin array
//////////////////////////////////////

reg eio_sys_rst = 1'b0;

reg [3:0] eio_sloop_r = 4'b0;
assign eio_sloop = eio_sloop_r;

reg [2:0] eio_flag_sel = 3'b0;
reg [3:0] eio_flags = 4'h0;
wire [3:0] eio_tx_pll_locked;

reg set_data_lock_r = 1'b0;
reg set_ref_lock_r = 1'b0;
assign set_data_lock = set_data_lock_r;
assign set_ref_lock = set_ref_lock_r;

wire [4*40-1:0] eio_din_sep;
wire [4*40-1:0] eio_dout_sep;
wire [4*66-1:0] eio_din_sep_66; // for fec
wire [3:0] eio_din_66_valid; // for fec

wire [1:0] pcs_dout_req;
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

wire rx_pcs_fully_aligned_s;
wire slave_dout_kr4;

wire io_frame_reset = eio_sys_rst | rst_sync_sts | (rst100 && ENA_KR4 && (TARGET_CHIP==5));
localparam FAKE_TX_SKEW = 1'b0;

//////////////////////////////////////
// inlined IO frame
   
//////
// former home of serdes, moved up
//////

wire cal_busy;   
assign clk_tx_io = eio_tx_clkout[2];
wire clk_rx_recover = eio_rx_clkout[2];
assign eio_tx_pll_locked = {4{tx_pll_locked}};
assign slave_dout_kr4 = 1'b1;
assign eio_dout_req = (pcs_dout_req[0] | eio_rx_flush) & !rx_backup;

////////////////////////////////////////////
// combine some of the flags
////////////////////////////////////////////

   
reg [9:0] flag_mx_meta = 0 /* synthesis preserve dont_replicate */
        /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *flag_mx_meta\[*\]]\" " */;

always @(posedge clk100) begin
        case (eio_flag_sel)
                3'h0 : flag_mx_meta <= tx_full;
                3'h1 : flag_mx_meta <= tx_empty;
                3'h2 : flag_mx_meta <= tx_pfull;
                3'h3 : flag_mx_meta <= tx_pempty;
                3'h4 : flag_mx_meta <= rx_full;
                3'h5 : flag_mx_meta <= rx_empty;
                3'h6 : flag_mx_meta <= rx_pfull;
                3'h7 : flag_mx_meta <= rx_pempty;
        endcase
        eio_flags <= flag_mx_meta[3:0];
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
            .clk(clk100),
            .ready_in((!io_frame_reset) & (!cal_busy)),
            .ready_out(rd0_ready)
    );
    defparam rd0 .CNTR_BITS = RST_CNTR;
    assign pll_powerdown = !io_frame_reset && !rd0_ready && (!cal_busy);
    
    wire rd1_ready;
    reset_delay rd1 (
            .clk(clk100),
            .ready_in(rd0_ready & (&eio_tx_pll_locked)),
            .ready_out(rd1_ready)
    );
    defparam rd1 .CNTR_BITS = RST_CNTR;
    assign tx_analogreset = !rd1_ready & (!cal_busy); //no analog reset when cal_busy
    assign txa_online = !tx_analogreset;
    
    wire rd2_ready;
    reset_delay rd2 (
            .clk(clk100),
            .ready_in(rd1_ready),
            .ready_out(rd2_ready)
    );
    defparam rd2 .CNTR_BITS = RST_CNTR;
    assign rx_analogreset = (!rd2_ready) & (!cal_busy) ; //no analog reset when cal_busy
    
    wire rd3_ready;
    reset_delay rd3 (
            .clk(clk100),
        .ready_in(rd2_ready & txp_lock),
            .ready_out(rd3_ready)
    );
    defparam rd3 .CNTR_BITS = RST_CNTR;
    assign tx_digitalreset = !rd3_ready;
    
    wire rd4_ready;
    reset_delay rd4 (
            .clk(clk100),
            .ready_in(rd3_ready & (&eio_freq_lock) & rxp_lock  & (~rx_fifo_bad)),
            .ready_out(rd4_ready)
    );
    defparam rd4 .CNTR_BITS = RST_CNTR;
    assign rx_digitalreset = !rd4_ready;
    
    sync_regs sr0 (
            .clk(clk_tx_main),
            .din(!tx_digitalreset),
            .dout(eio_tx_online)
    );
    defparam sr0 .WIDTH = 1;
    
    sync_regs sr1 (
            .clk(clk_rx_main),
            .din(!rx_digitalreset),
            .dout(eio_rx_online)
    );
    defparam sr1 .WIDTH = 1;

   aclr_filter f1(   // synchronizing deassertion
        .clk(clk_rx_main),
        .aclr(rx_digitalreset),
        .aclr_sync(rx_aclr_pcs_ready)
   );

    sync_regs sr2 (
            .clk(clk_rx_main),
            .din ({|rx_full,       |rx_empty      }),
            .dout({rx_full_1bit_s, rx_empty_1bit_s})
    );
    defparam sr2 .WIDTH = 2;

   //////////////////////////////////////////////
   // FSM - Rx PCS FIFO Flush 
   //       when overflow/underflow (full/empty) 
   //////////////////////////////////////////////
   always@(posedge clk_rx_main)begin
       state_r <= state_nx;
   end
   
   //state only
   always@(*)begin
     state_nx = state_r;
   
     if (!eio_rx_online) state_nx = ST_FIFO_DEAD;
     else begin 
       case(state_r)
         ST_FIFO_DEAD:         if (eio_rx_online)  state_nx = ST_FIFO_PURGING;
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


// inlined IO frame
//////////////////////////////////////


//////////////////////////////////////
// MAC rate PLLs
//////////////////////////////////////

reg soft_rxp_rst = 1'b0;

reg rxp_ignore_freq = 1'b0;
wire rd6_ready;
reset_delay rd6 (
        .clk(clk100),
        .ready_in((&eio_freq_lock) | rxp_ignore_freq),
        .ready_out(rd6_ready)
);
defparam rd6 .CNTR_BITS = RST_CNTR;
assign rxp_rst = !rd6_ready;

reg soft_txp_rst = 1'b0;

wire rd5_ready;
reset_delay rd5 (
        .clk(clk100),
        .ready_in(!soft_txp_rst),
        .ready_out(rd5_ready)
);
defparam rd5 .CNTR_BITS = RST_CNTR;
assign txp_rst = !rd5_ready;


//////////////////////////////////////////////
// clock monitor
//////////////////////////////////////////////

wire [19:0] khz_ref,khz_rx,khz_tx,khz_rx_rec,khz_tx_io;
frequency_monitor fm0 (
        .signal({clk_ref,clk_rx_main,clk_tx_main,clk_rx_recover,clk_tx_io}),
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
    .din_req(pcs_dout_req), // 2 copies
    
    .sclr_frm_err(sclr_frm_err_s),
    .frm_err_out(frm_err_out),
    .opp_ping_out(opp_ping_out),
    .fully_aligned(rx_pcs_fully_aligned_raw),
    .hi_ber(rx_hi_ber_raw),
    
    .dout_d(pcs_dout_d),
    .dout_c(pcs_dout_c),
    //.wpos(wpos),
    .dsk_depths(wpos),
    .dout_am(pcs_dout_am),
    
    // debug text terminal
	.byte_to_jtag(byte_to_jtag),
	.byte_from_jtag(byte_from_jtag),
	.byte_to_jtag_valid(byte_to_jtag_valid),
	.byte_from_jtag_ack(byte_from_jtag_ack),
	
	.stacker_ram_ena(stacker_ram_ena)
);
defparam rpcs .TARGET_CHIP = TARGET_CHIP;
defparam rpcs .AM_CNT_BITS = AM_CNT_BITS;
defparam rpcs .EN_LINK_FAULT = SYNOPT_LINK_FAULT;
defparam rpcs .SIM_FAKE_JTAG = SIM_FAKE_JTAG;
defparam rpcs .EARLY_REQ = (ENA_KR4 && (TARGET_CHIP==5)) ? 4 : 2;
defparam rpcs .SYNOPT_FULL_SKEW = SYNOPT_FULL_SKEW;

alt_aeu_40_tx_pcs_2 tpcs (
    .clk(clk_tx_main),
    .sclr(!eio_tx_online),
    
    .din_d(pcs_din_d), 
    .din_c(pcs_din_c), 
    .din_am(pcs_din_am),  // this din_d/c will be replaced with align markers
    .pre_din_am(pre_pcs_din_am), // advance warning
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
defparam tpcs .EN_LINK_FAULT = SYNOPT_LINK_FAULT;
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
sync_regs sreg1 (
        .clk (clk100),
        .din(frm_err_out & {NUM_VLANE{rxp_lock}}),
        .dout(frm_err_out_s)
);
defparam sreg1 .WIDTH = NUM_VLANE;

reg sclr_frm_err = 1'b0;
sync_regs sreg2 (
        .clk (clk_rx_main),
        .din(sclr_frm_err),
        .dout(sclr_frm_err_s)
);
defparam sreg2 .WIDTH = 1;

reg rx_pcs_soft_rst_s = 1'b0;
reg eio_rx_soft_purge_s = 1'b0;

sync_regs sreg3(
        .clk(clk_rx_main),
        .din({eio_rx_soft_purge_s,rx_pcs_soft_rst_s}),
        .dout({eio_rx_soft_purge,rx_pcs_soft_rst})      
);
defparam sreg3 .WIDTH = 2;
   
//assign rx_pcs_fully_aligned = rx_pcs_fully_aligned_raw && eio_rx_online;

initial rx_pcs_fully_aligned = 1'b0;
always @(posedge clk_rx_main or posedge rx_aclr_pcs_ready) begin
        if (rx_aclr_pcs_ready) rx_pcs_fully_aligned <= 1'b0;
        else                   rx_pcs_fully_aligned <= rx_pcs_fully_aligned_raw;
end


assign rx_hi_ber = rx_hi_ber_raw && eio_rx_online;
   
sync_regs sreg4(
        .clk(clk100),
        .din({rx_hi_ber,    rx_pcs_fully_aligned}),
        .dout({rx_hi_ber_s, rx_pcs_fully_aligned_s})    
);
defparam sreg4 .WIDTH = 2; // adubey (to add hi_ber)
   
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
assign e40_slave_dout_p = slave_dout_kr4 & slave_dout_phy;
serif_slave ss1 (
    .clk(clk100),
    .sclr(rst100),
    .din(serif_m_dout),
    .dout(slave_dout_phy),

    .wr(ss1_wr),
    .rd(ss1_rd),
    .addr(ss1_addr),
    .wdata(ss1_wdata),
    .rdata(ss1_rdata),
    .rdata_valid(ss1_rdata_valid)
);
defparam ss1 .ADDR_PAGE = BASE_RXPHY;

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
            
            8'h10 : ss1_rdata <= 32'h0 | {set_data_lock_r,set_ref_lock_r,rxp_ignore_freq,soft_rxp_rst,
                                                                                        soft_txp_rst,eio_sys_rst};
            8'h13 : ss1_rdata <= 32'h0 | eio_sloop_r;
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

            
            default : ss1_rdata <= 32'hdeadc0de;
        endcase
    end

    if (ss1_wr) begin
        case (ss1_addr)
            8'h1 : scratch1 <= ss1_wdata;
            8'h10 : {set_data_lock_r,set_ref_lock_r,rxp_ignore_freq,soft_rxp_rst,
                                                soft_txp_rst,eio_sys_rst} <= ss1_wdata[5:0];
        
            8'h13 : eio_sloop_r <= ss1_wdata[3:0];             
            8'h14 : eio_flag_sel <= ss1_wdata[2:0];             
            
            8'h24 : sclr_frm_err <= ss1_wdata[0];
            8'h25 : {eio_rx_soft_purge_s,rx_pcs_soft_rst_s} <= ss1_wdata[1:0];
               
                                
        endcase
    end

	// force power up state for partial reconfig    
    if (rst100) begin
        {set_data_lock_r,set_ref_lock_r,rxp_ignore_freq,soft_rxp_rst,
                   soft_txp_rst,eio_sys_rst} <= 6'b0;
		eio_sloop_r <= 4'b0;             
        sclr_frm_err <= 1'b0;
        {eio_rx_soft_purge_s,rx_pcs_soft_rst_s} <= 2'b0;
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
                

// inlined PCS assembly
/////////////////////////////////////////


assign  l4_rx_fcs_error = l4_rx_error[1];

alt_aeu_40_avl_filter tx_avl_filter (
        .clk                   (clk_txmac              ),
        .rst                   (reset_tx               ),
        .avl_ready             (l4_tx_ready            ),                              
        .avl_sop               (l4_tx_startofpacket    ), //input from Top
        .avl_eop               (l4_tx_endofpacket      ), //input from Top
        .avl_valid             (l4_tx_valid            ), //input from Top 
        .avl_empty             (l4_tx_empty            ), //input from Top
        .filtered_sop          (l4_tx_startofpacket_f  ), //output to adaptor, timing is the same as input, no delay
        .filtered_eop          (l4_tx_endofpacket_f    ), //output to adaptor, timing is the same as input, no delay
        .filtered_empty        (l4_tx_empty_f          ), //output to adaptor, timing is the same as input, no delay
        .protocol_err          (tx_avst_bus_err        )  //{inpkt_valid_down, eop_b2b, sop_b2b, sop_eop_sameword};
);
   
endmodule 

