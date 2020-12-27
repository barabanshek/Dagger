// (C) 1992-2016 Altera Corporation. All rights reserved.                         
// Your use of Altera Corporation's design tools, logic functions and other       
// software and tools, and its AMPP partner logic functions, and any output       
// files any of the foregoing (including device programming or simulation         
// files), and any associated documentation or information are expressly subject  
// to the terms and conditions of the Altera Program License Subscription         
// Agreement, Altera MegaCore Function License Agreement, or other applicable     
// license agreement, including, without limitation, that your use is for the     
// sole purpose of programming logic devices manufactured by Altera and sold by   
// Altera or its authorized distributors.  Please refer to the applicable         
// agreement for further details.                                                 
    


module acl_arb2
#(
    // Configuration
    parameter string PIPELINE = "data_stall",    // none|data|stall|data_stall|stall_data
    parameter integer KEEP_LAST_GRANT = 1,       // 0|1 - if one request can last multiple cycles (e.g. write burst), KEEP_LAST_GRANT must be 1
    parameter integer NO_STALL_NETWORK = 0,      // 0|1 - if one, remove the ability for arb to stall backward - must guarantee no collisions!

    // Masters
    parameter integer DATA_W = 32,               // > 0
    parameter integer BURSTCOUNT_W = 4,          // > 0
    parameter integer ADDRESS_W = 32,            // > 0
    parameter integer BYTEENA_W = DATA_W / 8,    // > 0
    parameter integer ID_W = 1                   // > 0
)
(
    // INPUTS

    input logic clock,
    input logic resetn,

    // INTERFACES

    acl_arb_intf m0_intf,
    acl_arb_intf m1_intf,
    acl_arb_intf mout_intf
);
    /////////////////////////////////////////////
    // ARCHITECTURE
    /////////////////////////////////////////////

    // mux_intf acts as an interface immediately after request arbitration
    acl_arb_intf #(
        .DATA_W( DATA_W ),
        .BURSTCOUNT_W( BURSTCOUNT_W ),
        .ADDRESS_W( ADDRESS_W ),
        .BYTEENA_W( BYTEENA_W ),
        .ID_W( ID_W )
    )
    mux_intf();

    // Selector and request arbitration.
    logic mux_sel;

    assign mux_intf.req = mux_sel ? m1_intf.req : m0_intf.req;

    generate
    if( KEEP_LAST_GRANT == 1 )
    begin
        logic last_mux_sel_r;

        always_ff @( posedge clock )
            last_mux_sel_r <= mux_sel;

        always_comb
            // Maintain last grant.
            if( last_mux_sel_r == 1'b0 && m0_intf.req.request )
                mux_sel = 1'b0;
            else if( last_mux_sel_r == 1'b1 && m1_intf.req.request )
                mux_sel = 1'b1;
            // Arbitrarily favor m0.
            else
                mux_sel = m0_intf.req.request ? 1'b0 : 1'b1;
    end
    else
    begin
        // Arbitrarily favor m0.
        assign mux_sel = m0_intf.req.request ? 1'b0 : 1'b1;
    end
    endgenerate

    // Stall signal for each upstream master.
    generate
    if( NO_STALL_NETWORK == 1 )
    begin
       assign m0_intf.stall = '0;
       assign m1_intf.stall = '0;
    end
    else
    begin
       assign m0_intf.stall = ( mux_sel & m1_intf.req.request) | mux_intf.stall;
       assign m1_intf.stall = (~mux_sel & m0_intf.req.request) | mux_intf.stall;
    end
    endgenerate


    // What happens at the output of the arbitration block? Depends on the pipelining option...
    // Each option is responsible for the following:
    //  1. Connecting mout_intf.req: request output of the arbitration block
    //  2. Connecting mux_intf.stall: upstream (to input masters) stall signal
    generate
    if( PIPELINE == "none" )
    begin
        // Purely combinational. Not a single register to be seen.

        // Request for downstream blocks.
        assign mout_intf.req = mux_intf.req;

        // Stall signal from downstream blocks
        assign mux_intf.stall = mout_intf.stall;
    end
    else if( PIPELINE == "data" )
    begin
        // Standard pipeline register at output. Latency of one cycle.

        acl_arb_intf #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        pipe_intf();

        acl_arb_pipeline_reg #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        pipe(
            .clock( clock ),
            .resetn( resetn ),

            .in_intf( mux_intf ),
            .out_intf( pipe_intf )
        );

        // Request for downstream blocks.
        assign mout_intf.req = pipe_intf.req;

        // Stall signal from downstream blocks.
        assign pipe_intf.stall = mout_intf.stall;
    end
    else if( PIPELINE == "stall" )
    begin
        // Staging register at output. Min. latency of zero cycles, max. latency of one cycle.

        acl_arb_intf #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        staging_intf();

        acl_arb_staging_reg #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        staging(
            .clock( clock ),
            .resetn( resetn ),

            .in_intf( mux_intf ),
            .out_intf( staging_intf )
        );

        // Request for downstream blocks.
        assign mout_intf.req = staging_intf.req;

        // Stall signal from downstream blocks.
        assign staging_intf.stall = mout_intf.stall;
    end
    else if( PIPELINE == "data_stall" )
    begin
        // Pipeline register followed by staging register at output. Min. latency
        // of one cycle, max. latency of two cycles.

        acl_arb_intf #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        pipe_intf(), staging_intf();

        acl_arb_pipeline_reg #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        pipe(
            .clock( clock ),
            .resetn( resetn ),

            .in_intf( mux_intf ),
            .out_intf( pipe_intf )
        );

        acl_arb_staging_reg #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        staging(
            .clock( clock ),
            .resetn( resetn ),

            .in_intf( pipe_intf ),
            .out_intf( staging_intf )
        );

        // Request for downstream blocks.
        assign mout_intf.req = staging_intf.req;        

        // Stall signal from downstream blocks.
        assign staging_intf.stall = mout_intf.stall;
    end
    else if( PIPELINE == "stall_data" )
    begin
        // Staging register followed by pipeline register at output. Min. latency
        // of one cycle, max. latency of two cycles.

        acl_arb_intf #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        staging_intf(), pipe_intf();

        acl_arb_staging_reg #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        staging(
            .clock( clock ),
            .resetn( resetn ),

            .in_intf( mux_intf ),
            .out_intf( staging_intf )
        );

        acl_arb_pipeline_reg #(
            .DATA_W( DATA_W ),
            .BURSTCOUNT_W( BURSTCOUNT_W ),
            .ADDRESS_W( ADDRESS_W ),
            .BYTEENA_W( BYTEENA_W ),
            .ID_W( ID_W )
        )
        pipe(
            .clock( clock ),
            .resetn( resetn ),

            .in_intf( staging_intf ),
            .out_intf( pipe_intf )
        );

        // Request for downstream blocks.
        assign mout_intf.req = pipe_intf.req;        

        // Stall signal from downstream blocks.
        assign pipe_intf.stall = mout_intf.stall;
    end
    endgenerate
endmodule

module acl_arb_pipeline_reg #(
    parameter integer DATA_W = 32,              // > 0
    parameter integer BURSTCOUNT_W = 4,         // > 0
    parameter integer ADDRESS_W = 32,           // > 0
    parameter integer BYTEENA_W = DATA_W / 8,   // > 0
    parameter integer ID_W = 1                  // > 0
)
(
    input clock,
    input resetn,

    acl_arb_intf in_intf,
    acl_arb_intf out_intf
);
    acl_arb_data #(
        .DATA_W( DATA_W ),
        .BURSTCOUNT_W( BURSTCOUNT_W ),
        .ADDRESS_W( ADDRESS_W ),
        .BYTEENA_W( BYTEENA_W ),
        .ID_W( ID_W )
    ) 
    pipe_r();

    // Pipeline register.
    always @( posedge clock or negedge resetn ) begin
        if( !resetn ) begin
            pipe_r.req <= 'x;   // only signals reset explicitly below need to be reset at all

            pipe_r.req.request <= 1'b0;
            pipe_r.req.read <= 1'b0;
            pipe_r.req.write <= 1'b0;
        end else if( !(out_intf.stall & pipe_r.req.request) & in_intf.req.enable) begin
            pipe_r.req <= in_intf.req;
        end
    end

    // Request for downstream blocks.
    assign out_intf.req.enable     = in_intf.req.enable    ; //the enable must bypass the register
    assign out_intf.req.request    = pipe_r.req.request    ;
    assign out_intf.req.read       = pipe_r.req.read       ;
    assign out_intf.req.write      = pipe_r.req.write      ;
    assign out_intf.req.writedata  = pipe_r.req.writedata  ;
    assign out_intf.req.burstcount = pipe_r.req.burstcount ;
    assign out_intf.req.address    = pipe_r.req.address    ;
    assign out_intf.req.byteenable = pipe_r.req.byteenable ;
    assign out_intf.req.id         = pipe_r.req.id         ;    

    // Upstream stall signal.
    assign in_intf.stall = out_intf.stall & pipe_r.req.request;
endmodule

module acl_arb_staging_reg #(
    parameter integer DATA_W = 32,              // > 0
    parameter integer BURSTCOUNT_W = 4,         // > 0
    parameter integer ADDRESS_W = 32,           // > 0
    parameter integer BYTEENA_W = DATA_W / 8,   // > 0
    parameter integer ID_W = 1                  // > 0
)
(
    input clock,
    input resetn,

    acl_arb_intf in_intf,
    acl_arb_intf out_intf
);
    logic stall_r;

    acl_arb_data #(
        .DATA_W( DATA_W ),
        .BURSTCOUNT_W( BURSTCOUNT_W ),
        .ADDRESS_W( ADDRESS_W ),
        .BYTEENA_W( BYTEENA_W ),
        .ID_W( ID_W )
    ) 
    staging_r();

    // Staging register.
    always @( posedge clock or negedge resetn )
        if( !resetn )
        begin
            staging_r.req <= 'x;    // only signals reset explicitly below need to be reset at all

            staging_r.req.request <= 1'b0;
            staging_r.req.read <= 1'b0;
            staging_r.req.write <= 1'b0;
        end
        else if( !stall_r )
            staging_r.req <= in_intf.req;

    // Stall register.
    always @( posedge clock or negedge resetn )
        if( !resetn )
            stall_r <= 1'b0;
        else
            stall_r <= out_intf.stall & (stall_r | in_intf.req.request);

    // Request for downstream blocks.
    assign out_intf.req = stall_r ? staging_r.req : in_intf.req;

    // Upstream stall signal.
    assign in_intf.stall = stall_r;
endmodule
