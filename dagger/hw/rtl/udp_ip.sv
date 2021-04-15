// Author: Cornell University
//
// Module Name :    udp_ip
// Project :        F-NIC
// Description :    implementation of the UDP/IP stack and FSM
//                    - Ethernet MAC/PHY interface FSM
//                    - UDP/IP/Ethernet header encapsulation
//                    - error checking and packet drop control
//

`include "nic_defs.vh"

module udp_ip
    (
        // App interface
        input logic reset,
        input logic clk,
        input NetworkIf  network_tx_in,
        output NetworkIf network_rx_out,

        // Networking MAC/PHY interface
        // TX Avalon-ST interface
        input              tx_clk_in,
        input              tx_reset_in,
        input              tx_ready_in,
        output reg [255:0] tx_data_out,
        output reg         tx_valid_out,
        output reg         tx_sop_out,
        output reg         tx_eop_out,
        output reg [4:0]   tx_empty_out,
        output reg         tx_error_out,

        // RX Avalon-ST interface
        input           rx_clk_in,
        input           rx_reset_in,
        input   [255:0] rx_data_in,
        input           rx_valid_in,
        input           rx_sop_in,
        input           rx_eop_in,
        input     [4:0] rx_empty_in,
        input     [5:0] rx_error_in,
        output reg      rx_ready_out,

        // Drop counter interfaces
        input logic [3:0]   pckt_drop_cnt_in,
        input               pckt_drop_cnt_valid_in,
        output logic [31:0] pckt_drop_cnt_out,

        // Error
        output error
    );

    // Types
    localparam RPC_PAYLOAD_SIZE_BYTES = 64;

    typedef logic[255:0] TxData_;

    typedef struct packed {
        logic [15:0] src_port;
        logic [15:0] dest_port;
        logic [15:0] length;    // UDP header + payload
        logic [15:0] checksum;
    } UDPHdr;   // 8B

    typedef struct packed {
        logic [3:0] version;
        logic [3:0] IHL;
        logic [5:0] DSCP;
        logic [1:0] ECN;
        logic [15:0] length; // IP header + payload
        logic [15:0] identification;
        logic [2:0] flags;
        logic [12:0] fragment_offst;
        logic [7:0] time_to_live;
        logic [7:0] protocol;
        logic [15:0] header_checksum;
        logic [31:0] src_ip;
        logic [31:0] dest_ip;
    } IPHdr;    // 20B

    typedef struct packed {
        logic [7:0] b0;
        logic [7:0] b1;
        logic [7:0] b2;
        logic [7:0] b3;
        logic [7:0] b4;
        logic [7:0] b5;
    } PhyAddr;  // 6B

    typedef struct packed {
        PhyAddr dest_mac;
        PhyAddr src_mac;
        logic [15:0] length;    // payload
    } EthernetHdr;  // 14B


    // =============================================================
    // Local networking configuration
    // =============================================================
    PhyAddr host_mac = '{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00};
    logic [31:0] host_ip = 32'h00000001;


    // =============================================================
    // TX path
    // =============================================================
    localparam LTX_FIFO_DEPTH = 5;

    // TX Queue
    logic tx_fifio_pop_en;
    logic tx_fifo_pop_valid;
    NetworkIf tx_fifo_pop_data;
    logic tx_fifo_ovf;

    async_fifo_channel #(
            .DATA_WIDTH($bits(NetworkIf)),
            .LOG_DEPTH(LTX_FIFO_DEPTH),
            .CLOCK_ARE_SYNCHRONIZED("FALSE"),
            .DELAY_PIPE(4)
        ) tx_fifo (
            .clear(tx_reset_in),
            .clk_1(clk),

            .push_en(network_tx_in.valid),
            .push_data(network_tx_in),

            .clk_2(tx_clk_in),
            .pop_enable(tx_fifio_pop_en),

            .pop_valid(tx_fifo_pop_valid),
            .pop_data(tx_fifo_pop_data),
            .pop_dw(),
            .pop_empty(tx_fifo_pop_empty),
            .error(tx_fifo_ovf)
        );

    // Check for tx_fifo overflow
    logic [31:0] tx_fifo_drop;
    always_ff @(posedge clk) begin
        if (reset)
            tx_fifo_drop <= 32'b0;
        else if (tx_fifo_ovf)
            tx_fifo_drop <= tx_fifo_drop + 1;
    end

    // Packet headers
    EthernetHdr tx_eth_hdr;
    always_comb begin
        tx_eth_hdr = '{'{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
                       '{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},  // TODO: change host mac
                       $bits(IPHdr)/8 + $bits(UDPHdr)/8 + RPC_PAYLOAD_SIZE_BYTES};
    end

    IPHdr tx_ip_hdr;
    always_comb begin
        tx_ip_hdr.version = 4'h4;
        tx_ip_hdr.IHL = 4'h5;
        tx_ip_hdr.DSCP = 6'h0;
        tx_ip_hdr.ECN = 2'h0;
        tx_ip_hdr.length = $bits(IPHdr)/8 + $bits(UDPHdr)/8 + RPC_PAYLOAD_SIZE_BYTES;
        tx_ip_hdr.identification = 16'h0;
        tx_ip_hdr.flags = 3'b000;
        tx_ip_hdr.fragment_offst = 13'h0;
        tx_ip_hdr.time_to_live = 8'h0;
        tx_ip_hdr.protocol = 8'h11; // UDP
        tx_ip_hdr.header_checksum = 16'h0;
        tx_ip_hdr.src_ip = tx_fifo_pop_data.addr_tpl.source_ip;
        tx_ip_hdr.dest_ip = tx_fifo_pop_data.addr_tpl.dest_ip;
    end

    // Compute checksum combinationally
//    logic [31:0] sum;
//    logic [7:0] carry;
//    logic carry_1;
//    always_comb begin
//        // Adder tree
//        sum = (((tx_ip_hdr[15:0] + tx_ip_hdr[31:16]) + (tx_ip_hdr[47:32] + tx_ip_hdr[63:48]))
//            + ((tx_ip_hdr[79:64] + tx_ip_hdr[111:96]) + (tx_ip_hdr[127:112] + tx_ip_hdr[143:128])))
//            + tx_ip_hdr[159:144];
//        carry = sum[23:16];
//        carry_1 = (sum[31:24] > 0) 1'b1: 1'b0;
//        tx_ip_hdr.header_checksum = (sum[15:0] + carry + carry_1) ^ 16'hFFFF;
//    end

    UDPHdr tx_udp_hdr;
    always_comb begin
        tx_udp_hdr.src_port = tx_fifo_pop_data.addr_tpl.source_port;
        tx_udp_hdr.dest_port = tx_fifo_pop_data.addr_tpl.dest_port;
        tx_udp_hdr.length = $bits(UDPHdr)/8 + RPC_PAYLOAD_SIZE_BYTES;
        tx_udp_hdr.checksum = 16'h0;
    end

    // TX FSM
    typedef enum logic [2:0] { TxIdle, TxPop, TxSop, TxData, TxData_1, TxEop, TxDel } TxState;

    TxState tx_state, tx_state_next;
    TxData_ tx_data;
    logic tx_sop, tx_eop, tx_dt;
    logic tx_empty_load;
    logic [4:0] tx_byte_remain;

    // FSM current state logic
    always_ff @(posedge tx_clk_in or posedge tx_reset_in) begin
        if (tx_reset_in)
            tx_state <= TxIdle;
        else
            tx_state <= tx_state_next;
    end

    // FSM switch state logic
    always_comb begin
        // Defaults
        tx_state_next = tx_state;
        tx_fifio_pop_en = 1'b0;

        // Switch state
        case (tx_state)
            TxIdle: begin
                // Pop request
                if (~tx_fifo_pop_empty) begin
                    tx_fifio_pop_en = 1'b1;
                    tx_state_next = TxPop;
                end
            end

            TxPop: begin
                if (tx_fifo_pop_valid)
                    tx_state_next = TxSop;
            end

            TxSop: begin
                if (tx_ready_in)
                    tx_state_next = TxData;
            end

            TxData: begin
                if (tx_ready_in)
                    tx_state_next = TxData_1;
            end

            TxData_1: begin
                if (tx_ready_in)
                    tx_state_next = TxEop;
            end

            TxEop: begin
                if (tx_ready_in)
                    tx_state_next = TxDel;
            end

            TxDel: begin
                tx_state_next = TxIdle;
            end
        endcase
    end

    // Form packets
    always_comb begin
        tx_data = 'h0;
        tx_empty_load = 1'b0;
        tx_byte_remain = 5'd0;

        if (tx_state == TxSop) begin
            // Ethernet header
            //   - 14B
            //   - 32B - 14B = 18B left = 144b
            tx_data[255:144] = tx_eth_hdr;

            // IP header (begin)
            //   - 20B
            //   - send first 18B of the IP header
            tx_data[143:0] = tx_ip_hdr[143:0];

        end else if (tx_state == TxData) begin
            // IP header (end)
            //   - 2B
            //   - 32B - 2B = 30B left = 240b
            tx_data[255:240] = tx_ip_hdr[159:144];

            // UDP header
            //   - 8B
            //   - 30B - 8B = 22B left = 176b
            tx_data[239:176] = tx_udp_hdr;

            // Payload (begin)
            //   - 64B
            //   - send first 22B of payload
            tx_data[175:0] = tx_fifo_pop_data.payload[175:0];

        end else if (tx_state == TxData_1) begin
            // Payload (cont.)
            //   - 32B
            tx_data = tx_fifo_pop_data.payload[431:176];

        end else if (tx_state == TxEop) begin
            // Payload (last)
            //   - 10B
            tx_data[79:0] = tx_fifo_pop_data.payload[511:432];

            // Padding
            //   - 22B
            // Note: this is just to pad the Avalon MAC 256-bit stream;
            //       due to correctly set packet length, no zero transmissions actually occur
            tx_data[255:80] = 'h0;

            tx_empty_load = 1'b1;
            tx_byte_remain = 5'd10;
        end
    end

    // Form tx_sop
    always_comb begin
        if (tx_state == TxSop)
            tx_sop = 1'b1;
        else
            tx_sop = 1'b0;
    end

    // Form tx_dt
    always_comb begin
        if (tx_state == TxData || tx_state == TxData_1)
            tx_dt = 1'b1;
        else
            tx_dt = 1'b0;
    end

    // Form tx_eop
    always_comb begin
        if (tx_state == TxEop)
            tx_eop = 1'b1;
        else
            tx_eop = 1'b0;
    end

    // Send to network
    always_ff @(posedge tx_clk_in or posedge tx_reset_in) begin
        if (tx_reset_in) begin
            tx_data_out  <= 'b0;
            tx_valid_out <= 'b0;
            tx_sop_out   <= 'b0;
            tx_eop_out   <= 'b0;
            tx_empty_out <= 'b0;
            tx_error_out <= 'b0;
        end else begin
            if (tx_empty_load)
                tx_empty_out <= 6'd32 - tx_byte_remain[4:0];
            else
                tx_empty_out <= 'b0;

            if (tx_ready_in) begin
                tx_data_out  <= tx_data;
                tx_valid_out <= tx_sop | tx_dt | tx_eop;
                tx_sop_out   <= tx_sop;
                tx_eop_out   <= tx_eop;
                tx_error_out <= 'b0;
            end
        end
    end


    // =============================================================
    // RX path
    // =============================================================
    localparam LRX_FIFO_DEPTH = 5;

    // RX FSM
    typedef enum logic [2:0] { RxSop, RxData, RxData_1, RxEop } RxState;

    RxState rx_state, rx_state_next;
    logic rx_sop_error, rx_eop_err;

    EthernetHdr rx_eth_hdr;
    IPHdr rx_ip_hdr;
    UDPHdr rx_udp_hdr;
    NetworkPayload rx_payload;
    logic rx_valid;

    // FSM current state logic
    always_ff @(posedge rx_clk_in or posedge rx_reset_in) begin
        if (rx_reset_in)
            rx_state <= RxSop;
        else
            rx_state <= rx_state_next;
    end

    // FSM switch state logic
    always_comb begin
        // Defaults
        rx_state_next = rx_state;

        case (rx_state)
            RxSop: begin
                if (rx_valid_in & rx_sop_in)
                    rx_state_next = RxData;
            end

            RxData: begin
                if (rx_valid_in)
                    rx_state_next = RxData_1;
            end

            RxData_1: begin
                if (rx_valid_in)
                    rx_state_next = RxEop;
            end

            RxEop: begin
                if (rx_valid_in & rx_eop_in)
                    rx_state_next = RxSop;
            end
        endcase
    end

    // Form packets
    logic [31:0] drop_cnt;
    logic udp_ip_hdr_valid;
    logic drop_packet;

    always_ff @(posedge rx_clk_in or posedge rx_reset_in) begin
        if (rx_reset_in) begin
            rx_sop_error <= 1'b0;
            rx_eop_err <= 1'b0;
            rx_valid <= 1'b0;

            rx_eth_hdr <= 'b0;
            rx_ip_hdr <= 'b0;
            rx_udp_hdr <= 'b0;
            rx_payload <= 'b0;

            drop_cnt <= 32'b0;
            udp_ip_hdr_valid <= 1'b0;

        end else begin
            // Defaults
            udp_ip_hdr_valid <= 1'b0;
            rx_valid <= 1'b0;

            if (rx_valid_in) begin
                if (rx_state == RxSop && rx_sop_in) begin
                    rx_eth_hdr       <= rx_data_in[255:144];
                    rx_ip_hdr[143:0] <= rx_data_in[143:0];
                end

                if (rx_state == RxData) begin
                    rx_ip_hdr[159:144] <= rx_data_in[255:240];
                    rx_udp_hdr         <= rx_data_in[239:176];
                    rx_payload[175:0]  <= rx_data_in[175:0];

                    udp_ip_hdr_valid <= 1'b1;
                end

                if (rx_state == RxData_1) begin
                    rx_payload[431:176] <= rx_data_in;
                end

                if (rx_state == RxEop/* && rx_eop_in*/) begin
                    if (rx_eop_in != 1'b1)
                        rx_eop_err <= 1'b1;
                    else begin
                        rx_payload[511:432] <= rx_data_in[79:0];

                        // Drop packet here if needed
                        //if (~drop_packet)
                            rx_valid <= 1'b1;
                        //else
                        //    drop_cnt <= drop_cnt + 1;
                    end
                end
            end
        end
    end

    // Check for errors and error counters
    logic [31:0] dest_mac_error_cnt;
    logic [31:0] dest_ip_error_cnt;
    logic [31:0] protocol_id_err_cnt;
    logic [31:0] ip_version_err_cnt;

    always_ff @(posedge rx_clk_in or posedge rx_reset_in) begin
        if (rx_reset_in) begin
            dest_mac_error_cnt <= 32'b0;
            dest_ip_error_cnt <= 32'b0;
            protocol_id_err_cnt <= 32'b0;
            ip_version_err_cnt <= 32'b0;
            drop_packet <= 1'b0;

        end else begin
            drop_packet <= 1'b0;

            // Check for errors, drop packets if found
            if (udp_ip_hdr_valid) begin
                // Check for the physical address errors
                if (rx_eth_hdr.dest_mac != host_mac) begin
                    dest_mac_error_cnt <= dest_mac_error_cnt + 1;
                    drop_packet <= 1'b1;
                end

                // Check for the IP address errors
                if (rx_ip_hdr.dest_ip != host_ip) begin
                    dest_ip_error_cnt <= dest_ip_error_cnt + 1;
                    drop_packet <= 1'b1;
                end

                // Check for the protocol id errors
                if (rx_ip_hdr.protocol != 8'h11) begin
                    protocol_id_err_cnt <= protocol_id_err_cnt + 1;
                    drop_packet <= 1'b1;
                end

                // Check for the ip version errors
                if (rx_ip_hdr.version != 4'h4) begin
                    ip_version_err_cnt <= ip_version_err_cnt + 1;
                    drop_packet <= 1'b1;
                end

                // Check ip checksum errors
                // TODO:
                // ...
            end
        end
    end

    // Assign rx outputs
    NetworkIf network_rx_out_fifo;
    always_comb begin
       network_rx_out_fifo.addr_tpl.source_ip = rx_ip_hdr.src_ip;
       network_rx_out_fifo.addr_tpl.source_port = rx_udp_hdr.src_port;
       network_rx_out_fifo.addr_tpl.dest_ip = rx_ip_hdr.dest_ip;
       network_rx_out_fifo.addr_tpl.dest_port = rx_udp_hdr.dest_port;
       network_rx_out_fifo.payload = rx_payload;
       network_rx_out_fifo.valid = rx_valid;
    end

    logic rx_fifo_ovf;
    async_fifo_channel #(
            .DATA_WIDTH($bits(NetworkAddressTuple) + $bits(NetworkPayload)),
            .LOG_DEPTH(LRX_FIFO_DEPTH),
            .CLOCK_ARE_SYNCHRONIZED("FALSE"),
            .DELAY_PIPE(4)
        ) rx_fifo (
            .clear(reset),
            .clk_1(rx_clk_in),

            .push_en(network_rx_out_fifo.valid),
            .push_data({network_rx_out_fifo.addr_tpl, network_rx_out_fifo.payload}),

            .clk_2(clk),
            .pop_enable(1'b1),

            .pop_valid(network_rx_out.valid),
            .pop_data({network_rx_out.addr_tpl, network_rx_out.payload}),
            .pop_dw(),
            .pop_empty(),
            .error(rx_fifo_ovf)
        );

    // Check for rx_fifo overflow
    logic [31:0] rx_fifo_drop;
    always_ff @(posedge rx_clk_in) begin
        if (rx_reset_in)
            rx_fifo_drop <= 32'b0;
        else if (rx_fifo_ovf)
            rx_fifo_drop <= rx_fifo_drop + 1;
    end

    // Always accept new packets
    // TODO: maybe better back-pressure?
    always_ff @(posedge rx_clk_in) begin
        rx_ready_out <= 'b1;
    end

    // Assign hard errors
    assign error = rx_eop_err | rx_sop_error;


    // =============================================================
    // Drop counter interface
    // =============================================================
    always_ff @(posedge clk) begin
        if (reset)
            pckt_drop_cnt_out <= 32'b0;
        else begin
            if (pckt_drop_cnt_valid_in) begin
                case (pckt_drop_cnt_in)
                    // Total number of drops
                    0: pckt_drop_cnt_out <= drop_cnt;

                    // Drops due to rx fifo ovf
                    1: pckt_drop_cnt_out <= rx_fifo_drop;

                    // Drops due to tx fifo ovf
                    2: pckt_drop_cnt_out <= tx_fifo_drop;

                    // Drop due to dest_mac_error_cnt
                    3: pckt_drop_cnt_out <= dest_mac_error_cnt;

                    // Drops due to dest_ip_error_cnt
                    4: pckt_drop_cnt_out <= dest_ip_error_cnt;

                    // Drops due to protocol_id_err_cnt
                    5: pckt_drop_cnt_out <= protocol_id_err_cnt;

                    // Drops due to ip_version_err_cnt
                    6: pckt_drop_cnt_out <= ip_version_err_cnt;

                    default: pckt_drop_cnt_out <= 32'b0;
                endcase
            end
        end
    end

endmodule
