// Author: Cornell University
//
// Module Name :    request_queue
// Project :        F-NIC
// Description :    implements a request queue
//
//


module request_queue
    #(
        // NIC ID
        parameter DATA_WIDTH = 8,
        parameter LSIZE = 0

    )
    (
        input logic clk,
        input logic reset,

        // Control
        input logic initialize,

        // Data in
        input logic                 push_en_in,
        input logic[DATA_WIDTH-1:0] push_data_in,
        output logic[LSIZE-1:0]     push_slot_id_out,
        output logic                push_done_out,

        // Data out
        input logic                  pop_en_in,
        input logic[LSIZE-1:0]       pop_slot_id_in,
        output logic[DATA_WIDTH-1:0] pop_data_out,

        // Status
        output logic initialized,
        output logic error

    );

    // Types
    typedef logic[DATA_WIDTH-1:0] Data;
    typedef logic[LSIZE-1:0] Addr;
    typedef enum logic { QueueInitIdle, QueueInit } QueueInitState;

    // Queue store
    Data queue_in, queue_out;
    Addr queue_wr_addr, queue_rd_addr;
    logic queue_wr_en;

    QueueInitState q_init_state;
    Addr q_init_addr;
    logic q_initialized;

    single_clock_wr_ram #(
            .DATA_WIDTH(DATA_WIDTH),
            .ADR_WIDTH(LSIZE)
        ) queue (
            .clk(clk),
            .q(queue_out),
            .d(q_init_state == QueueInit? {($bits(Data)){1'b0}}: queue_in),
            .write_address(q_init_state == QueueInit? q_init_addr: queue_wr_addr),
            .read_address(queue_rd_addr),
            .we(q_init_state == QueueInit? 1'b1: queue_wr_en)
        );

    // Free entry FIFO
    logic fr_fifo_push_en;
    Addr fr_init_addr, fr_addr_push, fr_addr_pop;
    logic fr_pop_enable;
    logic fr_pop_valid;
    logic fr_pop_empty;
    logic free_entry_fifo_error;

    async_fifo_channel #(
            .DATA_WIDTH(LSIZE),
            .LOG_DEPTH(LSIZE)
        ) free_entry_fifo (
            .clear(reset),
            .clk_1(clk),
            .push_en(q_init_state == QueueInit? 1'b1: fr_fifo_push_en),
            .push_data(q_init_state == QueueInit? fr_init_addr: fr_addr_push),
            .clk_2(clk),
            .pop_enable(fr_pop_enable),
            .pop_valid(fr_pop_valid),
            .pop_data(fr_addr_pop),
            .pop_dw(),
            .pop_empty(fr_pop_empty),
            .error(free_entry_fifo_error)
        );

    // Initialization logic
    always @(posedge clk) begin
        if (reset) begin
            q_init_state  <= QueueInitIdle;
            q_init_addr   <= {($bits(q_init_addr)){1'b0}};
            fr_init_addr  <= {($bits(q_init_addr)){1'b0}};
            q_initialized <= 1'b0;

        end else begin
            if (q_init_state == QueueInitIdle && initialize) begin
                q_init_state <= QueueInit;
            end

            if (q_init_state == QueueInit) begin
                if (q_init_addr == 2 ** LSIZE - 1) begin
                    q_init_addr   <= {($bits(q_init_addr)){1'b0}};
                    fr_init_addr  <= {($bits(q_init_addr)){1'b0}};
                    q_initialized <= 1'b1;
                    q_init_state  <= QueueInitIdle;
                end else begin
                    q_init_addr  <= q_init_addr + 1;
                    fr_init_addr <= fr_init_addr + 1;
                end
            end
        end
    end

    // Push logic
    Data push_data_in_d;
    logic no_free_slot_error;

    // Combinationally get the address of a free queue slot
    always_comb begin
        fr_pop_enable = push_en_in;
    end

    // Delay data to align with the fifo pop
    always @(posedge clk) begin
        push_data_in_d <= push_data_in;
    end

    always @(posedge clk) begin
        queue_wr_en   <= 1'b0;
        push_done_out <= 1'b0;

        if (fr_pop_valid) begin
            // The address of a free entry is here, write request in it
            queue_wr_addr <= fr_addr_pop;
            queue_in      <= push_data_in_d;
            queue_wr_en   <= 1'b1;
            // Output the address of the data
            push_slot_id_out  <= fr_addr_pop;
            push_done_out     <= 1'b1;
        end

        // Catch the full error if there is no free slot available
        if (push_en_in && fr_pop_empty) begin
            no_free_slot_error <= 1'b1;
        end

        if (reset) begin
            queue_wr_addr      <= {($bits(queue_wr_addr)){1'b0}};
            push_slot_id_out   <= {($bits(push_slot_id_out)){1'b0}};    // TODO: remove
            queue_wr_en        <= 1'b0;
            no_free_slot_error <= 1'b0;
            push_done_out      <= 1'b0;
        end
    end

    // Pop logic
    // Combinationally assign slot to read and data
    always_comb begin
        queue_rd_addr = pop_slot_id_in;
        pop_data_out  = queue_out;
    end

    // Write the emptied slot address to the FIFO
    always_ff @(posedge clk) begin
        if (reset) begin
            fr_addr_push    <= {($bits(fr_addr_push)){1'b0}};
            fr_fifo_push_en <= 1'b0;

        end else begin
            fr_fifo_push_en <= 1'b0;

            if (pop_en_in) begin
                fr_addr_push    <= queue_rd_addr;
                fr_fifo_push_en <= 1'b1;
            end
        end
    end

    // Status
    assign initialized = q_initialized;
    assign error = free_entry_fifo_error & no_free_slot_error;


endmodule
