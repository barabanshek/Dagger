// Author: Cornell University
//
// Module Name :    top_level_loopback_module
// Project :        F-NIC
// Description :    Top-level module for the design
//                    - using loopback
//                    - instantiates two NICs
//

`include "platform_if.vh"

`include "nic.sv"

//`include "nic_defs.vh"

module top_level_loopback_module (
    // CCI-P Clocks and Resets
    input           logic             pClk,          // 200MHz
    input           logic             pClkDiv2,      // 100MHz
    input           logic             pReset,

    // Host interface
    input           t_if_ccip_Rx      pck_cp2af_sRx,       // CCI-P Rx Port
    output          t_if_ccip_Tx      pck_af2cp_sTx        // CCI-P Tx Port
    );

    // We need two NICs:
    // * client-side NIC
    // * server-side NIC
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
    // Install NIC devices
    // =============================================================
    NetworkIf network_Tx_line,   network_Tx_line_1;
    NetworkIf network_Rx_line,   network_Rx_line_1;

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
            .reset(ccip_mux2pe_reset[0]),

            .sRx(pck_afu_RxPort[0]),
            .sTx(pck_afu_TxPort[0]),

            .network_tx_out(network_Tx_line),
            .network_rx_in(network_Rx_line)
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
            .reset(ccip_mux2pe_reset[1]),

            .sRx(pck_afu_RxPort[1]),
            .sTx(pck_afu_TxPort[1]),

            .network_tx_out(network_Tx_line_1),
            .network_rx_in(network_Rx_line_1)
        );



    // =============================================================
    // Emulate ToR network as a loop-back connection with latency
    //   - current latency = 1 cycle
    // =============================================================
    logic network_clk;
    assign network_clk = clk_div_2;

    logic network_rst;
    assign network_rst = ccip_mux2pe_reset[0];

    always @(posedge network_clk) begin
        network_Rx_line   <= network_Tx_line_1;
        network_Rx_line_1 <= network_Tx_line;

        if (network_rst) begin
            network_Rx_line.valid <= 1'b0;
            network_Rx_line_1.valid <= 1'b0;
        end
    end


endmodule
