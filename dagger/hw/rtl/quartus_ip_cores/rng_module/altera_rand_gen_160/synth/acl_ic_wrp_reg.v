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
    


module acl_ic_wrp_reg
(
  input logic clock,
  input logic resetn,

  acl_ic_wrp_intf wrp_in,
  (* dont_merge, altera_attribute = "-name auto_shift_register_recognition OFF" *) acl_ic_wrp_intf wrp_out
);
  always @(posedge clock or negedge resetn)
    if( ~resetn ) begin
      wrp_out.ack <= 1'b0;
      wrp_out.id <= 'x;
    end
    else begin
      wrp_out.ack <= wrp_in.ack;
      wrp_out.id <= wrp_in.id;
    end
endmodule

