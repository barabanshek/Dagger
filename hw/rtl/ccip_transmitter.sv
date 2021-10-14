// Author: Cornell University
//
// Module Name :    ccip_transmitter
// Project :        F-NIC
// Description :    implements the tx path of the CPU-NIC interface
//                    - batched eREQ_WRLINE_I over PCIe
//                    - configurable number of flows
//                    - configurable tx queue size
//                    - independent flow control
//

`include "async_fifo_channel.sv"
`include "platform_if.vh"
`include "nic_defs.vh"
`include "request_queue.sv"

module ccip_transmitter
    #(
        // NIC ID
        parameter NIC_ID = 0,
        // log # of NIC flows
        parameter LMAX_NUM_OF_FLOWS = 1,
        // log # of max TX queue size
        parameter LMAX_TX_QUEUE_SIZE = 1

    )
    (
        input logic clk,
        input logic reset,

        // Control
        input logic[LMAX_NUM_OF_FLOWS-1:0]    number_of_flows,
        input t_ccip_clAddr                   tx_base_addr,
        input logic[LMAX_CCIP_BATCH-1:0]    l_tx_batch_size,
        input logic[LMAX_TX_QUEUE_SIZE:0]     tx_queue_size,
        input logic                           start,

        // Status
        input logic  initialize,
        output logic initialized,
        output logic error,

        input logic lb_select,

        // CPU interface
        input  logic           sRx_c1TxAlmFull,
        output t_if_ccip_c1_Tx sTx_c1,

        output logic                       ccip_tx_ready,
        input RpcIf                        rpc_in,
        input logic                        rpc_in_valid,
        input logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_in,

        // Statistics
        output logic pdrop_tx_flows_out,

        // Debug output
        output logic[63:0] debug_out
    );

    // Parameters
    localparam LTX_FIFO_DEPTH = 3;
    localparam MAX_TX_FLOWS = 2**LMAX_NUM_OF_FLOWS;
    localparam RQ_LNUM_OF_SLOTS = LMAX_NUM_OF_FLOWS + LTX_FIFO_DEPTH;

    // Types
    typedef logic[RQ_LNUM_OF_SLOTS-1:0] ReqQueueSlotId;
    typedef logic[LMAX_NUM_OF_FLOWS-1:0] FlowId;
    typedef enum logic[1:0] { TxIdle, TxTransmit, TxGap } TxState;
    typedef logic[LMAX_CCIP_BATCH:0] TxBatch;
    typedef logic[LMAX_NUM_OF_FLOWS + LMAX_TX_QUEUE_SIZE:0] TxQueueAddress;

    typedef struct packed {
        TxQueueAddress region_begin;
        TxQueueAddress current;
        TxQueueAddress region_end;
    } TxQueueAddressTuple;

    // Request queue
    logic rq_push_en;
    RpcIf rq_push_data, rq_pop_data;
    ReqQueueSlotId rq_slot_id;
    logic rq_push_done;
    logic rq_pop_en;
    ReqQueueSlotId rq_pop_slot_id;
    logic rq_initialized;

    request_queue #(
            .DATA_WIDTH($bits(RpcIf)),
            .LSIZE(LMAX_NUM_OF_FLOWS + LTX_FIFO_DEPTH)
        ) request_queue_ (
            .clk(clk),
            .reset(reset),

            .push_en_in(rq_push_en),
            .push_data_in(rq_push_data),
            .push_slot_id_out(rq_slot_id),
            .push_done_out(rq_push_done),

            .pop_en_in(rq_pop_en),
            .pop_slot_id_in(rq_pop_slot_id),
            .pop_data_out(rq_pop_data),

            .initialize(initialize),
            .initialized(rq_initialized),
            .error(error)
        );

    // Flow FIFOs
    logic ff_push_en[MAX_TX_FLOWS];
    ReqQueueSlotId ff_push_data[MAX_TX_FLOWS];
    logic ff_pop_en[MAX_TX_FLOWS];
    logic ff_pop_valid[MAX_TX_FLOWS];
    ReqQueueSlotId ff_pop_data[MAX_TX_FLOWS];
    logic [LTX_FIFO_DEPTH-1:0] ff_dw[MAX_TX_FLOWS];
    logic ff_ovf[MAX_TX_FLOWS];

    genvar gi;
    generate
    for(gi=0; gi<MAX_TX_FLOWS; gi=gi+1) begin: gen_flow_fifo
        async_fifo_channel #(
                .DATA_WIDTH($bits(ReqQueueSlotId)),
                .LOG_DEPTH(LTX_FIFO_DEPTH)
            )
        flow_fifo (
                .clear(reset),
                .clk_1(clk),
                .push_en(ff_push_en[gi]),
                .push_data(ff_push_data[gi]),
                .clk_2(clk),
                .pop_enable(ff_pop_en[gi]),
                .pop_valid(ff_pop_valid[gi]),
                .pop_data(ff_pop_data[gi]),
                .pop_dw(ff_dw[gi]),
                .loss_out(),
                .error(ff_ovf[gi])
            );
    end
    endgenerate

    //
    // Push logic
    //
    FlowId rpc_flow_id_in_d, rpc_flow_id_in_1d, rpc_flow_id_in_2d;

    logic [15:0] lb_flow_cnt;

    integer i2, i3;
    always @(posedge clk) begin
        // Defaults
        rq_push_en <= 1'b0;
        for(i3=0; i3<MAX_TX_FLOWS; i3=i3+1) begin
            ff_push_en[i3] <= 1'b0;
        end

        // Put request to request queue (TODO: move bellow)
        rq_push_data <= rpc_in;
        rpc_flow_id_in_d <= rpc_flow_id_in;

        if (start && rpc_in_valid) begin
            $display("NIC%d: CCI-P transmitter, rpc_in requesed for flow= %d, rpc_data= %d",
                                        NIC_ID, rpc_flow_id_in, rpc_in.rpc_data.argv);
            rq_push_en   <= 1'b1;
        end

        // Delay rpc_flow_id to align with rq look-up
        rpc_flow_id_in_1d <= rpc_flow_id_in_d;
        rpc_flow_id_in_2d <= rpc_flow_id_in_1d;

        // Put slot_id to corresponding flow FIFO
        if (rq_push_done) begin
            $display("NIC%d: CCI-P transmitter, writing request to flow fifo= %d, rq_slot_id= %d",
                                        NIC_ID, rpc_flow_id_in_2d, rq_slot_id);
            if (lb_select && rpc_in.rpc_data.hdr.ctl.req_type == rpcReq) begin
                ff_push_data[lb_flow_cnt] <= rq_slot_id;
                ff_push_en[lb_flow_cnt] <= 1'b1;
                if (lb_flow_cnt == number_of_flows) begin
                    lb_flow_cnt <= {($bits(lb_flow_cnt)){1'b0}};
                end else begin
                    lb_flow_cnt <= lb_flow_cnt + 1;
                end
            end else begin
                ff_push_data[rpc_flow_id_in_2d] <= rq_slot_id;
                ff_push_en[rpc_flow_id_in_2d] <= 1'b1;
            end
        end

        if (reset) begin
            rq_push_en <= 1'b0;

            for(i2=0; i2<MAX_TX_FLOWS; i2=i2+1) begin
                ff_push_en[i2] <= 1'b0;
            end

            lb_flow_cnt <= {($bits(lb_flow_cnt)){1'b0}};
        end
    end

    //
    // Pop (transmit) logic
    //
    TxBatch tx_batch_size;

    // Flow address table to keep track of pointers in the queues for each flow
    typedef enum logic[1:0] { TxTblIdle, TxTblInit, TxTblInitialized } TxQueueAddrTableInitState;
    TxQueueAddrTableInitState tx_queue_addr_table_init_state;
    FlowId tx_queue_addr_tabe_init_cnt;
    TxQueueAddressTuple tx_queue_addr_table_init_w, tx_queue_addr_table_r_data, tx_queue_addr_table_w_data;
    TxQueueAddress tx_queue_addr_table_r_addr, tx_queue_addr_table_w_addr;
    logic tx_queue_addr_table_w_en;

    // {flow_id -> [address begin, address current, address end]}
    single_clock_wr_ram #(
            .DATA_WIDTH($bits(TxQueueAddressTuple)),
            .ADR_WIDTH(LMAX_NUM_OF_FLOWS)
        )
    tx_queue_address_tb (
            .clk(clk),
            .q(tx_queue_addr_table_r_data),
            .d(tx_queue_addr_table_init_state == TxTblInit? tx_queue_addr_table_init_w: tx_queue_addr_table_w_data),
            .write_address(tx_queue_addr_table_init_state == TxTblInit? tx_queue_addr_tabe_init_cnt: tx_queue_addr_table_w_addr),
            .read_address(tx_queue_addr_table_r_addr),
            .we(tx_queue_addr_table_init_state == TxTblInit? 1'b1: tx_queue_addr_table_w_en)
        );

    // Pre-compute flow address table based on the flow information
    // Note: this logic might run at a lower frequency
    TxQueueAddress tx_queue_addr;
    always_comb begin
        // Combinationally compute address tuples
        tx_queue_addr = tx_queue_addr_tabe_init_cnt * tx_queue_size;

        // Compute address tuple
        tx_queue_addr_table_init_w = '{
            region_begin: tx_queue_addr,
            current: tx_queue_addr,
            region_end: tx_queue_addr + tx_queue_size - tx_batch_size};
    end

    always_ff @(posedge clk) begin
        if (tx_queue_addr_table_init_state == TxTblIdle && initialize) begin
            tx_queue_addr_table_init_state <= TxTblInit;
        end

        if (tx_queue_addr_table_init_state == TxTblInit) begin
            // Increment entry
            if (tx_queue_addr_tabe_init_cnt == number_of_flows) begin
                tx_queue_addr_table_init_state <= TxTblInitialized;
            end else
                tx_queue_addr_tabe_init_cnt <= tx_queue_addr_tabe_init_cnt + 1;
        end

        if (reset) begin
            tx_queue_addr_table_init_state <= TxTblIdle;
            tx_queue_addr_tabe_init_cnt <= 'd0;
        end
    end

    // TX path
    FlowId tx_flow_cnt;
    TxQueueAddress tx_queue_address;
    t_ccip_clLen tx_cl_len;
    TxBatch tx_batch_cnt;
    TxState tx_state;

    // Aux combinational assignments
    always_comb begin
        tx_queue_addr_table_r_addr = tx_flow_cnt;

        // CCI-P Batch size
        if (l_tx_batch_size == 0) begin
            tx_batch_size     = 1;
            tx_cl_len         = eCL_LEN_1;
        end else if (l_tx_batch_size == 1) begin
            tx_batch_size     = 2;
            tx_cl_len         = eCL_LEN_2;
        end else if (l_tx_batch_size == 2) begin
            tx_batch_size     = 4;
            tx_cl_len         = eCL_LEN_4;
        end
    end

    // TX FSM:
    //  - determine current flow FIFO
    //  - read tx queue pointers
    //  - update tx queue pointers
    integer i4, i5;
    always @(posedge clk) begin
        // Initial values
        tx_queue_addr_table_w_en <= 1'b0;
        for(i5=0; i5<MAX_TX_FLOWS; i5=i5+1) begin
            ff_pop_en[i5] <= 1'b0;
        end

        if (tx_state == TxIdle) begin
            // Look for a flow that already has tx_batch_size number of requests
            if (ff_dw[tx_flow_cnt] >= tx_batch_size) begin
                // Found - go to TxTransmit
                $display("NIC%d: CCI-P transmitter, batch is found in flow fifo= %d",
                                        NIC_ID, tx_flow_cnt);
                ff_pop_en[tx_flow_cnt] <= 1'b1;
                tx_state               <= TxTransmit;
            end else begin
                // If not completed flow found, keep iterating
                if (tx_flow_cnt == number_of_flows) begin
                    tx_flow_cnt <= {($bits(tx_flow_cnt)){1'b0}};
                end else begin
                    tx_flow_cnt <= tx_flow_cnt + 1;
                end
                tx_state <= TxIdle;
            end
        end

        if (tx_state == TxTransmit) begin
            // When first time
            if (tx_batch_cnt == 0) begin
                // Save tx_queue_address for the following transmission
                tx_queue_address <= tx_queue_addr_table_r_data.current;

                // Update tx_queue_address
                // Increment queue entry in tx_queue_address_tb for the given flow_id
                tx_queue_addr_table_w_addr <= tx_flow_cnt;
                if (tx_queue_addr_table_r_data.current == tx_queue_addr_table_r_data.region_end) begin
                    // Wrap around
                    tx_queue_addr_table_w_data <= '{
                        region_begin: tx_queue_addr_table_r_data.region_begin,
                        current: tx_queue_addr_table_r_data.region_begin,
                        region_end: tx_queue_addr_table_r_data.region_end};
                end else begin
                   // Increment
                    tx_queue_addr_table_w_data <= '{
                        region_begin: tx_queue_addr_table_r_data.region_begin,
                        current: tx_queue_addr_table_r_data.current + tx_batch_size,
                        region_end: tx_queue_addr_table_r_data.region_end};
                end
                tx_queue_addr_table_w_en <= 1'b1;
            end

            // Increment batch counter
            if (tx_batch_cnt == tx_batch_size - 1) begin
                tx_batch_cnt <= {($bits(tx_batch_cnt)){1'b0}};
                tx_state     <= TxGap;
            end else begin
                ff_pop_en[tx_flow_cnt] <= 1'b1;
                tx_batch_cnt <= tx_batch_cnt + 1;
                tx_state <= TxTransmit;
            end
        end

        if (tx_state == TxGap)
            // We need this gap to update tx_queue_addr table
            tx_state <= TxIdle;

        // Reset
        if (reset) begin
            tx_state         <= TxIdle;
            tx_flow_cnt      <= {($bits(tx_flow_cnt)){1'b0}};
            tx_batch_cnt     <= {($bits(tx_batch_cnt)){1'b0}};
            for(i4=0; i4<MAX_TX_FLOWS; i4=i4+1) begin
                ff_pop_en[i4] <= 1'b0;
            end
        end
    end

    // TX pipeline (input - data from the above FSM):
    //  - STAGE 1: look-up payload location in request queue from flow FIFO
    //  - STAGE 2: look-up payload from request queue
    //  - STAGE 3: transmit over CCI-P
    TxQueueAddress tx_queue_address_d, tx_queue_address_d1;
    FlowId tx_flow_cnt_d, tx_flow_cnt_d1;
    TxBatch tx_out_batch_cnt;
    logic rq_read_d;
    always @(posedge clk) begin
        // Defaults
        rq_pop_en <= 1'b0;

        // Delay to alight with flow FIFO look-up
        tx_flow_cnt_d <= tx_flow_cnt;
        tx_queue_address_d <= tx_queue_address;

        // Request RPC packets from request queue
        if (ff_pop_valid[tx_flow_cnt_d]) begin
            rq_pop_slot_id <= ff_pop_data[tx_flow_cnt_d];
            rq_pop_en <= 1'b1;
        end

        // Delay to align with request queue look-up
        rq_read_d          <= rq_pop_en;
        tx_flow_cnt_d1     <= tx_flow_cnt_d;
        tx_queue_address_d1 <= tx_queue_address_d;

        // Transmit over CCI-P
        // Data
        sTx_c1.hdr                      <= t_ccip_c1_ReqMemHdr'(0);
        sTx_c1.hdr.cl_len               <= tx_cl_len;
        sTx_c1.hdr.vc_sel               <= eVC_VH0;
        sTx_c1.hdr.req_type             <= eREQ_WRLINE_I;
        sTx_c1.hdr.address              <= tx_base_addr + tx_queue_address_d1 + tx_out_batch_cnt;
        sTx_c1.hdr.sop                  <= tx_out_batch_cnt == 0;
        sTx_c1.data[$bits(RpcPckt)-1:0] <= rq_pop_data.rpc_data;

        // CCI-P Batch control
        sTx_c1.valid <= 1'b0;
        if (rq_read_d) begin
            $display("NIC%d: Writing back to flow %d", NIC_ID, tx_flow_cnt_d1);
            $display("NIC%d:         base queue entry= %d", NIC_ID, tx_queue_address_d1);
            $display("NIC%d:         %dth value in batch= %p", NIC_ID, tx_out_batch_cnt, rq_pop_data);

            sTx_c1.valid <= 1'b1;

            // Batch counter
            if (tx_out_batch_cnt == tx_batch_size - 1) begin
                tx_out_batch_cnt <= {($bits(tx_out_batch_cnt)){1'b0}};
            end else begin
                tx_out_batch_cnt <= tx_out_batch_cnt + 1;
            end
        end

        // Reset
        if (reset) begin
            tx_out_batch_cnt <= {($bits(tx_out_batch_cnt)){1'b0}};
            rq_pop_en        <= 1'b0;
        end
    end

    // Assert CCI-P tx ready signal
    assign ccip_tx_ready =  ~sRx_c1TxAlmFull;

    // Flow FIFO ovf statistics
    integer i6;
    always_comb begin
        pdrop_tx_flows_out = 1'b0;

        for(i6=0; i6<MAX_TX_FLOWS; i6=i6+1) begin
            pdrop_tx_flows_out = pdrop_tx_flows_out | ff_ovf[i6];
        end
    end

    // Assign status
    assign initialized = rq_initialized & (tx_queue_addr_table_init_state == TxTblInitialized);

    // Assign debug output
    assign debug_out = tx_state | (rpc_flow_id_in_2d << 8);

endmodule
