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
    


/*****************
* Writes a 2-D signal into an In-System Modifiable Memory that can be read out
* over JTAG
*
* After running the design use the accompanying tcl script to generate a .csv
* of the data:
*    quartus_stp -t acl_debug_mem.tcl
*****************/

module acl_debug_mem
#(
  parameter WIDTH=16,          
  parameter SIZE=10 
)
(
  input  logic clk,
  input  logic resetn,

  input  logic             write,
  input  logic [WIDTH-1:0] data[SIZE]
);

  /******************
  * LOCAL PARAMETERS
  *******************/
  localparam ADDRWIDTH=$clog2(SIZE);

  /******************
  * SIGNALS
  *******************/
  logic [ADDRWIDTH-1:0] addr;
  logic do_write;

  /******************
  * ARCHITECTURE
  *******************/

  always@(posedge clk or negedge resetn)
    if (!resetn)
      addr <= {ADDRWIDTH{1'b0}};
    else if (addr != {ADDRWIDTH{1'b0}})
      addr <= addr + 2'b01;
    else if (write)
      addr <= addr + 2'b01;

  assign do_write = write | (addr != {ADDRWIDTH{1'b0}});

  // Instantiate In-System Modifiable Memory
	altsyncram	altsyncram_component (
				.address_a (addr),
				.clock0 (clk),
				.data_a (data[addr]),
				.wren_a (do_write),
				.q_a (),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.intended_device_family = "Stratix IV",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=ACLDEBUGMEM",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = SIZE,
		altsyncram_component.widthad_a = ADDRWIDTH,
		altsyncram_component.width_a = WIDTH,
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.read_during_write_mode_port_a = "DONT_CARE",
		altsyncram_component.width_byteena_a = 1;


endmodule
