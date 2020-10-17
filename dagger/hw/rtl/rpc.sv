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

    parameter DIV_TO_SHIFT_8 = 3;

    // Serialization
    always_ff @(posedge clk) begin
        // Init vals
        network_tx_out       <= {($bits(NetworkPacketInternal)){1'b0}};
        network_tx_valid_out <= 1'b0;

        // Serialize rpc to network
        if (rpc_valid_in) begin
            $display("NIC%d::RPC serializing rpc data %p", NIC_ID, rpc_in.rpc_data);

            // **********************************
            //
            // More complex RPC data transformation should be placed here:
            // - compression
            // - encryption
            // - etc.
            //
            // **********************************
            network_tx_out.hdr.payload_size <= ($bits(RpcHeader) >> DIV_TO_SHIFT_8) + rpc_in.rpc_data.hdr.argl;
            network_tx_out.payload[$bits(RpcPckt)-1:0] <= rpc_in.rpc_data;

            network_tx_out.hdr.conn_id <= rpc_in.flow_id;
            network_tx_valid_out       <= 1'b1;
        end

        if (reset) begin
            network_tx_valid_out <= 1'b0;
        end
    end


    // Deserialization
    always_ff @(posedge clk) begin
        // Init vals
        rpc_out       <= {($bits(RpcIf)){1'b0}};
        rpc_valid_out <= 1'b0;

        if (network_rx_valid_in) begin
            // deserialize as request
            $display("NIC%d::RPC DeSerializing rpc %p", NIC_ID, network_rx_in.payload[$bits(RpcPckt)-1:0]);

            // **********************************
            //
            // More complex RPC data transformation should be placed here:
            // - compression
            // - encryption
            // - etc.
            //
            // **********************************
            rpc_out.rpc_data <= network_rx_in.payload[$bits(RpcPckt)-1:0];

            rpc_out.flow_id <= network_rx_in.hdr.conn_id;
            rpc_valid_out   <= 1'b1;
        end

        if (reset) begin
            rpc_valid_out <= 1'b0;
        end
    end


endmodule
