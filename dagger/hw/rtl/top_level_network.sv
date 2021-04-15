// Author: Cornell University
//
// Module Name :    top_level_network_module
// Project :        F-NIC
// Description :    Top-level module for the design
//                    - using real networking
//                    - instantiates one NIC and the networking MAC/PHY
//

`include "platform_if.vh"

`include "nic.sv"

//`include "nic_defs.vh"

module top_level_network_module (
    // CCI-P Clocks and Resets
    input           logic             pClk,          // 200MHz
    input           logic             pClkDiv2,      // 100MHz
    input           logic             pReset,

    // Host interface
    input           t_if_ccip_Rx      pck_cp2af_sRx,        // CCI-P Rx Port
    output          t_if_ccip_Tx      pck_af2cp_sTx,        // CCI-P Tx Port

    // Raw HSSI interface
    pr_hssi_if.to_fiu   hssi

    );

    // We need two sub-afus:
    // * NIC
    // * Ethernet MAC/PHY
    localparam NUM_SUB_AFUS    = 2;
    localparam NUM_PIPE_STAGES = 2;


    // Define clock and reset for design
    //logic clk;
    //assign clk = pClkDiv2;

    logic clk;
    assign clk = pClk;

    logic clk_div_2;
    assign clk_div_2 = pClkDiv2;

    logic reset;
    assign reset = pReset;

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
    // Instantiate a NIC device
    //   - as CCI-P device #1 since we want to use the lower CSR addresses for the
    //     Ethernet MAC/PHY
    //   - HW MMIO addr is in 32-bit space (1)
    //     HW MMIO objects are 64-bits (2)
    //     (1, 2) -> HW MMIO addresses are mult. of 2 (3)
    //     SW MMIO addr is in 64-bit space
    //     SW MMIO addr is 8B aligned (4)
    //     (3, 4) -> SW/HW = 4
    // =============================================================
    localparam NIC_MMIO_SW_ADDR = 32'h20000;
    localparam NIC_MMIO_ADDR_SW_2_HW = NIC_MMIO_SW_ADDR/4;

    // Ethernet streams
    logic eth_tx_clk;
    logic eth_tx_reset;
    logic eth_tx_ready;
    logic [255:0] eth_tx_data;
    logic eth_tx_valid;
    logic eth_tx_sop;
    logic eth_tx_eop;
    logic [4:0] eth_tx_empty;
    logic eth_tx_error;

    logic eth_rx_clk;
    logic eth_rx_reset;
    logic [255:0] eth_rx_data;
    logic eth_rx_valid;
    logic eth_rx_sop;
    logic eth_rx_eop;
    logic [4:0] eth_rx_empty;
    logic [5:0] eth_rx_error;
    logic eth_rx_ready;

    // NIC
    nic #(
            .NIC_ID(8'h00),
            .SRF_BASE_MMIO_ADDRESS(NIC_MMIO_ADDR_SW_2_HW),
            .SRF_BASE_MMIO_ADDRESS_AFU_ID(NIC_MMIO_ADDR_SW_2_HW),
            .NUM_SUB_AFUS(NUM_SUB_AFUS)
          ) nic (
            .clk(clk),
            .clk_div_2(clk_div_2),
            .reset(ccip_mux2pe_reset[1]),

            .sRx(pck_afu_RxPort[1]),
            .sTx(pck_afu_TxPort[1]),

            .tx_clk_in (eth_tx_clk),
            .tx_reset_in (eth_tx_reset),
            .tx_ready_in (eth_tx_ready),
            .tx_data_out (eth_tx_data),
            .tx_valid_out (eth_tx_valid),
            .tx_sop_out (eth_tx_sop),
            .tx_eop_out (eth_tx_eop),
            .tx_empty_out (eth_tx_empty),
            .tx_error_out (eth_tx_error),

            .rx_clk_in (eth_rx_clk),
            .rx_reset_in (eth_rx_reset),
            .rx_data_in (eth_rx_data),
            .rx_valid_in (eth_rx_valid),
            .rx_sop_in (eth_rx_sop),
            .rx_eop_in (eth_rx_eop),
            .rx_empty_in (eth_rx_empty),
            .rx_error_in (eth_rx_error),
            .rx_ready_out (eth_rx_ready)
        );


    // =============================================================
    // Instantiate an Ethernet MAC/PHY
    //   - as CCI-P device #0, so we reserve the lower CSR addresses to control it
    //     via the standard SW library
    // =============================================================
    ethernet_mac eth_ (
            .clk(clk),
            .reset(ccip_mux2pe_reset[0]),

            .sRx(pck_afu_RxPort[0]),
            .sTx(pck_afu_TxPort[0]),

            .tx_clk_out   (eth_tx_clk),
            .tx_reset_out (eth_tx_reset),
            .tx_ready_out (eth_tx_ready),
            .tx_data_in  (eth_tx_data),
            .tx_valid_in (eth_tx_valid),
            .tx_sop_in   (eth_tx_sop),
            .tx_eop_in   (eth_tx_eop),
            .tx_empty_in (eth_tx_empty),
            .tx_error_in (eth_tx_error),

            .rx_clk_out   (eth_rx_clk),
            .rx_reset_out (eth_rx_reset),
            .rx_data_out  (eth_rx_data),
            .rx_valid_out (eth_rx_valid),
            .rx_sop_out   (eth_rx_sop),
            .rx_eop_out   (eth_rx_eop),
            .rx_empty_out (eth_rx_empty),
            .rx_error_out (eth_rx_error),
            .rx_ready_in (eth_rx_ready),

            .hssi(hssi)
        );


endmodule
