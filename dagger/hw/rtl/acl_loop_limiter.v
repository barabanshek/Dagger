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
    


// This is a n-entry n-exit loop limiter module, n=1, 2, ...
module acl_loop_limiter #(
  parameter ENTRY_WIDTH = 8,// 1 - n    
            EXIT_WIDTH = 8, // 0 - n    
            THRESHOLD = 100,             
            THRESHOLD_NO_DELAY = 0, // Delay from i_valid/stall to o_valid/stall; 
                                    // default is 0, because setting it to 1 will hurt FMAX
                                    // e.g. Assuming at clock cycle n, the internal counter is full (valid_allow=0); i_stall and i_stall_exit both remain 0 
                                    //                               |  THRESHOLD_NO_DELAY = 0  |   THRESHOLD_NO_DELAY = 1                      
                                    //time    i_valid   i_valid_exit |  valid_allow   o_valid   |   valid_allow   o_valid                       
                                    //n       2'b11     2'b01        |  0             2'b00     |   0             2'b01                         
                                    //n+1     2'b11     2'b00        |  1             2'b01     |   0             2'b00     
            PEXIT_WIDTH = (EXIT_WIDTH == 0)? 1 : EXIT_WIDTH // to avoid negative index(modelsim compile error)
)(
  input                        clock,
  input                        resetn,
  input  [ENTRY_WIDTH-1:0]     i_valid,
  input  [ENTRY_WIDTH-1:0]     i_stall,  
  input  [PEXIT_WIDTH-1:0]     i_valid_exit,
  input  [PEXIT_WIDTH-1:0]     i_stall_exit,
  output [ENTRY_WIDTH-1:0]     o_valid,
  output [ENTRY_WIDTH-1:0]     o_stall  
);

localparam  ADD_WIDTH = $clog2(ENTRY_WIDTH + 1);
localparam  SUB_WIDTH = $clog2(PEXIT_WIDTH + 1);
localparam  THRESHOLD_W = $clog2(THRESHOLD + 1);

integer i;
wire [ENTRY_WIDTH-1:0]  inc_bin;
wire [ADD_WIDTH-1:0]    inc_wire [ENTRY_WIDTH]; 
wire [PEXIT_WIDTH-1:0]  dec_bin;
wire [SUB_WIDTH-1:0]    dec_wire [PEXIT_WIDTH];   
wire [ADD_WIDTH-1:0]    inc_value [ENTRY_WIDTH]; 
wire                    decrease_allow; 
wire [THRESHOLD_W:0]    valid_allow_wire;
reg  [THRESHOLD_W-1:0]  counter_next, valid_allow;
wire [ENTRY_WIDTH-1:0]  limit_mask;
wire [ENTRY_WIDTH-1:0]  accept_inc_bin;

assign decrease_allow =  inc_value[ENTRY_WIDTH-1] > dec_wire[PEXIT_WIDTH-1];
assign valid_allow_wire =  valid_allow  +  dec_wire[PEXIT_WIDTH-1] - inc_value[ENTRY_WIDTH-1];

always @(*) begin
  if(decrease_allow) counter_next = valid_allow_wire[THRESHOLD_W]? 0 : valid_allow_wire[THRESHOLD_W-1:0];  
  else counter_next = (valid_allow_wire > THRESHOLD)? THRESHOLD : valid_allow_wire[THRESHOLD_W-1:0];      
end

//valid_allow_temp is used only when THRESHOLD_NO_DELAY = 1
wire  [THRESHOLD_W:0]   valid_allow_temp; 
assign valid_allow_temp = valid_allow + dec_wire[PEXIT_WIDTH-1];

wire  [THRESHOLD_W:0]   valid_allow_check; 
assign valid_allow_check = (THRESHOLD_NO_DELAY? valid_allow_temp : {1'b0,valid_allow} );   
 
genvar z;
generate  
    for(z=0; z<ENTRY_WIDTH; z=z+1) begin : GEN_COMB_ENTRY
      assign inc_bin[z] = ~i_stall[z] & i_valid[z];
      assign inc_wire[z] = (z==0)? i_valid[0] : inc_wire[z-1] + i_valid[z];    
      // set mask bit n to 1 if the sum of (~i_stall[z] & i_valid[z], z=0, 1, ..., n) is smaller or equal to the number of output valid bits allowed.
      assign limit_mask[z] = inc_wire[z] <= (THRESHOLD_NO_DELAY? valid_allow_temp : valid_allow);   
      assign accept_inc_bin[z] = inc_bin[z] & limit_mask[z]; 
      assign inc_value[z] = (z==0)? accept_inc_bin[0] : inc_value[z-1] + accept_inc_bin[z];
      assign o_valid[z] = limit_mask[z] & i_valid[z];
      assign o_stall[z] =  (ENTRY_WIDTH == 1)? (valid_allow_check == 0 | i_stall[z]) : (!o_valid[z] | i_stall[z]);    
    end
    for(z=0; z<PEXIT_WIDTH; z=z+1) begin : GEN_COMB_EXIT
      assign dec_bin[z] = !i_stall_exit[z] & i_valid_exit[z];
      assign dec_wire[z] = (z==0)? dec_bin[0] : dec_wire[z-1] + dec_bin[z];    
    end
endgenerate

// Synchrounous
always @(posedge clock or negedge resetn) begin    
  if(!resetn) begin
    valid_allow <= THRESHOLD;
  end
  else begin      
    // update the internal counter
    valid_allow <= counter_next;    
  end
end   
endmodule
