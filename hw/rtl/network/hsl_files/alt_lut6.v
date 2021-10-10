module alt_lut6 #(
    parameter MASK = 64'h80000000_00000000,
    parameter SIM_EMULATE = 1'b0
) (
    input [5:0] din,
    output dout
);

generate
    if (SIM_EMULATE) begin
        assign dout = MASK [din];
    end else begin
        //Note: the S5 cell is 99% the same, and compatible
        //stratixv_lcell_comb a10c (
        twentynm_lcell_comb a10c (
            .dataa (din[0]),
            .datab (din[1]),
            .datac (din[2]),
            .datad (din[3]),
            .datae (din[4]),
            .dataf (din[5]),
            .datag(1'b1),
            .cin(1'b1),.sharein(1'b0),
            .sumout(),.cout(),.shareout(),
            .combout(dout)
        );
        defparam a10c .lut_mask = MASK;
        defparam a10c .shared_arith = "off";
        defparam a10c .extended_lut = "off";
    end
endgenerate

endmodule
