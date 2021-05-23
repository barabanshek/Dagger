// Author: Cornell University
//
// Module Name :    pipeliner
// Project :        F-NIC
// Description :    implements a pipeliner
//
//

module pipeliner
    #(
        parameter WIDTH = 8,
        parameter STAGES = 1
    )
    (
        input logic clk,
        input logic[WIDTH-1:0] in,
        output logic[WIDTH-1:0] out
    );

    logic[WIDTH-1:0] pipe [STAGES];

    integer i;
    always_ff @(posedge clk) begin
        pipe[0] <= in;

        for (i=0; i<STAGES-1; i=i+1) begin
            pipe[i+1] <= pipe[i];
        end

        out <= pipe[STAGES-1];
    end

endmodule
