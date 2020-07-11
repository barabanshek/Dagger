// Author: Cornell University
//
// Module Name :    ccip_mmio
// Project :        F-NIC
// Description :    implements bi-directional CPU-NIC interface
//                    - CPU-NIC: MMIO based
//                    - NIC-CPU: eREQ_WRPUSH_I with DDIO
//                    - this interface only supports transfer of 64B requests

`include "platform_if.vh"
`include "nic_defs.vh"

module ccip_mmio
    #(
        // NIC ID
        parameter NIC_ID = 0,
         // log # of NIC flows
        parameter LMAX_NUM_OF_FLOWS = 1,
          // VC for NIC-CPU channel
        parameter BACKWARD_VC = eVC_VH0,
        // Write-back type: eREQ_WRLINE_I/eREQ_WRLINE_M/eREQ_WRPUSH_I
        parameter BACKWARD_WR_TYPE = eREQ_WRLINE_I
    )
    (
        input logic clk,
        input logic reset,

        // Control
        input t_ccip_clAddr   rx_base_addr,
        input t_ccip_mmioAddr tx_base_addr,
        input logic[LMAX_NUM_OF_FLOWS-1:0] number_of_flows,
        input logic start,

        // Status
        input logic initialize,
        output logic initialized,

        // CPU interface
        input  logic           sRx_c0TxAlmFull,
        input  logic           sRx_c1TxAlmFull,
        input  logic           sRx_c0MMIOWrValid,
        input  t_if_ccip_c0_Rx sRx_c0,
        output t_if_ccip_c1_Tx sTx_c1,

        // RPC interface
        output RpcPckt rpc_out,
        output logic rpc_out_valid,
        output logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_out,

        output logic ccip_tx_ready,
        input RpcIf rpc_in,
        input logic rpc_in_valid,
        input logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_in
    );

    // Status
    assign initialized = initialize;  // always initialized


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
    // - eREQ_WRPUSH_I mode
    // =============================================================
    always_ff @(posedge clk) begin
        if (reset) begin
            sTx_c1.valid <= 1'b0; 

        end else begin
            // Initial value
            sTx_c1.valid <= 1'b0;
            sTx_c1.data  <= {($bits(t_ccip_clData)){1'b0}};

            // Do not check for sRx_c1TxAlmFull here:
            //   - ccip_tx_ready is handled by the upstream FIFO to block rpc_in packets
            //     if CCI-P can not accept new TX requests
            //   - after sRx_c1TxAlmFull, CCI-P can still accept 8 more requests
            if (start && rpc_in_valid) begin
                $display("NIC%d: Writing back to flow %d", NIC_ID, rpc_flow_id_in);
                $display("NIC%d:           value= %p", NIC_ID, rpc_in);

                sTx_c1.hdr          <= t_ccip_c1_ReqMemHdr'(0);
                sTx_c1.hdr.address  <= rx_base_addr + rpc_flow_id_in;
                sTx_c1.hdr.sop      <= 1'b1;
                sTx_c1.hdr.vc_sel   <= BACKWARD_VC;
                sTx_c1.hdr.req_type <= BACKWARD_WR_TYPE;

                sTx_c1.data[$bits(RpcIf)-1:0] <= rpc_in;

                sTx_c1.valid        <= 1'b1; 
            end

        end
    end

    // Assert CCI-P tx ready signal
    assign ccip_tx_ready =  ~sRx_c1TxAlmFull;


endmodule
