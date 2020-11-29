// Author: Cornell University
//
// Module Name :    pulse_gen
// Project :        F-NIC
// Description :    pulse generator
//
//

module pulse_gen
    #(
        parameter N_OF_CYCLES = 1
    )
    (
        input logic clk,
        input logic reset,
        input logic sig_in,

        output logic pulse_out
    );

    localparam CNT_WIDTH = $clog2(N_OF_CYCLES);

    logic pulse;
    logic[CNT_WIDTH-1:0] cnt;
    always_ff @(posedge clk) begin
        if (reset) begin
            cnt <= {(CNT_WIDTH){1'b0}};
            pulse <= 1'b0;
        end else begin
            if (sig_in) begin
                pulse <= 1'b1;
            end
            if (pulse) begin
                if (cnt == N_OF_CYCLES - 1) begin
                    pulse <= 1'b0;
                    cnt <= {(CNT_WIDTH){1'b0}};
                end else begin
                    cnt <= cnt + 1;
                end
            end
        end
    end

    assign pulse_out = pulse;


endmodule
