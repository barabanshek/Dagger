// Author: Cornell University
//
// Module Name :    ccip_mmio
// Project :        F-NIC
// Description :    implements bi-directional CPU-NIC interface
//                    - CPU-NIC: MMIO based
//                    - NIC-CPU: batched eREQ_WRLINE_I over PCIe
//                    - this interface only supports transfer of 64B requests
//
// Known bugs:
//                  1) MMIO fails when running with two NICs
//                      - symptoms: when two NICs are co-located on the same FPGA,
//                                  MMIO writes do not always succeed.
//                      - status: under investigation
//                      - priority: low
//

`include "platform_if.vh"
`include "nic_defs.vh"

`include "ccip_transmitter.sv"

module ccip_mmio
    #(
        // NIC ID
        parameter NIC_ID = 0,
         // log # of NIC flows
        parameter LMAX_NUM_OF_FLOWS = 1,
        // log depth of queues in each TX flow
        parameter LMAX_TX_QUEUE_SIZE = 1
    )
    (
        input logic clk,
        input logic reset,

        // Control
        input logic[LMAX_NUM_OF_FLOWS-1:0] number_of_flows,
        input t_ccip_clAddr                rx_base_addr,
        input t_ccip_mmioAddr              tx_base_addr,
        input logic[LMAX_CCIP_BATCH-1:0] l_tx_batch_size,
        
        input logic start,

        // Status
        input logic initialize,
        output logic initialized,
        output logic error,

        // CPU interface
        input  logic           sRx_c0TxAlmFull,
        input  logic           sRx_c1TxAlmFull,
        input  logic           sRx_c0MMIOWrValid,
        input  t_if_ccip_c0_Rx sRx_c0,
        output t_if_ccip_c1_Tx sTx_c1,

        input logic lb_select,

        // RPC interface
        output RpcPckt                      rpc_out,
        output logic                        rpc_out_valid,
        output logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_out,

        output logic                       ccip_tx_ready,
        input RpcIf                        rpc_in,
        input logic                        rpc_in_valid,
        input logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_in,

        // Statistics
        output logic pdrop_tx_flows_out
    );


    // =============================================================
    // CPU - NIC datapath
    // - MMIO writes
    // =============================================================
    localparam FLOW_ID_MASK = {16{1'b1}};

    t_ccip_c0_ReqMmioHdr mmio_req_hdr;
    logic signed [$bits(t_ccip_mmioAddr):0] tx_begin, tx_end;

    // Compute MMIO address range
    always_comb begin
        mmio_req_hdr = t_ccip_c0_ReqMmioHdr'(sRx_c0.hdr);
        tx_begin = tx_base_addr - mmio_req_hdr.address;
        tx_end = tx_begin + (2**LMAX_NUM_OF_FLOWS)*CL_SIZE_WORDS;
    end

    // Delay chain - 1 cycle
    RpcPckt sRx_casted_d;
    logic sRx_c0MMIOWrValid_d;
    logic mmio_addr_match_d;
    always_ff @(posedge clk) begin
        sRx_c0MMIOWrValid_d <= sRx_c0MMIOWrValid;
        sRx_casted_d        <= sRx_c0.data[$bits(RpcPckt)-1:0];
        // tx_base_addr <= MMIO_addr < tx_base_addr + (2**LMAX_NUM_OF_FLOWS)*CL_SIZE_WORDS
        mmio_addr_match_d   <= (tx_begin == 0 | tx_begin[$bits(t_ccip_mmioAddr)] == 1) &
                               (tx_end[$bits(t_ccip_mmioAddr)] == 0);
    end

    // Process requests
    always_ff @(posedge clk) begin
        if (reset) begin
            rpc_out_valid <= 1'b0;

        end else begin
            // Initial vals
            rpc_out_valid <= 1'b0;

            if (start &&
                sRx_c0MMIOWrValid_d &&
                mmio_addr_match_d) begin
                $display("NIC%d: new value read from flow %d", NIC_ID, sRx_casted_d.hdr.rpc_id & FLOW_ID_MASK);
                $display("NIC%d:        value= %p", NIC_ID, sRx_casted_d);

                rpc_out         <= sRx_casted_d;
                rpc_flow_id_out <= sRx_casted_d.hdr.rpc_id & FLOW_ID_MASK;
                rpc_out_valid   <= 1'b1;
            end

        end
    end


    // =============================================================
    // NIC - CPU datapath
    // =============================================================
    logic ccip_transmitter_initialized;
    logic ccip_transmitter_error;

    ccip_transmitter #(
            .NIC_ID(NIC_ID),
            .LMAX_NUM_OF_FLOWS(LMAX_NUM_OF_FLOWS),
            .LMAX_TX_QUEUE_SIZE(LMAX_TX_QUEUE_SIZE)
        ) ccip_tx (
            .clk(clk),
            .reset(reset),

            .number_of_flows(number_of_flows),
            .tx_base_addr(rx_base_addr),
            .l_tx_batch_size(l_tx_batch_size),
            .tx_queue_size(tx_queue_size),
            .start(start),

            .initialize(initialize),
            .initialized(ccip_transmitter_initialized),
            .error(ccip_transmitter_error),

            .sRx_c1TxAlmFull(sRx_c1TxAlmFull),
            .sTx_c1(sTx_c1),

            .lb_select(lb_select),

            .ccip_tx_ready(ccip_tx_ready),
            .rpc_in(rpc_in),
            .rpc_in_valid(rpc_in_valid),
            .rpc_flow_id_in(rpc_flow_id_in),

            .pdrop_tx_flows_out(pdrop_tx_flows_out)
        );


    // Status
    assign initialized = ccip_transmitter_initialized;
    assign error = ccip_transmitter_error;


endmodule
