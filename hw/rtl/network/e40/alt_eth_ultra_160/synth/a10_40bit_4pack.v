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
// $Id: //acds/prototype/alt_eth_ultra/ecustodi_br/ip/ethernet/alt_eth_ultra/40g/rtl/pma/s5_40bit_4pack.v#1 $
// $Revision: #1 $
// $Date: 2013/11/12 $
// $Author: ecustodi $
// ______________________________________________________________________________
// baeckler - 05-22-2012

`timescale 1 ps / 1 ps

module a10_40bit_4pack #(
        parameter PHY_REFCLK = 1,
        parameter REF_FREQ = "644.53125 MHz",
        parameter DATA_RATE = "10312.5 Mbps",
        parameter PLL_OUT_FREQ = "5156.25 MHz" // CAREFUL!! : this is MHz, not MBPS, typically 1/2 data rate    
)(
        input pll_refclk,
        
        input pll_pd,
        input rst_txa,
        input rst_txd,
        input rst_rxa,
        input rst_rxd,
        

        output [3:0] tx_clkout,
        output [3:0] rx_clkout,
        input clk_tx_common,
        input clk_rx_common,
                        
        output [3:0] tx_pin,   // To high speed IO: tx_serial
        input [3:0] rx_pin,    // From high speed IO rx_serial

        input [4*40-1:0] tx_din,
        output [4*40-1:0] rx_dout,
        
        input [3:0] tx_valid,
        input [3:0] rx_ready,
        input [3:0] rx_fifo_aclr,
        input [3:0] rx_bitslip,
        output [3:0] rx_valid,
        output [3:0] rx_datalocked,
        input  [3:0] rx_seriallpbken,
                                
        output [3:0] tx_full,
        output [3:0] tx_pfull,
        output [3:0] tx_empty,
        output [3:0] tx_pempty,
        output [3:0] rx_full,
        output [3:0] rx_pfull,
        output [3:0] rx_empty,
        output [3:0] rx_pempty,
  
        output tx_cal_busy,
        output rx_cal_busy,
  
        input  wire [0:0]   reconfig_clk,            //            reconfig_clk.clk
        input  wire [0:0]   reconfig_reset,          //          reconfig_reset.reset
        input  wire [0:0]   reconfig_write,          //           reconfig_avmm.write
        input  wire [0:0]   reconfig_read,           //                        .read
        input  wire [11:0]  reconfig_address,        //                        .address
        input  wire [31:0]  reconfig_writedata,      //                        .writedata
        output wire [31:0]  reconfig_readdata,       //                        .readdata
        output wire [0:0]   reconfig_waitrequest,    //                        .waitrequest
        
        input [3:0] tx_serial_clk,

        input set_lock_data,
        input set_lock_ref      
);

wire [3:0] tx_pma_clkout;
wire [3:0] rx_pma_clkout;
wire rx_cdr_refclk = pll_refclk;

wire [3:0] txcalbusy;
wire [3:0] rxcalbusy;   
assign tx_cal_busy = |txcalbusy;
assign rx_cal_busy = |rxcalbusy;

// 3 on the bottom
wire [80*3-1:0] tx_pma_parallel_data_bt;
wire [80*3-1:0] rx_pma_parallel_data_bt;
wire [64*3-1:0] tx_parallel_data_bt;
wire [64*3-1:0] rx_parallel_data_bt;
wire [70*3-1:0] reconfig_to_xcvr_bt;  
wire [46*3-1:0] reconfig_from_xcvr_bt;

// 1 on the top
wire [80-1:0] tx_pma_parallel_data_tp;
wire [80-1:0] rx_pma_parallel_data_tp;
wire [64-1:0] tx_parallel_data_tp;
wire [64-1:0] rx_parallel_data_tp;
wire [70-1:0] reconfig_to_xcvr_tp;  
wire [46-1:0] reconfig_from_xcvr_tp;
        
        
`define ALTERA_ETH_40G_NATIVE_PORT_MAPPING  (                               \
                .tx_analogreset({4{rst_txa}}), \
                .tx_digitalreset({4{rst_txd}}), \
                .rx_analogreset({4{rst_rxa}}), \
                .rx_digitalreset({4{rst_rxd}}), \
                .tx_cal_busy(txcalbusy), \
                .rx_cal_busy(rxcalbusy), \
                .tx_serial_clk0(tx_serial_clk), \
                .rx_cdr_refclk0(rx_cdr_refclk), \
                .tx_serial_data(tx_pin[3:0]), \
                .rx_serial_data(rx_pin[3:0]), \
                .rx_seriallpbken(rx_seriallpbken[3:0]), \
                .rx_set_locktoref({4{set_lock_ref}}), \
                .rx_set_locktodata({4{set_lock_data}}), \
                .rx_is_lockedtoref(), \
                .rx_is_lockedtodata(rx_datalocked[3:0]), \
                .tx_coreclkin({4{clk_tx_common}}), \
                .rx_coreclkin({4{clk_rx_common}}), \
                .tx_clkout(tx_clkout[3:0]), \
                .rx_clkout(rx_clkout[3:0]), \
                .rx_bitslip(rx_bitslip[3:0]), \
                .tx_enh_data_valid(tx_valid[3:0]), \
                .tx_enh_fifo_full(tx_full[3:0]), \
                .tx_enh_fifo_pfull(tx_pfull[3:0]), \
                .tx_enh_fifo_empty(tx_empty[3:0]), \
                .tx_enh_fifo_pempty(tx_pempty[3:0]), \
                .rx_enh_fifo_rd_en(rx_ready[3:0]), \
                .rx_enh_data_valid(rx_valid[3:0]), \
                .rx_enh_fifo_full(rx_full[3:0]), \
                .rx_enh_fifo_pfull(rx_pfull[3:0]), \
                .rx_enh_fifo_empty(rx_empty[3:0]), \
                .rx_enh_fifo_pempty(rx_pempty[3:0]), \
                .rx_enh_fifo_align_clr(rx_fifo_aclr[3:0]), \
                .reconfig_clk(reconfig_clk), \
                .reconfig_reset(reconfig_reset), \
                .reconfig_write(reconfig_write), \
                .reconfig_read(reconfig_read), \
                .reconfig_address(reconfig_address), \
                .reconfig_writedata(reconfig_writedata), \
                .reconfig_readdata(reconfig_readdata), \
                .reconfig_waitrequest(reconfig_waitrequest), \
                .tx_parallel_data(tx_din), \
                .unused_tx_parallel_data(352'b0), \
                .rx_parallel_data(rx_dout), \
                .unused_rx_parallel_data() \
        );
        
generate 
   if (PHY_REFCLK==1) begin : GX_A10_644
      gx_a10_40g_644 gx_a10_40g_644_inst           
      `ALTERA_ETH_40G_NATIVE_PORT_MAPPING
   end
   else begin : GX_A10_322
      gx_a10_40g_322 gx_a10_40g_322_inst           
      `ALTERA_ETH_40G_NATIVE_PORT_MAPPING
   end     
endgenerate

endmodule
