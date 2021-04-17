// Author: Cornell University
//
// Module Name :    udp_fsm
// Project :        F-NIC
// Description :    UDP fsm for the RPC NIC

`include "nic_defs.vh"

module udp_fsm
    (
    // App interface
    input logic reset,
    input logic clk,
    input NetworkIf network_tx_in,
    output NetworkIf network_rx_out,

    // Networking interface
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
    output reg      rx_ready_out
    );


    // =============================================================
    // TX path  
    // =============================================================
    localparam LTX_FIFO_DEPTH = 5;

    logic tx_fifio_pop_en;
    logic tx_fifo_pop_valid;
    logic tx_fifo_empty;
    NetworkPayload tx_fifo_pop_data;

    async_fifo_channel #(
            .DATA_WIDTH($bits(NetworkPayload)),
            .LOG_DEPTH(LTX_FIFO_DEPTH),
            .CLOCK_ARE_SYNCHRONIZED("FALSE"),
            .DELAY_PIPE(4)
        ) tx_fifo (
            .clear(tx_reset_in),
            .clk_1(clk),

            .push_en(network_tx_in.valid),
            .push_data(network_tx_in.payload),

            .clk_2(tx_clk_in),
            .pop_enable(tx_fifio_pop_en),

            .pop_valid(tx_fifo_pop_valid),
            .pop_data(tx_fifo_pop_data),
            .pop_dw(),
            .pop_empty(tx_fifo_empty),
            .error()
        );

    // Signals
    logic [255:0] tx_data;
    logic tx_sop, tx_eop, tx_dt;
    logic tx_empty_load;
    logic [4:0] tx_byte_remain;

    // TX FSM
    typedef enum logic [2:0] { TxIdle, TxPop, TxSop, TxData, TxEop, TxDel } TxState;

    TxState tx_state, tx_state_next; 

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
                if (~tx_fifo_empty) begin
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
        tx_data = 256'h0;
        tx_empty_load = 1'b0;
        tx_byte_remain = 5'd0;

        if (tx_state == TxSop) begin
            // header
            tx_data[255:144] = {48'hFFFFFFFFFFFF, // 6 bytes
                                48'h000000000000, // 6 bytes
                                {5'b0, 11'd64}//,    // 2 bytes
                                //32'h01            // 4 bytes
                            };
            // first 18 bytes of the payload
            //   - 46 bytes remain
            tx_data[143:0] = tx_fifo_pop_data[143:0];
        end else if (tx_state == TxData) begin
            // next 32 bytes of the payload
            //   - 14 bytes remain
            tx_data = tx_fifo_pop_data[399:144];
        end else if (tx_state == TxEop) begin
            // last 14 bytes of the payload
            tx_data = tx_fifo_pop_data[511:400];
            tx_empty_load = 1'b1;
            tx_byte_remain = 5'd14;
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
        if (tx_state == TxData)
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
    logic [47:0] rx_dst_mac, rx_src_mac;
    logic [11:0] rx_data_size; 
    NetworkPayload network_rx_pload;
    logic rx_done;

//    typedef enum logic [2:0] { RxIdle, RxSop, RxData, RxEop } RxState;
//
//    RxState rx_state, rx_state_next;
//
//    // FSM current state logic
//    always_ff @(posedge rx_clk_in) begin
//        if (rx_reset_in)
//            rx_state <= RxIdle;
//        else
//            rx_state <= rx_state_next;
//    end
//
//    // FSM switch state logic
//    always_comb begin
//        // Defaults
//        rx_state_next = rx_state;
//
//        case (rx_sate) begin
//            RxIdle: begin
//                if (rx_valid_in)
//                    rx_state_next = RxSop;
//            end
//
//            RxSop: begin
//                if (rx_valid_in)
//                    rx_state_next = RxData;
//            end
//
//            RxData: begin
//                if (rx_valid_in)
//                    rx_state_next = RxEop;
//            end
//
//        end
//    end
//
//    // Form packets
//    always_ff @(posedge clk) begin
//        if (rx_reset_in) begin
//            rx_sop_error <= 1'b0;
//            rx_eop_err <= 1'b0;
//            network_rx_pload <= 'b0;
//
//        end else begin
//            if (rx_state == RxSop) begin
//                if (rx_sop_in != 1'b1)
//                    rx_sop_error <= 1'b1;
//                else begin
//                    rx_dst_mac              <= rx_data_in[47:0];
//                    rx_src_mac              <= rx_data_in[95:48];
//                    rx_data_size            <= rx_data_in[111:96];
//                    network_rx_pload[143:0] <= rx_data_in[255:112];
//                end
//            end
//
//            if (rx_state == RxData)
//                network_rx_pload[399:144] <= rx_data_in;
//
//            if (rx_state == RxEop) begin
//                if (rx_eop_in != 1'b1)
//                    rx_eop_err <= 1'b1;
//            end
//
//        end
//    end

    always_ff @(posedge rx_clk_in or posedge rx_reset_in) begin
        if (rx_reset_in) begin
            network_rx_pload <= 'b0;
            rx_done <= 1'b0;

        end else begin
            rx_done <= 1'b0;
            //network_rx_pload[399:144] <= {(256){1'b1}};//rx_data_in;

            if (rx_valid_in) begin
                if (rx_sop_in) begin
                    // SoP
                   // rx_dst_mac              <= rx_data_in[47:0];
                   // rx_src_mac              <= rx_data_in[95:48];
                   // rx_data_size            <= rx_data_in[111:96];
                    network_rx_pload[143:0] <= rx_data_in[143:0];
                end else if (rx_eop_in) begin
                    // EoP
                    network_rx_pload[511:400] <= rx_data_in[111:0];
                    rx_done <= 1'b1;
                end else begin
                    // Data
                    network_rx_pload[399:144] <= rx_data_in;
                end
            end
        end
    end

    async_fifo_channel #(
            .DATA_WIDTH($bits(NetworkPayload)),
            .LOG_DEPTH(LRX_FIFO_DEPTH),
            .CLOCK_ARE_SYNCHRONIZED("FALSE"),
            .DELAY_PIPE(4)
        ) rx_fifo (
            .clear(reset),
            .clk_1(rx_clk_in),

            .push_en(rx_done),
            .push_data(network_rx_pload),

            .clk_2(clk),
            .pop_enable(1'b1),  // always pop if anything is here

            .pop_valid(network_rx_out.valid),
            .pop_data(network_rx_out.payload),
            .pop_dw(),
            .pop_empty(),
            .error()
        );

    always_ff @(posedge rx_clk_in) begin
        rx_ready_out <= 'b1;
    end

endmodule
