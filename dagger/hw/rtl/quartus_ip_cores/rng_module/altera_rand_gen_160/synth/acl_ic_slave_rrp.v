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
    


module acl_ic_slave_rrp #(
    parameter integer DATA_W = 32,              // > 0
    parameter integer BURSTCOUNT_W = 4,         // > 0
    parameter integer ADDRESS_W = 32,           // > 0
    parameter integer BYTEENA_W = DATA_W / 8,   // > 0
    parameter integer ID_W = 1,                 // > 0

    parameter integer NUM_MASTERS = 1,          // > 0

    parameter integer FIFO_DEPTH = 32,          // > 0 (don't care if SLAVE_FIXED_LATENCY > 0)
    parameter integer USE_LL_FIFO = 1,          // 0|1

    parameter integer SLAVE_FIXED_LATENCY = 0,  // 0=not fixed latency, >0=# fixed latency cycles
                                                // if >0 effectively FIFO_DEPTH=SLAVE_FIXED_LATENCY+1
    parameter integer PIPELINE = 1              // 0|1
)
(
    input logic clock,
    input logic resetn,

    acl_arb_intf m_intf,

    input logic s_readdatavalid,
    input logic [DATA_W-1:0] s_readdata,

    acl_ic_rrp_intf rrp_intf,

    output logic stall
);
    typedef struct packed {
        logic valid;
        logic [DATA_W-1:0] data;
    } slave_raw_read;

    slave_raw_read slave_read_in;
    slave_raw_read slave_read;  // this is the slave interface to the rest of the module

    assign slave_read_in = {s_readdatavalid, s_readdata};

    generate
    if( PIPELINE )
    begin
        // Pipeline the return path from the slave.
        slave_raw_read slave_read_pipe;

        always @(posedge clock or negedge resetn)
            if( !resetn )
            begin
                slave_read_pipe <= 'x;
                slave_read_pipe.valid <= 1'b0;
            end
            else begin
                if (m_intf.req.enable) begin
                    slave_read_pipe <= slave_read_in;
                end
            end

        assign slave_read = slave_read_pipe;
    end
    else
    begin
        assign slave_read = slave_read_in;
    end
    endgenerate

    generate
    if( NUM_MASTERS > 1 )
    begin
        localparam READ_FIFO_DEPTH = SLAVE_FIXED_LATENCY > 0 ? SLAVE_FIXED_LATENCY : FIFO_DEPTH;

        typedef struct packed {
            logic [ID_W-1:0] id;
            logic [BURSTCOUNT_W-1:0] burstcount;
        } raw_read_item;

        typedef struct packed {
            logic valid;
            logic [ID_W-1:0] id;
            logic [BURSTCOUNT_W-1:0] burstcount;
        } read_item;

        logic rf_full, rf_empty, rf_read, rf_write, next_read_item;
        raw_read_item m_raw_read_item, rf_raw_read_item;
        read_item rf_read_item, cur_read_item;

        if (READ_FIFO_DEPTH == 1)
        begin
          assign rf_raw_read_item = m_raw_read_item;
        end
        // FIFO of pending reads.
        // Two parts to this FIFO:
        //  1. An actual FIFO (either llfifo or scfifo).
        //  2. cur_read_item is the current pending read
        //
        // Together, there must be at least READ_FIFO_DEPTH
        // entries. Since cur_read_item counts as one,
        // the actual FIFOs are sized to READ_FIFO_DEPTH-1.
        else if( USE_LL_FIFO == 1 )
        begin
            acl_ll_fifo #(
                .WIDTH( $bits(raw_read_item) ),
                .DEPTH( READ_FIFO_DEPTH - 1 )
            )
            read_fifo(
                .clk( clock ),
                .reset( ~resetn ),
                .data_in( m_raw_read_item ),
                .write( rf_write ),
                .data_out( rf_raw_read_item ),
                .read( rf_read ),
                .empty( rf_empty ),
                .full( rf_full )
            ); 
        end
        else
        begin
            scfifo #(
                .lpm_width( $bits(raw_read_item) ),
                .lpm_widthu( $clog2(READ_FIFO_DEPTH-1) ),
                .lpm_numwords( READ_FIFO_DEPTH-1 ),
                .add_ram_output_register( "ON" ),
                .intended_device_family( "stratixiv" )
            )
            read_fifo (
                .aclr( ~resetn ),
                .clock( clock ),
                .empty( rf_empty ),
                .full( rf_full ),
                .data( m_raw_read_item ),
                .q( rf_raw_read_item ),
                .wrreq( rf_write ),
                .rdreq( rf_read ),
                .sclr(),
                .usedw(),
                .almost_full(),
                .almost_empty()
            );
        end

        assign m_raw_read_item.id = m_intf.req.id;
        assign m_raw_read_item.burstcount = m_intf.req.burstcount;

        assign rf_read_item.id = rf_raw_read_item.id;
        assign rf_read_item.burstcount = rf_raw_read_item.burstcount;

        // Place incoming read requests from the master into read FIFO.
        assign rf_write = ~m_intf.stall & m_intf.req.read & m_intf.req.enable;

        // Read next item from the FIFO.
        assign rf_read = ~rf_empty & (~rf_read_item.valid | next_read_item) & m_intf.req.enable;

        // Determine when cur_read_item can be updated, which is controlled by next_read_item.
        assign next_read_item = ~cur_read_item.valid | (slave_read.valid & (cur_read_item.burstcount == 1));

        // Stall upstream when read FIFO is full. If the slave is fixed latency, the read FIFO
        // is sized such that it can never stall.
        assign stall = SLAVE_FIXED_LATENCY > 0 ? 1'b0 : rf_full;

        // cur_read_item
        always @( posedge clock or negedge resetn )
        begin
            if( !resetn )
            begin
                cur_read_item <= 'x;    // only fields explicitly reset below need to be reset at all
                cur_read_item.valid <= 1'b0;
            end
            else
            begin
                if( next_read_item & m_intf.req.enable) begin
                    // Update current read from the read FIFO.
                    cur_read_item <= rf_read_item;
                end else if( slave_read.valid & m_intf.req.enable) begin
                    // Handle incoming data from the slave.
                    cur_read_item.burstcount <= cur_read_item.burstcount - 1;
                end

            end
        end

        // rrp_intf
        assign rrp_intf.datavalid = slave_read.valid;
        assign rrp_intf.data = slave_read.data;
        assign rrp_intf.id = cur_read_item.id;

        if (READ_FIFO_DEPTH == 1) begin
          assign rf_read_item.valid = rf_write;
        end
        // Handle the rf_read_item.valid signal. Different behavior between
        // sc_fifo and acl_ll_fifo.
        else if( USE_LL_FIFO == 1 )
        begin
            // The data is already at the output of the acl_ll_fifo, so the
            // data is valid as long as the FIFO is not empty.
            assign rf_read_item.valid = ~rf_empty;
        end
        else
        begin
            // The data is valid on the next cycle (due to output register on
            // scfifo RAM block).
            always @( posedge clock or negedge resetn )
            begin
                if( !resetn )
                    rf_read_item.valid <= 1'b0;
                else if( rf_read & m_intf.req.enable)
                    rf_read_item.valid <= 1'b1;
                else if( next_read_item & ~rf_read & & m_intf.req.enable)
                    rf_read_item.valid <= 1'b0;
            end
        end
    end
    else // NUM_MASTERS == 1
    begin
        // Only one master so don't need to check the id.
        assign rrp_intf.datavalid = slave_read.valid;
        assign rrp_intf.data = slave_read.data;

        assign stall = 1'b0;
    end
    endgenerate

endmodule
 
