// (C) 2001-2016 Altera Corporation. All rights reserved.
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


// (C) 2001-2016 Altera Corporation. All rights reserved.
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


// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/stacker2/stacker2.v#4 $
// $Revision: #4 $
// $Date: 2013/10/31 $
// $Author: jilee $
//-----------------------------------------------------------------------------
`timescale 1ps/1ps
// baeckler - 7-30-2014

module stacker2 #(
	parameter TARGET_CHIP = 5,
	parameter RAM_ADDR = 12,
	parameter RAM_WIDTH = 16,
	parameter PROG_NAME = "stacker2.hex",  // for quartus, intel hex
	parameter INIT_NAME = "stacker2.init", // for sim, vanilla hex
	parameter DEBUG_RAM_W = 1'b0,
	parameter SIM_EMULATE = 1'b0

)(
	input clk,
	input sclr,
	input main_ram_ena,

	input [RAM_WIDTH-1:0] io_rdata,
	output [RAM_WIDTH-1:0] io_wdata,
	output [RAM_ADDR-1:0] io_waddr,
	output io_we
);

wire [RAM_WIDTH-1:0] ram_a_rdata,ram_b_rdata;
reg branch_ena = 1'b1;

wire ram_a_we = 1'b0;
wire [RAM_WIDTH-1:0] ram_a_wdata = {RAM_WIDTH{1'b0}};

reg [RAM_WIDTH-1:0] rs_top = 0 /* synthesis preserve */;

reg [1:0] seq = 2'b0 /* synthesis preserve dont_replicate */;
reg seq_zero = 1'b0;
reg seq_two = 1'b0;
reg seq_three = 1'b0;
always @(posedge clk) begin
	if (sclr) begin
		seq <= 2'b0;
		seq_zero <= 1'b1;
		seq_two <= 1'b0;
		seq_three <= 1'b0;
	end
	else begin
		seq <= seq + 1'b1;
		seq_zero <= (seq == 2'h3);
		seq_two <= (seq == 2'h1);		
		seq_three <= (seq == 2'h2);		
	end	
end 

reg [RAM_WIDTH-1:0] ir = {RAM_WIDTH{1'b0}};
always @(posedge clk) if (seq_two) ir <= ram_a_rdata;

reg [RAM_ADDR-1:0] pc = 0 /* synthesis preserve */;

reg [RAM_ADDR-1:0] pc_plus = 0 /* synthesis preserve */;
always @(posedge clk) begin
	if (seq_zero) pc_plus <= pc + 1'b1;
end

always @(posedge clk) begin
	if (sclr) begin
		pc <= {RAM_ADDR{1'b0}};
	end
	else begin
		if (seq_three) begin
			if ((ir[15:14] == 2'b01) && branch_ena) pc <= ir[RAM_ADDR-1:0];
			else if (ir[15:13] == 3'b001) pc <= rs_top[RAM_ADDR-1:0];
			else pc <= pc_plus;	
		end
	end
end

wire [RAM_ADDR-1:0] ram_a_addr = pc;
wire ram_a_ena = main_ram_ena;

////////////////////////////////////////////////////////
// main memory

wire ram_b_we;
wire [RAM_ADDR-1:0] ram_b_addr;
wire [RAM_WIDTH-1:0] ram_b_wdata;

generate
	if (SIM_EMULATE) begin
		
		// equivalent logic for the main RAM		
		reg [RAM_WIDTH-1:0] rm [0:(1<<RAM_ADDR)-1];
		reg [RAM_ADDR-1:0] rm_addr_a = 0;
		reg [RAM_ADDR-1:0] rm_addr_b = 0;
		reg rm_we_b = 1'b0;
		reg [RAM_WIDTH-1:0] rm_data_b = 0;
		reg [RAM_WIDTH-1:0] rm_q_a = 0;
		reg [RAM_WIDTH-1:0] rm_q_b = 0;
		
		always @(posedge clk) begin
			rm_addr_b <= ram_b_addr;
			rm_we_b <= ram_b_we;
			rm_data_b <= ram_b_wdata;
			rm_q_b <= rm[rm_addr_b];
			if (rm_we_b) rm[rm_addr_b] <= rm_data_b;
						
			if (ram_a_ena) begin
				rm_addr_a <= ram_a_addr;				
				rm_q_a <= rm[rm_addr_a];
			end			
		end		
		
		assign ram_a_rdata = rm_q_a;
		assign ram_b_rdata = rm_q_b;
		
		initial begin
			$display ("Loading program from %s for simulation",INIT_NAME);
			$readmemh (INIT_NAME,rm);
		end
		
	end
	else begin
		altsyncram    altsyncram_component (
			.clock0 (clk),
			.wren_a (ram_a_we),
			.address_b (ram_b_addr),
			.data_b (ram_b_wdata),
			.wren_b (ram_b_we),
			.address_a (ram_a_addr),
			.data_a (ram_a_wdata),
			.q_a (ram_a_rdata),
			.q_b (ram_b_rdata),
			.aclr0 (1'b0),
			.aclr1 (1'b0),
			.addressstall_a (1'b0),
			.addressstall_b (1'b0),
			.byteena_a (1'b1),
			.byteena_b (1'b1),
			.clock1 (clk),
			
			.clocken0 (ram_a_ena),
			.clocken1 (ram_a_ena),
			
			.clocken2 (1'b1),
			.clocken3 (1'b1),
			.eccstatus (),
			.rden_a (1'b1),
			.rden_b (1'b1));
		defparam
			altsyncram_component.address_reg_b = "CLOCK1",
			altsyncram_component.clock_enable_input_a = "NORMAL",
			//altsyncram_component.clock_enable_input_b = "BYPASS",
			altsyncram_component.clock_enable_input_b = "NORMAL",
			
			altsyncram_component.clock_enable_output_a = "NORMAL",
			//altsyncram_component.clock_enable_output_b = "BYPASS",
			altsyncram_component.clock_enable_output_b = "NORMAL",
			
			altsyncram_component.indata_reg_b = "CLOCK1",
			altsyncram_component.init_file = PROG_NAME,
			altsyncram_component.intended_device_family = "Stratix V",
			altsyncram_component.lpm_type = "altsyncram",
			altsyncram_component.numwords_a = 1 << RAM_ADDR,
			altsyncram_component.numwords_b = 1 << RAM_ADDR,
			altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
			altsyncram_component.outdata_aclr_a = "NONE",
			altsyncram_component.outdata_aclr_b = "NONE",
			altsyncram_component.outdata_reg_a = "CLOCK0",
			altsyncram_component.outdata_reg_b = "CLOCK1",
			altsyncram_component.power_up_uninitialized = "FALSE",
			altsyncram_component.ram_block_type = "M20K",
			altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
			altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
			altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
			altsyncram_component.widthad_a = RAM_ADDR,
			altsyncram_component.widthad_b = RAM_ADDR,
			altsyncram_component.width_a = RAM_WIDTH,
			altsyncram_component.width_b = RAM_WIDTH,
			altsyncram_component.width_byteena_a = 1,
			altsyncram_component.width_byteena_b = 1,
			altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";
	end
endgenerate


////////////////////////////////////////////////////////
// return stack memory

reg [RAM_WIDTH-1:0] ds_top = {RAM_WIDTH{1'b0}};

wire rs_push;
wire rs_pop;
wire rs_sclr;
reg [4:0] rsp_w = 5'b0 /* synthesis preserve dont_replicate */;
reg [4:0] rsp_r = 5'b0 /* synthesis preserve dont_replicate */;
wire [RAM_WIDTH-1:0] rs_top_val_w;

generate 
   if (TARGET_CHIP==5) begin // A10
      a10mlab rstk (
        .wclk(clk),
        .wena(rs_push),
        .waddr_reg(rsp_w),
        .wdata_reg(rs_top),
        .raddr(rsp_r),
        .rdata(rs_top_val_w)
      );
      defparam rstk .WIDTH = RAM_WIDTH;
      defparam rstk .ADDR_WIDTH = 5;
      defparam rstk .SIM_EMULATE = SIM_EMULATE;
   end
   else begin // S5
      s5mlab rstk (
        .wclk(clk),
        .wena(rs_push),
        .waddr_reg(rsp_w),
        .wdata_reg(rs_top),
        .raddr(rsp_r),
        .rdata(rs_top_val_w)
      );
      defparam rstk .WIDTH = RAM_WIDTH;
      defparam rstk .ADDR_WIDTH = 5;
      defparam rstk .SIM_EMULATE = SIM_EMULATE;
   end
endgenerate


wire [4:0] rs_wdelta = {5{rs_pop}} | rs_push;
always @(posedge clk) begin
    if (rs_sclr) begin
        rsp_w <= 5'b0;
        rsp_r <= 5'b11111;
    end
    else begin
        rsp_w <= rsp_w + rs_wdelta;
        rsp_r <= rsp_r + rs_wdelta;
    end
end

// return stack top register
wire rs_push_src;
always @(posedge clk) begin
    if (rs_pop) rs_top <= rs_top_val_w;
    else if (rs_push) rs_top <= rs_push_src ? ({RAM_WIDTH{1'b0}} | pc_plus) : ds_top;
end

assign rs_sclr = sclr;
assign rs_push = (seq_three && (ir[15:13] == 3'b011) && branch_ena) ||
				(seq_three && (ir[15:13] == 3'b000) && ir[10]); // rs_push
assign rs_push_src = (seq_three && ir[14]); 				
				
assign rs_pop = (seq_three && (ir[15:13] == 3'b001)) ||
				(seq_three && (ir[15:13] == 3'b000) && ir[9]); // rs_pop
				

////////////////////////////////////////////////////////
// data stack memory 

reg ds_swap = 1'b0;
wire ds_push;
wire ds_pop;
wire ds_sclr = sclr;
reg [4:0] dsp_r = 5'b0 /* synthesis preserve dont_replicate */;
reg [4:0] dsp_w = 5'b0 /* synthesis preserve dont_replicate */;
wire [RAM_WIDTH-1:0] ds_next_val_w;
reg [RAM_WIDTH-1:0] ds_next = {RAM_WIDTH{1'b0}};

generate
   if (TARGET_CHIP==5) begin // A10
      a10mlab dstk (
         .wclk(clk),
         .wena(ds_push),
         .waddr_reg(dsp_w),
         .wdata_reg(ds_next),
         .raddr(dsp_r),
         .rdata(ds_next_val_w)
      );
      defparam dstk .WIDTH = RAM_WIDTH;
      defparam dstk .ADDR_WIDTH = 5;
      defparam dstk .SIM_EMULATE = SIM_EMULATE;
   end
   else begin // S5
      s5mlab dstk (
         .wclk(clk),
         .wena(ds_push),
         .waddr_reg(dsp_w),
         .wdata_reg(ds_next),
         .raddr(dsp_r),
         .rdata(ds_next_val_w)
      );
      defparam dstk .WIDTH = RAM_WIDTH;
      defparam dstk .ADDR_WIDTH = 5;
      defparam dstk .SIM_EMULATE = SIM_EMULATE;
   end
endgenerate


wire [4:0] ds_wdelta = {5{ds_pop}} | ds_push;
always @(posedge clk) begin
    if (ds_sclr) begin
        dsp_w <= 5'b0;
        dsp_r <= 5'b11111;        
    end
    else begin
        dsp_w <= dsp_w + ds_wdelta;
        dsp_r <= dsp_r + ds_wdelta;
    end
end

// data stack next register
always @(posedge clk) begin
    if (ds_pop) ds_next <= ds_next_val_w;
    else if (ds_push || ds_swap) ds_next <= ds_top;
end

// data stack top register
wire [RAM_WIDTH-1:0] ds_top_fn;
always @(posedge clk) begin
    if (ds_pop || ds_swap) ds_top <= ds_next;
    else if (ds_push) ds_top <= ds_top_fn;
end

reg ds_fetch1 = 1'b0;
reg ds_fetch2 = 1'b0;
always @(posedge clk) begin
	ds_fetch1 <= (seq_three && (ir[15:14] == 2'b00) && ir[11]); // fetch
	ds_fetch2 <= ds_fetch1;
end

reg ds_alu1 = 1'b0;
reg ds_alu2 = 1'b0;
always @(posedge clk) begin
	ds_alu1 <= (seq_three && (ir[15:14] == 2'b00) && ir[8]); // alu
	ds_alu2 <= ds_alu1;
end

reg alu_drop = 1'b0;
reg [RAM_WIDTH-1:0] alu_out = 0;
assign ds_top_fn = ds_fetch2 ? ram_b_rdata : 
				ds_alu2 ? alu_out :
				 {1'b0,ir[14:0]};
assign ds_push = (seq_three && ir[15]) || // literal
				ds_fetch2 ||
				(ds_alu2 && !alu_drop);
			
reg ds_pop_again = 1'b0;
always @(posedge clk) begin
	ds_pop_again <= (seq_three && (ir[15:14] == 2'b00) && ir[12]) || // store
				(seq_three && (ir[15:14] == 2'b00) && ir[6]) // alupop_b				
			;
end
				
assign ds_pop = (seq_three && (ir[15:14] == 2'b00) && ir[12]) || // store 
				(seq_three && (ir[15:14] == 2'b00) && ir[11]) || // fetch
				(seq_three && (ir[15:14] == 2'b00) && ir[7]) || // alupop_a
				ds_pop_again
				;

assign ram_b_we = seq_three && (ir[15:14] == 2'b00) && ir[12] && !ds_top[15] && !ds_top[14]; // store
assign ram_b_addr = ds_top[RAM_ADDR-1:0];
assign ram_b_wdata = ds_next;
assign io_wdata = ram_b_wdata;
assign io_waddr = ram_b_addr;
assign io_we = seq_three && (ir[15:14] == 2'b00) && ir[12] && (ds_top[15] || ds_top[14]);


////////////////////////////////////////////////////////
// ALU

reg [RAM_WIDTH-1:0] alu0 = 0;
reg [RAM_WIDTH-1:0] alu1 = 0;
reg alu2 = 0;

reg [1:0] alu_op_r = 2'b0;
wire [5:0] alu_op = {alu_op_r,ir[3:0]};

reg [RAM_WIDTH-1:0] logic_ops /* synthesis keep */;
always @(*) begin
	case (alu_op[1:0]) 
		2'b00 : logic_ops = ds_top ^ ds_next;
		2'b01 : logic_ops = ds_top & ds_next;
		2'b10 : logic_ops = ds_top | ds_next;
		2'b11 : logic_ops = ~ds_top;
	endcase
end
	
reg [RAM_WIDTH-1:0] shift_ops /* synthesis keep */;
always @(*) begin
	case (alu_op[1:0]) 
		2'b00 : shift_ops = {ds_top[0],ds_top[15:1]};
		2'b01 : shift_ops = {ds_top[14:0],ds_top[15]};
		2'b10 : shift_ops = {1'b0,ds_top[15:1]};
		2'b11 : shift_ops = {ds_top[14:0],1'b0};
	endcase
end

reg [RAM_WIDTH-1:0] byte_ops /* synthesis keep */;
always @(*) begin
	case (alu_op[1:0]) 
		2'b00 : byte_ops = {ds_top[7:0],ds_top[15:8]};
		2'b01 : byte_ops = {ds_next[7:0],ds_top[7:0]};
		2'b10 : byte_ops = {8'b0,ds_top[15:8]};
		2'b11 : byte_ops = {ds_top[7:0],8'b0};
	endcase
end

reg [RAM_WIDTH-1:0] src_ops /* synthesis keep */;
always @(*) begin
	case (alu_op[1:0]) 
		2'b00 : src_ops = ds_top;
		2'b01 : src_ops = ds_next;
		2'b10 : src_ops = rs_top;
		2'b11 : src_ops = io_rdata;
	endcase
end

reg [2:0] alu_lo_r;
always @(posedge clk) begin
	if (seq_three) alu_op_r <= ir[5:4];		
	if (seq_three) alu_lo_r <= ir[2:0];		
	
	case (alu_op[3:2])
		2'b00 : alu0 <= logic_ops;
		2'b01 : alu0 <= shift_ops;
		2'b10 : alu0 <= byte_ops;
		2'b11 : alu0 <= src_ops;
	endcase

	alu1 <= ({16{alu_op[0]}} ^ ds_top[15:0]) + ds_next[15:0] + alu_op[0];
	
	alu2 <= |ds_top;
	
	case (alu_op[5:4])
		2'b00 : alu_out <= alu0;
		2'b01 : alu_out <= alu1;
		2'b10 : alu_out <= {16{alu2 ^ alu_lo_r[0]}};
		2'b11 : alu_out <= {16{alu1[15]}};			
	endcase
end

always @(posedge clk) begin
	if (seq_three) branch_ena <= 1'b1;
	if (seq_three) alu_drop <= 1'b0;
	ds_swap <= 1'b0;
	
	if ((alu_op[5:4] == 2'b10) && (alu_lo_r[1]) && ds_alu1) begin
		// conditional branch
		branch_ena <= alu2 ^ alu_lo_r[0];
		alu_drop <= 1'b1;
	end
	
	if ((alu_op[5:4] == 2'b10) && (alu_lo_r[2]) && ds_alu1) begin
		if (!ds_pop_again) ds_swap <= 1'b1;
		alu_drop <= 1'b1;
	end	
end

// synthesis translate_off
generate
if (DEBUG_RAM_W) begin
	always @(posedge clk) begin
		if (ram_b_we && ram_b_addr != 12'h146) $display ("writing %x to RAM %x at time %d",
			ram_b_wdata,
			ram_b_addr,$time);
	end
end
endgenerate
// synthesis translate_on


endmodule



// BENCHMARK INFO :  10AX115R3F40I2SGES
// BENCHMARK INFO :  Quartus II 64-Bit Version 14.0a10s.0 Build 530 07/17/2014 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  stacker2.v
// BENCHMARK INFO :  Uses helper file :  alt_a10mlab.v
// BENCHMARK INFO :  Total registers : 175
// BENCHMARK INFO :  Total pins : 14
// BENCHMARK INFO :  Total virtual pins : 33
// BENCHMARK INFO :  Total block memory bits : 65,536
// BENCHMARK INFO :  Comb ALUTs :  228                 
// BENCHMARK INFO :  ALMs : 189 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.077 ns, From ds_top[5], To io_waddr[5]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.177 ns, From ds_top[8], To io_waddr[8]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.122 ns, From ds_top[0], To io_waddr[0]}

