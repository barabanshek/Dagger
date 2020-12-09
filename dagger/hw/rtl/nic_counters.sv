// Author: Cornell University
//
// Module Name :    nic counters
// Project :        F-NIC
// Description :    different nic counters

module nic_counters
    (
    input logic reset,

    // Count signals
    input logic clk_0,
    input logic t_incoming_rpc,
    input logic t_outcoming_rpc,
    input logic t_pdrop_tx_flows,

    input logic clk_1,
    input logic t_outcoming_network_packets,
    input logic t_incoming_network_packets,

    // I/O
    input logic clk_io,
    input logic[7:0]   counter_id_in,
    output logic[63:0] counter_value_out

    );

    // Counters
    logic[63:0] counters [5];

    // Count: clock domain clk_0
    logic t_incoming_rpc_d;
    logic t_outcoming_rpc_d;
    logic t_pdrop_tx_flows_d;

    always @(posedge clk_0) begin
        if (reset) begin
            counters[0] <= {(64){1'b0}};
            counters[1] <= {(64){1'b0}};
            counters[4] <= {(64){1'b0}};

        end else begin
            t_incoming_rpc_d  <= t_incoming_rpc;
            t_outcoming_rpc_d <= t_outcoming_rpc;
            t_pdrop_tx_flows_d <= t_pdrop_tx_flows;

            if (t_incoming_rpc_d)  counters[0] <= counters[0] + 1;
            if (t_outcoming_rpc_d) counters[1] <= counters[1] + 1;
            if (t_pdrop_tx_flows_d) counters[4] <= counters[4] + 1;
        end
    end

    // Count: clock domain clk_1
    logic t_outcoming_network_packets_d;
    logic t_incoming_network_packets_d;

    always @(posedge clk_1) begin
        if (reset) begin
            counters[2] <= {(64){1'b0}};
            counters[3] <= {(64){1'b0}};

        end else begin
            t_outcoming_network_packets_d <= t_outcoming_network_packets;
            t_incoming_network_packets_d  <= t_incoming_network_packets;

            if (t_outcoming_network_packets_d) counters[2] <= counters[2] + 1;
            if (t_incoming_network_packets_d)  counters[3] <= counters[3] + 1;
        end
    end

    // Return value
    always @(posedge clk_io) begin
        if (reset) begin
            counter_value_out <= {(64){1'b0}};
        end else begin
            counter_value_out <= counters[counter_id_in];
        end
    end

endmodule
