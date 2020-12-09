// Author: Cornell University
//
// Module Name :    connection_manager
// Project :        F-NIC
// Description :    implements a connection manager
//
//

`include "cpu_if_defs.vh"
`include "rpc_defs.vh"

module connection_manager
    #(
        parameter NIC_ID = 0,
        parameter LCACHE_SIZE = 0
    )
    (
        input logic clk,
        input logic reset,

        // Control
        input logic initialize,

        // Connection control
        input ConnectionControlIf c_ctl_in,
        output ConnSetupStatus c_ctl_status_out,

        // RPC paththrough
        // from CPU towards network
        input CManagerRpcIf rpc_in,
        output CManagerNetRpcIf rpc_net_out,
        // from network towards CPU
        input CManagerNetRpcIf rpc_net_in,
        output CManagerRpcIf rpc_out,

        // Status
        output logic initialized,
        output logic error
    );

    // Types
    typedef enum logic[0:0] { cClosed, cOpen } ConnectionStatus;

    typedef enum logic { CTInitIdle, CTInit } CTInitState;

    typedef logic[LCACHE_SIZE-1:0] CTAddr;

    typedef struct packed {
        IPv4 dest_ip;
        Port dest_port;
        FlowId client_flow_id;
        ConnectionStatus status;
    } ConnectionTableEntry;

    // Connection table
    logic ct_initialized;
    CTInitState ct_init_state;
    CTAddr ct_init_addr;
    CTAddr c_tbl_rd_addr[2];
    CTAddr c_tbl_wr_addr[2];
    logic c_tbl_wr_en[2];
    ConnectionTableEntry c_tbl_wr_data[2];
    ConnectionTableEntry c_tbl_rd_data[2];

    single_clock_wr_ram #(
            .DATA_WIDTH($bits(ConnectionTableEntry)),
            .ADR_WIDTH(LCACHE_SIZE)
        ) c_tbl (
            .clk(clk),
            .q(c_tbl_rd_data[0]),
            .d(ct_init_state == CTInit? {($bits(ConnectionTableEntry)){1'b0}}: c_tbl_wr_data[0]),
            .write_address(ct_init_state == CTInit? ct_init_addr: c_tbl_wr_addr[0]),
            .read_address(c_tbl_rd_addr[0]),
            .we(ct_init_state == CTInit? 1'b1: c_tbl_wr_en[0])
        );

    // Replica of connection table
    // TODO: potential optimization - do not replicate the whole table,
    //                                only what requires concurrent access
    single_clock_wr_ram #(
            .DATA_WIDTH($bits(ConnectionTableEntry)),
            .ADR_WIDTH(LCACHE_SIZE)
        ) c_tbl_r1 (
            .clk(clk),
            .q(c_tbl_rd_data[1]),
            .d(ct_init_state == CTInit? {($bits(ConnectionTableEntry)){1'b0}}: c_tbl_wr_data[1]),
            .write_address(ct_init_state == CTInit? ct_init_addr: c_tbl_wr_addr[1]),
            .read_address(c_tbl_rd_addr[1]),
            .we(ct_init_state == CTInit? 1'b1: c_tbl_wr_en[1])
        );

    // Connection status table
    CTAddr c_st_tbl_rd_addr;
    CTAddr c_st_tbl_wr_addr;
    logic c_st_tbl_wr_en;
    ConnectionStatus c_st_tbl_wr_data;
    ConnectionStatus c_st_tbl_rd_data;

    single_clock_wr_ram #(
            .DATA_WIDTH($bits(ConnectionStatus)),
            .ADR_WIDTH(LCACHE_SIZE)
        ) c_tbl_valid (
            .clk(clk),
            .q({c_st_tbl_rd_data}),
            .d(ct_init_state == CTInit? cClosed: c_st_tbl_wr_data),
            .write_address(ct_init_state == CTInit? ct_init_addr: c_st_tbl_wr_addr),
            .read_address(c_st_tbl_rd_addr),
            .we(ct_init_state == CTInit? 1'b1: c_st_tbl_wr_en)
        );


    // =============================================================
    // Connection table initialization
    // =============================================================
    always_ff @(posedge clk) begin
        if (reset) begin
            ct_init_state <= CTInitIdle;
            ct_init_addr <= {($bits(ct_init_addr)){1'b0}};
            ct_initialized <= 1'b0;

        end else begin
            if (ct_init_state == CTInitIdle && initialize) begin
                ct_init_state <= CTInit;
            end

            if (ct_init_state == CTInit) begin
                if (ct_init_addr == 2 ** LCACHE_SIZE - 1) begin
                    ct_init_addr <= {($bits(ct_init_addr)){1'b0}};
                    ct_init_state <= CTInitIdle;
                    ct_initialized <= 1'b1;
                end else begin
                    ct_init_addr <= ct_init_addr + 1;
                end
            end
        end
    end


    // =============================================================
    // Connection setup FSM
    // =============================================================
    typedef enum logic[2:0] { cCtlIdle,
                              cCtlOpenCheck,
                              cCtlOpen,
                              cCtlCloseCheck,
                              cCtlClose } ConnCtlState;

    ConnCtlState c_ctl_state, c_ctl_state_next;

    integer i;
    always_comb begin
        // Defaults
        c_st_tbl_rd_addr = {($bits(c_st_tbl_rd_addr)){1'b0}};
        c_st_tbl_wr_addr = {($bits(c_st_tbl_wr_addr)){1'b0}};
        c_st_tbl_wr_data = cClosed;
        c_st_tbl_wr_en   = 1'b0;

        for (i=0;i<2;i=i+1) begin
            c_tbl_wr_addr[i] = {($bits(c_tbl_wr_addr[i])){1'b0}};
            c_tbl_wr_data[i] = {($bits(c_tbl_wr_data[i])){1'b0}};
            c_tbl_wr_en[i] = {($bits(c_tbl_wr_en[i])){1'b0}};
        end

        c_ctl_state_next = c_ctl_state;

        // Switch
        case (c_ctl_state)
            cCtlIdle: begin
                if (ct_initialized && c_ctl_in.enable) begin
                    // Check connection id is within the range
                    if (c_ctl_in.conn_id >= 2**LCACHE_SIZE) begin
                        c_ctl_state_next = cCtlIdle;
                    end else begin
                        if (c_ctl_in.open) begin
                            // Open connection
                            c_st_tbl_rd_addr = c_ctl_in.conn_id;
                            c_ctl_state_next = cCtlOpenCheck;
                        end else begin
                            // Close connection
                            c_st_tbl_rd_addr = c_ctl_in.conn_id;
                            c_ctl_state_next = cCtlCloseCheck;
                        end
                    end
                end else begin
                    c_ctl_state_next = cCtlIdle;
                end
            end

            cCtlOpenCheck: begin
                if (c_st_tbl_rd_data == cOpen) begin
                    // If already open, go to Idle
                    c_ctl_state_next = cCtlIdle;
                end else begin
                    // Write connection data
                    // status
                    c_st_tbl_wr_addr = c_ctl_in.conn_id;
                    c_st_tbl_wr_data = cOpen;
                    c_st_tbl_wr_en   = 1'b1;
                    // data
                    for (i=0;i<2;i=i+1) begin
                        c_tbl_wr_addr[i] = c_ctl_in.conn_id;
                        c_tbl_wr_data[i] = '{dest_ip: c_ctl_in.dest_ip,
                                             dest_port: c_ctl_in.dest_port,
                                             client_flow_id: c_ctl_in.client_flow_id,
                                             status: cOpen};
                        c_tbl_wr_en[i]   = 1'b1;
                    end

                    c_ctl_state_next = cCtlOpen;
                end
            end

            cCtlCloseCheck: begin
                if (c_st_tbl_rd_data == cClosed) begin
                    // If not open, go to Idle
                    c_ctl_state_next = cCtlIdle;
                end else begin
                    // Write connection data
                    // status
                    c_st_tbl_wr_addr = c_ctl_in.conn_id;
                    c_st_tbl_wr_data = cClosed;
                    c_st_tbl_wr_en   = 1'b1;
                    // data
                    for (i=0;i<2;i=i+1) begin
                        c_tbl_wr_addr[i] = c_ctl_in.conn_id;
                        c_tbl_wr_data[i] = '{dest_ip: {$bits(IPv4){1'b0}},
                                             dest_port: {$bits(Port){1'b0}},
                                             client_flow_id: {$bits(FlowId){1'b0}},
                                             status: cClosed};
                        c_tbl_wr_en[i]   = 1'b1;
                    end

                    c_ctl_state_next = cCtlClose;
                end
            end

            cCtlOpen: begin
                c_ctl_state_next = cCtlIdle;
            end

            cCtlClose: begin
                c_ctl_state_next = cCtlIdle;
            end

        endcase
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            c_ctl_status_out <= '{valid: 1'b0,
                                  conn_id: {(32){1'b0}},
                                  error_status: cOK,
                                  padding: {(5){1'b0}}
                                };

        end else begin
            c_ctl_status_out <= '{valid: 1'b0,
                                  conn_id: {(32){1'b0}},
                                  error_status: cOK,
                                  padding: {(5){1'b0}}
                                };

            case (c_ctl_state)
                cCtlIdle: begin
                    // Assert an error if connection id exceeds the cache size
                    //   - TODO: if DRAM swapping is implemented, remove this check
                    if (ct_initialized && c_ctl_in.enable
                                       && c_ctl_in.conn_id >= 2**LCACHE_SIZE) begin
                        $display("NIC%d::RPC failed to open connection id=%d, \
                                              connection id is too large", NIC_ID, c_ctl_in.conn_id);
                        c_ctl_status_out <= '{valid: 1'b1,
                                              conn_id: c_ctl_in.conn_id,
                                              error_status: cIdWrong,
                                              padding: {(5){1'b0}}
                                            };
                    end
                end

                cCtlOpenCheck: begin
                    // If already open, assert an error
                    if (c_st_tbl_rd_data == cOpen) begin
                        $display("NIC%d::RPC failed to open connection id=%d, \
                                                already open", NIC_ID, c_ctl_in.conn_id);
                        c_ctl_status_out <= '{valid: 1'b1,
                                              conn_id: c_ctl_in.conn_id,
                                              error_status: cAlreadyOpen,
                                              padding: {(5){1'b0}}
                                            };
                    end
                end

                cCtlCloseCheck: begin
                    // If closed, assert an error
                    if (c_st_tbl_rd_data == cClosed) begin
                        $display("NIC%d::RPC failed to close connection id=%d, \
                                                        already closed", NIC_ID, c_ctl_in.conn_id);
                        c_ctl_status_out <= '{valid: 1'b1,
                                              conn_id: c_ctl_in.conn_id,
                                              error_status: cIsClosed,
                                              padding: {(5){1'b0}}
                                            };
                    end
                end

                cCtlOpen: begin
                    $display("NIC%d::RPC connection id=%d is open, connection data:%p",
                                                                NIC_ID, c_ctl_in.conn_id, c_ctl_in);
                    c_ctl_status_out <= '{valid: 1'b1,
                                          conn_id: c_ctl_in.conn_id,
                                          error_status: cOK,
                                          padding: {(5){1'b0}}
                                        };
                end

                cCtlClose: begin
                    $display("NIC%d::RPC connection id=%d is closed", NIC_ID, c_ctl_in.conn_id);
                    c_ctl_status_out <= '{valid: 1'b1,
                                          conn_id: c_ctl_in.conn_id,
                                          error_status: cOK,
                                          padding: {(5){1'b0}}
                                        };
                end

            endcase
        end
    end

    // FSM iteration
    always_ff @(posedge clk) begin
        if (reset) begin
            c_ctl_state <= cCtlIdle;
        end else begin
            c_ctl_state <= c_ctl_state_next;
        end
    end




    // =============================================================
    // RPC path
    // =============================================================
    // Combinationally start look-up
    integer i1;
    always_comb begin
        // Defaults
        for (i1=0;i1<2;i1=i1+1) begin
            c_tbl_rd_addr[i] = {($bits(c_tbl_rd_addr[i])){1'b0}};
        end

        // For RPC flows from CPU, look-up from c_tbl
        if (rpc_in.valid) begin
            if (rpc_in.rpc_data.hdr.connection_id < 2**LCACHE_SIZE) begin
                c_tbl_rd_addr[0] = rpc_in.rpc_data.hdr.connection_id;
            end
        end

        // For RPC flows from network, look-up from c_tbl_r1
        if (rpc_net_in.valid) begin
            if (rpc_net_in.rpc_data.hdr.connection_id < 2**LCACHE_SIZE) begin
                c_tbl_rd_addr[1] = rpc_net_in.rpc_data.hdr.connection_id;
            end
        end
    end

    // Delay RPC flow by 1 cycle for look-up
    CManagerRpcIf rpc_in_1d;
    CManagerNetRpcIf rpc_net_in_1d;
    always @(posedge clk) begin
        rpc_in_1d <= rpc_in;
        rpc_net_in_1d <= rpc_net_in;
    end

    // Commit look-up
    always @(posedge clk) begin
        // RPC data flow
        rpc_net_out.rpc_data <= rpc_in_1d.rpc_data;
        rpc_net_out.net_addr.dest_ip <= c_tbl_rd_data[0].dest_ip;
        rpc_net_out.net_addr.dest_port <= c_tbl_rd_data[0].dest_port;
        rpc_net_out.net_addr.source_ip <= {$bits(IPv4){1'b0}};
        rpc_net_out.net_addr.source_port <= {$bits(Port){1'b0}};

        rpc_out.rpc_data <= rpc_net_in_1d.rpc_data;
        rpc_out.flow_id <= c_tbl_rd_data[1].client_flow_id;

        // RPC control flow
        rpc_net_out.valid <= 1'b0;
        if (rpc_in_1d.valid) begin
            if (c_tbl_rd_data[0].status == cOpen) begin
                rpc_net_out.valid <= 1'b1;
            end
        end

        rpc_out.valid <= 1'b0;
        if (rpc_net_in_1d.valid) begin
            if (c_tbl_rd_data[1].status == cOpen) begin
                rpc_out.valid <= 1'b1;
            end
        end

        // Reset
        if (reset) begin
            rpc_net_out.valid <= 1'b0;
            rpc_out.valid <= 1'b0;
        end
    end

    // Handle errors
    logic rpc_path_error;
    always @(posedge clk) begin
        if (reset) begin
            rpc_path_error <= 1'b0;

        end else begin
            if (rpc_in.valid && rpc_in.rpc_data.hdr.connection_id >= 2**LCACHE_SIZE) begin
                $display("NIC%d::RPC RPC request with wrong connection id=%d \
                                                    is received, connection id is too large",
                                                    NIC_ID, rpc_in.rpc_data.hdr.connection_id);
                rpc_path_error <= 1'b1;
            end

            if (rpc_in_1d.valid && c_tbl_rd_data[0].status == cClosed) begin
                $display("NIC%d::RPC RPC request with wrong connection id=%d \
                                                    is received, connection is closed",
                                                    NIC_ID, rpc_in.rpc_data.hdr.connection_id);
                rpc_path_error <= 1'b1;
            end

            if (rpc_net_in.valid && rpc_net_in.rpc_data.hdr.connection_id >= 2**LCACHE_SIZE) begin
                $display("NIC%d::RPC RPC request with wrong connection id=%d \
                                                    is received from network, connection id is too large",
                                                    NIC_ID, rpc_net_in.rpc_data.hdr.connection_id);
                rpc_path_error <= 1'b1;
            end

            if (rpc_net_in_1d.valid && c_tbl_rd_data[1].status == cClosed) begin
                $display("NIC%d::RPC RPC request with wrong connection id=%d \
                                                    is received from network, connection is closed",
                                                    NIC_ID, rpc_net_in_1d.rpc_data.hdr.connection_id);
                rpc_path_error <= 1'b1;
            end

        end
    end


assign initialized = ct_initialized;
assign error = rpc_path_error;


endmodule
