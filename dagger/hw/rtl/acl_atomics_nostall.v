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
    


/****************************
* --------------------------
* Atomic Instruction Handler
* --------------------------
*
* Design Goal#1:
* --------------
* This module is instantiated at the end of global or local memory arbitration.
* It monitors every memory request issued to the memory, as well as readdata 
* that is returned back. In case an incoming atomic request is detected, it 
* activates necessary mechanisms so that memory state and readdata are consistent.
* 
* Design Goal#2: 
* --------------
* Because local memory interconnect and routers do not expect local
* memory to stall, this module does not stall incoming requests as long as
* (1) there is enough hardware to store all the state, (2) there is no incoming
* read/write/atomic request at the same cycle an earlier atomic request is writing
* to memory. The former requirement is handled by selecting approriate value
* for NUM_TXS parameter. The latter requirement is handled in the local memory
* interconnect, but not in global memory interconnect.
*
* Atomic Request Operands:
* ------------------------
* The operands for atomic operations are stored in writedata signal which is 
* normally not used for read requests. This is the layout for writedata signal:
* Bit      0: high is this is atomic request.
* Bits  1-32: operand0 of atomic operation (valid atomic_add, atomic_min, etc.)
* Bits 33-64: operand1 of atomic operation (valid for atomic_cmpxchg)
* Bits 65-67: atomic operation types (e.g. add, min, cmpxchg, etc.)
* Bits 67-71: segment offset of the 32-bit atomic operation at the given address.
*  
* Anatomy of an Atomic Request: 
* -----------------------------
* We refer each memory request "a transaction" which 
* go through the following states:
* 
* ST_READ(R): a read from memory request is issued a response is expected.
* ST_ALU(A): readdata from memory is received and returned back to the arbitration 
* in the previous cycle. In this cycle, the atomic operation (add, min, xor, etc.) 
* is performed. At the end of this cycle, the result of atomic operation is stored
* in a register.
* ST_WRITEBACK(W): The result of atomic operation is written to memory.
*
* Hence, atomic requests can be represented with the following pipeline diagram 
* (the number of ST_READ cycles depends on whether global or local memory is used).
* 
* #1: atomic_inst: R1 R2 R3 R4 A W
*
* For ease of implementation, non-atomic read requests also go through the same
* pipeline stages. Non-atomic writes take one cycle, hence, do not go through
* pipeline stages.
*
* Conflicts:
* ----------
* We say two transactions are "conflicting", if they access the same 
* address. Conflicts can potentially cause inconsistent memory state and 
* incorrect readdata returns.
* 
* Data Forwarding: 
* ----------------
* "No-stall" atomics are realized via data forwarding between 
* subsequent conflicting atomic transactions.
* 
* ST_ALU-to-ST_ALU forwarding: 
*
* #1: atomic_inc(A): R1 R2 R3 R4  A  W
* #2: atomic_inc(A):    R1 R2 R3 R4  A W
* 
* We forward from ALU output of #1 to ALU input of #2.
* 
* ST_ALU-to-ST_READ forwarding:
*
* #1: atomic_inc(A): R1 R2 R3 R4  A  W
* #2: atomic_inc(A):       R1 R2 R3 R4  A W
*
* We forward from ALU output of #1 to R3 of #2. Hence, each atomic transaction 
* records data it receives via forwarding during its ST_READ stages.
* 
* Selecting the readdata: Due to forwarding logic, an atomic transaction needs to
* choose which readdata to take as input to its ALU.
* 
* There are 3 sources: (1) readdata received from memory,
*                      (2) ST_ALU-to-ST_READ forwarded data,
*                      (3) ST_ALU-to-ST_ALU forwarded data.
*
* This is in the order of most recent to least recent data in memory. Hence,
* priorities are 3-2-1.
* 
* FMAX WARNING: This selection of inputs is the critical path for Fmax.
*
* Sequential Consistency:
* -----------------------
* For performance reasons, the atomic module does not provide sequential 
* consistency for non-atomic read requests. That is, if a read request is received
* while there are conflicting atomic transactions, data forwarding will not be
* performed from atomic transactions to non-atomic read transactions, hence, the
* read request will return "old" data. It is trivial to perform data forwarding
* for non-atomic reads as long as they operate on 32-bit data. It is very complex
* to forward data when the non-atomic read request operates on wide data 
* (burstcount > 1, or reads larger than 32-bit).
* 
* Sequential consistency is provided for non-atomic writes. When an incoming
* non-atomic write conflicts with atomic transactions in flight, the atomic
* transactions take notice and dont write their results to memory in order not to
* overwrite the data of the non-atomic write.
*
* Optimizations:
* --------------
* (1) Selective ALU: instantiate ALU operations only for operations used in kernel,
*     e.g. dont instantiate min operation if atomic_min is not used in kernel.
* (2) Free Transactions: dont keep state for non-atomic reads, if there are
*     no atomics in flight.
*
*****************************/

module acl_atomics_nostall
(
   clock, resetn,

   // arbitration port
   mem_arb_enable, //not used
   mem_arb_read,
   mem_arb_write,
   mem_arb_burstcount,
   mem_arb_address,
   mem_arb_writedata,
   mem_arb_byteenable,
   mem_arb_waitrequest,
   mem_arb_readdata,
   mem_arb_readdatavalid,
   mem_arb_writeack,

   //  Avalon port
   mem_avm_enable, //not used
   mem_avm_read,
   mem_avm_write,
   mem_avm_burstcount,
   mem_avm_address,
   mem_avm_writedata,
   mem_avm_byteenable,
   mem_avm_waitrequest,
   mem_avm_readdata,
   mem_avm_readdatavalid,
   mem_avm_writeack
);

/*************
* Parameters *
*************/

// WARNING: this MUST match numAtomicOperations in ACLIntrinsics.h
parameter ATOMIC_OP_WIDTH=3; // this many atomic operations 

// WARNING: this MUST match the alignment of atomic instructions (for now, it is 
// always 4).
parameter SEGMENT_WIDTH_BYTES=4;

parameter USED_ATOMIC_OPERATIONS=8'b11111111; // atomics operations used in kernel
parameter ADDR_WIDTH=27; // width of addresses to memory
parameter DATA_WIDTH=96; // size of data chunks from/to memory
parameter BURST_WIDTH=6; // size of burst
parameter BYTEEN_WIDTH=32; // this many bytes in each data chunk
parameter OPERATION_WIDTH=32; // atomic operations are ALL 32-bit
parameter NUM_TXS=4; // support this many txs in flight
parameter COUNTER_WIDTH=32; // keep track of this many request between a memory request and its response

parameter LOCAL_MEM=0;

/******************
* Local Variables *
******************/

localparam OPERATION_WIDTH_BITS=$clog2(OPERATION_WIDTH);
localparam DATA_WIDTH_BITS=$clog2(DATA_WIDTH);
localparam DATA_WIDTH_BYTES=(DATA_WIDTH >> 3);
localparam DATA_WIDTH_BYTES_BITS=$clog2(DATA_WIDTH_BYTES);
localparam SEGMENT_WIDTH_BITS=$clog2(SEGMENT_WIDTH_BYTES);

// tx states
localparam tx_ST_IDLE=0;
localparam tx_ST_READ=1;
localparam tx_ST_ALU=2;
localparam tx_ST_WRITEBACK=3;
localparam NUM_STATES = 4; // must be power-of-2

// memory request types
localparam op_NONE=0;
localparam op_READ=1;
localparam op_WRITE=2;
localparam op_ATOMIC=3;
localparam NUM_OPS = 4; // must be power-of-2

localparam NO_TX=NUM_TXS;
localparam NUM_TXS_BITS = $clog2(NUM_TXS);
localparam NUM_STATES_BITS = $clog2(NUM_STATES);
localparam NUM_OPS_BITS = $clog2(NUM_OPS);

/********
* Ports *
********/

// Standard global signals
input logic clock;
input logic resetn;

// Arbitration port
input logic mem_arb_enable;
input logic mem_arb_read;
input logic mem_arb_write;
input logic [BURST_WIDTH-1:0] mem_arb_burstcount;
input logic [ADDR_WIDTH-1:0] mem_arb_address;
input logic [DATA_WIDTH-1:0] mem_arb_writedata;
input logic [BYTEEN_WIDTH-1:0] mem_arb_byteenable;
output logic mem_arb_waitrequest;
output logic [DATA_WIDTH-1:0] mem_arb_readdata;
output logic mem_arb_readdatavalid;
output logic mem_arb_writeack;

// Avalon port
output mem_avm_enable;
output mem_avm_read;
output mem_avm_write;
output [BURST_WIDTH-1:0] mem_avm_burstcount;
output [ADDR_WIDTH-1:0] mem_avm_address;
output [DATA_WIDTH-1:0] mem_avm_writedata;
output [BYTEEN_WIDTH-1:0] mem_avm_byteenable;
input mem_avm_waitrequest;
input [DATA_WIDTH-1:0] mem_avm_readdata;
input mem_avm_readdatavalid;
input mem_avm_writeack;

/***********************
* Transaction Metadata *
***********************/

reg [NUM_OPS_BITS-1:0] tx_op [0:NUM_TXS]; // read, write, atomic
reg [NUM_STATES_BITS-1:0] tx_state [0:NUM_TXS]; // read, alu, writeback
reg [ATOMIC_OP_WIDTH-1:0] tx_atomic_op [0:NUM_TXS]; // add, min, max, xor, and, etc.
reg [ADDR_WIDTH-1:0] tx_address [0:NUM_TXS];
reg [BYTEEN_WIDTH-1:0] tx_byteenable [0:NUM_TXS];
reg [BURST_WIDTH-1:0] tx_burstcount [0:NUM_TXS];
reg [DATA_WIDTH_BITS-1:0] tx_segment_address [0:NUM_TXS];
reg [OPERATION_WIDTH-1:0] tx_operand0 [0:NUM_TXS]; // operand0 of atomic operation
reg [OPERATION_WIDTH-1:0] tx_operand1 [0:NUM_TXS]; // operand1 of atomic operation
reg [OPERATION_WIDTH-1:0] tx_atomic_forwarded_readdata [0:NUM_TXS]; // forwarded data from earlier txs
reg tx_atomic_forwarded [0:NUM_TXS]; // data is forwarded from another atomic tx
reg [BYTEEN_WIDTH-1:0] tx_bytedisable [0:NUM_TXS]; // dont write to this address
reg [NUM_TXS-1:0] tx_conflict_list[0:NUM_TXS]; // active txs that this tx is conflicting with
reg [BURST_WIDTH-1:0] tx_num_outstanding_responses [0:NUM_TXS]; // responses this tx will receive, it is initialized to burstcount, tx remains in READ state until it is zero
reg [OPERATION_WIDTH-1:0] tx_writedata [0:NUM_TXS]; // what will be commited to memory

// these registers are used by a single tx at a time, so they are pipelined, and 
// not replicated.
reg [OPERATION_WIDTH-1:0] tx_readdata; // what was read from memory, or forwarded, input for alu
wire [OPERATION_WIDTH-1:0] tx_alu_out; // the result of the atomic operation

reg [COUNTER_WIDTH-1:0] count_requests; // number of read requests that are sent to memory
reg [COUNTER_WIDTH-1:0] count_responses; // number of responses received from memory

/******************
* Various Signals *
******************/

reg [NUM_TXS_BITS:0] num_active_atomic_txs; // number of atomic txs in flight
reg [NUM_TXS_BITS:0] free_slot; // unoccupied slot next tx will be inserted in
wire slots_full; // high if all slots are full

// conflict detection
logic atomic_active[0:NUM_TXS];
logic conflicting_ops[0:NUM_TXS];
logic address_conflict[0:NUM_TXS];
logic byteen_conflict[0:NUM_TXS];
logic conflict[0:NUM_TXS];
logic [NUM_TXS:0] conflicts;
wire [NUM_TXS:0] conflicting_txs;

// decode the new transaction
wire [NUM_OPS_BITS-1:0] new_op_type;
wire [OPERATION_WIDTH-1:0] new_operand0;
wire [OPERATION_WIDTH-1:0] new_operand1;
wire [DATA_WIDTH_BITS-1:0] new_segment_address;
wire [ATOMIC_OP_WIDTH-1:0] new_atomic_op;

// find transactions in various stages
wire is_readdata_received;
logic [NUM_TXS_BITS:0] tx_readdata_received;
wire [DATA_WIDTH_BITS-1:0] segment_address_in_read_received;
wire atomic_forwarded_in_read_received;
wire [OPERATION_WIDTH-1:0] atomic_forwarded_readdata_in_read_received;

// oldest tx in READ state
reg [NUM_TXS_BITS:0] tx_next_readdata_received;

reg [NUM_TXS_BITS:0] tx_in_alu;
reg [NUM_OPS_BITS-1:0] op_in_alu;
reg [ATOMIC_OP_WIDTH-1:0] atomic_op_in_alu;
reg [OPERATION_WIDTH-1:0] operand0_in_alu;
reg [OPERATION_WIDTH-1:0] operand1_in_alu;
reg [DATA_WIDTH_BITS-1:0] segment_address_in_alu;

reg [DATA_WIDTH-1:0] tx_alu_out_last; // what was alu out last cycle?
reg [NUM_TXS_BITS:0] tx_in_alu_last; // which tx was in alu last cycle?

reg [NUM_TXS_BITS:0] num_txs_in_writeback; // number of txs waiting to commit to memory

reg [NUM_TXS_BITS:0] tx_in_writeback;
reg [NUM_OPS_BITS-1:0] op_in_writeback;
reg [DATA_WIDTH-1:0] writedata_in_writeback;
reg [ADDR_WIDTH-1:0] address_in_writeback;
reg [BYTEEN_WIDTH-1:0] byteenable_in_writeback;
reg [BURST_WIDTH-1:0] burstcount_in_writeback;

// keep track of oldest/youngest transaction
wire oldest_tx_is_committing;
wire youngest_tx_is_committing;
reg [NUM_TXS_BITS:0] oldest_tx;
reg [NUM_TXS_BITS:0] youngest_tx;

// control signals
wire can_send_read;
wire can_send_non_atomic_write;
wire can_send_atomic_write;
wire can_return_readdata;
wire [DATA_WIDTH-1:0] rrp_readdata;

wire send_read;
wire send_non_atomic_write;
wire send_atomic_write;

wire tx_commits;
wire new_read_request;
wire atomic_tx_starts;
wire atomic_tx_commits;

// support for "free" txs 
// (i.e. txs that are not inserted in slots because they are no atomics in flight)
wire free_tx; // no atomic read tx and no atomics in slots.
wire free_tx_starts; // no atomic read tx and no atomics in slots.
wire free_readdata_expected; // next readdata response belongs to a free tx
wire free_readdata_received; // received readdata response belongs to a free tx
reg [COUNTER_WIDTH-1:0] free_requests; 
reg [COUNTER_WIDTH-1:0] free_responses;

integer t;

/***************
* Local Memory *
***************/

wire [BURST_WIDTH-1:0] input_burstcount;

// connect unconnected signals in local memory
generate
if( LOCAL_MEM == 0 ) assign input_burstcount = mem_arb_burstcount;
else assign input_burstcount = 1;
endgenerate

/*********************************
* Arbitration/Avalon connections *
*********************************/

assign mem_avm_enable = mem_arb_enable;
assign mem_avm_read = ( send_read || free_tx );
assign mem_avm_write = ( send_non_atomic_write || send_atomic_write );
assign mem_avm_burstcount = ( send_read || free_tx || send_non_atomic_write ) ? input_burstcount : burstcount_in_writeback;
assign mem_avm_address = ( send_read || free_tx || send_non_atomic_write ) ? mem_arb_address : address_in_writeback;
assign mem_avm_writedata = send_non_atomic_write ? mem_arb_writedata : writedata_in_writeback; 
assign mem_avm_byteenable = ( send_read || free_tx || send_non_atomic_write ) ? mem_arb_byteenable : byteenable_in_writeback;
assign mem_arb_waitrequest = ( mem_avm_waitrequest || ( mem_arb_read && !can_send_read && !free_tx ) );
assign mem_arb_readdatavalid = ( can_return_readdata | free_readdata_received );
assign mem_arb_writeack =  mem_avm_writeack;
assign mem_arb_readdata = free_readdata_received ? mem_avm_readdata : rrp_readdata;

/******************
* Control Signals *
******************/

// a read request (atomic or non-atomic) is stalled if all slots are full or
// there is an atomic tx writing to memory.
// free txs are never stalled.
assign can_send_read = ~free_tx && // no need to occupy slot
                       ~slots_full &&
                       ~send_atomic_write;

// non atomic write has priority, it is never stalled
assign can_send_non_atomic_write = 1'b1;

// atomic writes are stalled only if there is a free tx request
assign can_send_atomic_write = ~( free_tx || ( mem_arb_write && can_send_non_atomic_write) );

// what goes through the atomic module (for arbitration/avalon connections)
assign send_read = mem_arb_read && can_send_read;
assign send_non_atomic_write = mem_arb_write && can_send_non_atomic_write; 
assign send_atomic_write = can_send_atomic_write && tx_in_writeback != NO_TX && op_in_writeback == op_ATOMIC;

// what actually happens (take into account waitrequest)
wire tx_can_commit =     ( ~mem_avm_waitrequest && can_send_atomic_write );
assign tx_commits =        ( ~mem_avm_waitrequest && can_send_atomic_write && tx_in_writeback != NO_TX );
assign new_read_request =  ( ~mem_avm_waitrequest && can_send_read && mem_arb_read );
assign atomic_tx_starts =  ( ~mem_avm_waitrequest && can_send_read && new_op_type == op_ATOMIC );
assign atomic_tx_commits = ( ~mem_avm_waitrequest && can_send_atomic_write && tx_in_writeback != NO_TX && op_in_writeback == op_ATOMIC );

/*************************
* Decode the new request *
**************************/

assign new_op_type = ( mem_arb_read & mem_arb_writedata[0:0] ) ? op_ATOMIC : mem_arb_read ? op_READ : mem_arb_write ? op_WRITE : op_NONE;
assign new_operand0 = mem_arb_writedata[1 +: OPERATION_WIDTH];  // mem_arb_writedata[32:1]
assign new_operand1 = mem_arb_writedata[OPERATION_WIDTH+1 +: OPERATION_WIDTH]; //mem_arb_writedata[64:33]
assign new_atomic_op = mem_arb_writedata[2*OPERATION_WIDTH+1 +: ATOMIC_OP_WIDTH];   // mem_arb_writedata[70:65]
assign new_segment_address = ( mem_arb_writedata[2*OPERATION_WIDTH+ATOMIC_OP_WIDTH+1 +: DATA_WIDTH_BYTES_BITS ] << (OPERATION_WIDTH_BITS - SEGMENT_WIDTH_BITS) ); // mem_arb_writedata[75:71]

/********************
* Free Transactions *
********************/

assign free_tx = ( new_op_type == op_READ && num_active_atomic_txs == 0 );
assign free_tx_starts = ( free_tx && ~mem_avm_waitrequest );
// the next readdata will belong to a free tx if the number of free requests dont
// match the number of responses received for free txs
assign free_readdata_expected = ( free_requests != free_responses );
assign free_readdata_received = ( ( mem_avm_readdatavalid == 1'b1 ) && ( free_requests != free_responses ) );

always@(posedge clock or negedge resetn)
begin

   if ( !resetn ) begin
     free_requests <= { COUNTER_WIDTH{1'b0} };
     free_responses <= { COUNTER_WIDTH{1'b0} };
   end
   else begin
     
     if( free_tx_starts ) begin
       free_requests <= free_requests + input_burstcount;
     end

     if( free_readdata_received ) begin
       free_responses <= free_responses + 1;
     end
   end
end

/*****************
* Find Free Slot *
*****************/

assign slots_full = (free_slot == NO_TX); 

always@(posedge clock or negedge resetn)
begin
  if ( !resetn ) begin
    free_slot <= 0;
  end
  else begin
    // initial condition, no tx in flight and there is no new request
    if( youngest_tx == NO_TX && !new_read_request ) begin
      free_slot <= 0;
    end
    // no tx in flight, and there is a new request
    else if( youngest_tx == NO_TX && new_read_request ) begin
      free_slot <= 1;
    end
    // there are txs in flight, and there is a new request
    else if( new_read_request ) begin
      free_slot <= ( tx_state[(free_slot+1)%NUM_TXS] == tx_ST_IDLE ) ? ( (free_slot+1)%NUM_TXS ) :
                   ( oldest_tx_is_committing ) ? oldest_tx : NO_TX;
    end
    // there is no new request and youngest tx (and only tx) is committing
    else if( youngest_tx_is_committing ) begin
      free_slot <= 0;
    end
    // there is no new request, all slots are full but oldest tx is committing
    else if( oldest_tx_is_committing && free_slot == NO_TX ) begin
      free_slot <= oldest_tx;
    end
  end
end

/***************************
* Find Active Transactions *
****************************/

always@(posedge clock or negedge resetn)
begin
  if ( !resetn ) begin
    num_active_atomic_txs <= {NUM_TXS_BITS{1'b0}};
  end
  else begin
    // new atomic transaction starting
    if( atomic_tx_starts && !atomic_tx_commits ) begin
      num_active_atomic_txs <= num_active_atomic_txs + 1;
    end
    // atomic transaction is committing
    if( !atomic_tx_starts && atomic_tx_commits ) begin
      num_active_atomic_txs <= num_active_atomic_txs - 1;
    end
  end
end

/*********************
* Conflict Detection *
*********************/

always @(*)
begin
  conflicts = {NUM_TXS{1'b0}};
  for (t=0; t<=NUM_TXS; t=t+1)
  begin
    // tx is active and not committing in this cycle
    atomic_active[t] = ( ( tx_state[t] != tx_ST_IDLE ) && !( tx_can_commit && t == tx_in_writeback ) );
    // keep track of conflicts only with atomics, non-atomic conflicts do not 
    // matter because we dont support sequential consistency
    conflicting_ops[t] = ( ( new_op_type == op_ATOMIC || new_op_type == op_WRITE ) && ( tx_op[t] == op_ATOMIC ) );
    address_conflict[t] = ( tx_address[t] == mem_arb_address );
    byteen_conflict[t] = ( ( ( tx_byteenable[t] & ~tx_bytedisable[t] ) & mem_arb_byteenable ) != {BYTEEN_WIDTH{1'b0}} );
    conflict[t] = atomic_active[t] & conflicting_ops[t] & address_conflict[t] & byteen_conflict[t];
    if( conflict[t] ) begin
      conflicts = conflicts | ( 1 << t );
    end
  end
end

assign conflicting_txs = conflicts;

/******************************
* Youngest/Oldest transaction *
******************************/

assign youngest_tx_is_committing = ( tx_can_commit && tx_in_writeback == youngest_tx );
assign oldest_tx_is_committing = ( tx_can_commit && tx_in_writeback == oldest_tx );

always@(posedge clock or negedge resetn)
begin
  if ( !resetn ) begin
    youngest_tx <= NO_TX;
  end
  else begin
    // new transaction in free_slot
    if( new_read_request ) begin
      youngest_tx <= free_slot;
    end
    else if( youngest_tx_is_committing ) begin
      youngest_tx <= NO_TX;
    end
  end
end

// find the first active transaction that comes after oldest_tx
wire [NUM_TXS_BITS:0] next_oldest_tx;
wire [NUM_TXS_BITS:0] next_oldest_tx_index;
assign next_oldest_tx_index = ( (oldest_tx+1) % NUM_TXS );
assign next_oldest_tx = ( tx_state[ next_oldest_tx_index ] != tx_ST_IDLE ) ? next_oldest_tx_index : NO_TX;

always@(posedge clock or negedge resetn)
begin
  if ( !resetn ) begin
    oldest_tx <= NO_TX;
  end
  else begin

    // oldest tx is committing, there is no other tx, and there is a new request inserted in free_slot
    if( oldest_tx_is_committing && next_oldest_tx == NO_TX && new_read_request ) begin
      oldest_tx <= free_slot;
    end
    // oldest tx is committing, but there are other txs or there is no new request
    else if ( oldest_tx_is_committing ) begin
      oldest_tx <= next_oldest_tx;
    end
    // there are no txs in flight, and new request inserted in free_slot
    else if ( new_read_request && ( oldest_tx == NO_TX ) ) begin
      oldest_tx <= free_slot;
    end

  end
end

/********************
* State Transitions *
********************/

always@(posedge clock or negedge resetn)
begin
  for (t=0; t<=NUM_TXS; t=t+1)
  begin
    if (!resetn) begin
      tx_state[t] <= tx_ST_IDLE;
      tx_op[t] <= op_NONE;
      tx_atomic_op[t] <= {ATOMIC_OP_WIDTH{1'b0}};
      tx_address[t] <= {ADDR_WIDTH{1'b0}};
      tx_byteenable[t] <= {BYTEEN_WIDTH{1'b0}};
      tx_segment_address[t] <= {DATA_WIDTH_BITS{1'b0}};
      tx_operand0[t] <= {OPERATION_WIDTH{1'b0}};
      tx_operand1[t] <= {OPERATION_WIDTH{1'b0}};
      tx_conflict_list[t] <=  {NUM_TXS{1'b0}};
    end
    else begin
      case (tx_state[t])

        tx_ST_IDLE:
        begin
          // new request inserted in free_slot
          if ( new_read_request && ( t == free_slot ) ) begin
            tx_state[t] <= tx_ST_READ;
            tx_op[t] <= new_op_type;
            tx_atomic_op[t] <= new_atomic_op;
            tx_address[t] <= mem_arb_address;
            tx_byteenable[t] <= mem_arb_byteenable;
            tx_burstcount[t] <= input_burstcount;
            tx_segment_address[t] <= new_segment_address;
            tx_operand0[t] <= new_operand0;
            tx_operand1[t] <= new_operand1;
            tx_conflict_list[t] <= conflicting_txs;
          end
        end

        tx_ST_READ:
        begin
          // readdata received from memory, sending readdatavalid to arb
          // all the conflicts must already be resolved, also guaranteed
          // to return data in order
          // dont switch state unless ALL responses have arrived if burstcount >1
          if( tx_readdata_received == t && (tx_num_outstanding_responses[t] == 1) ) begin
            tx_state[t] <= tx_ST_ALU;
          end
        end

        // ALU takes a single cycle
        tx_ST_ALU:
        begin
          tx_state[t] <= tx_ST_WRITEBACK;
        end

        // write atomic result to memory if not stalled
        tx_ST_WRITEBACK:
        begin
          tx_state[t] <= ( tx_can_commit && tx_in_writeback == t ) ? tx_ST_IDLE : tx_ST_WRITEBACK;
        end

      endcase
    end
  end
end

/**************************************
* Find Transaction that Receives Data *
**************************************/

// find the first active transaction that comes after tx_next_readdata_received
wire [NUM_TXS_BITS:0] next_tx_next_readdata_received;
wire [NUM_TXS_BITS:0] next_tx_next_readdata_received_index;
// the next-next tx that will receive readdata comes after the current tx expecting readddata
assign next_tx_next_readdata_received_index = ( (tx_next_readdata_received+1) % NUM_TXS );
// the next tx has already issued a read request, or it is issueing it in this cycle
assign next_tx_next_readdata_received = ( tx_state[ next_tx_next_readdata_received_index ] == tx_ST_READ || 
                                          ( new_read_request && free_slot == next_tx_next_readdata_received_index ) ) ? next_tx_next_readdata_received_index : NO_TX;

always@(posedge clock or negedge resetn)
begin
  if ( !resetn ) begin
    tx_next_readdata_received <= NO_TX;
  end
  else begin

    // currently no tx is expecting readdata and there is a new tx at free_slot
    if( tx_next_readdata_received == NO_TX && new_read_request ) begin
      tx_next_readdata_received <= free_slot;
    end
    // the tx that expects readdata received it in this cycle,
    // so it is not expecting readdata anymore, move to the next
    else if ( tx_next_readdata_received != NO_TX && 
              mem_avm_readdatavalid && 
              ~free_readdata_expected &&
              // all readdata responses have been received in case burstcount > 1
              ( tx_num_outstanding_responses[tx_next_readdata_received] == 1 ) ) begin
      tx_next_readdata_received <= next_tx_next_readdata_received;
    end
  end
end

// certain parameters that belong to tx that receives the readdata in this cycle
// if no readdata is received (i.e. tx_readdata_received == NO_TX ), 
// these values would be wrong, but neither alu input nor return readdata does not matter anyways
assign segment_address_in_read_received = tx_segment_address[tx_next_readdata_received];
assign atomic_forwarded_in_read_received = tx_atomic_forwarded[tx_next_readdata_received];
assign atomic_forwarded_readdata_in_read_received = tx_atomic_forwarded_readdata[tx_next_readdata_received];

assign is_readdata_received = ( mem_avm_readdatavalid && ~free_readdata_expected );
assign tx_readdata_received = is_readdata_received ? tx_next_readdata_received : NO_TX;

/**************************
* Find Transaction in ALU *
**************************/

always@(posedge clock or negedge resetn)
begin
  if (!resetn) begin
    tx_in_alu <= NO_TX;
    op_in_alu <= op_NONE;
    atomic_op_in_alu <= op_NONE;
    operand0_in_alu <= {OPERATION_WIDTH{1'b0}};
    operand1_in_alu <= {OPERATION_WIDTH{1'b0}};
    segment_address_in_alu <= {DATA_WIDTH_BITS{1'b0}};
  end
  // do not transition to alu state if tx that received readdata has burstcount > 1
  // and still serving outstanding requests
  else if(tx_num_outstanding_responses[tx_readdata_received] != 1) begin
    tx_in_alu <= NO_TX;
  end
  else begin
    tx_in_alu <= tx_readdata_received;
    op_in_alu <= tx_op[tx_next_readdata_received];
    atomic_op_in_alu <= tx_atomic_op[tx_next_readdata_received];
    operand0_in_alu <= tx_operand0[tx_next_readdata_received];
    operand1_in_alu <= tx_operand1[tx_next_readdata_received];
    segment_address_in_alu <= tx_segment_address[tx_next_readdata_received];
  end
end

// find tx that was in alu in the last cycle
always@(posedge clock or negedge resetn)
begin

   if ( !resetn ) begin
     tx_alu_out_last <= { DATA_WIDTH{1'bx} };
     tx_in_alu_last <= NO_TX;
   end
   else begin
     tx_alu_out_last <= tx_alu_out;
     tx_in_alu_last <= tx_in_alu;
   end

end

/***************************************
* Find Transactions in Writeback State *
***************************************/

always@(posedge clock or negedge resetn)
begin
  if (!resetn) begin
    num_txs_in_writeback <= {NUM_TXS_BITS{1'b0}};
  end
  else
  begin
    if( tx_commits && tx_in_alu == NO_TX ) begin
      num_txs_in_writeback <= num_txs_in_writeback - 1;
    end
    else if( !tx_commits && tx_in_alu != NO_TX ) begin
      num_txs_in_writeback <= num_txs_in_writeback + 1;
    end
  end
end

always@(posedge clock or negedge resetn)
begin
  if (!resetn) begin
    tx_in_writeback <= NO_TX;
    op_in_writeback <= op_NONE;
    writedata_in_writeback <= {DATA_WIDTH{1'b0}};
    address_in_writeback <= {ADDR_WIDTH{1'b0}};
    byteenable_in_writeback <= {BYTEEN_WIDTH{1'b0}};
    burstcount_in_writeback <= {BURST_WIDTH{1'b0}};
  end
  else
  // oldest tx (i.e. tx_in_writeback) is committing
  // and next_oldest is also in atomic_writeback
  if( tx_can_commit && num_txs_in_writeback > 1 )
  //if(oldest_tx_is_committing && tx_state[next_oldest_tx_index] == tx_ST_WRITEBACK )
  begin
    tx_in_writeback <= next_oldest_tx;
    op_in_writeback <= tx_op[next_oldest_tx_index];
    writedata_in_writeback <= ( tx_writedata[next_oldest_tx_index] << tx_segment_address[next_oldest_tx_index] );
    address_in_writeback <= tx_address[next_oldest_tx_index];
    byteenable_in_writeback <= ( tx_byteenable[next_oldest_tx_index] & ~tx_bytedisable[next_oldest_tx_index] );
    burstcount_in_writeback <= tx_burstcount[next_oldest_tx_index];
  end
  else
  // oldest tx (i.e. tx_in_writeback) is committing
  // or there is no tx in atomic writeback stage
  if( tx_can_commit || ( num_txs_in_writeback == 0 ) )
  begin
    tx_in_writeback <= tx_in_alu;
    op_in_writeback <= tx_op[tx_in_alu];
    writedata_in_writeback <= ( tx_alu_out << segment_address_in_alu );
    address_in_writeback <= tx_address[tx_in_alu];
    byteenable_in_writeback <= ( tx_byteenable[tx_in_alu] & ~tx_bytedisable[tx_in_alu] );
    burstcount_in_writeback <= tx_burstcount[tx_in_alu];
  end
end

/********************************
* Count read requests/responses *
********************************/

always@(posedge clock or negedge resetn)
begin

   if ( !resetn ) begin
     count_requests <= { COUNTER_WIDTH{1'b0} };
     count_responses <= { COUNTER_WIDTH{1'b0} };
   end
   else begin
     
     // new read request
     if( mem_avm_read & ~mem_avm_waitrequest ) begin
       count_requests <= count_requests + input_burstcount;
     end

     // new read response
     if( mem_avm_readdatavalid ) begin
       count_responses <= count_responses + 1;
     end
   end
end

/****************************************
* Compute outstanding requests for a tx *
****************************************/

always@(posedge clock or negedge resetn)
begin
  for (t=0; t<=NUM_TXS; t=t+1)
  begin
    if (!resetn) begin
      tx_num_outstanding_responses[t] <= {BURST_WIDTH{1'b0}};
    end
    else if( new_read_request && t == free_slot ) begin
      tx_num_outstanding_responses[t] <= input_burstcount;
    end
    else if( t == tx_readdata_received ) begin //&& tx_state[t] == tx_ST_READ ) begin
      tx_num_outstanding_responses[t] <= tx_num_outstanding_responses[t] - 1;
    end
  end
end

/**********************************
* Non-atomic Write to Bytedisable *
**********************************/

// WARNING: Arbitration should make sure that a non-atomic write and atomic writeback
// do not happen in the same cycle. Thus, atomic does not miss the bytedisable
// signal when it writebacks
always@(posedge clock or negedge resetn)
begin
  for (t=0; t<=NUM_TXS; t=t+1)
  begin
    if (!resetn) begin
      tx_bytedisable[t] <= {BYTEEN_WIDTH{1'b0}};
    end
    else if ( tx_state[t] == tx_ST_IDLE ) begin
       tx_bytedisable[t] <= {BYTEEN_WIDTH{1'b0}};
    end
    else
    // conflicting write with this tx
    if( mem_arb_write && ( conflicts & (1 << t) ) ) begin
      tx_bytedisable[t] <= ( tx_bytedisable[t] | mem_arb_byteenable );
    end
  end
end

/****************************
* Find conflict with ALU tx *
****************************/

// detect the dependence early, so next cycle we know the conflict
reg readdata_received_conflicts_with_alu;

always@(posedge clock or negedge resetn)
begin
  if (!resetn) begin
    readdata_received_conflicts_with_alu <= 1'b0;
  end
   // readdata is received by a tx and this tx conflicts with tx that comes after it
   // i.e. when this tx reaches ALU in the next cycle, it will conflict with the
   // tx that receives readdata
  else if ( ( is_readdata_received ) &&
            ( ( tx_conflict_list[next_tx_next_readdata_received_index] & (1 << tx_next_readdata_received) ) != 0 ) ) begin
    readdata_received_conflicts_with_alu <= 1'b1;
  end
  else begin
    readdata_received_conflicts_with_alu <= 1'b0;
  end
end

/**************************
* Compute Return Readdata *
**************************/

logic [DATA_WIDTH-1:0] merge_readdata;

integer p;
always@(*)
begin
  merge_readdata = mem_avm_readdata;

  // merge with alu out
  if( readdata_received_conflicts_with_alu ) begin
    merge_readdata[segment_address_in_read_received +: OPERATION_WIDTH] = tx_alu_out;
  end
  // merge with forwarded data
  else if( atomic_forwarded_in_read_received == 1'b1 ) begin
    merge_readdata[segment_address_in_read_received +: OPERATION_WIDTH] = atomic_forwarded_readdata_in_read_received;
  end

end

// readdata path is guaranteed to be in program order because 
// a single tx will send read signal in each cycle
assign can_return_readdata = is_readdata_received;
assign rrp_readdata = merge_readdata;

/*******************
* Select ALU Input *
*******************/

wire [OPERATION_WIDTH-1:0] selected_readdata;
assign selected_readdata = readdata_received_conflicts_with_alu ? tx_alu_out : 
                           ( atomic_forwarded_in_read_received == 1'b1 ) ? atomic_forwarded_readdata_in_read_received :
                           mem_avm_readdata[segment_address_in_read_received +: OPERATION_WIDTH];

always@(posedge clock or negedge resetn)
begin
  if (!resetn) begin
    tx_readdata <= {OPERATION_WIDTH{1'b0}};
  end
  else begin
    tx_readdata <= selected_readdata;
  end
end

/*********************
* Compute Atomic Out *
*********************/

atomic_alu # (.USED_ATOMIC_OPERATIONS(USED_ATOMIC_OPERATIONS), .ATOMIC_OP_WIDTH(ATOMIC_OP_WIDTH), .OPERATION_WIDTH(OPERATION_WIDTH)) tx_alu
( 
  .readdata( tx_readdata ),
  .atomic_op( atomic_op_in_alu ),
  .operand0( operand0_in_alu ),
  .operand1( operand1_in_alu ),
  .atomic_out( tx_alu_out )
);

always@(posedge clock or negedge resetn)
begin
  for (t=0; t<=NUM_TXS; t=t+1)
  begin 
    if (!resetn) begin
      tx_writedata[t] <= {DATA_WIDTH{1'b0}};
    end
    else if( tx_state[t] == tx_ST_ALU ) begin
      tx_writedata[t] <= tx_alu_out;
    end   
  end
end

/******************
* Data Forwarding *
******************/

always@(posedge clock or negedge resetn)
begin
  for (t=0; t<=NUM_TXS; t=t+1)
  begin
    if (!resetn) begin
      tx_atomic_forwarded_readdata[t] <= {OPERATION_WIDTH{1'b0}};
      tx_atomic_forwarded[t] <= 1'b0;
    end
    // this tx is a new tx
    else if( mem_arb_read == 1'b1 && t == free_slot ) begin
      tx_atomic_forwarded_readdata[t] <= {OPERATION_WIDTH{1'b0}};
      tx_atomic_forwarded[t] <= 1'b0;
    end
      // this tx has a conflict with the tx in ALU
    else if( (tx_conflict_list[t] & (1 << tx_in_alu)) != 0 ) begin
      tx_atomic_forwarded_readdata[t] <= tx_alu_out;
      tx_atomic_forwarded[t] <= 1'b1;
    end
     // this tx had a conflict with the tx in ALU last cycle (matters when this is a new tx)
    else if( ( tx_conflict_list[t] & (1 << tx_in_alu_last) ) != 0 ) begin
      tx_atomic_forwarded_readdata[t] <= tx_alu_out_last;
      tx_atomic_forwarded[t] <= 1'b1;
    end
  end
end

endmodule

/****************************
* ALU for atomic operations *
****************************/

module atomic_alu
(
   readdata,
   atomic_op,
   operand0,
   operand1,
   atomic_out
);

parameter ATOMIC_OP_WIDTH=3; // this many atomic operations 
parameter OPERATION_WIDTH=32; // atomic operations are ALL 32-bit

parameter USED_ATOMIC_OPERATIONS=8'b00000001;

// WARNING: these MUST match ACLIntrinsics::ID enum in ACLIntrinsics.h
localparam a_ADD=0;
localparam a_XCHG=1;
localparam a_CMPXCHG=2;
localparam a_MIN=3;
localparam a_MAX=4;
localparam a_AND=5;
localparam a_OR=6;
localparam a_XOR=7;

// Standard global signals
input logic [OPERATION_WIDTH-1:0] readdata;
input logic [ATOMIC_OP_WIDTH-1:0] atomic_op;
input logic [OPERATION_WIDTH-1:0] operand0;
input logic [OPERATION_WIDTH-1:0] operand1;
output logic [OPERATION_WIDTH-1:0] atomic_out;

wire [31:0] atomic_out_add /* synthesis keep */;
wire [31:0] atomic_out_cmp /* synthesis keep */;
wire [31:0] atomic_out_cmpxchg /* synthesis keep */;
wire [31:0] atomic_out_min /* synthesis keep */;
wire [31:0] atomic_out_max /* synthesis keep */;
wire [31:0] atomic_out_and /* synthesis keep */;
wire [31:0] atomic_out_or /* synthesis keep */;
wire [31:0] atomic_out_xor /* synthesis keep */;

generate
if( ( USED_ATOMIC_OPERATIONS & (1 << a_ADD) ) != 0 ) assign atomic_out_add = readdata + operand0;
else assign atomic_out_add = {ATOMIC_OP_WIDTH{1'bx}};
endgenerate

generate
if( ( USED_ATOMIC_OPERATIONS & (1 << a_XCHG) ) != 0 ) assign atomic_out_cmp = operand0;
else assign atomic_out_cmp = {ATOMIC_OP_WIDTH{1'bx}};
endgenerate

generate
if( ( USED_ATOMIC_OPERATIONS & (1 << a_CMPXCHG) ) != 0 ) assign atomic_out_cmpxchg = ( readdata == operand0 ) ? operand1 : readdata;
else assign atomic_out_cmpxchg = {ATOMIC_OP_WIDTH{1'bx}};
endgenerate

generate
if( ( USED_ATOMIC_OPERATIONS & (1 << a_MIN) ) != 0 ) assign atomic_out_min = ( readdata < operand0 ) ? readdata : operand0;
else assign atomic_out_min = {ATOMIC_OP_WIDTH{1'bx}};
endgenerate

generate
if( ( USED_ATOMIC_OPERATIONS & (1 << a_MAX) ) != 0 ) assign atomic_out_max = (readdata > operand0) ? readdata : operand0;
else assign atomic_out_max = {ATOMIC_OP_WIDTH{1'bx}};
endgenerate

generate
if( ( USED_ATOMIC_OPERATIONS & (1 << a_AND) ) != 0 ) assign atomic_out_and = ( readdata & operand0 );
else assign atomic_out_and = {ATOMIC_OP_WIDTH{1'bx}};
endgenerate

generate
if( ( USED_ATOMIC_OPERATIONS & (1 << a_OR) ) != 0 ) assign atomic_out_or = ( readdata | operand0 );
else assign atomic_out_or = {ATOMIC_OP_WIDTH{1'bx}};
endgenerate

generate
if( ( USED_ATOMIC_OPERATIONS & (1 << a_XOR) ) != 0 ) assign atomic_out_xor = ( readdata ^ operand0 );
else assign atomic_out_xor = {ATOMIC_OP_WIDTH{1'bx}};
endgenerate

always @(*)
begin
  case ( atomic_op )

  a_ADD:
  begin
    atomic_out = atomic_out_add;
  end
  a_XCHG:
  begin
    atomic_out = atomic_out_cmp;
  end
  a_CMPXCHG:
  begin
    atomic_out = atomic_out_cmpxchg;
  end
  a_MIN:
  begin
    atomic_out = atomic_out_min;
  end
  a_MAX:
  begin
    atomic_out = atomic_out_max;
  end
  a_AND:
  begin
    atomic_out = atomic_out_and;
  end
  a_OR:
  begin
    atomic_out = atomic_out_or;
  end
  default:
  begin
    atomic_out = atomic_out_xor;
  end

  endcase
end

endmodule
