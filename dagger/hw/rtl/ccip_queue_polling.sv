// Author: Cornell University
//
// Module Name :    ccip_polling
// Project :        F-NIC
// Description :    implements bi-directional CPU-NIC interface
//                    - CPU-NIC: polling based over UPI
//                    - NIC-CPU: eREQ_WRLINE_I over PCIe
//                    - book-keeping: TODO


`include "async_fifo_channel.sv"
`include "platform_if.vh"
`include "nic_defs.vh"

module ccip_queue_polling
    #(
        // NIC ID
        parameter NIC_ID = 0,
        // total number of NICs in the system
        parameter NUM_SUB_AFUS = 1,
        // polling rate
        parameter POLLING_RATE = 0,
        // log # of NIC flows
        parameter LMAX_NUM_OF_FLOWS = 1,
        // log depth of queues in each flow
        parameter LMAX_RX_QUEUE_SIZE = 1

    )
    (
        input logic clk,
        input logic reset,

        // Control
        input logic[LMAX_NUM_OF_FLOWS-1:0]  number_of_flows,
        input t_ccip_clAddr                 rx_base_addr,
        input t_ccip_clAddr                 rx_bk_base_addr,
        input logic[LMAX_RX_QUEUE_SIZE-1:0] rx_queue_size,
        input t_ccip_clAddr                 tx_base_addr,
        input logic[LMAX_CCIP_BATCH-1:0]  l_tx_batch_size,
        input logic                         start,

        // Status
        input logic  initialize,
        output logic initialized,
        output logic error,

        // CPU interface
        input  logic           sRx_c0TxAlmFull,
        input  logic           sRx_c1TxAlmFull,
        input  t_if_ccip_c0_Rx sRx_c0,
        output t_if_ccip_c0_Tx sTx_c0,
        output t_if_ccip_c1_Tx sTx_c1,

        // RPC interface
        output RpcPckt                      rpc_out,
        output logic                        rpc_out_valid,
        output logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_out,

        output logic                       ccip_tx_ready,
        input RpcIf                        rpc_in,
        input logic                        rpc_in_valid,
        input logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_in
    );


    // =============================================================
    // CPU - NIC datapath
    // =============================================================

    // N MSBs of *.c0.hdr.mdata are reserved for the upper-level CCI-P MUX;
    // Always ensure MDATA_W <= 16 - N
    localparam MDATA_W      = LMAX_NUM_OF_FLOWS + LMAX_RX_QUEUE_SIZE;
    localparam META_PATTERN = {(MDATA_W){1'b1}};
    generate
        if (MDATA_W > 16 - $clog2(NUM_SUB_AFUS)) begin
            $error("** Illegal Condition ** MDATA_W(%d) > MAX_ALLOWED(%d)", MDATA_W, 16 - $clog2(NUM_SUB_AFUS));
        end
    endgenerate

    // Poll all entries in all buffers in Shared mode
    //   - poll local cache and bring data over UPI
    //   - allocate in S state so we don't burn UPI bandwidth
    //   - do bookkiping over PCIe
    logic[MDATA_W-1:0]  queue_poll_cnt;
    logic[MDATA_W-1:0]  flow_poll_cnt;
    logic[7:0]          poll_frq_div_cnt;

    always_ff @(posedge clk) begin
        if (reset) begin
            sTx_c0.valid     <= 1'b0;
            queue_poll_cnt   <= {($bits(queue_poll_cnt)){1'b0}};
            flow_poll_cnt    <= {($bits(flow_poll_cnt)){1'b0}};
            poll_frq_div_cnt <= {($bits(poll_frq_div_cnt)){1'b0}};

        end else begin
            // Data
            sTx_c0.hdr                    <= t_ccip_c0_ReqMemHdr'(0);
            sTx_c0.hdr.address            <= tx_base_addr +
                                             (flow_poll_cnt << LMAX_RX_QUEUE_SIZE) +
                                             queue_poll_cnt;
            sTx_c0.hdr.mdata[MDATA_W-1:0] <= META_PATTERN ^
                                             ((flow_poll_cnt << LMAX_RX_QUEUE_SIZE) +
                                               queue_poll_cnt);
            sTx_c0.hdr.vc_sel             <= eVC_VL0;
            sTx_c0.hdr.req_type           <= eREQ_RDLINE_I;

            // Control
            sTx_c0.valid <= 1'b0;

            if (start) begin
                if (poll_frq_div_cnt == POLLING_RATE) begin
                    if (!sRx_c0TxAlmFull) begin
                        sTx_c0.valid <= 1'b1;

                        // Switch entry in the queue
                        if (queue_poll_cnt == rx_queue_size) begin
                            queue_poll_cnt <= {($bits(queue_poll_cnt)){1'b0}};

                            // Switch queue
                            if (flow_poll_cnt == number_of_flows) begin
                                flow_poll_cnt <= {($bits(flow_poll_cnt)){1'b0}};
                            end else begin
                                flow_poll_cnt <= flow_poll_cnt + 1;
                            end
                        end else begin
                            queue_poll_cnt <= queue_poll_cnt + 1;
                        end
                    end
                    poll_frq_div_cnt <= {($bits(poll_frq_div_cnt)){1'b0}};
                end else begin
                    poll_frq_div_cnt <= poll_frq_div_cnt + 1;
                end
            end

        end
    end

    // Get answer
    RpcPckt                       sRx_casted;
    RpcPckt                       ccip_read_poll_data;
    logic[MDATA_W-1:0]            ccip_read_poll_cl_casted;
    logic[MDATA_W-1:0]            ccip_read_poll_cl;
    logic[LMAX_RX_QUEUE_SIZE-1:0] ccip_queue_cnt;
    logic[LMAX_NUM_OF_FLOWS-1:0]  ccip_flow_cnt;
    logic                         ccip_read_poll_data_valid;

    always_comb begin
        sRx_casted               = sRx_c0.data[$bits(RpcPckt)-1:0];
        ccip_read_poll_cl_casted = sRx_c0.hdr.mdata[MDATA_W-1:0] ^ META_PATTERN;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            ccip_read_poll_data_valid <= 1'b0;
            ccip_read_poll_cl         <= {(MDATA_W){1'b0}};
            ccip_read_poll_data       <= {($bits(RpcPckt)){1'b0}};

        end else begin
            // Data
            ccip_queue_cnt      <= ccip_read_poll_cl_casted[LMAX_RX_QUEUE_SIZE-1:0];
            ccip_flow_cnt       <= (ccip_read_poll_cl_casted >> LMAX_RX_QUEUE_SIZE);
            ccip_read_poll_cl   <= ccip_read_poll_cl_casted;
            ccip_read_poll_data <= sRx_casted;

            // Control
            ccip_read_poll_data_valid <= 1'b0;
            if (start && sRx_c0.rspValid && sRx_casted.hdr.ctl.valid) begin
                ccip_read_poll_data_valid <= 1'b1;
            end
        end
    end

    // Compare to see if the CL is updated
    localparam LMAX_POLL_ENTRIES = LMAX_NUM_OF_FLOWS + LMAX_RX_QUEUE_SIZE;
    localparam MAX_POLL_ENTRIES = 2**LMAX_POLL_ENTRIES;

    typedef enum logic { DBInitIdle, DBInit } DBitTbInitState;
    DBitTbInitState db_tb_init_state;
    logic d_bit_tb_initialized;
    logic d_bit_rd, d_bit_wr;
    logic[LMAX_POLL_ENTRIES-1:0] d_bit_rd_addr, d_bit_wr_addr, d_bit_wr_addr_init;
    logic d_bit_we, d_bit_we_init;

    single_clock_wr_ram #(
            .DATA_WIDTH(1),
            .ADR_WIDTH(LMAX_POLL_ENTRIES)
        )
    ccip_dirty_tb (
            .clk(clk),
            .q(d_bit_rd),
            .d(db_tb_init_state == DBInit? 1'b0: d_bit_wr),
            .write_address(db_tb_init_state == DBInit? d_bit_wr_addr_init: d_bit_wr_addr),
            .read_address(d_bit_rd_addr),
            .we(db_tb_init_state == DBInit? 1'b1: d_bit_we)
        );

    // ccip_dirty_tb init logic
    always_ff @(posedge clk) begin
        if (reset) begin
            db_tb_init_state     <= DBInitIdle;
            d_bit_wr_addr_init   <= {($bits(d_bit_wr_addr_init)){1'b0}};
            d_bit_tb_initialized <= 1'b0;

        end else begin
            if (db_tb_init_state == DBInitIdle && ~d_bit_tb_initialized && initialize) begin
                db_tb_init_state <= DBInit;
            end

            if (db_tb_init_state == DBInit) begin
                if (d_bit_wr_addr_init == MAX_POLL_ENTRIES - 1) begin
                    db_tb_init_state     <= DBInitIdle;
                    d_bit_tb_initialized <= 1'b1;
                end else begin
                    d_bit_wr_addr_init <= d_bit_wr_addr_init + 1;
                end 
            end
        end
    end

    // Look-up d_bit
    logic d_bit_rd_1d;
    always_comb begin
        d_bit_rd_addr = ccip_read_poll_cl;
        d_bit_rd_1d   = d_bit_rd;
    end

    // Data
    logic ccip_read_poll_data_valid_1d;
    logic ccip_read_poll_data_update_flag_1d;
    logic[MDATA_W-1:0] ccip_read_poll_cl_1d;
    logic[LMAX_NUM_OF_FLOWS-1:0] ccip_flow_cnt_1d;
    logic[LMAX_RX_QUEUE_SIZE-1:0] ccip_queue_cnt_1d;
    RpcPckt ccip_read_poll_data_1d;
    always_ff @(posedge clk) begin
        // 1-cycle
        ccip_read_poll_data_valid_1d       <= ccip_read_poll_data_valid;
        ccip_read_poll_cl_1d               <= ccip_read_poll_cl;
        ccip_read_poll_data_update_flag_1d <= ccip_read_poll_data.hdr.ctl.update_flag;
        ccip_flow_cnt_1d                   <= ccip_flow_cnt;
        ccip_queue_cnt_1d                  <= ccip_queue_cnt;
        ccip_read_poll_data_1d             <= ccip_read_poll_data;

        // commit
        rpc_flow_id_out <= ccip_flow_cnt_1d;
        rpc_out         <= ccip_read_poll_data_1d;
        d_bit_wr_addr   <= ccip_read_poll_cl_1d;
        d_bit_wr        <= d_bit_rd_1d ^ 1'b1;
    end

    // Control
    always_ff @(posedge clk) begin
        if (reset) begin
            rpc_out_valid <= 1'b0;
            d_bit_we      <= 1'b0;
            //bk_counter    <= {(MDATA_W){1'b0}};

        end else begin
            d_bit_we      <= 1'b0;
            rpc_out_valid <= 1'b0;

            if (ccip_read_poll_data_valid_1d) begin
                if (d_bit_rd_1d != ccip_read_poll_data_update_flag_1d) begin
                    $display("NIC%d: new value read from flow %d, queue %d", NIC_ID, ccip_flow_cnt_1d, ccip_queue_cnt_1d);
                    $display("NIC%d:        value= %p", NIC_ID, ccip_read_poll_data_1d);

                    // Increment update flag and forward RPC
                    d_bit_we        <= 1'b1;
                    rpc_out_valid   <= 1'b1;

                    // Do CPU bookkeeping
                    //sTx_c1.hdr               <= t_ccip_c1_ReqMemHdr'(0);
                    //sTx_c1.hdr.address       <= rx_bk_base_addr + bk_counter;
                    //sTx_c1.hdr.sop           <= 1'b1;
                    //sTx_c1.hdr.vc_sel        <= eVC_VH0;
                    //sTx_c1.hdr.req_type      <= eREQ_WRPUSH_I;
                    //sTx_c1.data[MDATA_W-1:0] <= ccip_read_poll_cl;
                    //sTx_c1.valid             <= 1'b1;

                    //bk_counter <= bk_counter + 1;
                end
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

    // Status
    assign initialized = d_bit_tb_initialized;


endmodule
