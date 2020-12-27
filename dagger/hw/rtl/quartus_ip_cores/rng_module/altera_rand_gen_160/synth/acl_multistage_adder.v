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
    


module acl_multistage_adder(clock, resetn, clear, enable, result, dataa, datab, add_sub);
  // This module tessellates the accumulator into SECTION_SIZE-bit chunks.
  parameter WIDTH = 32;
  parameter SECTION_SIZE = 19;
  input clock, resetn, clear, add_sub, enable;
  input [WIDTH-1:0] dataa;
  input [WIDTH-1:0] datab;
  output [WIDTH-1:0] result;
  
  wire [WIDTH-1:0] dataa_inter;
  wire [WIDTH-1:0] datab_inter;
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

  function integer mymin;
    input integer a;
    input integer b;
    integer temp;
    begin
      if (a < b) temp = a; else temp = b;
      mymin = temp;
    end
  endfunction   

  localparam TOTAL_STAGES = stage_count(WIDTH, SECTION_SIZE);
  
  assign dataa_inter = dataa;
  assign datab_inter = datab;
  
  // This little trick is for modelsim to resolve its handling of generate statements.
  // It prevents modelsim from thinking there is an out-of-bound access.
  // This also simplifies one of the if statements below.
  reg [TOTAL_STAGES-1 : -1] pipelined_add_sub;  
  reg [TOTAL_STAGES-1 : -1] pipelined_carry;  
  reg [WIDTH-1 : 0] pipelined_datab [TOTAL_STAGES-1 : -1];
  reg [WIDTH-1 : 0] pipelined_result [TOTAL_STAGES-1 : -1];
  
  genvar i;
  generate
    for (i = 0; i < TOTAL_STAGES; i = i + 1)
    begin: add_sub_stage
      always@(posedge clock or negedge resetn)
      begin
        if( ~resetn )
        begin
          pipelined_add_sub[i] <= 1'b0;
          pipelined_datab[i] <= {{WIDTH}{1'b0}};
        end
        else if (enable)
        begin
          if( clear )  
          begin
            pipelined_add_sub[i] <= 1'b0;
            pipelined_datab[i] <= {{WIDTH}{1'b0}};
          end
          else
          begin
            if ( i == 0) begin
            pipelined_add_sub[i] <= add_sub;
            pipelined_datab[i] <= datab_inter;
            end
            else begin
            pipelined_add_sub[i] <= pipelined_add_sub[i-1];
            pipelined_datab[i] <= pipelined_datab[i-1];       
        end
          end
        end
      end
      
      always@(posedge clock or negedge resetn)
      begin
        if( ~resetn )
        begin
          pipelined_result[i] <= {{WIDTH}{1'b0}};
          pipelined_carry[i] <= 1'b0;
        end
        else if (enable)
        begin
          if( clear )  
          begin
            pipelined_result[i] <= {{WIDTH}{1'b0}};
            pipelined_carry[i] <= 1'b0;
          end
          else
          begin
            if (i > 0)
            begin
              pipelined_result[i][mymax(SECTION_SIZE*i - 1,0):0] <= pipelined_result[i-1][mymax(SECTION_SIZE*i - 1,0):0];
            end

            if ( i == 0 ) begin
            {pipelined_carry[i], pipelined_result[i][mymin(SECTION_SIZE*(i+1), WIDTH) - 1 : SECTION_SIZE*i]} <=
               dataa_inter[mymin(SECTION_SIZE*(i+1), WIDTH) - 1 : SECTION_SIZE*i] + 
               (datab_inter[mymin(SECTION_SIZE*(i+1), WIDTH) - 1 : SECTION_SIZE*i] ^ {{SECTION_SIZE}{add_sub}})
               + add_sub;
            if (SECTION_SIZE*(i+1) < WIDTH)
            begin
              pipelined_result[i][WIDTH-1: mymin(SECTION_SIZE*(i+1), WIDTH-1)] <= dataa_inter[WIDTH-1: mymin(SECTION_SIZE*(i+1), WIDTH-1)];
            end
            end else begin
            {pipelined_carry[i], pipelined_result[i][mymin(SECTION_SIZE*(i+1), WIDTH) - 1 : SECTION_SIZE*i]} <=
               pipelined_result[i-1][mymin(SECTION_SIZE*(i+1), WIDTH) - 1 : SECTION_SIZE*i] + 
               (pipelined_datab[i-1][mymin(SECTION_SIZE*(i+1), WIDTH) - 1 : SECTION_SIZE*i] ^ {{SECTION_SIZE}{pipelined_add_sub[i-1]}})
               + pipelined_carry[i-1];
            if (SECTION_SIZE*(i+1) < WIDTH)
            begin
              pipelined_result[i][WIDTH-1: mymin(SECTION_SIZE*(i+1), WIDTH-1)] <= pipelined_result[i-1][WIDTH-1: mymin(SECTION_SIZE*(i+1), WIDTH-1)];
            end
        end
          end
        end
      end
    end
  endgenerate  
  
  assign result = pipelined_result[TOTAL_STAGES-1];

endmodule


// vim:set filetype=verilog:
