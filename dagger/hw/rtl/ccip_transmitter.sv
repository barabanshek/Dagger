// Author: Cornell University
//
// Module Name :    ccip_transmitter
// Project :        F-NIC
// Description :    implements the tx path of the CPU-NIC interface
//                    - batched eREQ_WRLINE_I over PCIe
//                    - configurable number of flows
//                    - independent flow control
//

`include "async_fifo_channel.sv"
`include "platform_if.vh"
`include "nic_defs.vh"
`include "request_queue.sv"
`include "rng_module.v"

module ccip_transmitter
    #(
        // NIC ID
        parameter NIC_ID = 0,
        // log # of NIC flows
        parameter LMAX_NUM_OF_FLOWS = 1

    )
    (
        input logic clk,
        input logic reset,

        // Control
        input logic[LMAX_NUM_OF_FLOWS-1:0]  number_of_flows,
        input t_ccip_clAddr                 tx_base_addr,
        input logic[LMAX_CCIP_BATCH-1:0]  l_tx_batch_size,
        input logic                         start,

        // Status
        input logic  initialize,
        output logic initialized,
        output logic error,

        // CPU interface
        input  logic           sRx_c1TxAlmFull,
        output t_if_ccip_c1_Tx sTx_c1,

        output logic                       ccip_tx_ready,
        input RpcIf                        rpc_in,
        input logic                        rpc_in_valid,
        input logic[LMAX_NUM_OF_FLOWS-1:0] rpc_flow_id_in,

        // Statistics
        output logic pdrop_tx_flows_out
    );

    // Parameters
    localparam LTX_FIFO_DEPTH = 3;
    localparam MAX_TX_FLOWS = 2**LMAX_NUM_OF_FLOWS;
    localparam RQ_LNUM_OF_SLOTS = LMAX_NUM_OF_FLOWS + LTX_FIFO_DEPTH;

    // Types
    typedef logic[RQ_LNUM_OF_SLOTS-1:0] ReqQueueSlotId;
    typedef logic[LMAX_NUM_OF_FLOWS-1:0] FlowId;
    typedef enum logic { TxIdle, TxTransmit } TxState;
    typedef logic[LMAX_CCIP_BATCH:0] TxBatch;

    // Request queue
    logic rq_push_en;
    RpcIf rq_push_data, rq_pop_data;
    ReqQueueSlotId rq_slot_id;
    logic rq_push_done;
    logic rq_pop_en;
    ReqQueueSlotId rq_pop_slot_id;

    logic rng_enable, rng_ready, rng_valid;
    logic [31:0] rng_data;
    
    rng_module u0 (
	.start          (1'b1),          //     call.enable
	.clock          (clk),                 //    clock.clk
	.rand_num_data  (rng_data),  	       // rand_num.data
	.rand_num_ready (rng_ready),           //         .ready
	.rand_num_valid (rng_valid),           //         .valid
	.resetn         (~reset)                //    reset.reset_n
	);

    logic [LMAX_NUM_OF_FLOWS-1:0] quotient, remainder;
    lpm_divide lpm_divide_ (
        .numer(rng_data[LMAX_NUM_OF_FLOWS-1:0]),
        .denom(number_of_flows),
        .quotient(quotient),
        .remain(remainder)
    );
    defparam 
        lpm_divide_.lpm_widthn = LMAX_NUM_OF_FLOWS,
        lpm_divide_.lpm_widthd = LMAX_NUM_OF_FLOWS;

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
            .initialized(initialized),
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
                .DATA_WIDTH($bits(RpcIf)),
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
                .error(ff_ovf[gi])
            );
    end
    endgenerate

    // Push logic
    FlowId rpc_flow_id_in_1d, rpc_flow_id_in_2d, rpc_flow_id_in_rand;

    integer i2, i3;
    always @(posedge clk) begin
        // Defaults
        rq_push_en <= 1'b0;
        rng_ready <= 1'b0;
        for(i3=0; i3<MAX_TX_FLOWS; i3=i3+1) begin
            ff_push_en[i3] <= 1'b0;
        end

        // Put request to request queue
        rq_push_data <= rpc_in;

        if (start && rpc_in_valid) begin
            $display("NIC%d: CCI-P transmitter, rpc_in requesed for flow= %d",
                                        NIC_ID, rpc_flow_id_in);
            rq_push_en   <= 1'b1;
            rng_ready <= 1'b1;
        end

        // Delay rpc_flow_id to align with rq look-up
        rpc_flow_id_in_1d <= rpc_flow_id_in;
        rpc_flow_id_in_2d <= rpc_flow_id_in_1d;

        rpc_flow_id_in_rand <= remainder;

        // Put slot_id to corresponding flow FIFO
        if (rq_push_done) begin
            $display("NIC%d: CCI-P transmitter, writing request to flow fifo= %d, rq_slot_id= %d",
                                        NIC_ID, rpc_flow_id_in_1d, rq_slot_id);
            
            if (rpc_in.rpc_data.hdr.ctl.req_type == rpcReq) begin
                ff_push_data[rpc_flow_id_in_rand] <= rq_slot_id;
                ff_push_en[rpc_flow_id_in_rand] <= 1'b1;
            end
            else begin
                ff_push_data[rpc_flow_id_in_2d] <= rq_slot_id;
                ff_push_en[rpc_flow_id_in_2d] <= 1'b1;
            end
        end

        if (reset) begin
            rng_ready <= 1'b0;
            rq_push_en <= 1'b0;

            for(i2=0; i2<MAX_TX_FLOWS; i2=i2+1) begin
                ff_push_en[i2] <= 1'b0;
            end
        end
    end

    // Pop (transmit) logic
    TxBatch tx_batch_size;
    t_ccip_clLen tx_cl_len;
    logic [LMAX_NUM_OF_FLOWS+LMAX_CCIP_BATCH:0] tx_out_flow_shift;
    TxState tx_state;
    FlowId tx_flow_cnt, tx_flow_cnt_d, tx_flow_cnt_d1;
    TxBatch tx_batch_cnt;
    TxBatch tx_out_batch_cnt;
    logic rq_read_d;

    // Combinational assignment of batch sizes
    always_comb begin
        if (l_tx_batch_size == 0) begin
            tx_batch_size     = 1;
            tx_cl_len         = eCL_LEN_1;
            tx_out_flow_shift = tx_flow_cnt_d1;
        end else if (l_tx_batch_size == 1) begin
            tx_batch_size     = 2;
            tx_cl_len         = eCL_LEN_2;
            tx_out_flow_shift = tx_flow_cnt_d1 << 1;
        end else if (l_tx_batch_size == 2) begin
            tx_batch_size     = 4;
            tx_cl_len         = eCL_LEN_4;
            tx_out_flow_shift = tx_flow_cnt_d1 << 2;
        end
    end

    integer i4, i5;
    always @(posedge clk) begin
        // Initial values
        rq_pop_en <= 1'b0;
        for(i5=0; i5<MAX_TX_FLOWS; i5=i5+1) begin
            ff_pop_en[i5] <= 1'b0;
        end

        if (tx_state == TxIdle) begin
            // Look for a flow that already has tx_batch_size number of requests
            if (ff_dw[tx_flow_cnt] >= tx_batch_size) begin
                $display("NIC%d: CCI-P transmitter, batch is find in flow fifo= %d",
                                        NIC_ID, tx_flow_cnt);
                ff_pop_en[tx_flow_cnt] <= 1'b1;
                tx_state               <= TxTransmit;
            end else begin
                if (tx_flow_cnt == number_of_flows) begin
                    tx_flow_cnt <= {($bits(tx_flow_cnt)){1'b0}};
                end else begin
                    tx_flow_cnt <= tx_flow_cnt + 1;
                end
                tx_state <= TxIdle;
            end
        end

        if (tx_state == TxTransmit) begin
            if (tx_batch_cnt == tx_batch_size - 1) begin
                tx_batch_cnt <= {($bits(tx_batch_cnt)){1'b0}};
                tx_state     <= TxIdle;
            end else begin
                ff_pop_en[tx_flow_cnt] <= 1'b1;
                tx_batch_cnt <= tx_batch_cnt + 1;
                tx_state <= TxTransmit;
            end
        end

        // Delay to alight with ff look-up
        tx_flow_cnt_d <= tx_flow_cnt;

        // Get RPC packets from request queue
        if (ff_pop_valid[tx_flow_cnt_d]) begin
            rq_pop_slot_id <= ff_pop_data[tx_flow_cnt_d];
            rq_pop_en <= 1'b1;
        end

        // Delay to align with rq look-up
        rq_read_d      <= rq_pop_en;
        tx_flow_cnt_d1 <= tx_flow_cnt_d;

        // Transmit over CCI-P
        // Data
        sTx_c1.hdr                    <= t_ccip_c1_ReqMemHdr'(0);
        sTx_c1.hdr.cl_len             <= tx_cl_len;
        sTx_c1.hdr.vc_sel             <= eVC_VH0;
        sTx_c1.hdr.req_type           <= eREQ_WRLINE_I;
        sTx_c1.hdr.address            <= tx_base_addr + tx_out_flow_shift + tx_out_batch_cnt;
        sTx_c1.hdr.sop                <= tx_out_batch_cnt == 0;
        sTx_c1.data[$bits(RpcIf)-1:0] <= rq_pop_data;   // TODO: fix here!

        // Control
        sTx_c1.valid <= 1'b0;
        if (rq_read_d) begin
            $display("NIC%d: Writing back to flow %d", NIC_ID, tx_flow_cnt_d1);
            $display("NIC%d:         %dth value= %p", NIC_ID, tx_out_batch_cnt, rq_pop_data);

            sTx_c1.valid <= 1'b1;

            // Batch counter
            if (tx_out_batch_cnt == tx_batch_size - 1) begin
                tx_out_batch_cnt <= {($bits(tx_out_batch_cnt)){1'b0}};
            end else begin
                tx_out_batch_cnt <= tx_out_batch_cnt + 1;
            end
        end

        if (reset) begin
            tx_state         <= TxIdle;
            tx_flow_cnt      <= {($bits(tx_flow_cnt)){1'b0}};
            tx_batch_cnt     <= {($bits(tx_batch_cnt)){1'b0}};
            tx_out_batch_cnt <= {($bits(tx_out_batch_cnt)){1'b0}};
            rq_pop_en        <= 1'b0;
            for(i4=0; i4<MAX_TX_FLOWS; i4=i4+1) begin
                ff_pop_en[i4] <= 1'b0;
            end
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

endmodule
