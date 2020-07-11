// Author: Cornell University
//
// Module Name :    rpc
// Project :        F-NIC
// Description :    RPC processing unit

`include "nic_defs.vh"
`include "rpc_defs.vh"

module rpc
    #(
        parameter NIC_ID = 32'h0
    )
    (
    input logic clk,
    input logic reset,

    // Inputs to/from CPU
    input logic   rpc_valid_in,
    input RpcIf   rpc_in,

    output logic  rpc_valid_out,
    output RpcIf  rpc_out,

    // Ports to/from network
    output NetworkPacketInternal network_tx_out,
    output logic                 network_tx_valid_out,

    input NetworkPacketInternal network_rx_in,
    input logic                 network_rx_valid_in

    );


    // Serialization
    RpcReqPckt  rpc_req_pck_ser;
    RpcRespPckt rpc_resp_pck_ser;

    always_comb begin
        // convert RpcPckt to RpcReqPckt and RpcRespPckt
        rpc_req_pck_ser  = rpc_in.rpc_data;
        rpc_resp_pck_ser = rpc_in.rpc_data;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            network_tx_out       <= {($bits(NetworkPacketInternal)){1'b0}};
            network_tx_valid_out <= 1'b0;

        end else begin
            // Init vals
            network_tx_out       <= {($bits(NetworkPacketInternal)){1'b0}};
            network_tx_valid_out <= 1'b0;

            // Serialize rpc to network
            if (rpc_valid_in) begin
                if (rpc_in.rpc_data.hdr.ctl.req_type == rpcReq) begin
                    // serialize requests
                    $display("NIC%d::RPC serializing rpc as request %p", NIC_ID, rpc_req_pck_ser);

                    // **********************************
                    //
                    // More complex RPC data transformation should be placed here:
                    // - compression
                    // - encryption
                    // - etc.
                    //
                    // **********************************
                    network_tx_out.hdr.payload_size               <= $bits(RpcReqPckt);
                    network_tx_out.payload[$bits(RpcReqPckt)-1:0] <= rpc_req_pck_ser;
                end else begin
                    // serialize responses
                    $display("NIC%d::RPC serializing rpc as response %p", NIC_ID, rpc_resp_pck_ser);

                    // **********************************
                    //
                    // More complex RPC data transformation should be placed here:
                    // - compression
                    // - encryption
                    // - etc.
                    //
                    // **********************************
                    network_tx_out.hdr.payload_size                <= $bits(RpcRespPckt);
                    network_tx_out.payload[$bits(RpcRespPckt)-1:0] <= rpc_resp_pck_ser;
                end

                network_tx_out.hdr.conn_id <= rpc_in.flow_id;
                network_tx_valid_out       <= 1'b1;
            end
        end
    end


    // Deserialization
    RpcReqPckt  rpc_req_pck_deser;
    RpcRespPckt rpc_resp_pck_deser;
    RpcPckt     rpc_pck;

    always_comb begin
        // get header
        rpc_pck = network_rx_in.payload[$bits(RpcPckt)-1:0];
        // convert RpcPckt to RpcReqPckt and RpcRespPckt
        rpc_req_pck_deser  = network_rx_in.payload[$bits(RpcReqPckt)-1:0];
        rpc_resp_pck_deser = network_rx_in.payload[$bits(RpcRespPckt)-1:0];
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            rpc_valid_out <= 1'b0;
            rpc_out       <= {($bits(RpcIf)){1'b0}};

        end else begin
            // Init vals
            rpc_valid_out <= 1'b0;

            if (network_rx_valid_in) begin
                if (rpc_pck.hdr.ctl.req_type == rpcReq) begin
                    // deserialize as request
                    $display("NIC%d::RPC DeSerializing rpc as request %p", NIC_ID, rpc_req_pck_deser);

                    // **********************************
                    //
                    // More complex RPC data transformation should be placed here:
                    // - compression
                    // - encryption
                    // - etc.
                    //
                    // **********************************
                    rpc_out.rpc_data <= rpc_req_pck_deser;
                end else begin
                    // deserialize as response
                    $display("NIC%d::RPC DeSerializing rpc as response %p", NIC_ID, rpc_resp_pck_deser);

                    // **********************************
                    //
                    // More complex RPC data transformation should be placed here:
                    // - compression
                    // - encryption
                    // - etc.
                    //
                    // **********************************
                    rpc_out.rpc_data <= rpc_resp_pck_deser;
                end

                rpc_out.flow_id <= network_rx_in.hdr.conn_id;
                rpc_valid_out   <= 1'b1;
            end
        end
    end


endmodule
