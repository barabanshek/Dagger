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
//
// Known bugs:
//                  1) When cross-clock shim is added, the system fails to read
//                     the CCI-P mode register
//
//
// ***************************************************************************


`include "top_level.sv"
`include "ccip_async_shim.sv"

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

    // Define default clock
    `define SYS_CLOCK_200
    //`define SYS_CLOCK_400

`ifdef SYS_CLOCK_200
    // Run system with medium frequency: 200 and 100MHz

    t_if_ccip_Tx afu_tx;
    t_if_ccip_Rx afu_rx;

    logic reset_pass;

    // Shim to cross clock for CCI-P
    ccip_async_shim cross_clock (
        .bb_softreset(pck_cp2af_softReset),
        .bb_clk(pClk),
        .bb_tx(pck_af2cp_sTx),
        .bb_rx(pck_cp2af_sRx),

        .afu_softreset(reset_pass),
        .afu_clk(pClkDiv2),
        .afu_tx(afu_tx),
        .afu_rx(afu_rx)
    );

    // Top-level
    top_level_module top_level (
        .pClk(pClkDiv2),
        .pClkDiv2(pClkDiv4),
        .pReset(reset_pass),
        .pck_cp2af_sRx(afu_rx),
        .pck_af2cp_sTx(afu_tx)
    );

`elsif SYS_CLOCK_400
    // Run system with high frequency: 400 and 200MHz

    top_level_module top_level (
        .pClk(pClk),
        .pClkDiv2(pClkDiv2),
        .pReset(pck_cp2af_softReset),
        .pck_cp2af_sRx(pck_cp2af_sRx),
        .pck_af2cp_sTx(pck_af2cp_sTx)
    );

`else
    $error("** Illegal Configuration ** the system clock is not defined");

`endif


endmodule
