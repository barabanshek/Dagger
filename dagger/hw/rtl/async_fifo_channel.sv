// Author: Cornell University
//
// Module Name :    async_fifo_channel
// Project :        F-NIC
// Description :    channel implementing an async showahead fifo
//

module async_fifo_channel
    #(
        parameter DATA_WIDTH = 32,
        parameter LOG_DEPTH = 5,
        parameter DELAY_PIPE = 0
    )
    (
    input logic clear,

    input logic                  clk_1,
    input logic                  push_en,
    input logic [DATA_WIDTH-1:0] push_data,

    input logic                   clk_2,
    input logic                   pop_enable,
    output logic                  pop_valid,
    output logic [DATA_WIDTH-1:0] pop_data,
    output logic [LOG_DEPTH-1:0]  pop_dw,
    output logic                  pop_empty,

    output logic error
    );


    logic fifo_empty;
    logic fifo_full;

    dcfifo  dcfifo_ (
                // reset
                .aclr (clear),

                // push
                .wrclk (clk_1),
                .wrreq (push_en & ~fifo_full),
                .data  (push_data),

                // pop
                .rdclk   (clk_2),
                .rdreq   (~fifo_empty & pop_enable),
                .q       (pop_data),
                .rdempty (fifo_empty),

                // status
                .wrfull (fifo_full),

                .rdfull (),
                .rdusedw (pop_dw),
                .wrempty (),
                .wrusedw (),
                .eccstatus()
            );
    defparam
        dcfifo_.add_usedw_msb_bit  = "ON",
        dcfifo_.enable_ecc  = "FALSE",
        dcfifo_.lpm_hint  = "DISABLE_DCFIFO_EMBEDDED_TIMING_CONSTRAINT=TRUE",
        dcfifo_.lpm_numwords  = 2**LOG_DEPTH,
        dcfifo_.lpm_showahead  = "OFF",
        dcfifo_.lpm_type  = "dcfifo",
        dcfifo_.lpm_width  = DATA_WIDTH,
        dcfifo_.lpm_widthu  = LOG_DEPTH,
        dcfifo_.overflow_checking  = "ON",
        dcfifo_.rdsync_delaypipe  = DELAY_PIPE,
        dcfifo_.clocks_are_synchronized = "TRUE",
        dcfifo_.read_aclr_synch  = "ON",
        dcfifo_.underflow_checking  = "ON",
        dcfifo_.use_eab  = "ON",
        dcfifo_.write_aclr_synch  = "ON",
        dcfifo_.wrsync_delaypipe  = DELAY_PIPE;

    // 1-cycle delay to sync
    logic pop_valid_delay;
    always @(posedge clk_2) begin
        pop_valid_delay <= ~fifo_empty & pop_enable;
    end
    assign pop_valid = pop_valid_delay;

    // Error if full
    logic packet_lost_detected;
    always @(posedge clk_1, posedge clear) begin
        if (clear) begin
            packet_lost_detected <= 1'b0;
        end else if (push_en & fifo_full) begin
            packet_lost_detected <= 1'b1;
        end
    end
    assign error = packet_lost_detected;

    assign pop_empty = fifo_empty;

endmodule
