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
    


module acl_enable_sink 
#(
    parameter integer DATA_WIDTH = 32,         
    parameter integer PIPELINE_DEPTH = 32,
    parameter integer SCHEDULEII = 1,

    // these parameters are dependent on the latency of the cluster entry and exit nodes
    // overall latency of this IP
    parameter integer IP_PIPELINE_LATENCY_PLUS1 = 1,

    // to support the 0-latency stall free entry, add one more valid bit
    parameter integer ZERO_LATENCY_OFFSET = 1

)
(
    input  logic clock,
    input  logic resetn,
    input  logic [DATA_WIDTH-1:0] data_in,  
    output logic [DATA_WIDTH-1:0] data_out,
    input  logic input_accepted,
    input  logic valid_in,
    output logic valid_out,
    input  logic stall_in,
    output logic stall_entry,
    output logic enable,
    input  logic inc_pipelined_thread,
    input  logic dec_pipelined_thread
);


    wire throttle_pipelined_iterations;  

    //output of the enable cluster
    assign data_out = data_in;
    assign valid_out = valid_in;
    // if there is no register at the output of this IP than we need to add the valid input to the enable to ensure a capacity of 1
    assign enable = ((IP_PIPELINE_LATENCY_PLUS1 == 1) ? ~valid_out : 1'b0) | ~stall_in;
    assign stall_entry = ~enable | throttle_pipelined_iterations;


    //handle II > 1
    reg[$clog2(SCHEDULEII):0] IIschedcount;
    reg[$clog2(SCHEDULEII):0] threads_count;

    always @(posedge clock or negedge resetn)
    begin
       if (!resetn) begin
          IIschedcount <= 0;
          threads_count <= 0;
       end else if(enable) begin

          // do not increase the counter if a thread is exiting
          // increasing threads_count is already decreasing the window
          // increasing IIschedcount ends up accepting the next thread too early
          IIschedcount <= (input_accepted && dec_pipelined_thread) ? IIschedcount : (IIschedcount == (SCHEDULEII - 1) ? 0 : (IIschedcount + 1));

          if (input_accepted) begin
             threads_count <= threads_count + inc_pipelined_thread - dec_pipelined_thread;
          end

       end
    end 

    // allow threads in a window of the II cycles
    // this prevents the next iteration from entering too early
    assign throttle_pipelined_iterations = (IIschedcount >= (threads_count > 0 ? threads_count : 1));

endmodule

// vim:set filetype=verilog:
