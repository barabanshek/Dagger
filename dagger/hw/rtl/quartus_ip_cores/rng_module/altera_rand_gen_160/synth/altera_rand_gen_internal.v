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
    


/////////////////////////////////////////////////////////////////
// MODULE altera_rand_gen_internal
/////////////////////////////////////////////////////////////////

`include "altera_rand_gen_function_wrapper.v"
`include "acl_stream_fifo.v"

module altera_rand_gen_internal
(
   input logic clock,
   input logic resetn,
   // AVST rand_num
   output logic rand_num_valid,
   input logic rand_num_ready,
   output logic [31:0] rand_num_data,
   input logic start,
   output logic busy,
   output logic done,
   input logic stall
);
   logic avst_local_bb1__rand_num_almost_full;
   logic rand_num_unbuffered_valid;
   logic rand_num_unbuffered_ready;
   logic [31:0] rand_num_unbuffered_data;
   logic lmem_invalid_single_bit;

   // INST altera_rand_gen_internal of altera_rand_gen_function_wrapper
   altera_rand_gen_function_wrapper altera_rand_gen_internal
   (
      .clock(clock),
      .resetn(resetn),
      // AVST avst_local_bb1__rand_num
      .avst_local_bb1__rand_num_valid(rand_num_unbuffered_valid),
      .avst_local_bb1__rand_num_ready(rand_num_unbuffered_ready),
      .avst_local_bb1__rand_num_data(rand_num_unbuffered_data),
      .avst_local_bb1__rand_num_almostfull(avst_local_bb1__rand_num_almost_full),
      .start(start),
      .busy(busy),
      .done(done),
      .stall(stall)
   );

   // INST avst_local_bb1__rand_num_buffer of acl_stream_fifo
   acl_stream_fifo
   #(
      .FIFO_DEPTH(0),
      .DATA_W(32)
   )
   avst_local_bb1__rand_num_buffer
   (
      .clock(clock),
      .resetn(resetn),
      // AVST stream_in
      .stream_in_valid(rand_num_unbuffered_valid),
      .stream_in_ready(rand_num_unbuffered_ready),
      .stream_in_data(rand_num_unbuffered_data),
      // AVST stream_out
      .stream_out_valid(rand_num_valid),
      .stream_out_ready(rand_num_ready),
      .stream_out_data(rand_num_data),
      .almost_full(avst_local_bb1__rand_num_almost_full)
   );

   assign lmem_invalid_single_bit = 'b0;
endmodule

