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

module tab_hash(clk, reset, valid, ready, done, processing, key, hash);
    input clk, reset, ready, done;
    input [63:0] key;
    output reg valid, processing;
    output [31:0] hash;

    reg [3:0] state, next_state;
    reg [31:0] hash_reg, next_hash;
    
    assign hash = hash_reg;
    logic [31:0] sbox [0:255] = 
    {
        32'hF53E1837, 32'h5F14C86B, 32'h9EE3964C, 32'hFA796D53,
        32'h32223FC3, 32'h4D82BC98, 32'hA0C7FA62, 32'h63E2C982,
        32'h24994A5B, 32'h1ECE7BEE, 32'h292B38EF, 32'hD5CD4E56,
        32'h514F4303, 32'h7BE12B83, 32'h7192F195, 32'h82DC7300,
        32'h084380B4, 32'h480B55D3, 32'h5F430471, 32'h13F75991,
        32'h3F9CF22C, 32'h2FE0907A, 32'hFD8E1E69, 32'h7B1D5DE8,
        32'hD575A85C, 32'hAD01C50A, 32'h7EE00737, 32'h3CE981E8,
        32'h0E447EFA, 32'h23089DD6, 32'hB59F149F, 32'h13600EC7,
        32'hE802C8E6, 32'h670921E4, 32'h7207EFF0, 32'hE74761B0,
        32'h69035234, 32'hBFA40F19, 32'hF63651A0, 32'h29E64C26,
        32'h1F98CCA7, 32'hD957007E, 32'hE71DDC75, 32'h3E729595,
        32'h7580B7CC, 32'hD7FAF60B, 32'h92484323, 32'hA44113EB,
        32'hE4CBDE08, 32'h346827C9, 32'h3CF32AFA, 32'h0B29BCF1,
        32'h6E29F7DF, 32'hB01E71CB, 32'h3BFBC0D1, 32'h62EDC5B8,
        32'hB7DE789A, 32'hA4748EC9, 32'hE17A4C4F, 32'h67E5BD03,
        32'hF3B33D1A, 32'h97D8D3E9, 32'h09121BC0, 32'h347B2D2C,
        32'h79A1913C, 32'h504172DE, 32'h7F1F8483, 32'h13AC3CF6,
        32'h7A2094DB, 32'hC778FA12, 32'hADF7469F, 32'h21786B7B,
        32'h71A445D0, 32'hA8896C1B, 32'h656F62FB, 32'h83A059B3,
        32'h972DFE6E, 32'h4122000C, 32'h97D9DA19, 32'h17D5947B,
        32'hB1AFFD0C, 32'h6EF83B97, 32'hAF7F780B, 32'h4613138A,
        32'h7C3E73A6, 32'hCF15E03D, 32'h41576322, 32'h672DF292,
        32'hB658588D, 32'h33EBEFA9, 32'h938CBF06, 32'h06B67381,
        32'h07F192C6, 32'h2BDA5855, 32'h348EE0E8, 32'h19DBB6E3,
        32'h3222184B, 32'hB69D5DBA, 32'h7E760B88, 32'hAF4D8154,
        32'h007A51AD, 32'h35112500, 32'hC9CD2D7D, 32'h4F4FB761,
        32'h694772E3, 32'h694C8351, 32'h4A7E3AF5, 32'h67D65CE1,
        32'h9287DE92, 32'h2518DB3C, 32'h8CB4EC06, 32'hD154D38F,
        32'hE19A26BB, 32'h295EE439, 32'hC50A1104, 32'h2153C6A7,
        32'h82366656, 32'h0713BC2F, 32'h6462215A, 32'h21D9BFCE,
        32'hBA8EACE6, 32'hAE2DF4C1, 32'h2A8D5E80, 32'h3F7E52D1,
        32'h29359399, 32'hFEA1D19C, 32'h18879313, 32'h455AFA81,
        32'hFADFE838, 32'h62609838, 32'hD1028839, 32'h0736E92F,
        32'h3BCA22A3, 32'h1485B08A, 32'h2DA7900B, 32'h852C156D,
        32'hE8F24803, 32'h00078472, 32'h13F0D332, 32'h2ACFD0CF,
        32'h5F747F5C, 32'h87BB1E2F, 32'hA7EFCB63, 32'h23F432F0,
        32'hE6CE7C5C, 32'h1F954EF6, 32'hB609C91B, 32'h3B4571BF,
        32'hEED17DC0, 32'hE556CDA0, 32'hA7846A8D, 32'hFF105F94,
        32'h52B7CCDE, 32'h0E33E801, 32'h664455EA, 32'hF2C70414,
        32'h73E7B486, 32'h8F830661, 32'h8B59E826, 32'hBB8AEDCA,
        32'hF3D70AB9, 32'hD739F2B9, 32'h4A04C34A, 32'h88D0F089,
        32'hE02191A2, 32'hD89D9C78, 32'h192C2749, 32'hFC43A78F,
        32'h0AAC88CB, 32'h9438D42D, 32'h9E280F7A, 32'h36063802,
        32'h38E8D018, 32'h1C42A9CB, 32'h92AAFF6C, 32'hA24820C5,
        32'h007F077F, 32'hCE5BC543, 32'h69668D58, 32'h10D6FF74,
        32'hBE00F621, 32'h21300BBE, 32'h2E9E8F46, 32'h5ACEA629,
        32'hFA1F86C7, 32'h52F206B8, 32'h3EDF1A75, 32'h6DA8D843,
        32'hCF719928, 32'h73E3891F, 32'hB4B95DD6, 32'hB2A42D27,
        32'hEDA20BBF, 32'h1A58DBDF, 32'hA449AD03, 32'h6DDEF22B,
        32'h900531E6, 32'h3D3BFF35, 32'h5B24ABA2, 32'h472B3E4C,
        32'h387F2D75, 32'h4D8DBA36, 32'h71CB5641, 32'hE3473F3F,
        32'hF6CD4B7F, 32'hBF7D1428, 32'h344B64D0, 32'hC5CDFCB6,
        32'hFE2E0182, 32'h2C37A673, 32'hDE4EB7A3, 32'h63FDC933,
        32'h01DC4063, 32'h611F3571, 32'hD167BFAF, 32'h4496596F,
        32'h3DEE0689, 32'hD8704910, 32'h7052A114, 32'h068C9EC5,
        32'h75D0E766, 32'h4D54CC20, 32'hB44ECDE2, 32'h4ABC653E,
        32'h2C550A21, 32'h1A52C0DB, 32'hCFED03D0, 32'h119BAFE2,
        32'h876A6133, 32'hBC232088, 32'h435BA1B2, 32'hAE99BBFA,
        32'hBB4F08E4, 32'hA62B5F49, 32'h1DA4B695, 32'h336B84DE,
        32'hDC813D31, 32'h00C134FB, 32'h397A98E6, 32'h151F0E64,
        32'hD9EB3E69, 32'hD3C7DF60, 32'hD2F2C336, 32'h2DDD067B,
        32'hBD122835, 32'hB0B3BD3A, 32'hB0D54E46, 32'h8641F1E4,
        32'hA0B38F96, 32'h51D39199, 32'h37A6AD75, 32'hDF84EE41,
        32'h3C034CBA, 32'hACDA62FC, 32'h11923B8B, 32'h45EF170A
    };

    always @(*) begin
        case(state) 
            4'd0: begin
                valid <= 1'd0;
                processing <= 1'd0;
                next_hash <= 32'd4294967291;
                if(ready) next_state <= 4'd1;
                else next_state <= 4'd0;
            end
            4'd1: begin
                valid <= 1'd0;
                processing <= 1'd1;
                next_hash <= hash ^ sbox[key[63:56]];
                next_state <= 4'd2; 
            end
            4'd2: begin
                valid <= 1'd0;
                processing <= 1'd1;
                next_hash <= hash ^ sbox[key[55:48]];
                next_state <= 4'd3; 
            end
            4'd3: begin
                valid <= 1'd0;
                processing <= 1'd1;
                next_hash <= hash ^ sbox[key[47:40]];
                next_state <= 4'd4; 
            end
            4'd4: begin
                valid <= 1'd0;
                processing <= 1'd1;
                next_hash <= hash ^ sbox[key[39:32]];
                next_state <= 4'd5; 
            end
            4'd5: begin
                valid <= 1'd0;
                processing <= 1'd1;
                next_hash <= hash ^ sbox[key[31:24]];
                next_state <= 4'd6; 
            end
            4'd6: begin
                valid <= 1'd0;
                processing <= 1'd1;
                next_hash <= hash ^ sbox[key[23:16]];
                next_state <= 4'd7; 
            end
            4'd7: begin
                valid <= 1'd0;
                processing <= 1'd1;
                next_hash <= hash ^ sbox[key[15:8]];
                next_state <= 4'd8; 
            end
            4'd8: begin
                valid <= 1'd0;
                processing <= 1'd1;
                next_hash <= hash ^ sbox[key[7:0]];
                next_state <= 4'd9; 
            end
            4'd9: begin
                valid <= 1'd1;
                processing <= 1'd1;
                next_hash <= hash;
                if (done) next_state <= 4'd0;
                else next_state <= 4'd9; 
            end
            
        endcase 
    end

    always @(posedge clk) begin
        if(reset) begin
            state <= 4'd0;
            hash_reg <= 32'd4294967291;
        end
        else begin
            state <= next_state;
            hash_reg <= next_hash;
        end
    end
endmodule
    
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

    logic [LMAX_NUM_OF_FLOWS:0] number_of_flows_plus_one;
    lpm_add_sub lpm_add_sub_ (
        .dataa({1'd0, number_of_flows}),
        .datab(5'd1),
        .result(number_of_flows_plus_one)
    );
    defparam
        lpm_add_sub_.lpm_direction = "ADD", 
        lpm_add_sub_.lpm_width = 5;

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

    logic [LMAX_NUM_OF_FLOWS:0] quotient, remainder;
    lpm_divide lpm_divide_ (
        .numer(rng_data[LMAX_NUM_OF_FLOWS:0]),
        .denom(number_of_flows_plus_one),
        .quotient(quotient),
        .remain(remainder)
    );
    defparam 
        lpm_divide_.lpm_widthn = 32,
        lpm_divide_.lpm_widthd = 32;

    

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

    logic valid[9];
    logic ready[9];
    logic done[9];
    logic processing[9];
    logic [63:0] key[9];
    logic [31:0] hash[9];
    logic ReqQueueSlotId rq_slot[9];
    genvar gj;
    generate 
    for(gj=0; gj<9; gj=gj+1) begin: hash_load_balancers
        tab_hash load_balancer(
            .clk(clk),
            .reset(reset),
            .valid(valid[gi]),
            .ready(ready[gi]),
            .done(done[gi]),
            .processing(.processing[gi]),
            .key(key[gi]),
            .hash(hash[gi])
        );
    end
    endgenerate

    // Push logic
    FlowId rpc_flow_id_in_1d, rpc_flow_id_in_2d, rpc_flow_id_in_rand;

    integer i2, i3, i4, i5, i6, i7;
    always @(posedge clk) begin
        // Defaults
        rq_push_en <= 1'b0;
        rng_ready <= 1'b0;
        for(i3=0; i3<MAX_TX_FLOWS; i3=i3+1) begin
            ff_push_en[i3] <= 1'b0;
        end

        for(i5=0; i5<9; i5=i5+1) begin
            ready[i5] <= 1'd0;
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

        rpc_flow_id_in_rand <= remainder[LMAX_NUM_OF_FLOWS - 1:0];

        // Put slot_id to corresponding flow FIFO
        if (rq_push_done) begin
            $display("NIC%d: CCI-P transmitter, writing request to flow fifo= %d, rq_slot_id= %d",
                                        NIC_ID, rpc_flow_id_in_1d, rq_slot_id);
            
            if (rpc_in.rpc_data.hdr.ctl.req_type == rpcReq) begin
                    // ff_push_data[rpc_flow_id_in_rand] <= rq_slot_id;
                    // ff_push_en[rpc_flow_id_in_rand] <= 1'b1;
                //priority encoder to select hash calculator
                if(processing[0] == 1'd0) begin
                    key[0] 
                end
                    
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

            for(i4=0; i4<9; i4=i4+1) begin
                ready[i4] <= 1'd0;
            end

            for(i6=0; i6<9; i6=i6+1) begin
                key[i6] <= 64'd0;
            end

            for(i7=0; i7<9; i7=i7+1) begin
                rq_
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
