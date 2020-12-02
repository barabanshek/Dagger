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
    


module acl_multistage_accumulator(clock, resetn, clear, result, increment, go);
  // This module tessellates the accumulator into SECTION_SIZE-bit chunks.
  // it is important to note that this accumulator has been designed to work with kernel finish detector,
  // and as such the increment signal is not pipelined. This means that you cannot simply use it for arbitrary purposes.
  // To make it work as a pipelined accumulator, INCREMENT_WIDTH must be no greater than SECTION_SIZE. In a case that it is,
  // pipelining of the increment signal should be added. However, in kernel finish detector it is unnecessary.
  //
  // Assumption 1 - increment does not change until the final result is computed or INCREMENT_WIDTH < SECTION_SIZE. In the
  //                latter case, increment only needs to be valid for one clock cycle.
  // Assumption 2 - clear and go are never asserted at the same time.
  parameter ACCUMULATOR_WIDTH = 96;
  parameter INCREMENT_WIDTH = 1; 
  parameter SECTION_SIZE = 19;
  input clock, resetn, clear;
  input [INCREMENT_WIDTH-1:0] increment;
  input go;
  output [ACCUMULATOR_WIDTH-1:0] result;
  
  function integer stage_count;
    input integer width;
    input integer size;
    integer temp,i;
    begin
      temp = width/size;
      if ((width % size) > 0) temp = temp+1;
      stage_count = temp;
    end
  endfunction
  
  function integer mymax;
    input integer a;
    input integer b;
    integer temp;
    begin
      if (a > b) temp = a; else temp = b;
      mymax = temp;
    end
  endfunction  

  localparam TOTAL_STAGES = stage_count(ACCUMULATOR_WIDTH, SECTION_SIZE);
  localparam INCR_FILL = mymax(ACCUMULATOR_WIDTH, TOTAL_STAGES*SECTION_SIZE);
  
  // This little trick is for modelsim to resolve its handling of generate statements.
  // It prevents modelsim from thinking there is an out-of-bound access to increment.
  // This also simplifies one of the if statements below.
  reg [INCR_FILL-1:0] increment_ext;
  initial
  begin
    increment_ext = {{INCR_FILL}{1'b0}};
  end
  
  always@(*)
  begin
    increment_ext = {{INCR_FILL}{1'b0}};
    increment_ext[INCREMENT_WIDTH-1:0] = increment;
  end
  
  reg [TOTAL_STAGES-1 : -1] pipelined_go;  
  reg [SECTION_SIZE:0] stages [TOTAL_STAGES-1 : -1];
  reg [TOTAL_STAGES-1 : -1] pipelined_dispatch;
  reg [ACCUMULATOR_WIDTH-1:0] pipelined_data [TOTAL_STAGES-1 : 0];  
  integer j;
  initial
  begin
    pipelined_go = {{TOTAL_STAGES+1}{1'b0}};
    for (j=-1; j < TOTAL_STAGES; j = j + 1)
      stages[j] = {{SECTION_SIZE}{1'b0}};
  end
      
  always@(*)
  begin
    pipelined_go[-1] = go;
    stages[-1] = {{SECTION_SIZE}{1'b0}};
  end
  
  genvar i;
  generate
    for (i = 0; i < TOTAL_STAGES; i = i + 1)
    begin: ndr_stage
      always@(posedge clock or negedge resetn)
      begin
        if( ~resetn )
          pipelined_go[i] <= 1'b0;
        else if( clear )  
          pipelined_go[i] <= 1'b0;
        else
          pipelined_go[i] <= pipelined_go[i-1];
      end
      
      always@(posedge clock or negedge resetn)
      begin
        if( ~resetn )
          stages[i] <= {{SECTION_SIZE}{1'bx}};
        else if( clear )  
          stages[i] <= {{SECTION_SIZE}{1'b0}};
        else if( pipelined_go[i-1] )
        begin
          if (i*SECTION_SIZE < INCREMENT_WIDTH)
          begin
            // Note that even when (i+1)*SECTION_SIZE-1 > INCREMENT_WIDTH, the increment_ext is extended with 0s,
            // so it does not impact addition. But this does make Modelsim happy.
            stages[i] <= stages[i][SECTION_SIZE-1:0] + increment_ext[(i+1)*SECTION_SIZE-1:i*SECTION_SIZE] + stages[i-1][SECTION_SIZE];
          end
          else
          begin
            stages[i] <= stages[i][SECTION_SIZE-1:0] + stages[i-1][SECTION_SIZE];
          end
        end
      end
     
      always@(posedge clock or negedge resetn)
      begin
        if( ~resetn )
          pipelined_data[i] <= {{ACCUMULATOR_WIDTH}{1'bx}};
        else if( clear )  
          pipelined_data[i] <= {{ACCUMULATOR_WIDTH}{1'b0}};
        else if( pipelined_go[i-1] )
        begin
          pipelined_data[i] <= {{ACCUMULATOR_WIDTH}{1'b0}};
          if (i==1)
            pipelined_data[i] <= stages[i-1];
          else if (i > 1)
          begin
            // Sadly Modelsim is kind of stupid here and for i=0 it actually evaluates the 
            // expressions here and finds that (i-1)*SECTION_SIZE - 1 = -SECTION_SIZE - 1 and thinks
            // the indexing to pipelined_data[i-1] happens in opposite direction to the one declared.
            // Quartus is smart enough to figure out that is not the case though, so the synthesized circuit
            // is not affected. To fix this, I am putting a max((i-1)*SECTION_SIZE - 1,0) so that
            // in the cases this statement is irrelevant, the access range for the bus is in the proper direction.
            pipelined_data[i] <= {stages[i-1], pipelined_data[i-1][mymax((i-1)*SECTION_SIZE - 1,0):0]};
          end
        end
      end      
    end
  endgenerate  
  
  generate
    if (TOTAL_STAGES == 1)
      assign result = stages[TOTAL_STAGES-1];
   else
      assign result = {stages[TOTAL_STAGES-1], pipelined_data[TOTAL_STAGES-1][(TOTAL_STAGES-1)*SECTION_SIZE-1:0]};
  endgenerate
endmodule
