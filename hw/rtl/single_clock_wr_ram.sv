// Author: Cornell University
//
// Module Name :    single_clock_wr_ram
// Project :        F-NIC
// Description :    Single-Clock Simple Dual-Port Synchronous RAM with New Data
//                  Read-During-Write Behavior
// Reference:       Altera Recommended HDL Coding Styles, example 13-13
//

module single_clock_wr_ram
    #(
        parameter DATA_WIDTH = 32,
        parameter ADR_WIDTH  = 8
    )
    (
        output reg [DATA_WIDTH-1:0] q,
        input [DATA_WIDTH-1:0] d,
        input [ADR_WIDTH-1:0] write_address, read_address,
        input we, clk
    );

    reg [DATA_WIDTH-1:0] mem [(2**ADR_WIDTH)-1:0];

    always @ (posedge clk) begin
        if (we)
            mem[write_address] <= d;
        q <= mem[read_address];
    end

endmodule
