// Author: Cornell University
//
// Module Name :    ccip_dma
// Project :        F-NIC
// Description :    implements bi-directional CPU-NIC interface
//                    - CPU-NIC: dma with MMIO notification over PCIe
//                    - NIC-CPU: batched eREQ_WRLINE_I over PCIe
//
// Known bugs:
//                  1) Multithreading support is slow: the same MMIO region is
//                     shared between threads.
//

`include "platform_if.vh"
`include "nic_defs.vh"

module ccip_dma
    #(
        // NIC ID
        parameter NIC_ID = 0, 
        // log # of NIC flows
        parameter LMAX_NUM_OF_FLOWS = 1,
        // total number of NICs in the system
        parameter NUM_SUB_AFUS = 1
    )
    (
        input logic clk,
        input logic reset,

        // Control
        input logic[LMAX_NUM_OF_FLOWS-1:0]      number_of_flows,
        input t_ccip_mmioAddr                   rx_mmio_addr, 
        input t_ccip_clAddr                     rx_base_addr,
        input logic [LMAX_CCIP_DMA_BATCH-1:0]   rx_batch_size,
        input t_ccip_clAddr                     tx_base_addr,
        input logic [LMAX_CCIP_BATCH-1:0]     l_tx_batch_size,

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
    localparam FLOW_ID_MASK = {16{1'b1}};

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
    logic[7:0] dma_dbell_bucket;    // TODO: remove hardcode

    always_ff @(posedge clk) begin
        if (reset) begin
            dma_dbell_bucket <= {($bits(dma_dbell_bucket)){1'b0}};
            trig_dma         <= 1'b0;

        end else begin
            trig_dma <= 1'b0;

            if (start &&
                sRx_c0MMIOWrValid &&
                mmio_req_hdr.address == rx_mmio_addr) begin

                dma_dbell_bucket <= sRx_c0.data[7:0];
                trig_dma         <= 1'b1;
            end

            if (trig_dma) begin
                $display("NIC%d: new value read request, bucket= %p", NIC_ID, dma_dbell_bucket);
            end
        end
    end

    // Send DMA request for a batch
    typedef enum logic { RxIdle, RxRdBatch } RxState;
    RxState rx_state;

    logic [LMAX_CCIP_DMA_BATCH-1:0] rx_batch_cnt;

    // 1-cycle delay to relax timings
    t_ccip_clAddr tx_base_addr_d;
    always_ff @(posedge clk) begin
        tx_base_addr_d <= tx_base_addr;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            rx_state     <= RxIdle;
            rx_batch_cnt <= {($bits(rx_batch_cnt)){1'b0}};
            sTx_c0.valid <= 1'b0;

        end else begin
            sTx_c0.hdr          = t_ccip_c0_ReqMemHdr'(0);
            sTx_c0.hdr.address  = tx_base_addr_d + dma_dbell_bucket + rx_batch_cnt;
            sTx_c0.hdr.vc_sel   = eVC_VH0;
            sTx_c0.hdr.req_type = eREQ_RDLINE_I;

            sTx_c0.valid                  <= 1'b0;

            if (rx_state == RxIdle) begin
                if (trig_dma) begin
                    sTx_c0.valid <= 1'b1;
                    rx_batch_cnt <= rx_batch_cnt + 1;
                    rx_state     <= RxRdBatch;
                end
            end

            if (rx_state == RxRdBatch) begin
                if (!sRx_c0TxAlmFull) begin
                    if (rx_batch_cnt != rx_batch_size) begin
                        sTx_c0.valid <= 1'b1;
                        rx_batch_cnt <= rx_batch_cnt + 1;
                        rx_state     <= RxRdBatch;
                    end else begin
                        rx_batch_cnt <= {($bits(rx_batch_cnt)){1'b0}};
                        rx_state     <= RxIdle;
                    end
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
                $display("NIC%d: new value read from flow %d", NIC_ID, sRx_casted.hdr.rpc_id & FLOW_ID_MASK);
                $display("NIC%d:        value= %p", NIC_ID, sRx_casted);

                rpc_out_valid   <= 1'b1;
                rpc_flow_id_out <= sRx_casted.hdr.rpc_id & FLOW_ID_MASK;
                rpc_out         <= sRx_casted;
            end
        end
    end



    // =============================================================
    // NIC - CPU datapath
    // - eREQ_WRPUSH_I mode
    // =============================================================
    localparam LTX_FIFO_DEPTH = 6;

    logic tx_fifo_pop;
    logic [LTX_FIFO_DEPTH-1:0] tx_fifo_dw;
    logic tx_fifo_pop_valid;
    RpcIf tx_fifo_pop_data;

    async_fifo_channel #(
            .DATA_WIDTH($bits(RpcIf)),
            .LOG_DEPTH(LTX_FIFO_DEPTH)
        )
    tx_batching_fifo (
            .clear(reset),
            .clk_1(clk),
            .push_en(start && rpc_in_valid),
            .push_data({rpc_in}),
            .clk_2(clk),
            .pop_enable(tx_fifo_pop),
            .pop_valid(tx_fifo_pop_valid),
            .pop_data({tx_fifo_pop_data}),
            .pop_dw(tx_fifo_dw),
            .error(error)
        );

    typedef enum logic { TxIdle, TxReadFIFO } TxState;

    TxState tx_state;
    logic [LMAX_CCIP_BATCH-1:0] tx_in_cnt;
    logic [LMAX_CCIP_BATCH-1:0] tx_out_cnt;
    logic [LMAX_NUM_OF_FLOWS-1:0] tx_out_flow;
    logic [LMAX_NUM_OF_FLOWS+LMAX_CCIP_BATCH:0] tx_out_flow_shift;

    // Batching shifts
    logic [LMAX_CCIP_BATCH:0] tx_batch_size;
    t_ccip_clLen tx_cl_len;
    always_comb begin
        if (l_tx_batch_size == 0) begin
            tx_batch_size     = 1;
            tx_cl_len         = eCL_LEN_1;
            tx_out_flow_shift = tx_out_flow;
        end else if (l_tx_batch_size == 1) begin
            tx_batch_size     = 2;
            tx_cl_len         = eCL_LEN_2;
            tx_out_flow_shift = tx_out_flow << 1;
        end else if (l_tx_batch_size == 2) begin
            tx_batch_size     = 4;
            tx_cl_len         = eCL_LEN_4;
            tx_out_flow_shift = tx_out_flow << 2;
        end
    end

    // Read from TX FIFO
    always_ff @(posedge clk) begin
        if (reset) begin
            tx_state    <= TxIdle;
            tx_in_cnt   <= {($bits(tx_in_cnt)){1'b0}};
            tx_fifo_pop <= 1'b0;

        end else begin
            tx_fifo_pop <= 1'b0;

            if (tx_state == TxIdle && tx_fifo_dw >= tx_batch_size) begin
                tx_fifo_pop <= 1'b1;
                tx_state    <= TxReadFIFO;
            end

            if (tx_state == TxReadFIFO) begin
                if (tx_in_cnt == tx_batch_size - 1) begin
                    tx_in_cnt   <= {($bits(tx_in_cnt)){1'b0}};
                    tx_state    <= TxIdle;
                end else begin
                    tx_fifo_pop <= 1'b1;
                    tx_in_cnt   <= tx_in_cnt + 1;
                    tx_state    <= TxReadFIFO;
                end
            end
        end
    end

    // Delay
    t_ccip_clAddr rx_base_addr_d;
    always_ff @(posedge clk) begin
        rx_base_addr_d <= rx_base_addr;
    end

    // Write to CCI-P
    always_ff @(posedge clk) begin
        if (reset) begin
            sTx_c1.valid   <= 1'b0;
            tx_out_cnt     <= {($bits(tx_out_cnt)){1'b0}};
            tx_out_flow    <= {($bits(tx_out_flow)){1'b0}};

        end else begin
            // Data
            sTx_c1.hdr                    <= t_ccip_c1_ReqMemHdr'(0);
            sTx_c1.hdr.cl_len             <= tx_cl_len;
            sTx_c1.hdr.vc_sel             <= eVC_VH0;
            sTx_c1.hdr.req_type           <= eREQ_WRLINE_I;
            sTx_c1.hdr.address            <= rx_base_addr_d + tx_out_flow_shift + tx_out_cnt;
            sTx_c1.hdr.sop                <= tx_out_cnt == 0;
            sTx_c1.data[$bits(RpcIf)-1:0] <= tx_fifo_pop_data;

            // Control
            sTx_c1.valid <= 1'b0;
            if (tx_fifo_pop_valid) begin
                $display("NIC%d: Writing back to flow %d", NIC_ID, tx_out_flow);
                $display("NIC%d:         %dth value= %p", NIC_ID, tx_out_cnt, tx_fifo_pop_data);

                sTx_c1.valid                  <= 1'b1;

                // Counters
                if (tx_out_cnt == tx_batch_size - 1) begin
                    if (tx_out_flow == number_of_flows) begin
                        tx_out_flow <= {($bits(tx_out_flow)){1'b0}};
                    end else begin
                        tx_out_flow <= tx_out_flow + 1;
                    end
                    tx_out_cnt <= {($bits(tx_out_cnt)){1'b0}};
                end else begin
                    tx_out_cnt <= tx_out_cnt + 1;
                end
            end
        end
    end

    // Assert CCI-P tx ready signal
    assign ccip_tx_ready =  ~sRx_c1TxAlmFull;


endmodule
