
// DESCRIPTION
// 
// This is the small flavor of the standard NIOS processor modified slightly to make it easier to use for state
// machine replacement. The RAMs are small and internal to make it easy to use without an SOPC builder
// system. All of the boilerplate C library is removed to conserve memory. The compile and link is
// operating through a little shell script instead of the Eclipse environment. If that sounds unpleasant, no
// harm no foul, please go back to the full Altera NIOS environment. If the new way sounds easier to
// understand that's what the intent was.
// 
// The 16 bit address space is hardwired as follows -
// 
//  0x0000 : program memory (read only)
//  0x4000 : scratch memory (read/write)
//  0x8000 : external mapped registers
// 
// The lower two bits are byte positions, RAM address lines refer to 32 bit words.
//
//register purpose
// r0 : zero
// r1 : assembler temp
// r2 : return value
// r3 : return value
// r4 : arguments
// r5 : arguments
// r6 : arguments
// r7 : arguments
// r8-r15 : caller save general
// r16-r23 : callee save general
// r24 : exception temp
// r25 : break temp
// r26 : global pointer
// r27 : sp
// r28 : fp
// r29 : exception return address
// r31 : return address

// 

module alt_nios2_smg #(
	parameter ADDR_WIDTH = 16, // processor address bus width

	parameter PROG_MEM_INIT = "nios2_smg_iram.hex",
	parameter PROG_MEM_ADDR_WIDTH = 10,
	parameter SCRATCH_MEM_INIT = "nios2_smg_dram.hex",
	parameter SCRATCH_MEM_ADDR_WIDTH = 9,		
	parameter REGFILE_INIT = "nios2_smg_regfile.hex",

	parameter REG_PWE = 1'b0,  // is it OK to assume prg_addr and prg_data hold
								// after write pulse?
								
	// simulation debug messages
	parameter DEBUG_REGFILE = 1'b0,	// write activity to the register file
	parameter DEBUG_SCRATCH = 1'b0	// write activity to the scratch data ram
)(
	input            clk,
	input            sclr_n,

	// external bus
	output  [ADDR_WIDTH-1:0] ext_address,
	output  ext_read,
	output  ext_write,
	output  [31:0] ext_writedata,
	input  [31:0] ext_readdata,

	// back door program load port
	input [15:0] prg_addr,
	input [31:0] prg_din,
	input prg_wr,

	output illegal_opcode
);

reg sclr_common = 1'b0 /* synthesis preserve */;
always @(posedge clk) sclr_common <= !sclr_n;

reg sclr_esrc = 1'b0 /* synthesis preserve */;
always @(posedge clk) sclr_esrc <= !sclr_n;


// data / IO bus (internal and external)
wire  [ ADDR_WIDTH-1: 0] d_address;
reg  [  3: 0] d_byteenable;
reg           d_read;
reg           d_write;
reg  [ 31: 0] d_writedata;
wire  [ 31: 0] d_readdata;
wire           d_waitrequest;

// instruction memory bus (internal)
wire  [ ADDR_WIDTH-1: 0] i_address;
reg             i_read;
wire   [ 31: 0] i_readdata;
wire            i_waitrequest; 

wire    [  1: 0] D_compare_op;
wire             D_ctrl_alu_force_xor;
wire             D_ctrl_alu_signed_comparison;
wire             D_ctrl_alu_subtract;
wire             D_ctrl_b_is_dst;
wire             D_ctrl_br;
wire             D_ctrl_br_cmp;
wire             D_ctrl_force_src2_zero;
wire             D_ctrl_hi_imm16;
wire             D_ctrl_ignore_dst;
wire             D_ctrl_implicit_dst_retaddr;
wire             D_ctrl_jmp_direct;
wire             D_ctrl_ld;
wire             D_ctrl_ld_signed;
wire             D_ctrl_logic;
wire             D_ctrl_retaddr;
wire             D_ctrl_rot_right;
wire             D_ctrl_shift_logical;
wire             D_ctrl_shift_rot;
wire             D_ctrl_shift_rot_right;
wire             D_ctrl_src2_choose_imm;
wire             D_ctrl_st;
wire             D_ctrl_uncond_cti_non_br;
wire             D_ctrl_unsigned_lo_imm16;
wire    [  4: 0] D_dst_regnum;
reg     [ 31: 0] D_iw;
wire    [  4: 0] D_iw_a;
wire    [  4: 0] D_iw_b;
wire    [  4: 0] D_iw_c;
wire    [ 15: 0] D_iw_imm16;
wire    [  1: 0] D_iw_memsz;
wire    [  5: 0] D_iw_op;
wire    [  5: 0] D_iw_opx;

wire    [  ADDR_WIDTH-3: 0] D_jmp_direct_target_waddr;
wire    [  1: 0] D_logic_op;
wire    [  1: 0] D_logic_op_raw;
wire             D_mem16;
wire             D_mem32;
wire             D_mem8;
reg              D_valid;
wire             D_wr_dst_reg;
reg              E_alu_sub;
wire    [ 32: 0] E_arith_result ;
wire    [ 31: 0] E_arith_src1;
wire    [ 31: 0] E_arith_src2;
wire             E_eq;
reg              E_invert_arith_src_msb;
wire             E_ld_stall;
wire    [ 31: 0] E_logic_result /* synthesis keep */;
wire             E_logic_result_is_0;
wire             E_lt;
wire    [ ADDR_WIDTH-1: 0] E_mem_baddr;
wire    [  3: 0] E_mem_byte_en;
reg              E_new_inst;
reg     [  4: 0] E_shift_rot_cnt;
wire    [  4: 0] E_shift_rot_cnt_nxt;
wire             E_shift_rot_done;
wire             E_shift_rot_fill_bit;
reg     [ 31: 0] E_shift_rot_result;
wire    [ 31: 0] E_shift_rot_result_nxt;
wire             E_shift_rot_stall;
reg     [ 31: 0] E_src1;
reg     [ 31: 0] E_src2;
wire    [ 31: 0] E_st_data;
wire             E_st_stall;
wire             E_stall;
reg              E_valid;
wire    [ 31: 0] F_iw;
reg     [  ADDR_WIDTH-3: 0] F_pc;
wire             F_pc_en;
wire    [  ADDR_WIDTH-3: 0] F_pc_nxt;
wire    [  ADDR_WIDTH-3: 0] F_pc_plus_one;
wire    [  1: 0] F_pc_sel_nxt;
wire             F_valid;
reg     [  1: 0] R_compare_op;
reg              R_ctrl_br;
reg              R_ctrl_br_cmp;
wire             R_ctrl_br_cmp_nxt;
wire             R_ctrl_br_nxt;
reg              R_ctrl_force_src2_zero;
wire             R_ctrl_force_src2_zero_nxt;
reg              R_ctrl_hi_imm16;
wire             R_ctrl_hi_imm16_nxt;
reg              R_ctrl_jmp_direct;
wire             R_ctrl_jmp_direct_nxt;
reg              R_ctrl_ld;
wire             R_ctrl_ld_nxt;
reg              R_ctrl_ld_signed;
wire             R_ctrl_ld_signed_nxt;
reg              R_ctrl_logic;
wire             R_ctrl_logic_nxt;
reg              R_ctrl_retaddr;
wire             R_ctrl_retaddr_nxt;
reg              R_ctrl_rot_right;
wire             R_ctrl_rot_right_nxt;
reg              R_ctrl_shift_logical;
wire             R_ctrl_shift_logical_nxt;
reg              R_ctrl_shift_rot;
wire             R_ctrl_shift_rot_nxt;
reg              R_ctrl_shift_rot_right;
wire             R_ctrl_shift_rot_right_nxt;
reg              R_ctrl_st;
wire             R_ctrl_st_nxt;
reg              R_ctrl_uncond_cti_non_br;
wire             R_ctrl_uncond_cti_non_br_nxt;
reg              R_ctrl_unsigned_lo_imm16;
wire             R_ctrl_unsigned_lo_imm16_nxt;
reg     [  4: 0] R_dst_regnum;
wire             R_en;
reg     [  1: 0] R_logic_op;
wire    [ 31: 0] R_rf_a;
wire    [ 31: 0] R_rf_b;
wire    [ 31: 0] R_src1;
wire    [ 31: 0] R_src2;
wire    [ 15: 0] R_src2_hi;
wire    [ 15: 0] R_src2_lo;
reg              R_src2_use_imm;
wire    [  7: 0] R_stb_data;
wire    [ 15: 0] R_sth_data;
reg              R_valid;
reg              R_wr_dst_reg;
wire     [ 31: 0] W_alu_result;
wire             W_br_taken;

wire              W_cmp_result;

wire    [ ADDR_WIDTH-1: 0] W_mem_baddr;
wire    [ 31: 0] W_rf_wr_data;
wire             W_rf_wren;
reg              W_valid;
wire    [ 31: 0] W_wr_data;
wire             av_fill_bit;
reg     [  1: 0] av_ld_align_cycle;
wire    [  1: 0] av_ld_align_cycle_nxt;
wire             av_ld_align_one_more_cycle;
reg              av_ld_aligning_data;
wire             av_ld_aligning_data_nxt;
reg     [  7: 0] av_ld_byte0_data;
wire    [  7: 0] av_ld_byte0_data_nxt;
reg     [  7: 0] av_ld_byte1_data;
wire             av_ld_byte1_data_en;
wire    [  7: 0] av_ld_byte1_data_nxt;
reg     [  7: 0] av_ld_byte2_data;
wire    [  7: 0] av_ld_byte2_data_nxt;
reg     [  7: 0] av_ld_byte3_data;
wire    [  7: 0] av_ld_byte3_data_nxt;
wire    [ 31: 0] av_ld_data_aligned_filtered;
wire    [ 31: 0] av_ld_data_aligned_unfiltered;
wire             av_ld_done;
wire             av_ld_extend;
wire             av_ld_getting_data;
wire             av_ld_rshift8;
reg              av_ld_waiting_for_data;
wire             av_ld_waiting_for_data_nxt;
wire             av_sign_bit;
wire             d_read_nxt;
wire             d_write_nxt;

wire             i_read_nxt;

always @(posedge clk) begin
    if (sclr_common)     d_write <= 0;
    else   d_write <= d_write_nxt;
end

assign av_ld_data_aligned_filtered = av_ld_data_aligned_unfiltered;

assign D_iw_a = D_iw[31 : 27];
assign D_iw_b = D_iw[26 : 22];
assign D_iw_c = D_iw[21 : 17];
assign D_iw_opx = D_iw[16 : 11];
assign D_iw_op = D_iw[5 : 0];
assign D_iw_imm16 = D_iw[21 : 6];
assign D_iw_memsz = D_iw[4 : 3];
assign D_mem8 = D_iw_memsz == 2'b00;
assign D_mem16 = D_iw_memsz == 2'b01;
assign D_mem32 = D_iw_memsz[1] == 1'b1;

wire D_op_call = D_iw_op == 0;
wire D_op_jmpi = D_iw_op == 1;
wire D_op_ldbu = D_iw_op == 3;
wire D_op_addi = D_iw_op == 4;
wire D_op_stb = D_iw_op == 5;
wire D_op_br = D_iw_op == 6;
wire D_op_ldb = D_iw_op == 7;
wire D_op_cmpgei = D_iw_op == 8;
wire D_op_ldhu = D_iw_op == 11;
wire D_op_andi = D_iw_op == 12;
wire D_op_sth = D_iw_op == 13;
wire D_op_bge = D_iw_op == 14;
wire D_op_ldh = D_iw_op == 15;
wire D_op_cmplti = D_iw_op == 16;
wire D_op_initda = D_iw_op == 19;
wire D_op_ori = D_iw_op == 20;
wire D_op_stw = D_iw_op == 21;
wire D_op_blt = D_iw_op == 22;
wire D_op_ldw = D_iw_op == 23;
wire D_op_cmpnei = D_iw_op == 24;
wire D_op_flushda = D_iw_op == 27;
wire D_op_xori = D_iw_op == 28;
wire D_op_stc = D_iw_op == 29;
wire D_op_bne = D_iw_op == 30;
wire D_op_ldl = D_iw_op == 31;
wire D_op_cmpeqi = D_iw_op == 32;
wire D_op_ldbuio = D_iw_op == 35;
wire D_op_muli = D_iw_op == 36;
wire D_op_stbio = D_iw_op == 37;
wire D_op_beq = D_iw_op == 38;
wire D_op_ldbio = D_iw_op == 39;
wire D_op_cmpgeui = D_iw_op == 40;
wire D_op_ldhuio = D_iw_op == 43;
wire D_op_andhi = D_iw_op == 44;
wire D_op_sthio = D_iw_op == 45;
wire D_op_bgeu = D_iw_op == 46;
wire D_op_ldhio = D_iw_op == 47;
wire D_op_cmpltui = D_iw_op == 48;
wire D_op_initd = D_iw_op == 51;
wire D_op_orhi = D_iw_op == 52;
wire D_op_stwio = D_iw_op == 53;
wire D_op_bltu = D_iw_op == 54;
wire D_op_ldwio = D_iw_op == 55;
wire D_op_rdprs = D_iw_op == 56;
wire D_op_flushd = D_iw_op == 59;
wire D_op_xorhi = D_iw_op == 60;
wire D_op_rsv02 = D_iw_op == 2;
wire D_op_rsv09 = D_iw_op == 9;
wire D_op_rsv10 = D_iw_op == 10;
wire D_op_rsv17 = D_iw_op == 17;
wire D_op_rsv25 = D_iw_op == 25;
wire D_op_rsv33 = D_iw_op == 33;
wire D_op_rsv34 = D_iw_op == 34;
wire D_op_rsv41 = D_iw_op == 41;
wire D_op_rsv42 = D_iw_op == 42;
wire D_op_rsv49 = D_iw_op == 49;
wire D_op_rsv57 = D_iw_op == 57;
wire D_op_rsv61 = D_iw_op == 61;
wire D_op_rsv62 = D_iw_op == 62;
wire D_op_rsv63 = D_iw_op == 63;

wire D_op_opx = D_iw_op == 58;

wire D_op_eret = D_op_opx & (D_iw_opx == 1);
wire D_op_roli = D_op_opx & (D_iw_opx == 2);
wire D_op_rol = D_op_opx & (D_iw_opx == 3);
wire D_op_ret = D_op_opx & (D_iw_opx == 5);
wire D_op_nor = D_op_opx & (D_iw_opx == 6);
wire D_op_mulxuu = D_op_opx & (D_iw_opx == 7);
wire D_op_cmpge = D_op_opx & (D_iw_opx == 8);
wire D_op_bret = D_op_opx & (D_iw_opx == 9);
wire D_op_ror = D_op_opx & (D_iw_opx == 11);
wire D_op_jmp = D_op_opx & (D_iw_opx == 13);
wire D_op_and = D_op_opx & (D_iw_opx == 14);
wire D_op_cmplt = D_op_opx & (D_iw_opx == 16);
wire D_op_slli = D_op_opx & (D_iw_opx == 18);
wire D_op_sll = D_op_opx & (D_iw_opx == 19);
wire D_op_or = D_op_opx & (D_iw_opx == 22);
wire D_op_mulxsu = D_op_opx & (D_iw_opx == 23);
wire D_op_cmpne = D_op_opx & (D_iw_opx == 24);
wire D_op_srli = D_op_opx & (D_iw_opx == 26);
wire D_op_srl = D_op_opx & (D_iw_opx == 27);
wire D_op_nextpc = D_op_opx & (D_iw_opx == 28);
wire D_op_callr = D_op_opx & (D_iw_opx == 29);
wire D_op_xor = D_op_opx & (D_iw_opx == 30);
wire D_op_mulxss = D_op_opx & (D_iw_opx == 31);
wire D_op_cmpeq = D_op_opx & (D_iw_opx == 32);
wire D_op_divu = D_op_opx & (D_iw_opx == 36);
wire D_op_div = D_op_opx & (D_iw_opx == 37);
wire D_op_rdctl = D_op_opx & (D_iw_opx == 38);
wire D_op_mul = D_op_opx & (D_iw_opx == 39);
wire D_op_cmpgeu = D_op_opx & (D_iw_opx == 40);
wire D_op_trap = D_op_opx & (D_iw_opx == 45);
wire D_op_wrctl = D_op_opx & (D_iw_opx == 46);
wire D_op_cmpltu = D_op_opx & (D_iw_opx == 48);
wire D_op_break = D_op_opx & (D_iw_opx == 52);
wire D_op_hbreak = D_op_opx & (D_iw_opx == 53);
wire D_op_sub = D_op_opx & (D_iw_opx == 57);
wire D_op_srai = D_op_opx & (D_iw_opx == 58);
wire D_op_sra = D_op_opx & (D_iw_opx == 59);
wire D_op_intr = D_op_opx & (D_iw_opx == 61);
wire D_op_crst = D_op_opx & (D_iw_opx == 62);
wire D_op_rsvx00 = D_op_opx & (D_iw_opx == 0);
wire D_op_rsvx10 = D_op_opx & (D_iw_opx == 10);
wire D_op_rsvx17 = D_op_opx & (D_iw_opx == 17);
wire D_op_rsvx21 = D_op_opx & (D_iw_opx == 21);
wire D_op_rsvx25 = D_op_opx & (D_iw_opx == 25);
wire D_op_rsvx34 = D_op_opx & (D_iw_opx == 34);
wire D_op_rsvx35 = D_op_opx & (D_iw_opx == 35);
wire D_op_rsvx42 = D_op_opx & (D_iw_opx == 42);
wire D_op_rsvx43 = D_op_opx & (D_iw_opx == 43);
wire D_op_rsvx44 = D_op_opx & (D_iw_opx == 44);
wire D_op_rsvx50 = D_op_opx & (D_iw_opx == 50);
wire D_op_rsvx51 = D_op_opx & (D_iw_opx == 51);
wire D_op_rsvx56 = D_op_opx & (D_iw_opx == 56);
wire D_op_rsvx60 = D_op_opx & (D_iw_opx == 60);
wire D_op_rsvx63 = D_op_opx & (D_iw_opx == 63);

assign R_en = 1'b1;

assign F_pc_sel_nxt = (W_br_taken | R_ctrl_uncond_cti_non_br)   ? 2'b10 :
					2'b11;

assign F_pc_nxt = 
  (F_pc_sel_nxt == 2'b10)? E_arith_result[ADDR_WIDTH-1 : 2] :
  F_pc_plus_one;

assign F_pc_en = W_valid;
assign F_pc_plus_one = F_pc + 1'b1;
always @(posedge clk) begin
    if (sclr_common)     F_pc <= 0;
    else if (F_pc_en)  F_pc <= F_pc_nxt;
end

assign F_valid = i_read & ~i_waitrequest;
assign i_read_nxt = W_valid | (i_read & i_waitrequest);
assign i_address = {F_pc, 2'b00};

always @(posedge clk) begin 
    if (sclr_common)     i_read <= 1'b1;
    else   i_read <= i_read_nxt;
end

assign F_iw = i_readdata;

always @(posedge clk) begin 
    if (sclr_common)     D_iw <= 0;
    else if (F_valid)  D_iw <= F_iw;
end

always @(posedge clk) begin 
    if (sclr_common) D_valid <= 0;
    else   D_valid <= F_valid;
end

assign D_dst_regnum = D_ctrl_implicit_dst_retaddr    ? 5'd31 : 
  D_ctrl_b_is_dst                ? D_iw_b :
  D_iw_c;

assign D_wr_dst_reg = (D_dst_regnum != 0) & ~D_ctrl_ignore_dst;
assign D_logic_op_raw = D_op_opx ? D_iw_opx[4 : 3] : 
  D_iw_op[4 : 3];

assign D_logic_op = D_ctrl_alu_force_xor ? 2'b11 : D_logic_op_raw;
assign D_compare_op = D_op_opx ? D_iw_opx[4 : 3] : 
  D_iw_op[4 : 3];

assign D_jmp_direct_target_waddr = D_iw[19 : 6]; // 31:6
always @(posedge clk) begin 
    if (sclr_common)     R_valid <= 0;
    else   R_valid <= D_valid;
end

always @(posedge clk) begin 
    if (sclr_common)     R_wr_dst_reg <= 0;
    else   R_wr_dst_reg <= D_wr_dst_reg;
end

always @(posedge clk) begin 
    if (sclr_common)     R_dst_regnum <= 0;
    else   R_dst_regnum <= D_dst_regnum;
end

always @(posedge clk) begin 
    if (sclr_common)     R_logic_op <= 0;
    else   R_logic_op <= D_logic_op;
end

always @(posedge clk) begin 
    if (sclr_common)     R_compare_op <= 0;
    else   R_compare_op <= D_compare_op;
end

always @(posedge clk) begin 
    if (sclr_common)     R_src2_use_imm <= 0;
    else   R_src2_use_imm <= D_ctrl_src2_choose_imm | (D_ctrl_br & R_valid);
end

assign W_rf_wren = (R_wr_dst_reg & W_valid); 
	//  | ~sclr_n;
	// I don't believe this is necessary or appropriate, regfile state
	// not protected during reset
	
assign W_rf_wr_data = R_ctrl_ld ? av_ld_data_aligned_filtered : W_wr_data;

assign R_src1 = (((R_ctrl_br & E_valid) | (R_ctrl_retaddr & R_valid)))? {F_pc_plus_one, 2'b00} :
  ((R_ctrl_jmp_direct & E_valid))? {D_jmp_direct_target_waddr, 2'b00} :
  R_rf_a;

assign R_src2_lo = ((R_ctrl_force_src2_zero|R_ctrl_hi_imm16))? 16'b0 :
  (R_src2_use_imm)? D_iw_imm16 :
  R_rf_b[15 : 0];

assign R_src2_hi = ((R_ctrl_force_src2_zero|R_ctrl_unsigned_lo_imm16))? 16'b0 :
  (R_ctrl_hi_imm16)? D_iw_imm16 :
  (R_src2_use_imm)? {16 {D_iw_imm16[15]}} :
  R_rf_b[31 : 16];

assign R_src2 = {R_src2_hi, R_src2_lo};
always @(posedge clk) begin 
    if (sclr_common)     E_valid <= 0;
    else   E_valid <= R_valid | E_stall;
end

always @(posedge clk) begin 
    if (sclr_common)     E_new_inst <= 0;
    else   E_new_inst <= R_valid;
end

always @(posedge clk) begin 
    if (sclr_esrc) E_src1 <= 32'b0;
    else   E_src1 <= R_src1;
end

always @(posedge clk) begin 
    if (sclr_esrc) E_src2 <= 32'b0;
    else   E_src2 <= R_src2;
end

always @(posedge clk) begin 
    if (sclr_common)     E_invert_arith_src_msb <= 0;
    else   E_invert_arith_src_msb <= D_ctrl_alu_signed_comparison & R_valid;
end

always @(posedge clk) begin 
    if (sclr_common)     E_alu_sub <= 0;
    else   E_alu_sub <= D_ctrl_alu_subtract & R_valid;
end

assign E_stall = E_shift_rot_stall | E_ld_stall | E_st_stall;
assign E_arith_src1 = { E_src1[31] ^ E_invert_arith_src_msb, 
  E_src1[30 : 0]};

assign E_arith_src2 = { E_src2[31] ^ E_invert_arith_src_msb, 
  E_src2[30 : 0]};

assign E_arith_result = E_alu_sub ?
  E_arith_src1 - E_arith_src2 :
  E_arith_src1 + E_arith_src2;

assign E_mem_baddr = E_arith_result[ADDR_WIDTH-1 : 0];

assign E_logic_result = (R_logic_op == 2'b00)? (~(E_src1 | E_src2)) :
  (R_logic_op == 2'b01)? (E_src1 & E_src2) :
  (R_logic_op == 2'b10)? (E_src1 | E_src2) :
  (E_src1 ^ E_src2);

assign E_logic_result_is_0 = E_logic_result == 0;
assign E_eq = E_logic_result_is_0;
assign E_lt = E_arith_result[32];
 
// retimed back regs 
reg eq_r = 1'b0;
reg lt_r = 1'b0;
reg [1:0] cmp_op_r = 1'b0;
always @(posedge clk) begin
	eq_r <= E_eq;
	lt_r <= E_lt;
	cmp_op_r <= R_compare_op;
end

//assign E_cmp_result = 
//  (R_compare_op == 2'b00)? E_eq :
//  (R_compare_op == 2'b01)? ~E_lt :
//  (R_compare_op == 2'b10)? E_lt :
//  ~E_eq;

assign E_shift_rot_cnt_nxt = E_new_inst ? E_src2[4 : 0] : E_shift_rot_cnt-1'b1;
assign E_shift_rot_done = (E_shift_rot_cnt == 0) & ~E_new_inst;
assign E_shift_rot_stall = R_ctrl_shift_rot & E_valid & ~E_shift_rot_done;
assign E_shift_rot_fill_bit = R_ctrl_shift_logical ? 1'b0 :
  (R_ctrl_rot_right ? E_shift_rot_result[0] : 
  E_shift_rot_result[31]);

assign E_shift_rot_result_nxt = (E_new_inst)? E_src1 :
  (R_ctrl_shift_rot_right)? {E_shift_rot_fill_bit, E_shift_rot_result[31 : 1]} :
  {E_shift_rot_result[30 : 0], E_shift_rot_fill_bit};

always @(posedge clk) begin 
    if (sclr_common)     E_shift_rot_result <= 0;
    else   E_shift_rot_result <= E_shift_rot_result_nxt;
end

always @(posedge clk) begin 
    if (sclr_common)     E_shift_rot_cnt <= 0;
    else   E_shift_rot_cnt <= E_shift_rot_cnt_nxt;
end

// new registers, retimed backwards
reg [31:0] alu_result_p0 = 32'b0;
reg [31:0] alu_result_p1 = 32'b0;
reg alu_result_sel = 1'b0;
always @(posedge clk) begin
	alu_result_p0 <= (R_ctrl_br_cmp)? 32'h0 :
	   (R_ctrl_shift_rot)? E_shift_rot_result :
	   (R_ctrl_logic)? E_logic_result : 32'h0;
	alu_result_p1 <= E_arith_result[31:0];
	alu_result_sel <= (R_ctrl_br_cmp | R_ctrl_shift_rot | R_ctrl_logic) ^ 1'b1;
end

 // assign E_alu_result = (R_ctrl_br_cmp)? 32'h0 :
 //   (R_ctrl_shift_rot)? E_shift_rot_result :
 //   (R_ctrl_logic)? E_logic_result :
 //   E_arith_result[31:0];

assign R_stb_data = R_rf_b[7 : 0];
assign R_sth_data = R_rf_b[15 : 0];
assign E_st_data = (D_mem8)? {R_stb_data, R_stb_data, R_stb_data, R_stb_data} :
  (D_mem16)? {R_sth_data, R_sth_data} :
  R_rf_b;

assign E_mem_byte_en = ({D_iw_memsz, E_mem_baddr[1 : 0]} == {2'b00, 2'b00})? 4'b0001 :
  ({D_iw_memsz, E_mem_baddr[1 : 0]} == {2'b00, 2'b01})? 4'b0010 :
  ({D_iw_memsz, E_mem_baddr[1 : 0]} == {2'b00, 2'b10})? 4'b0100 :
  ({D_iw_memsz, E_mem_baddr[1 : 0]} == {2'b00, 2'b11})? 4'b1000 :
  ({D_iw_memsz, E_mem_baddr[1 : 0]} == {2'b01, 2'b00})? 4'b0011 :
  ({D_iw_memsz, E_mem_baddr[1 : 0]} == {2'b01, 2'b01})? 4'b0011 :
  ({D_iw_memsz, E_mem_baddr[1 : 0]} == {2'b01, 2'b10})? 4'b1100 :
  ({D_iw_memsz, E_mem_baddr[1 : 0]} == {2'b01, 2'b11})? 4'b1100 :
  4'b1111;

assign d_read_nxt = (R_ctrl_ld & E_new_inst) | (d_read & d_waitrequest);
assign E_ld_stall = R_ctrl_ld & ((E_valid & ~av_ld_done) | E_new_inst);
assign d_write_nxt = (R_ctrl_st & E_new_inst) | (d_write & d_waitrequest);
assign E_st_stall = d_write_nxt;
assign d_address = W_mem_baddr;
assign av_ld_getting_data = d_read & ~d_waitrequest;
always @(posedge clk) begin 
    if (sclr_common)     d_read <= 0;
    else   d_read <= d_read_nxt;
end

always @(posedge clk) begin 
    if (sclr_common)     d_writedata <= 0;
    else   d_writedata <= E_st_data;
end

always @(posedge clk) begin 
    if (sclr_common)     d_byteenable <= 0;
    else   d_byteenable <= E_mem_byte_en;
end

assign av_ld_align_cycle_nxt = av_ld_getting_data ? 2'h0 : (av_ld_align_cycle+1'b1);
assign av_ld_align_one_more_cycle = av_ld_align_cycle == (D_mem16 ? 2 : 3);
assign av_ld_aligning_data_nxt = av_ld_aligning_data ? 
  ~av_ld_align_one_more_cycle : (~D_mem32 & av_ld_getting_data);

assign av_ld_waiting_for_data_nxt = av_ld_waiting_for_data ? 
  ~av_ld_getting_data : (R_ctrl_ld & E_new_inst);

assign av_ld_done = ~av_ld_waiting_for_data_nxt & (D_mem32 | ~av_ld_aligning_data_nxt);
assign av_ld_rshift8 = av_ld_aligning_data & 
  (av_ld_align_cycle < (W_mem_baddr[1 : 0]));

assign av_ld_extend = av_ld_aligning_data;
assign av_ld_byte0_data_nxt = av_ld_rshift8      ? av_ld_byte1_data :
  av_ld_extend       ? av_ld_byte0_data :
  d_readdata[7 : 0];

assign av_ld_byte1_data_nxt = av_ld_rshift8      ? av_ld_byte2_data :
  av_ld_extend       ? {8 {av_fill_bit}} :
  d_readdata[15 : 8];

assign av_ld_byte2_data_nxt = av_ld_rshift8      ? av_ld_byte3_data :
  av_ld_extend       ? {8 {av_fill_bit}} :
  d_readdata[23 : 16];

assign av_ld_byte3_data_nxt = av_ld_rshift8      ? av_ld_byte3_data :
  av_ld_extend       ? {8 {av_fill_bit}} :
  d_readdata[31 : 24];

assign av_ld_byte1_data_en = ~(av_ld_extend & D_mem16 & ~av_ld_rshift8);
assign av_ld_data_aligned_unfiltered = {av_ld_byte3_data, av_ld_byte2_data, 
  av_ld_byte1_data, av_ld_byte0_data};

assign av_sign_bit = D_mem16 ? av_ld_byte1_data[7] : av_ld_byte0_data[7];
assign av_fill_bit = av_sign_bit & R_ctrl_ld_signed;
always @(posedge clk) begin 
    if (sclr_common)     av_ld_align_cycle <= 0;
    else   av_ld_align_cycle <= av_ld_align_cycle_nxt;
end

always @(posedge clk) begin 
    if (sclr_common)     av_ld_waiting_for_data <= 0;
    else   av_ld_waiting_for_data <= av_ld_waiting_for_data_nxt;
end

always @(posedge clk) begin 
    if (sclr_common) av_ld_aligning_data <= 0;
    else   av_ld_aligning_data <= av_ld_aligning_data_nxt;
end

always @(posedge clk) begin 
    if (sclr_common)     av_ld_byte0_data <= 0;
    else   av_ld_byte0_data <= av_ld_byte0_data_nxt;
end

always @(posedge clk) begin 
    if (sclr_common)     av_ld_byte1_data <= 0;
    else if (av_ld_byte1_data_en)
        av_ld_byte1_data <= av_ld_byte1_data_nxt;
end

always @(posedge clk) begin 
    if (sclr_common)     av_ld_byte2_data <= 0;
    else   av_ld_byte2_data <= av_ld_byte2_data_nxt;
end

always @(posedge clk) begin 
    if (sclr_common)     av_ld_byte3_data <= 0;
    else   av_ld_byte3_data <= av_ld_byte3_data_nxt;
end

always @(posedge clk) begin 
    if (sclr_common)     W_valid <= 0;
    else   W_valid <= E_valid & ~E_stall;
end

// W was previously just registered E_cmp_result, now a LUT 
assign W_cmp_result = 
  (cmp_op_r == 2'b00)? eq_r :
  (cmp_op_r == 2'b01)? ~lt_r :
  (cmp_op_r == 2'b10)? lt_r :
  ~eq_r;

// W was previously just registered E_alu_result, now a LUT 
assign W_alu_result = alu_result_sel ? alu_result_p1 : alu_result_p0;
    
assign W_wr_data = R_ctrl_br_cmp ? W_cmp_result : W_alu_result[31 : 0];

assign W_br_taken = R_ctrl_br & W_cmp_result;

assign W_mem_baddr = W_alu_result[ADDR_WIDTH-1 : 0];
  
assign D_ctrl_jmp_direct = D_op_call|D_op_jmpi;
assign R_ctrl_jmp_direct_nxt = D_ctrl_jmp_direct;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_jmp_direct <= 0;
    else if (R_en)
        R_ctrl_jmp_direct <= R_ctrl_jmp_direct_nxt;
end


assign D_ctrl_implicit_dst_retaddr = D_op_call|D_op_rsv02;

assign D_ctrl_uncond_cti_non_br = D_op_call | 
  D_op_jmpi | 
  D_op_rsvx17 | 
  D_op_rsvx25 | 
  D_op_ret | 
  D_op_jmp | 
  D_op_rsvx21 | 
  D_op_callr;

assign R_ctrl_uncond_cti_non_br_nxt = D_ctrl_uncond_cti_non_br;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_uncond_cti_non_br <= 0;
    else if (R_en)
        R_ctrl_uncond_cti_non_br <= R_ctrl_uncond_cti_non_br_nxt;
end

assign D_ctrl_retaddr = D_op_call | 
  D_op_rsv02 | 
  D_op_nextpc | 
  D_op_callr ;

assign R_ctrl_retaddr_nxt = D_ctrl_retaddr;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_retaddr <= 0;
    else if (R_en)
        R_ctrl_retaddr <= R_ctrl_retaddr_nxt;
end

assign D_ctrl_shift_logical = D_op_slli|D_op_sll|D_op_srli|D_op_srl;
assign R_ctrl_shift_logical_nxt = D_ctrl_shift_logical;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_shift_logical <= 0;
    else if (R_en)
        R_ctrl_shift_logical <= R_ctrl_shift_logical_nxt;
end

assign D_ctrl_rot_right = D_op_rsvx10|D_op_ror|D_op_rsvx42|D_op_rsvx43;
assign R_ctrl_rot_right_nxt = D_ctrl_rot_right;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_rot_right <= 0;
    else if (R_en)
        R_ctrl_rot_right <= R_ctrl_rot_right_nxt;
end


assign D_ctrl_shift_rot_right = D_op_srli | 
  D_op_srl | 
  D_op_srai | 
  D_op_sra | 
  D_op_rsvx10 | 
  D_op_ror | 
  D_op_rsvx42 | 
  D_op_rsvx43;

assign R_ctrl_shift_rot_right_nxt = D_ctrl_shift_rot_right;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_shift_rot_right <= 0;
    else if (R_en)
        R_ctrl_shift_rot_right <= R_ctrl_shift_rot_right_nxt;
end


assign D_ctrl_shift_rot = D_op_slli | 
  D_op_rsvx50 | 
  D_op_sll | 
  D_op_rsvx51 | 
  D_op_roli | 
  D_op_rsvx34 | 
  D_op_rol | 
  D_op_rsvx35 | 
  D_op_srli | 
  D_op_srl | 
  D_op_srai | 
  D_op_sra | 
  D_op_rsvx10 | 
  D_op_ror | 
  D_op_rsvx42 | 
  D_op_rsvx43;

assign R_ctrl_shift_rot_nxt = D_ctrl_shift_rot;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_shift_rot <= 0;
    else if (R_en)
        R_ctrl_shift_rot <= R_ctrl_shift_rot_nxt;
end

assign D_ctrl_logic = D_op_and | 
  D_op_or | 
  D_op_xor | 
  D_op_nor | 
  D_op_andhi | 
  D_op_orhi | 
  D_op_xorhi | 
  D_op_andi | 
  D_op_ori | 
  D_op_xori;

assign R_ctrl_logic_nxt = D_ctrl_logic;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_logic <= 0;
    else if (R_en)
        R_ctrl_logic <= R_ctrl_logic_nxt;
end

assign D_ctrl_hi_imm16 = D_op_andhi|D_op_orhi|D_op_xorhi;
assign R_ctrl_hi_imm16_nxt = D_ctrl_hi_imm16;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_hi_imm16 <= 0;
    else if (R_en)
        R_ctrl_hi_imm16 <= R_ctrl_hi_imm16_nxt;
end


assign D_ctrl_unsigned_lo_imm16 = D_op_cmpgeui | 
  D_op_cmpltui | 
  D_op_andi | 
  D_op_ori | 
  D_op_xori | 
  D_op_roli | 
  D_op_rsvx10 | 
  D_op_slli | 
  D_op_srli | 
  D_op_rsvx34 | 
  D_op_rsvx42 | 
  D_op_rsvx50 | 
  D_op_srai;

assign R_ctrl_unsigned_lo_imm16_nxt = D_ctrl_unsigned_lo_imm16;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_unsigned_lo_imm16 <= 0;
    else if (R_en)
        R_ctrl_unsigned_lo_imm16 <= R_ctrl_unsigned_lo_imm16_nxt;
end

assign D_ctrl_br = D_op_br | 
  D_op_bge | 
  D_op_blt | 
  D_op_bne | 
  D_op_beq | 
  D_op_bgeu | 
  D_op_bltu | 
  D_op_rsv62;

assign R_ctrl_br_nxt = D_ctrl_br;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_br <= 0;
    else if (R_en)
        R_ctrl_br <= R_ctrl_br_nxt;
end

assign D_ctrl_alu_subtract = D_op_sub | 
  D_op_rsvx25 | 
  D_op_cmplti | 
  D_op_cmpltui | 
  D_op_cmplt | 
  D_op_cmpltu | 
  D_op_blt | 
  D_op_bltu | 
  D_op_cmpgei | 
  D_op_cmpgeui | 
  D_op_cmpge | 
  D_op_cmpgeu | 
  D_op_bge | 
  D_op_rsv10 | 
  D_op_bgeu | 
  D_op_rsv42;

assign D_ctrl_alu_signed_comparison = D_op_cmpge|D_op_cmpgei|D_op_cmplt|D_op_cmplti|D_op_bge|D_op_blt;

assign D_ctrl_br_cmp = D_op_br | 
  D_op_bge | 
  D_op_blt | 
  D_op_bne | 
  D_op_beq | 
  D_op_bgeu | 
  D_op_bltu | 
  D_op_rsv62 | 
  D_op_cmpgei | 
  D_op_cmplti | 
  D_op_cmpnei | 
  D_op_cmpgeui | 
  D_op_cmpltui | 
  D_op_cmpeqi | 
  D_op_rsvx00 | 
  D_op_cmpge | 
  D_op_cmplt | 
  D_op_cmpne | 
  D_op_cmpgeu | 
  D_op_cmpltu | 
  D_op_cmpeq | 
  D_op_rsvx56;

assign R_ctrl_br_cmp_nxt = D_ctrl_br_cmp;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_br_cmp <= 0;
    else if (R_en)
        R_ctrl_br_cmp <= R_ctrl_br_cmp_nxt;
end

assign D_ctrl_ld_signed = D_op_ldb | 
  D_op_ldh | 
  D_op_ldl | 
  D_op_ldw | 
  D_op_ldbio | 
  D_op_ldhio | 
  D_op_ldwio | 
  D_op_rsv63;

assign R_ctrl_ld_signed_nxt = D_ctrl_ld_signed;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_ld_signed <= 0;
    else if (R_en)
        R_ctrl_ld_signed <= R_ctrl_ld_signed_nxt;
end

assign D_ctrl_ld = D_op_ldb | 
  D_op_ldh | 
  D_op_ldl | 
  D_op_ldw | 
  D_op_ldbio | 
  D_op_ldhio | 
  D_op_ldwio | 
  D_op_rsv63 | 
  D_op_ldbu | 
  D_op_ldhu | 
  D_op_ldbuio | 
  D_op_ldhuio;

assign R_ctrl_ld_nxt = D_ctrl_ld;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_ld <= 0;
    else if (R_en)
        R_ctrl_ld <= R_ctrl_ld_nxt;
end

assign D_ctrl_st = D_op_stb | 
  D_op_sth | 
  D_op_stw | 
  D_op_stc | 
  D_op_stbio | 
  D_op_sthio | 
  D_op_stwio | 
  D_op_rsv61;

assign R_ctrl_st_nxt = D_ctrl_st;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_st <= 0;
    else if (R_en)
        R_ctrl_st <= R_ctrl_st_nxt;
end

assign D_ctrl_b_is_dst = D_op_addi | 
  D_op_andhi | 
  D_op_orhi | 
  D_op_xorhi | 
  D_op_andi | 
  D_op_ori | 
  D_op_xori | 
  D_op_call | 
  D_op_rdprs | 
  D_op_cmpgei | 
  D_op_cmplti | 
  D_op_cmpnei | 
  D_op_cmpgeui | 
  D_op_cmpltui | 
  D_op_cmpeqi | 
  D_op_jmpi | 
  D_op_rsv09 | 
  D_op_rsv17 | 
  D_op_rsv25 | 
  D_op_rsv33 | 
  D_op_rsv41 | 
  D_op_rsv49 | 
  D_op_rsv57 | 
  D_op_ldb | 
  D_op_ldh | 
  D_op_ldl | 
  D_op_ldw | 
  D_op_ldbio | 
  D_op_ldhio | 
  D_op_ldwio | 
  D_op_rsv63 | 
  D_op_ldbu | 
  D_op_ldhu | 
  D_op_ldbuio | 
  D_op_ldhuio | 
  D_op_initd | 
  D_op_initda | 
  D_op_flushd | 
  D_op_flushda;

assign D_ctrl_ignore_dst = D_op_br | 
  D_op_bge | 
  D_op_blt | 
  D_op_bne | 
  D_op_beq | 
  D_op_bgeu | 
  D_op_bltu | 
  D_op_rsv62 | 
  D_op_stb | 
  D_op_sth | 
  D_op_stw | 
  D_op_stc | 
  D_op_stbio | 
  D_op_sthio | 
  D_op_stwio | 
  D_op_rsv61 | 
  D_op_jmpi | 
  D_op_rsv09 | 
  D_op_rsv17 | 
  D_op_rsv25 | 
  D_op_rsv33 | 
  D_op_rsv41 | 
  D_op_rsv49 | 
  D_op_rsv57;

assign D_ctrl_src2_choose_imm = D_op_addi | 
  D_op_andhi | 
  D_op_orhi | 
  D_op_xorhi | 
  D_op_andi | 
  D_op_ori | 
  D_op_xori | 
  D_op_call | 
  D_op_rdprs | 
  D_op_cmpgei | 
  D_op_cmplti | 
  D_op_cmpnei | 
  D_op_cmpgeui | 
  D_op_cmpltui | 
  D_op_cmpeqi | 
  D_op_jmpi | 
  D_op_rsv09 | 
  D_op_rsv17 | 
  D_op_rsv25 | 
  D_op_rsv33 | 
  D_op_rsv41 | 
  D_op_rsv49 | 
  D_op_rsv57 | 
  D_op_ldb | 
  D_op_ldh | 
  D_op_ldl | 
  D_op_ldw | 
  D_op_ldbio | 
  D_op_ldhio | 
  D_op_ldwio | 
  D_op_rsv63 | 
  D_op_ldbu | 
  D_op_ldhu | 
  D_op_ldbuio | 
  D_op_ldhuio | 
  D_op_initd | 
  D_op_initda | 
  D_op_flushd | 
  D_op_flushda | 
  D_op_stb | 
  D_op_sth | 
  D_op_stw | 
  D_op_stc | 
  D_op_stbio | 
  D_op_sthio | 
  D_op_stwio | 
  D_op_rsv61 | 
  D_op_roli | 
  D_op_rsvx10 | 
  D_op_slli | 
  D_op_srli | 
  D_op_rsvx34 | 
  D_op_rsvx42 | 
  D_op_rsvx50 | 
  D_op_srai;

assign D_ctrl_force_src2_zero = D_op_call | 
  D_op_rsv02 | 
  D_op_nextpc | 
  D_op_callr | 
  D_op_rsvx17 | 
  D_op_rsvx25 | 
  D_op_ret | 
  D_op_jmp | 
  D_op_rsvx21 | 
  D_op_jmpi;

assign R_ctrl_force_src2_zero_nxt = D_ctrl_force_src2_zero;
always @(posedge clk) begin 
    if (sclr_common)     R_ctrl_force_src2_zero <= 0;
    else if (R_en)
        R_ctrl_force_src2_zero <= R_ctrl_force_src2_zero_nxt;
end

assign D_ctrl_alu_force_xor = D_op_cmpgei | 
  D_op_cmpgeui | 
  D_op_cmpeqi | 
  D_op_cmpge | 
  D_op_cmpgeu | 
  D_op_cmpeq | 
  D_op_cmpnei | 
  D_op_cmpne | 
  D_op_bge | 
  D_op_rsv10 | 
  D_op_bgeu | 
  D_op_rsv42 | 
  D_op_beq | 
  D_op_rsv34 | 
  D_op_bne | 
  D_op_rsv62 | 
  D_op_br | 
  D_op_rsv02;

///////////////////////////////////////////////////////////////////
// program memory
///////////////////////////////////////////////////////////////////
  
// B is a read only instruction port for the NIOS
// A is a write only back door program load port

reg prg_we;
generate if (REG_PWE) begin
	initial prg_we = 1'b0;
	always @(posedge clk) prg_we <= !prg_addr[15] && !prg_addr[14] && prg_wr;
end
else begin
	always @(*) prg_we = !prg_addr[15] && !prg_addr[14] && prg_wr;
end
endgenerate

altsyncram    prg_ram (
            .address_a (prg_addr[PROG_MEM_ADDR_WIDTH + 1:2]),
            .clock0 (clk),
            .data_a (prg_din),
            .wren_a (prg_we),
            .address_b (i_address[PROG_MEM_ADDR_WIDTH + 1:2]),
            .q_b (i_readdata),
            .aclr0 (1'b0),
            .aclr1 (1'b0),
            .addressstall_a (1'b0),
            .addressstall_b (1'b0),
            .byteena_a (1'b1),
            .byteena_b (1'b1),
            .clock1 (1'b1),
            .clocken0 (1'b1),
            .clocken1 (1'b1),
            .clocken2 (1'b1),
            .clocken3 (1'b1),
            .data_b ({32{1'b1}}),
            .eccstatus (),
            .q_a (),
            .rden_a (1'b1),
            .rden_b (1'b1),
            .wren_b (1'b0));
defparam
    prg_ram.address_aclr_a = "NONE",
  //?  prg_ram.address_reg_a = "CLOCK0",
    prg_ram.address_aclr_b = "NONE",
    prg_ram.address_reg_b = "CLOCK0",
    prg_ram.clock_enable_input_a = "BYPASS",
    prg_ram.clock_enable_input_b = "BYPASS",
    prg_ram.clock_enable_output_b = "BYPASS",
    prg_ram.enable_ecc = "FALSE",
    prg_ram.init_file = PROG_MEM_INIT,
    prg_ram.intended_device_family = "Stratix V",
    prg_ram.lpm_type = "altsyncram",
    prg_ram.numwords_a = (1 << PROG_MEM_ADDR_WIDTH),
    prg_ram.numwords_b = (1 << PROG_MEM_ADDR_WIDTH),
    prg_ram.operation_mode = "DUAL_PORT",
    prg_ram.outdata_aclr_b = "NONE",
    prg_ram.outdata_reg_b = "CLOCK0",
    prg_ram.power_up_uninitialized = "FALSE",
    prg_ram.ram_block_type = "M20K",
    prg_ram.read_during_write_mode_mixed_ports = "DONT_CARE",
    prg_ram.widthad_a = PROG_MEM_ADDR_WIDTH,
    prg_ram.widthad_b = PROG_MEM_ADDR_WIDTH,
    prg_ram.width_a = 32,
    prg_ram.width_b = 32,
    prg_ram.width_byteena_a = 1;

reg last_i_read = 1'b0;
reg last2_i_read = 1'b0;
always @(posedge clk) begin
    last_i_read <= i_read;	 
    last2_i_read <= last_i_read;
end  
assign i_waitrequest = (i_read && !last_i_read) ||
					(i_read && !last2_i_read);

///////////////////////////////////////////////////////////////////
// scratch memory
///////////////////////////////////////////////////////////////////

wire [31:0] d_scratch_readdata;
wire scratch_select = d_address[ADDR_WIDTH-1:ADDR_WIDTH-2] == 2'b01;

// synthesis translate off
always @(posedge clk) begin
	if (DEBUG_SCRATCH & d_write & scratch_select) $display ("Writing %08x to scratch [%04x]",d_writedata,d_address[SCRATCH_MEM_ADDR_WIDTH + 1:2]);
	if (DEBUG_SCRATCH & d_read & scratch_select) $display ("Reading from scratch [%04x]",d_address[SCRATCH_MEM_ADDR_WIDTH + 1:2]);
end
// synthesis translate on

wire prg_wr_scr = !prg_addr[15] && prg_addr[14] && prg_wr;

reg scratch_load = 1'b0;
always @(posedge clk) scratch_load <= sclr_common;

altsyncram    scr_ram (
	.byteena_a (scratch_load ? 4'b1111 : d_byteenable),
	.clock0 (clk),
	.wren_a ((d_write & scratch_select) | prg_wr_scr),
	.address_b (1'b1),
	.data_b (1'b1),
	.wren_b (1'b0),
	.address_a (scratch_load ? prg_addr[SCRATCH_MEM_ADDR_WIDTH + 1:2] : d_address[SCRATCH_MEM_ADDR_WIDTH + 1:2]),
	.data_a (scratch_load ? prg_din : d_writedata),
	.q_a (d_scratch_readdata),
	.q_b (),
	.aclr0 (1'b0),
	.aclr1 (1'b0),
	.addressstall_a (1'b0),
	.addressstall_b (1'b0),
	.byteena_b (1'b1),
	.clock1 (1'b1),
	.clocken0 (1'b1),
	.clocken1 (1'b1),
	.clocken2 (1'b1),
	.clocken3 (1'b1),
	.eccstatus (),
	.rden_a (1'b1),
	.rden_b (1'b1)
);
defparam
	scr_ram.byte_size = 8,
	scr_ram.clock_enable_input_a = "BYPASS",
	scr_ram.clock_enable_output_a = "BYPASS",
	scr_ram.intended_device_family = "Arria 10",
	scr_ram.lpm_type = "altsyncram",
	scr_ram.numwords_a = (1 << SCRATCH_MEM_ADDR_WIDTH),
	scr_ram.operation_mode = "SINGLE_PORT",
	scr_ram.outdata_aclr_a = "NONE",
	scr_ram.outdata_reg_a = "CLOCK0",
	scr_ram.power_up_uninitialized = "FALSE",
	scr_ram.init_file = SCRATCH_MEM_INIT,
	scr_ram.ram_block_type = "M20K",
	scr_ram.read_during_write_mode_port_a  = "DONT_CARE",
    scr_ram.widthad_a = SCRATCH_MEM_ADDR_WIDTH,
	scr_ram.width_a = 32,
	scr_ram.width_byteena_a = 4;
	
	
///////////////////////////////////////////////////////////////////
// split data bus between scratch and external
///////////////////////////////////////////////////////////////////

reg last_d_read = 1'b0;
reg last2_d_read = 1'b0;

always @(posedge clk) begin
    last_d_read <= d_read;	 
    last2_d_read <= last_d_read;
end 

reg ext_cycle = 1'b0;
always @(posedge clk) begin
	if (d_read) begin
		ext_cycle <= !scratch_select;   
	end
end

assign d_waitrequest = (d_read && !last_d_read) || 
					 (d_read && !last2_d_read) || 
					 (d_read && ext_cycle && !last2_d_read);
  
assign ext_address = d_address;
assign ext_read = d_read && d_address[ADDR_WIDTH-1];
assign ext_write = d_write && d_address[ADDR_WIDTH-1];
assign ext_writedata = d_writedata;
  
reg [31:0] ext_readdata_r = 0;

always @(posedge clk) begin
	ext_readdata_r <= ext_readdata;  
end

assign d_readdata = ext_cycle ? ext_readdata_r : d_scratch_readdata;    

///////////////////////////////////////////////////////////
// register file - common write, two independent reads
///////////////////////////////////////////////////////////

// synthesis translate off
always @(posedge clk) begin
	if (DEBUG_REGFILE & W_rf_wren) $display ("Writing %08x to r%d",W_rf_wr_data,R_dst_regnum);
end
// synthesis translate on

altsyncram	regfile_a (
			.address_a (R_dst_regnum),
			.clock0 (clk),
			.data_a (W_rf_wr_data),
			.wren_a (W_rf_wren),
			.address_b (D_iw_a),
			.q_b (R_rf_a),
			.aclr0 (1'b0),
			.aclr1 (1'b0),
			.addressstall_a (1'b0),
			.addressstall_b (1'b0),
			.byteena_a (1'b1),
			.byteena_b (1'b1),
			.clock1 (1'b1),
			.clocken0 (1'b1),
			.clocken1 (1'b1),
			.clocken2 (1'b1),
			.clocken3 (1'b1),
			.data_b ({32{1'b1}}),
			.eccstatus (),
			.q_a (),
			.rden_a (1'b1),
			.rden_b (1'b1),
			.wren_b (1'b0));
defparam
	regfile_a.address_aclr_b = "NONE",
	regfile_a.address_reg_b = "CLOCK0",
	regfile_a.clock_enable_input_a = "BYPASS",
	regfile_a.clock_enable_input_b = "BYPASS",
	regfile_a.clock_enable_output_b = "BYPASS",
	regfile_a.init_file = REGFILE_INIT,
	regfile_a.intended_device_family = "Stratix V",
	regfile_a.lpm_type = "altsyncram",
	regfile_a.numwords_a = 32,
	regfile_a.numwords_b = 32,
	regfile_a.operation_mode = "DUAL_PORT",
	regfile_a.outdata_aclr_b = "NONE",
	regfile_a.outdata_reg_b = "UNREGISTERED",
	regfile_a.power_up_uninitialized = "FALSE",
	regfile_a.ram_block_type = "MLAB",
	regfile_a.widthad_a = 5,
	regfile_a.widthad_b = 5,
	regfile_a.width_a = 32,
	regfile_a.width_b = 32,
	regfile_a.width_byteena_a = 1;


altsyncram	regfile_b (
			.address_a (R_dst_regnum),
			.clock0 (clk),
			.data_a (W_rf_wr_data),
			.wren_a (W_rf_wren),
			.address_b (D_iw_b),
			.q_b (R_rf_b),
			.aclr0 (1'b0),
			.aclr1 (1'b0),
			.addressstall_a (1'b0),
			.addressstall_b (1'b0),
			.byteena_a (1'b1),
			.byteena_b (1'b1),
			.clock1 (1'b1),
			.clocken0 (1'b1),
			.clocken1 (1'b1),
			.clocken2 (1'b1),
			.clocken3 (1'b1),
			.data_b ({32{1'b1}}),
			.eccstatus (),
			.q_a (),
			.rden_a (1'b1),
			.rden_b (1'b1),
			.wren_b (1'b0));
defparam
	regfile_b.address_aclr_b = "NONE",
	regfile_b.address_reg_b = "CLOCK0",
	regfile_b.clock_enable_input_a = "BYPASS",
	regfile_b.clock_enable_input_b = "BYPASS",
	regfile_b.clock_enable_output_b = "BYPASS",
	regfile_b.init_file = REGFILE_INIT,
	regfile_b.intended_device_family = "Stratix V",
	regfile_b.lpm_type = "altsyncram",
	regfile_b.numwords_a = 32,
	regfile_b.numwords_b = 32,
	regfile_b.operation_mode = "DUAL_PORT",
	regfile_b.outdata_aclr_b = "NONE",
	regfile_b.outdata_reg_b = "UNREGISTERED",
	regfile_b.power_up_uninitialized = "FALSE",
	regfile_b.ram_block_type = "MLAB",
	regfile_b.widthad_a = 5,
	regfile_b.widthad_b = 5,
	regfile_b.width_a = 32,
	regfile_b.width_b = 32,
	regfile_b.width_byteena_a = 1;


///////////////////////////////////////////////////////////
// illegal opcode trap
///////////////////////////////////////////////////////////

reg bad_muldiv = 1'b0;
reg bad_break = 1'b0;
reg bad_except = 1'b0;
reg bad_ctrl = 1'b0;
reg any_bad_op = 1'b0;

always @(posedge clk) begin
	bad_muldiv <= 
	   (D_op_div | 
		D_op_divu | 
		D_op_mul | 
		D_op_muli | 
		D_op_mulxss | 
		D_op_mulxsu | 
		D_op_mulxuu);

	bad_break <=
		(D_op_bret |
		D_op_break |
		D_op_hbreak |
		D_op_crst |
		D_op_rsvx63);

	bad_except <= 
		(D_op_eret |
		D_op_trap | 
		D_op_rsvx44 | 
		D_op_intr | 
		D_op_rsvx60);
		
	bad_ctrl <=
		(D_op_wrctl |
		D_op_rdctl);
		
	any_bad_op <= bad_muldiv | bad_break | bad_except | bad_ctrl;
end

assign illegal_opcode = any_bad_op;

///////////////////////////////////////////////////////////
// debug monitor
///////////////////////////////////////////////////////////

// synthesis translate off
reg nios_reset = 1'b0;
always @(posedge clk) begin
	if (~|F_pc) begin
		nios_reset <= 1'b1;
		if (!nios_reset) $display ("NIOS is entering reset");
	end
	else begin
		nios_reset <= 1'b0;
		if (nios_reset) $display ("NIOS is exiting reset");
	end	

	if (D_op_div | 
		D_op_divu | 
		D_op_mul | 
		D_op_muli | 
		D_op_mulxss | 
		D_op_mulxsu | 
		D_op_mulxuu) begin
		$display ("The opcode is an unimplemented MUL / DIV");
	end

	if (illegal_opcode) $display ("Illegal opcode");

	if (W_rf_wren && R_dst_regnum == 6'd29) begin
		$display ("The NIOS hit an exception");
		$stop();
	end

	if (d_write && d_address[ADDR_WIDTH-1:ADDR_WIDTH-2] == 2'b00) begin
		$display ("The NIOS is trying to write to program memory at %x",d_address);
		$stop();
	end

	if (d_write && d_address[ADDR_WIDTH-1:ADDR_WIDTH-2] == 2'b01) begin
		if (|d_address[ADDR_WIDTH-3:SCRATCH_MEM_ADDR_WIDTH+2]) begin
			$display ("The NIOS is trying to write to unavailable scratch memory at %x",d_address);
			$stop();
		end
	end
end
// synthesis translate on

endmodule

