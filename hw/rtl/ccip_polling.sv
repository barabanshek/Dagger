// Author: Cornell University
//
// Module Name :    ccip_polling
// Project :        F-NIC
// Description :    implements bi-directional CPU-NIC interface
//                    - CPU-NIC: polling based
//                    - NIC-CPU: eREQ_WRPUSH_I with DDIO

`include "platform_if.vh"
`include "nic_defs.vh"

module ccip_polling
    #(
        // NIC ID
        parameter NIC_ID = 0, 
        // log # of NIC flows
        parameter LMAX_NUM_OF_FLOWS = 1,
        // total number of NICs in the system
        parameter NUM_SUB_AFUS = 1,
        // VC for CPU-NIC channel: eVC_VH0/eVC_VL0
        parameter FORWARD_VC = eVC_VH0,
        // Poll type: eREQ_RDLINE_I/eREQ_RDLINE_S
        parameter FORWARD_RD_TYPE = eREQ_RDLINE_I,
        // VC for NIC-CPU channel: eVC_VH0/eVC_VL0
        parameter BACKWARD_VC = eVC_VH0,
        // Write-back type: eREQ_WRLINE_I/eREQ_WRLINE_M/eREQ_WRPUSH_I
        parameter BACKWARD_WR_TYPE = eREQ_WRLINE_I,
        // polling rate
        parameter POLLING_RATE = 0
    )
    (
        input logic clk,
        input logic reset,

        // Control
        input t_ccip_clAddr rx_base_addr,
        input t_ccip_clAddr tx_base_addr,
        input logic[LMAX_NUM_OF_FLOWS-1:0] number_of_flows,
        input logic start,

        // Status
        input logic initialize,
        output logic initialized,

        // CPU interface
        input  logic           sRx_c0TxAlmFull,
        input  logic           sRx_c1TxAlmFull,
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
    // - polling mode over PCIe
    // - POLLING_RATE controls polling rate
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

    // Poll
    logic[MDATA_W-1:0]  flow_poll_cnt;
    logic[7:0]          flow_poll_frq_div_cnt;

    always_ff @(posedge clk) begin
        if (reset) begin
            sTx_c0.valid          <= 1'b0;
            flow_poll_cnt         <= {($bits(flow_poll_cnt)){1'b0}};
            flow_poll_frq_div_cnt <= {($bits(flow_poll_frq_div_cnt)){1'b0}};

        end else begin
            // Initial vals
            sTx_c0.valid <= 1'b0;

            if (start) begin
                if (flow_poll_frq_div_cnt == POLLING_RATE) begin
                    if (!sRx_c0TxAlmFull) begin
                        sTx_c0.hdr         <= t_ccip_c0_ReqMemHdr'(0);

                        sTx_c0.hdr.address            <= tx_base_addr + flow_poll_cnt;
                        sTx_c0.hdr.mdata[MDATA_W-1:0] <= META_PATTERN ^ flow_poll_cnt;
                        sTx_c0.hdr.vc_sel             <= FORWARD_VC;
                        sTx_c0.hdr.req_type           <= FORWARD_RD_TYPE;

                        sTx_c0.valid       <= 1'b1;

                        if (flow_poll_cnt != number_of_flows - 1) begin
                            flow_poll_cnt <= flow_poll_cnt + 1;
                        end else begin
                            flow_poll_cnt <= {($bits(flow_poll_cnt)){1'b0}};
                        end
                    end

                    flow_poll_frq_div_cnt <= {($bits(flow_poll_frq_div_cnt)){1'b0}};
                end else begin
                    flow_poll_frq_div_cnt <= flow_poll_frq_div_cnt + 1;
                end
            end

        end
    end

    // Get answer
    RpcPckt            sRx_casted, ccip_read_poll_data;
    logic[MDATA_W-1:0] ccip_read_poll_cl;
    logic              ccip_read_poll_data_valid;

    always_comb begin
        sRx_casted = sRx_c0.data[$bits(RpcPckt)-1:0];
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            ccip_read_poll_data_valid <= 1'b0;
            ccip_read_poll_cl         <= {(MDATA_W){1'b0}};
            ccip_read_poll_data       <= {($bits(RpcPckt)){1'b0}};

        end else begin
            // Initial vals
            ccip_read_poll_data_valid <= 1'b0;

            if (start && sRx_c0.rspValid) begin
                if (sRx_casted.hdr.ctl.valid) begin
                    ccip_read_poll_data_valid <= 1'b1;
                    ccip_read_poll_cl         <= sRx_c0.hdr.mdata[MDATA_W-1:0] ^ META_PATTERN;
                    ccip_read_poll_data       <= sRx_casted;
                end
            end
        end
    end

    // Compare to see if the CL is updated
    logic rpc_id_table [2**LMAX_NUM_OF_FLOWS];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i=0; i<2**LMAX_NUM_OF_FLOWS; i=i+1) begin
                rpc_id_table[i] <= 1'b0;
            end
            rpc_out_valid <= 1'b0;

        end else begin
            rpc_out_valid <= 1'b0;

            if (ccip_read_poll_data_valid) begin
                if (rpc_id_table[ccip_read_poll_cl] != ccip_read_poll_data.hdr.ctl.update_flag) begin
                    $display("NIC%d: new value read from flow %d", NIC_ID, ccip_read_poll_cl);
                    $display("NIC%d:        value= %p", NIC_ID, ccip_read_poll_data);

                    rpc_out         <= ccip_read_poll_data;
                    rpc_flow_id_out <= ccip_read_poll_cl;
                    rpc_out_valid   <= 1'b1;

                    rpc_id_table[ccip_read_poll_cl] <= ccip_read_poll_data.hdr.ctl.update_flag;
                end
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
