// Author: Cornell University
//
// Module Name :    udp_ip_tb
// Project :        F-NIC
// Description :    testbench for the UDP/IP stack and FSM
//

`include "../nic_defs.vh"
`include "../general_defs.vh"

// sets the granularity at which we simulate
`timescale 1 ns / 1 ps

module udp_ip_tb();

    logic clk_100;
    logic reset_100;
    logic clk_312_5;
    logic reset_312_5;

    // Generate clocks
    initial begin
        // clock_100
        clk_100 = 1'b0;
        forever begin
          #5
          clk_100 = ~clk_100;
        end
    end

    initial begin
        // clock_312_5
        clk_312_5 = 1'b0;
        forever begin
          #1.6
          clk_312_5 = ~clk_312_5;
        end
    end

    // Signals
    PhyAddr host_1_phy_addr, host_2_phy_addr;
    IPv4 host_1_ipv4_addr, host_2_ipv4_addr;
    NetworkIf network_tx, network_rx;
    logic tx_ready, rx_ready;
    logic [255:0] tx_data, rx_data;
    logic tx_valid, rx_valid;
    logic tx_sop, tx_eop, rx_sop, rx_eop;
    logic [4:0] tx_empty, rx_empty;
    logic tx_error;
    logic [5:0] rx_error;
    logic [3:0] pckt_drop_cnt_in_2;
    logic pckt_drop_cnt_valid_2;
    logic [31:0] pckt_drop_cnt_out_2;

    // UUTs
    udp_ip UUT_1 (
            .host_phy_addr(host_1_phy_addr),
            .host_ipv4_addr(host_1_ipv4_addr),

            .clk(clk_100),
            .reset(reset_100),
            .network_tx_in(network_tx),
            .network_rx_out(),

            .tx_clk_in (clk_312_5),
            .tx_reset_in (reset_312_5),
            .tx_ready_in (tx_ready),
            .tx_data_out (tx_data),
            .tx_valid_out (tx_valid),
            .tx_sop_out (tx_sop),
            .tx_eop_out (tx_eop),
            .tx_empty_out (tx_empty),
            .tx_error_out (tx_error),

            .rx_clk_in (),
            .rx_reset_in (),
            .rx_data_in (),
            .rx_valid_in (),
            .rx_sop_in (),
            .rx_eop_in (),
            .rx_empty_in (),
            .rx_error_in (),
            .rx_ready_out (),

            .pckt_drop_cnt_in(),
            .pckt_drop_cnt_valid_in(),
            .pckt_drop_cnt_out(),

            .error()
        );

    udp_ip UUT_2 (
            .host_phy_addr(host_2_phy_addr),
            .host_ipv4_addr(host_2_ipv4_addr),

            .clk(clk_100),
            .reset(reset_100),
            .network_tx_in(),
            .network_rx_out(network_rx),

            .tx_clk_in (),
            .tx_reset_in (),
            .tx_ready_in (),
            .tx_data_out (),
            .tx_valid_out (),
            .tx_sop_out (),
            .tx_eop_out (),
            .tx_empty_out (),
            .tx_error_out (),

            .rx_clk_in (clk_312_5),
            .rx_reset_in (reset_312_5),
            .rx_data_in (rx_data),
            .rx_valid_in (rx_valid),
            .rx_sop_in (rx_sop),
            .rx_eop_in (rx_eop),
            .rx_empty_in (rx_empty),
            .rx_error_in (rx_error),
            .rx_ready_out (rx_ready),

            .pckt_drop_cnt_in(pckt_drop_cnt_in_2),
            .pckt_drop_cnt_valid_in(pckt_drop_cnt_valid_2),
            .pckt_drop_cnt_out(pckt_drop_cnt_out_2),

            .error()
        );

    // Network delay injector
    logic delay_injector_en;
    logic [15:0] delay_injector_cnt;
    integer delay_injector_A, delay_injector_B;
    integer delay_rnd_val_A, delay_rnd_val_B;
    always_ff @(posedge clk_312_5) begin
        if (reset_312_5) begin
            tx_ready = 1'b1;
            delay_injector_cnt <= 16'b0;
        end else begin
            if (delay_injector_en) begin
                delay_injector_cnt <= delay_injector_cnt + 1;

                if (delay_injector_cnt == 0) begin
                    delay_rnd_val_A = $urandom_range(2, delay_injector_A);
                    delay_rnd_val_B = delay_rnd_val_A + $urandom_range(2, delay_injector_B);
                end

                if (delay_injector_cnt == delay_rnd_val_A) begin
                    tx_ready = 1'b0;
                end

                if (delay_injector_cnt == delay_rnd_val_B) begin
                    tx_ready = 1'b1;
                    delay_injector_cnt <= 16'b0;
                end

            end else begin
                tx_ready = 1'b1;
                delay_injector_cnt <= 16'b0;
            end
        end
    end

    // Connections
    assign rx_data = tx_data;
    assign rx_sop = tx_sop;
    assign rx_eop = tx_eop;
    assign rx_empty = tx_empty;
    assign rx_valid = tx_valid & tx_ready; // only transmit when ready
    //assign tx_ready = rx_ready;
    assign rx_error = 6'b000000;

    // FIFO to store received packets
    logic recv_queue_pop_en;
    logic recv_queue_pop_valid;
    NetworkIf recv_queue_pop_data;
    logic [7:0] recv_queue_pop_dw;
    async_fifo_channel #(
            .DATA_WIDTH($bits(NetworkIf)),
            .LOG_DEPTH(8)
        ) rx_packet_queue (
            .clear(reset_100),
            .clk_1(clk_100),
            .push_en(network_rx.valid),
            .push_data(network_rx),

            .clk_2(clk_100),
            .pop_enable(recv_queue_pop_en),
            .pop_valid(recv_queue_pop_valid),
            .pop_data(recv_queue_pop_data),
            .pop_dw(recv_queue_pop_dw),
            .pop_empty(),
            .loss_out(),
            .error()
        );

    // Functions
    function [511:0] gen_payload(int seed);
        for (int i=0; i<64; i=i+1) begin
            gen_payload[(i+1)*8-1-:8] = i ^ seed;
        end
    endfunction

    // variables
    integer test2_num_packets = 9;
    integer test3_num_packets = 29;
    integer test4_num_packets = 30;
    integer num_errors = 0;
    integer num_failed_tests = 0;

    // Test cases
    initial
    begin
        // Initial values
        recv_queue_pop_en = 1'b0;
        network_tx.valid = 1'b0;
        network_tx.payload = 'b0;
        network_tx.addr_tpl.source_ip = '{8'h00, 8'h00, 8'h00, 8'h00};
        network_tx.addr_tpl.dest_ip = '{8'h00, 8'h00, 8'h00, 8'h00};
        network_tx.addr_tpl.source_port = 16'h00;
        network_tx.addr_tpl.dest_port = 16'h00;

        $display("MSIM> START OF SIMULATION");

        // Reset
        reset_100 = 1'b1;
        reset_312_5 = 1'b1;
        #100
        reset_100 = 1'b0;
        reset_312_5 = 1'b0;
        #100

        //
        // start testcases with negedge clock
        //
        //
        // TEST #1: send a single packet
        //
        host_1_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h01, 8'h01, 8'h01};
        host_1_ipv4_addr = '{8'h01, 8'h02, 8'h03, 8'h04};
        host_2_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h02, 8'h02, 8'h02};
        host_2_ipv4_addr = '{8'h05, 8'h06, 8'h07, 8'h08};

        network_tx.addr_tpl.dest_ip = '{8'h05, 8'h06, 8'h07, 8'h08};
        network_tx.addr_tpl.source_port = 16'hcf18;
        network_tx.addr_tpl.dest_port = 16'hcf18;
        network_tx.payload = gen_payload(12);

        network_tx.valid = 1'b1;
        #10
        network_tx.valid = 1'b0;

        #1000
        // Check received packet after some time
        num_errors = 0;
        if (recv_queue_pop_dw == 0) begin
            $display("MSIM> ERROR: not all requests received, only %d", recv_queue_pop_dw);
            ++num_errors;
        end else begin
            recv_queue_pop_en = 1'b1;
            #10
            recv_queue_pop_en = 1'b0;

            if (recv_queue_pop_data.payload != gen_payload(12)) begin
                $display("MSIM> ERROR: incorrect payload received");
                ++num_errors;
            end

            if (recv_queue_pop_data.addr_tpl.source_ip != '{8'h01, 8'h02, 8'h03, 8'h04} |
                    recv_queue_pop_data.addr_tpl.dest_ip != '{8'h05, 8'h06, 8'h07, 8'h08} |
                    recv_queue_pop_data.addr_tpl.source_port != 16'hcf18 |
                    recv_queue_pop_data.addr_tpl.dest_port != 16'hcf18) begin
                $display("MSIM> ERROR: incorrect header received");
                ++num_errors;
            end
        end

        if (num_errors == 0)
            $display("MSIM> TEST #1 PASSED!");
        else begin
            $display("MSIM> TEST #1 FAILED!");
            ++num_failed_tests;
        end

        //
        // TEST #2: send multiple packets
        //
        host_1_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h01, 8'h01, 8'h01};
        host_1_ipv4_addr = '{8'h01, 8'h02, 8'h03, 8'h04};
        host_2_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h02, 8'h02, 8'h02};
        host_2_ipv4_addr = '{8'h05, 8'h06, 8'h07, 8'h08};

        for (int i=0; i<test2_num_packets; ++i) begin
            #100
            network_tx.addr_tpl.dest_ip = '{8'h05, 8'h06, 8'h07, 8'h08};
            network_tx.addr_tpl.source_port = i;
            network_tx.addr_tpl.dest_port = i+12345;
            network_tx.payload = gen_payload(i);

            network_tx.valid = 1'b1;
            #10
            network_tx.valid = 1'b0;
        end

        #1000
        // Check received packet after some time
        num_errors = 0;
        if (recv_queue_pop_dw != test2_num_packets) begin
            $display("MSIM> ERROR: not all requests received, only %d", recv_queue_pop_dw);
            ++num_errors;
        end else begin
            for (int i=0; i<test2_num_packets; ++i) begin
                recv_queue_pop_en = 1'b1;
                #10
                recv_queue_pop_en = 1'b0;

                if (recv_queue_pop_data.payload != gen_payload(i)) begin
                    $display("MSIM> ERROR: incorrect payload received");
                    ++num_errors;
                end

                if (recv_queue_pop_data.addr_tpl.source_ip != '{8'h01, 8'h02, 8'h03, 8'h04} |
                        recv_queue_pop_data.addr_tpl.dest_ip != '{8'h05, 8'h06, 8'h07, 8'h08} |
                        recv_queue_pop_data.addr_tpl.source_port != i |
                        recv_queue_pop_data.addr_tpl.dest_port != i+12345) begin
                    $display("MSIM> ERROR: incorrect header received");
                    ++num_errors;
                end
            end
        end

        if (num_errors == 0)
            $display("MSIM> TEST #2 PASSED!");
        else begin
            $display("MSIM> TEST #2 FAILED!");
            ++num_failed_tests;
        end

        //
        // TEST #3: send multiple packets, inject delays
        //
        host_1_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h01, 8'h01, 8'h01};
        host_1_ipv4_addr = '{8'h01, 8'h02, 8'h03, 8'h04};
        host_2_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h02, 8'h02, 8'h02};
        host_2_ipv4_addr = '{8'h05, 8'h06, 8'h07, 8'h08};

        delay_injector_A = 10;
        delay_injector_B = 4;
        delay_injector_en = 1'b1;
        for (int i=0; i<test3_num_packets; ++i) begin
            #50
            network_tx.addr_tpl.dest_ip = '{8'h05, 8'h06, 8'h07, 8'h08};
            network_tx.addr_tpl.source_port = i;
            network_tx.addr_tpl.dest_port = i+12345;
            network_tx.payload = gen_payload(i);
            network_tx.valid = 1'b1;
            #10
            network_tx.valid = 1'b0;
        end
        delay_injector_en = 1'b0;

        #1000
        // Check received packets after some time
        num_errors = 0;
        if (recv_queue_pop_dw != test3_num_packets) begin
            $display("MSIM> ERROR: not all requests received, only %d", recv_queue_pop_dw);
            ++num_errors;
        end else begin
            for (int i=0; i<test3_num_packets; ++i) begin
                recv_queue_pop_en = 1'b1;
                #10
                recv_queue_pop_en = 1'b0;

                if (recv_queue_pop_data.payload != gen_payload(i)) begin
                    $display("MSIM> ERROR: incorrect payload received");
                    ++num_errors;
                end

                if (recv_queue_pop_data.addr_tpl.source_ip != '{8'h01, 8'h02, 8'h03, 8'h04} |
                        recv_queue_pop_data.addr_tpl.dest_ip != '{8'h05, 8'h06, 8'h07, 8'h08} |
                        recv_queue_pop_data.addr_tpl.source_port != i |
                        recv_queue_pop_data.addr_tpl.dest_port != i+12345) begin
                    $display("MSIM> ERROR: incorrect header received");
                    ++num_errors;
                end
            end
        end

        if (num_errors == 0)
            $display("MSIM> TEST #3 PASSED!");
        else begin
            $display("MSIM> TEST #3 FAILED!");
            ++num_failed_tests;
        end

        // Reset
        reset_100 = 1'b1;
        reset_312_5 = 1'b1;
        #100
        reset_100 = 1'b0;
        reset_312_5 = 1'b0;
        #100

        //
        // TEST #4: send a single packet, drop due to wrong IP
        //
        host_1_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h01, 8'h01, 8'h01};
        host_1_ipv4_addr = '{8'h01, 8'h02, 8'h03, 8'h04};
        host_2_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h02, 8'h02, 8'h02};
        host_2_ipv4_addr = '{8'h05, 8'h06, 8'h07, 8'h08};
        #100

        network_tx.addr_tpl.dest_ip = '{8'h05, 8'h06, 8'h07, 8'hFF};
        network_tx.addr_tpl.source_port = 16'hcf18;
        network_tx.addr_tpl.dest_port = 16'hcf18;
        network_tx.payload = gen_payload(12);

        network_tx.valid = 1'b1;
        #10
        network_tx.valid = 1'b0;

        #1000
        // Check received packet after some time
        num_errors = 0;
        if (recv_queue_pop_dw != 0) begin
            $display("MSIM> ERROR: no packets expected");
            ++num_errors;
        end else begin
            pckt_drop_cnt_in_2 = 4'd0;
            pckt_drop_cnt_valid_2 = 1'b1;
            #10
            pckt_drop_cnt_valid_2 = 1'b0;

            if (pckt_drop_cnt_out_2 != 1) begin
                $display("MSIM> ERROR: wrong number of total packet drops");
                ++num_errors;
            end

            pckt_drop_cnt_in_2 = 4'd4;
            pckt_drop_cnt_valid_2 = 1'b1;
            #10
            pckt_drop_cnt_valid_2 = 1'b0;

            if (pckt_drop_cnt_out_2 != 1) begin
                $display("MSIM> ERROR: wrong number of total packet drops");
                ++num_errors;
            end
        end

        if (num_errors == 0)
            $display("MSIM> TEST #4 PASSED!");
        else begin
            $display("MSIM> TEST #4 FAILED!");
            ++num_failed_tests;
        end

        // Reset
        reset_100 = 1'b1;
        reset_312_5 = 1'b1;
        #100
        reset_100 = 1'b0;
        reset_312_5 = 1'b0;
        #100

        //
        // TEST #5: send multiple packets, inject delays, drop some packets due to wrong IP
        //
        host_1_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h01, 8'h01, 8'h01};
        host_1_ipv4_addr = '{8'h01, 8'h02, 8'h03, 8'h04};
        host_2_phy_addr = '{8'h00, 8'h00, 8'h00, 8'h02, 8'h02, 8'h02};
        host_2_ipv4_addr = '{8'h05, 8'h06, 8'h07, 8'h08};
        #100

        delay_injector_A = 10;
        delay_injector_B = 4;
        delay_injector_en = 1'b1;
        for (int i=0; i<test4_num_packets; ++i) begin
            #50
            // Incorrect IP for each 5th packet
            network_tx.addr_tpl.dest_ip = '{8'h05 + (i%5 == 0), 8'h06, 8'h07, 8'h08};
            network_tx.addr_tpl.source_port = i;
            network_tx.addr_tpl.dest_port = i+12345;
            network_tx.payload = gen_payload(i);
            network_tx.valid = 1'b1;
            #10
            network_tx.valid = 1'b0;
        end
        delay_injector_en = 1'b0;

        #1000
        // Check received packets after some time
        num_errors = 0;
        if (recv_queue_pop_dw != test4_num_packets - test4_num_packets/5) begin
            $display("MSIM> ERROR: wrong number of requests received: %d expected: %d",
                                            recv_queue_pop_dw, test4_num_packets - test4_num_packets/5);
            ++num_errors;
        end else begin
            for (int i=0; i<test4_num_packets; ++i) begin
                if (i%5 != 0) begin
                    recv_queue_pop_en = 1'b1;
                    #10
                    recv_queue_pop_en = 1'b0;

                    if (recv_queue_pop_data.payload != gen_payload(i)) begin
                        $display("MSIM> ERROR: incorrect payload received");
                        ++num_errors;
                    end

                    if (recv_queue_pop_data.addr_tpl.source_ip != '{8'h01, 8'h02, 8'h03, 8'h04} |
                            recv_queue_pop_data.addr_tpl.dest_ip != '{8'h05, 8'h06, 8'h07, 8'h08} |
                            recv_queue_pop_data.addr_tpl.source_port != i |
                            recv_queue_pop_data.addr_tpl.dest_port != i+12345) begin
                        $display("MSIM> ERROR: incorrect header received");
                        ++num_errors;
                    end
                end
            end
        end

        pckt_drop_cnt_in_2 = 4'd0;
        pckt_drop_cnt_valid_2 = 1'b1;
        #10
        pckt_drop_cnt_valid_2 = 1'b0;

        if (pckt_drop_cnt_out_2 != 6) begin
            $display("MSIM> ERROR: wrong number of total packet drops: %d", pckt_drop_cnt_out_2);
            ++num_errors;
        end

        pckt_drop_cnt_in_2 = 4'd4;
        pckt_drop_cnt_valid_2 = 1'b1;
        #10
        pckt_drop_cnt_valid_2 = 1'b0;

        if (pckt_drop_cnt_out_2 != 6) begin
            $display("MSIM> ERROR: wrong number of total packet drops: %d", pckt_drop_cnt_out_2);
            ++num_errors;
        end

        if (num_errors == 0)
            $display("MSIM> TEST #5 PASSED!");
        else begin
            $display("MSIM> TEST #5 FAILED!");
            ++num_failed_tests;
        end

    //
    // Wait a bit before termination
    //
    #10000

    $display("MSIM> TOTAL TESTS FAILED: %d", num_failed_tests);
    $display("MSIM> END OF SIMULATION");
    $stop;

    end

endmodule
