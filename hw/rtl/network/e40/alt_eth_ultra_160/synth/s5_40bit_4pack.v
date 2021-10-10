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
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/pma/s5_40bit_4pack.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ______________________________________________________________________________
// baeckler - 05-22-2012

module s5_40bit_4pack #(
        parameter PHY_REFCLK = 1,
        parameter REF_FREQ = (PHY_REFCLK == 1)?"644.53125 MHz":"322.265625 MHz" 
        )(
        input pll_refclk,
        
        input pll_pd,
        input rst_txa,
        input rst_txd,
        input rst_rxa,
        input rst_rxd,
        output tx_pll_locked,

        output [3:0] tx_clkout,
        output [3:0] rx_clkout,
        input clk_tx_common,
        input clk_rx_common,
                        
        output [3:0] tx_pin,
        input [3:0] rx_pin,

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
        
        input  wire [559:0] reconfig_to_xcvr,        //        reconfig_to_xcvr.reconfig_to_xcvr
        output wire [367:0] reconfig_from_xcvr,      //      reconfig_from_xcvr.reconfig_from_xcvr

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

 s5xcvr # ( 
                .REF_FREQ                       (REF_FREQ)
        ) gx (
                .pll_powerdown({4{pll_pd}}),           //           pll_powerdown.pll_powerdown
                .tx_analogreset({4{rst_txa}}),          //          tx_analogreset.tx_analogreset
                .tx_digitalreset({4{rst_txd}}),         //         tx_digitalreset.tx_digitalreset
                .tx_serial_data(tx_pin[3:0]),          //          tx_serial_data.tx_serial_data
                .pll_locked(tx_pll_locked),
                .tx_pll_refclk(pll_refclk),             //             tx_pll_refclk.tx_pll_refclk
                .rx_analogreset({4{rst_rxa}}),          //          rx_analogreset.rx_analogreset
                .rx_digitalreset({4{rst_rxd}}),         //         rx_digitalreset.rx_digitalreset
                .rx_cdr_refclk(rx_cdr_refclk),           //           rx_cdr_refclk.rx_cdr_refclk
                .rx_pma_clkout(rx_pma_clkout[3:0]),           //           rx_pma_clkout.rx_pma_clkout
                .rx_serial_data(rx_pin[3:0]),          //          rx_serial_data.rx_serial_data
                .rx_set_locktodata({4{set_lock_data}}),       //       rx_set_locktodata.rx_set_locktodata
                .rx_set_locktoref({4{set_lock_ref}}),        //        rx_set_locktoref.rx_set_locktoref
                .rx_is_lockedtoref(),       //       rx_is_lockedtoref.rx_is_lockedtoref
                .rx_is_lockedtodata(rx_datalocked[3:0]),      //      rx_is_lockedtodata.rx_is_lockedtodata
                .rx_seriallpbken(rx_seriallpbken[3:0]),         //         rx_seriallpbken.rx_seriallpbken
                
                .tx_10g_coreclkin({4{clk_tx_common}}),        //        tx_10g_coreclkin.tx_10g_coreclkin
                .rx_10g_coreclkin({4{clk_rx_common}}),        //        rx_10g_coreclkin.rx_10g_coreclkin
                
                .tx_10g_clkout(tx_clkout[3:0]),           //           tx_10g_clkout.tx_10g_clkout
                .rx_10g_clkout(rx_clkout[3:0]),           //           rx_10g_clkout.rx_10g_clkout
                
                .rx_10g_clk33out(),         //         rx_10g_clk33out.rx_10g_clk33out
                
                .tx_10g_control(36'b0),          //          tx_10g_control.tx_10g_control
                .rx_10g_control(),          //          rx_10g_control.rx_10g_control
                
                .tx_10g_data_valid(tx_valid[3:0]),       //       tx_10g_data_valid.tx_10g_data_valid
                .tx_10g_fifo_full(tx_full[3:0]),        //        tx_10g_fifo_full.tx_10g_fifo_full
                .tx_10g_fifo_pfull(tx_pfull[3:0]),       //       tx_10g_fifo_pfull.tx_10g_fifo_pfull
                .tx_10g_fifo_empty(tx_empty[3:0]),       //       tx_10g_fifo_empty.tx_10g_fifo_empty
                .tx_10g_fifo_pempty(tx_pempty[3:0]),      //      tx_10g_fifo_pempty.tx_10g_fifo_pempty
                .rx_10g_fifo_rd_en(rx_ready[3:0]),       //       rx_10g_fifo_rd_en.rx_10g_fifo_rd_en
                .rx_10g_data_valid(rx_valid[3:0]),       //       rx_10g_data_valid.rx_10g_data_valid
                .rx_10g_fifo_full(rx_full[3:0]),        //        rx_10g_fifo_full.rx_10g_fifo_full
                .rx_10g_fifo_pfull(rx_pfull[3:0]),       //       rx_10g_fifo_pfull.rx_10g_fifo_pfull
                .rx_10g_fifo_empty(rx_empty[3:0]),       //       rx_10g_fifo_empty.rx_10g_fifo_empty
                .rx_10g_fifo_pempty(rx_pempty[3:0]),      //      rx_10g_fifo_pempty.rx_10g_fifo_pempty
                .rx_10g_fifo_align_clr(rx_fifo_aclr[3:0]),   //   rx_10g_fifo_align_clr.rx_10g_fifo_align_clr
                
                .rx_10g_bitslip(rx_bitslip[3:0]),          //          rx_10g_bitslip.rx_10g_bitslip
                
                .tx_cal_busy(txcalbusy),             //             tx_cal_busy.tx_cal_busy
                .rx_cal_busy(rxcalbusy),             //             rx_cal_busy.rx_cal_busy
                
                .reconfig_to_xcvr(reconfig_to_xcvr),        //        reconfig_to_xcvr.reconfig_to_xcvr
                .reconfig_from_xcvr(reconfig_from_xcvr),      //      reconfig_from_xcvr.reconfig_from_xcvr
                .tx_parallel_data(tx_din),        //        tx_parallel_data.tx_parallel_data
                .unused_tx_parallel_data(96'b0), // unused_tx_parallel_data.unused_tx_parallel_data
                .rx_parallel_data(rx_dout),        //        rx_parallel_data.rx_parallel_data
                .unused_rx_parallel_data()  // unused_rx_parallel_data.unused_rx_parallel_data
        );
        
        //defparam gx .s5xcvr_ref.teng_txfifo_mode    = "generic";
        //defparam gx .s5xcvr_ref.teng_txfifo_pempty  = 7;
        //defparam gx .s5xcvr_ref.teng_txfifo_pfull   = 23;
        
        //defparam gx .s5xcvr_ref.teng_rxfifo_mode    = "generic";
        //defparam gx .s5xcvr_ref.teng_rxfifo_pempty  = 7;
        //defparam gx .s5xcvr_ref.teng_rxfifo_pfull   = 23;

endmodule
