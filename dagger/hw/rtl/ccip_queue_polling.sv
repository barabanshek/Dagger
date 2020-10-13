// Author: Cornell University
//
// Module Name :    ccip_polling
// Project :        F-NIC
// Description :    implements bi-directional CPU-NIC interface
//                    - CPU-NIC: polling based over UPI
//                    - NIC-CPU: batched eREQ_WRLINE_I over PCIe
//                    - book-keeping: TODO
//
// Known bugs:
//                  1) Some requests are duplicated
//                    - symptoms: some requests are duplicated
//                    - reason: ccip_dirty_tb table takes 1 cycle for the dirty
//                              flag update. If two requests from the same entry
//                              are coming next to each other, the dirty_bit won't
//                              be updated.
//

`include "platform_if.vh"
`include "nic_defs.vh"
`include "async_fifo_channel.sv"
`include "ccip_transmitter.sv"

module ccip_queue_polling
    #(
        // NIC ID
        parameter NIC_ID = 0,
        // total number of NICs in the system
        parameter NUM_SUB_AFUS = 1,
        // polling rate
        parameter LMAX_POLLING_RATE = 8,
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
        input logic[LMAX_POLLING_RATE-1:0]  tx_polling_rate,
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
        input RpcIf                        rpc_in,  // TODO: why RpcIf here if rpc_flow_id is still used?
        input logic                        rpc_in_valid,
        input logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_in
    );


    // =============================================================
    // CPU - NIC datapath
    // =============================================================
    localparam RX_BATCH_SIZE = 4;

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
    typedef enum logic { RxIdle, RxDelay } RxState;

    RxState rx_state;
    logic[1:0] rx_batch_cnt;
    logic[MDATA_W-1:0]  queue_poll_cnt;
    logic[MDATA_W-1:0]  flow_poll_cnt;
    logic[LMAX_POLLING_RATE-1:0] poll_frq_div_cnt;

    always_ff @(posedge clk) begin
        if (reset) begin
            rx_state         <= RxIdle;
            rx_batch_cnt     <= {($bits(rx_batch_cnt)){1'b0}};
            sTx_c0.valid     <= 1'b0;
            queue_poll_cnt   <= {($bits(queue_poll_cnt)){1'b0}};
            flow_poll_cnt    <= {($bits(flow_poll_cnt)){1'b0}};
            poll_frq_div_cnt <= {($bits(poll_frq_div_cnt)){1'b0}};

        end else begin
            // Data
            sTx_c0.hdr                    <= t_ccip_c0_ReqMemHdr'(0);
            sTx_c0.hdr.cl_len             <= eCL_LEN_4;
            sTx_c0.hdr.vc_sel             <= eVC_VL0;
            sTx_c0.hdr.req_type           <= eREQ_RDLINE_I;
            sTx_c0.hdr.address            <= tx_base_addr +
                                             (flow_poll_cnt << LMAX_RX_QUEUE_SIZE) +
                                             queue_poll_cnt;
            sTx_c0.hdr.mdata[MDATA_W-1:0] <= META_PATTERN ^
                                             ((flow_poll_cnt << LMAX_RX_QUEUE_SIZE) +
                                               queue_poll_cnt);

            // Control
            sTx_c0.valid <= 1'b0;

            if (rx_state == RxIdle) begin
                if (start && !sRx_c0TxAlmFull) begin
                    // Start batch read
                    sTx_c0.valid <= 1'b1;
                    rx_state     <= RxDelay;
                end
            end

            if (rx_state == RxDelay) begin
                if (poll_frq_div_cnt == tx_polling_rate) begin
                    // Switch entry/queue
                    if (queue_poll_cnt == rx_queue_size - RX_BATCH_SIZE + 1) begin
                        queue_poll_cnt <= {($bits(queue_poll_cnt)){1'b0}};

                        // Switch queue
                        if (flow_poll_cnt == number_of_flows) begin
                            flow_poll_cnt <= {($bits(flow_poll_cnt)){1'b0}};
                        end else begin
                            flow_poll_cnt <= flow_poll_cnt + 1;
                        end
                    end else begin
                        queue_poll_cnt <= queue_poll_cnt + RX_BATCH_SIZE;
                    end

                    poll_frq_div_cnt <= {($bits(poll_frq_div_cnt)){1'b0}};
                    rx_state         <= RxIdle;
                end else begin
                    poll_frq_div_cnt <= poll_frq_div_cnt + 1;
                    rx_state         <= RxDelay;
                end
            end
        end
    end

    // Get answer
    RpcPckt                       sRx_casted;
    RpcPckt                       ccip_read_poll_data;
    logic[MDATA_W-1:0]            ccip_read_poll_cl_casted;
    logic[1:0]                    ccip_read_poll_cl_batch_line;
    logic[MDATA_W-1:0]            ccip_read_poll_cl;
    logic[LMAX_RX_QUEUE_SIZE-1:0] ccip_queue_cnt;
    logic[LMAX_NUM_OF_FLOWS-1:0]  ccip_flow_cnt;
    logic                         ccip_read_poll_data_valid;

    always_comb begin
        sRx_casted                   = sRx_c0.data[$bits(RpcPckt)-1:0];
        ccip_read_poll_cl_casted     = sRx_c0.hdr.mdata[MDATA_W-1:0] ^ META_PATTERN;
        ccip_read_poll_cl_batch_line = sRx_c0.hdr.cl_num;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            ccip_read_poll_data_valid <= 1'b0;
            ccip_read_poll_cl         <= {(MDATA_W){1'b0}};
            ccip_read_poll_data       <= {($bits(RpcPckt)){1'b0}};

        end else begin
            // Data
            ccip_queue_cnt      <= ccip_read_poll_cl_casted[LMAX_RX_QUEUE_SIZE-1:0] +
                                   ccip_read_poll_cl_batch_line;
            ccip_flow_cnt       <= (ccip_read_poll_cl_casted >> LMAX_RX_QUEUE_SIZE);
            ccip_read_poll_cl   <= ccip_read_poll_cl_casted + ccip_read_poll_cl_batch_line;
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
                    $display("NIC%d: new value read from flow %d, queue entry %d", NIC_ID, ccip_flow_cnt_1d, ccip_queue_cnt_1d);
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
    // =============================================================
    localparam LTX_FIFO_DEPTH = 3;

    logic ccip_transmitter_initialized;
    logic ccip_transmitter_error;

    ccip_transmitter #(
            .NIC_ID(NIC_ID),
            .LMAX_NUM_OF_FLOWS(LMAX_NUM_OF_FLOWS)
        ) ccip_tx (
            .clk(clk),
            .reset(reset),

            .number_of_flows(number_of_flows),
            .tx_base_addr(rx_base_addr),
            .l_tx_batch_size(l_tx_batch_size),
            .start(start),

            .initialize(initialize),
            .initialized(ccip_transmitter_initialized),
            .error(ccip_transmitter_error),

            .sRx_c1TxAlmFull(sRx_c1TxAlmFull),
            .sTx_c1(sTx_c1),

            .ccip_tx_ready(ccip_tx_ready),
            .rpc_in(rpc_in),
            .rpc_in_valid(rpc_in_valid),
            .rpc_flow_id_in(rpc_flow_id_in)
        );


    // Status
    assign initialized = d_bit_tb_initialized & ccip_transmitter_initialized;
    assign error = ccip_transmitter_error;


endmodule
