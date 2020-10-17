// ***************************************************************************
// Copyright (c) 2013-2016, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Author: Cornell University
//
// Module Name :    ccip_std_afu
// Project :        F-NIC
// Description :    CCI-P top-level module:
//                      - MUX CCI-P
//                      - instantiate NICs

// ***************************************************************************


`include "platform_if.vh"
`include "ccip_nic_if.vh"

`include "nic_defs.vh"

module ccip_std_afu (
    // CCI-P Clocks and Resets
    input           logic             pClk,              // 400MHz - CCI-P clock domain. Primary interface clock
    input           logic             pClkDiv2,          // 200MHz - CCI-P clock domain.
    input           logic             pClkDiv4,          // 100MHz - CCI-P clock domain.
    input           logic             uClk_usr,          // User clock domain. Refer to clock programming guide  ** Currently provides fixed 300MHz clock **
    input           logic             uClk_usrDiv2,      // User clock domain. Half the programmed frequency  ** Currently provides fixed 150MHz clock **
    input           logic             pck_cp2af_softReset,      // CCI-P ACTIVE HIGH Soft Reset
    input           logic [1:0]       pck_cp2af_pwrState,       // CCI-P AFU Power State
    input           logic             pck_cp2af_error,          // CCI-P Protocol Error Detected

    // Interface structures
    input           t_if_ccip_Rx      pck_cp2af_sRx,        // CCI-P Rx Port
    output          t_if_ccip_Tx      pck_af2cp_sTx         // CCI-P Tx Port
    );


    // We need two AFUs:
    // * client-side NIC
    // * server-side NIC
    localparam NUM_SUB_AFUS    = 2;
    localparam NUM_PIPE_STAGES = 2;


    // Define clock and reset for design
    logic clk;
    assign clk = pClk;

    logic clk_div_2;
    assign clk_div_2 = pClkDiv2;

    logic clk_div_4;
    assign clk_div_4 = pClkDiv4;

    logic reset;
    assign reset = pck_cp2af_softReset;

    // Register requests
    t_if_ccip_Rx sRx;
    always_ff @(posedge clk)
    begin
        sRx <= pck_cp2af_sRx;
    end

    t_if_ccip_Tx sTx;
    assign pck_af2cp_sTx = sTx;


    // =============================================================
    // Install CCI-P MUX    
    // =============================================================
    t_if_ccip_Rx    pck_afu_RxPort        [NUM_SUB_AFUS-1:0];
    t_if_ccip_Tx    pck_afu_TxPort        [NUM_SUB_AFUS-1:0];
    logic           ccip_mux2pe_reset     [NUM_SUB_AFUS-1:0];

    ccip_mux #(NUM_SUB_AFUS, NUM_PIPE_STAGES) ccip_mux_U0 (
                        .pClk(clk),
                        .pClkDiv2(clk_div_2),
                        .SoftReset(reset),
                        .up_Error(),
                        .up_PwrState(),
                        .up_RxPort(sRx),
                        .up_TxPort(sTx),
                        .afu_SoftReset(ccip_mux2pe_reset),
                        .afu_PwrState(),
                        .afu_Error(),
                        .afu_RxPort(pck_afu_RxPort), 
                        .afu_TxPort(pck_afu_TxPort)
        );


    // =============================================================
    // Install NIC devices
    // =============================================================
    // Emulate ToR network as a loop-back connection
    NetworkPacketInternal network_Tx_line_data,   network_Tx_line_data_1;
    logic                 network_Tx_line_strobe, network_Tx_line_strobe_1;
    NetworkPacketInternal network_Rx_line_data,   network_Rx_line_data_1;
    logic                 network_Rx_line_strobe, network_Rx_line_strobe_1;

    // NIC_0:
    //     TODO: So far, NIC::connect_to_accel always reads UUID by 0x00000
    //     so it always reads from nic_0
    //     fix it in software: different NICs must have different MMIO space

    logic nic_0_reset;
    t_if_ccip_Rx nic_0_rx;
    t_if_ccip_Tx nic_0_tx;

    nic #(
            .NIC_ID(8'h00),
            .SRF_BASE_MMIO_ADDRESS(32'h00000),
            .SRF_BASE_MMIO_ADDRESS_AFU_ID(32'h00000),
            .NUM_SUB_AFUS(NUM_SUB_AFUS)
          ) nic_0 (
            .clk(clk),
            .clk_div_2(clk_div_2),
            .clk_div_4(clk_div_4),
            .reset(ccip_mux2pe_reset[0]),

            .sRx(pck_afu_RxPort[0]),
            .sTx(pck_afu_TxPort[0]),

            .network_tx_out(network_Tx_line_data),
            .network_tx_valid_out(network_Tx_line_strobe),
            .network_rx_in(network_Rx_line_data),
            .network_rx_valid_in(network_Rx_line_strobe)
        );

    // NIC_1:
    //     HW MMIO addr is in 32-bit space (1)
    //     HW MMIO objects are 64-bits (2)
    //     (1, 2) -> HW MMIO addresses are mult. of 2 (3)
    //     SW MMIO addr is in 64-bit space
    //     SW MMIO addr is 8B aligned (4)
    //     (3, 4) -> SW/HW = 4
    localparam NIC_1_MMIO_SW_ADDR = 32'h20000;
    localparam NIC_1_MMIO_ADDR_SW_2_HW = NIC_1_MMIO_SW_ADDR/4;

    logic nic_1_reset;
    t_if_ccip_Rx nic_1_rx;
    t_if_ccip_Tx nic_1_tx;

    nic #(
            .NIC_ID(8'h01),
            .SRF_BASE_MMIO_ADDRESS(NIC_1_MMIO_ADDR_SW_2_HW),
            .SRF_BASE_MMIO_ADDRESS_AFU_ID(NIC_1_MMIO_ADDR_SW_2_HW),
            .NUM_SUB_AFUS(NUM_SUB_AFUS)
          ) nic_1 (
            .clk(clk),
            .clk_div_2(clk_div_2),
            .clk_div_4(clk_div_4),
            .reset(ccip_mux2pe_reset[1]),

            .sRx(pck_afu_RxPort[1]),
            .sTx(pck_afu_TxPort[1]),

            .network_tx_out(network_Tx_line_data_1),
            .network_tx_valid_out(network_Tx_line_strobe_1),
            .network_rx_in(network_Rx_line_data_1),
            .network_rx_valid_in(network_Rx_line_strobe_1)
        );


    // =============================================================
    // Emulate ToR network as a loop-back connection with latency
    //   - current latency = 1 cycle
    // =============================================================
    logic network_clk;
    assign network_clk = clk_div_4;

    logic network_rst;
    assign network_rst = ccip_mux2pe_reset[0];

    always @(posedge network_clk) begin
        network_Rx_line_strobe <= network_Tx_line_strobe_1;
        network_Rx_line_data   <= network_Tx_line_data_1;

        network_Rx_line_strobe_1 <= network_Tx_line_strobe;
        network_Rx_line_data_1   <= network_Tx_line_data;

        if (network_rst) begin
            network_Rx_line_strobe <= 1'b0;
            network_Rx_line_strobe_1 <= 1'b0;
        end
    end


endmodule
