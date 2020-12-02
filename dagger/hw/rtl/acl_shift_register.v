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
    


module acl_shift_register(
clock, resetn, clear, enable, Q, D
);
parameter WIDTH=32;
parameter STAGES=1;

input clock,resetn,clear,enable;
input [WIDTH-1:0] D;
output [WIDTH-1:0] Q;
wire clock,resetn,clear,enable;
wire [WIDTH-1:0] D;
reg [WIDTH-1:0] stages[STAGES-1:0];

generate

if (STAGES == 0) begin

assign Q = D;

end
else begin
genvar istage;

for (istage=0;istage<STAGES;istage=istage+1) begin : stages_loop

always@(posedge clock or negedge resetn) begin
  if (!resetn) begin
    stages[istage] <= {(WIDTH){1'b0}};
  end
  else if (clear) begin
    stages[istage] <= {(WIDTH){1'b0}};
  end
  else if (enable) begin
    if (istage == 0) begin
      stages[istage] <= D;
    end
    else begin
      stages[istage] <= stages[istage-1];
    end
  end
end

end

assign Q = stages[STAGES-1];
end

endgenerate

endmodule


// vim:set filetype=verilog:
