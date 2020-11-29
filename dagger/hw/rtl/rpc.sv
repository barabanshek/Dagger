// Author: Cornell University
//
// Module Name :    rpc
// Project :        F-NIC
// Description :    RPC processing unit

`include "cpu_if_defs.vh"
`include "nic_defs.vh"

`include "connection_manager.sv"

module rpc
    #(
        parameter NIC_ID = 0
    )
    (
    input logic clk,
    input logic reset,

    // Control
    input logic initialize,

    input logic conn_setup_en_in,
    input ConnSetupFrame conn_setup_frame_in,
    output ConnSetupStatus conn_setup_status_out,

    // Inputs to/from CPU
    input logic   rpc_valid_in,
    input RpcIf   rpc_in,

    output logic  rpc_valid_out,
    output RpcIf  rpc_out,

    // Ports to/from network
    output NetworkPacketInternal network_tx_out,
    output logic                 network_tx_valid_out,

    input NetworkPacketInternal network_rx_in,
    input logic                 network_rx_valid_in,

    // Status
    output logic initialized,
    output logic error
    );

    localparam DIV_TO_SHIFT_8 = 3;

    // =============================================================
    // Serializers
    // =============================================================
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


    // =============================================================
    // RPC connection manager
    // =============================================================
    ConnectionControlIf c_ctl_if;
    logic conn_setup_parsing_error;
    logic [4:0] setup_vector;

    // Parse input from ConnSetupFrame to ConnectionControlIf
    integer i;
    always_ff @(posedge clk) begin
        if (reset) begin
            conn_setup_parsing_error <= 1'b0;
            c_ctl_if.enable <= 1'b0;

            for(i=0;i<4;i=i+1) begin
                setup_vector[i] <= 1'b0;
            end

        end else begin
            c_ctl_if.enable <= 1'b0;

            if (conn_setup_en_in) begin
                case (conn_setup_frame_in.cmd)
                    setUpConnId: begin
                        c_ctl_if.conn_id <= conn_setup_frame_in.data;
                        setup_vector[0] <= 1'b1;
                    end

                    setUpOpen: begin
                        c_ctl_if.open <= conn_setup_frame_in.data;
                        setup_vector[1] <= 1'b1;
                    end

                    setUpDestIPv4: begin
                        c_ctl_if.dest_ip <= conn_setup_frame_in.data;
                        setup_vector[2] <= 1'b1;
                    end

                    setUpDestPort: begin
                        c_ctl_if.dest_port <= conn_setup_frame_in.data;
                        setup_vector[3] <= 1'b1;
                    end

                    setUpClientFlowId: begin
                        c_ctl_if.client_flow_id <= conn_setup_frame_in.data;
                        setup_vector[4] <= 1'b1;
                    end

                    setUpEnable: begin
                        if (c_ctl_if.open) begin
                            if (~(setup_vector[0] &&
                                  setup_vector[1] &&
                                  setup_vector[2] &&
                                  setup_vector[3] &&
                                  setup_vector[4])) begin
                                $display("NIC%d::RPC failed to open connection, not all the parameters are set ", NIC_ID);
                                conn_setup_parsing_error <= 1'b1;

                            end else begin
                                $display("NIC%d::RPC setting up connection: <%p>", NIC_ID, c_ctl_if);
                                c_ctl_if.enable <= 1'b1;

                                for(i=0;i<4;i=i+1) begin
                                    setup_vector[i] <= 1'b0;
                                end
                            end
                        end else begin
                            if (~setup_vector[0]) begin
                                $display("NIC%d::RPC failed to close connection, not all the parameters are set ", NIC_ID);
                                conn_setup_parsing_error <= 1'b1;

                            end else begin
                                $display("NIC%d::RPC setting up connection: <%p>", NIC_ID, c_ctl_if);
                                c_ctl_if.enable <= 1'b1;

                                for(i=0;i<4;i=i+1) begin
                                    setup_vector[i] <= 1'b0;
                                end
                            end
                        end
                    end

                    default: begin
                        $display("NIC%d::RPC failed to set up connection, wrong command: ", NIC_ID, conn_setup_frame_in.cmd);
                        conn_setup_parsing_error <= 1'b1;
                    end
                endcase
            end
        end
    end

    // Connection manager
    logic ct_error;

    connection_manager #(
            .NIC_ID(NIC_ID),
            .LCACHE_SIZE(LCONN_TBL_SIZE)
        ) c_manager (
            .clk(clk),
            .reset(reset),

            .initialize(initialize),

            .c_ctl_in(c_ctl_if),
            .c_ctl_status_out(conn_setup_status_out),

            .initialized(initialized),
            .error(ct_error)
        );

    assign error = conn_setup_parsing_error |
                   ct_error;

endmodule
