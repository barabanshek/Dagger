// Author: Cornell University
//
// Module Name :    ccip_dma
// Project :        F-NIC
// Description :    implements bi-directional CPU-NIC interface
//                    - CPU-NIC: dma with MMIO notification over PCIe
//                    - NIC-CPU: eREQ_WRPUSH_I with DDIO

`include "platform_if.vh"
`include "nic_defs.vh"

module ccip_dma
    #(
        // NIC ID
        parameter NIC_ID = 0, 
        // log # of NIC flows
        parameter LMAX_NUM_OF_FLOWS = 1,
        // total number of NICs in the system
        parameter NUM_SUB_AFUS = 1,
        // VC for CPU-NIC channel: eVC_VH0/eVC_VL0
        parameter FORWARD_VC = eVC_VH0,
        // VC for NIC-CPU channel: eVC_VH0/eVC_VL0
        parameter BACKWARD_VC = eVC_VH0,
        // Write-back type: eREQ_WRLINE_I/eREQ_WRLINE_M/eREQ_WRPUSH_I
        parameter BACKWARD_WR_TYPE = eREQ_WRLINE_I
    )
    (
        input logic clk,
        input logic reset,

        // Control
        input t_ccip_mmioAddr rx_mmio_addr, 
        input t_ccip_clAddr rx_base_addr,
        input t_ccip_clAddr tx_base_addr,
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
        output t_if_ccip_c0_Tx sTx_c0,
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
    // - CPU-NIC: dma with MMIO notification over PCIe
    // =============================================================
    // N MSBs of *.c0.hdr.mdata are reserved for the upper-level CCI-P MUX;
    // Always ensure MDATA_W <= 16 - N
    localparam MDATA_W      = LMAX_NUM_OF_FLOWS;
    localparam META_PATTERN = {(MDATA_W){1'b1}};
    generate
        if (MDATA_W > 16 - $clog2(NUM_SUB_AFUS)) begin
            $error("** Illegal Condition ** MDATA_W(%d) > MAX_ALLOWED(%d)", MDATA_W, 16 - $clog2(NUM_SUB_AFUS));
        end
    endgenerate

    // Wait for DMA initiation
    t_ccip_c0_ReqMmioHdr mmio_req_hdr;
    always_comb begin
        mmio_req_hdr = t_ccip_c0_ReqMmioHdr'(sRx_c0.hdr);
    end

    logic trig_dma;
    logic[LMAX_NUM_OF_FLOWS-1:0] dma_cl;
    always_ff @(posedge clk) begin
        if (reset) begin
            dma_cl   <= {(LMAX_NUM_OF_FLOWS){1'b0}};
            trig_dma <= 1'b0;

        end else begin
            trig_dma <= 1'b0;

            if (start &&
                sRx_c0MMIOWrValid &&
                mmio_req_hdr.address == rx_mmio_addr) begin
                $display("NIC%d: new value read request", NIC_ID);

                trig_dma <= 1'b1;
                dma_cl   <= sRx_c0.data[LMAX_NUM_OF_FLOWS-1:0];
            end
        end
    end

    // Send DMA request
    always_ff @(posedge clk) begin
        if (reset) begin
            sTx_c0.valid <= 1'b0;
            error        <= 1'b0;

        end else begin
            sTx_c0.valid <= 1'b0;

            if (trig_dma) begin
                if (!sRx_c0TxAlmFull) begin
                    sTx_c0.hdr         <= t_ccip_c0_ReqMemHdr'(0);

                    sTx_c0.hdr.address            <= tx_base_addr + dma_cl;
                    sTx_c0.hdr.mdata[MDATA_W-1:0] <= META_PATTERN ^ dma_cl;
                    sTx_c0.hdr.vc_sel             <= FORWARD_VC;
                    sTx_c0.hdr.req_type           <= eREQ_RDLINE_I;

                    sTx_c0.valid <= 1'b1;
                end else begin
                    // Do smth like stashing outstanding DMA initiations
                    // Assert an error so far
                    error <= 1'b1;
                end
            end
        end
    end

    // Get answer
    RpcPckt sRx_casted;
    always_comb begin
        sRx_casted = sRx_c0.data[$bits(RpcPckt)-1:0];
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            rpc_out_valid   <= 1'b0;
            rpc_flow_id_out <= {(MDATA_W){1'b0}};
            rpc_out         <= {($bits(RpcPckt)){1'b0}};

        end else begin
            // Initial vals
            rpc_out_valid <= 1'b0;

            if (start && sRx_c0.rspValid) begin
                $display("NIC%d: new value read from flow %d", NIC_ID, sRx_c0.hdr.mdata[LMAX_NUM_OF_FLOWS-1:0] ^ META_PATTERN);
                $display("NIC%d:        value= %p", NIC_ID, sRx_casted);

                rpc_out_valid   <= 1'b1;
                rpc_flow_id_out <= sRx_c0.hdr.mdata[LMAX_NUM_OF_FLOWS-1:0] ^ META_PATTERN;
                rpc_out         <= sRx_casted;
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
