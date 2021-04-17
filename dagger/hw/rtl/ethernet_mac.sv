// Author: Cornell University
//
// Based on the original:
//   - Engineer:    mariano.aguirre@intel.com
//   - Create Date: March/2017
//   - Module Name: ccip_eth_csr.v
//   - Project:     Ethernet
//
// Module Name :    ethernet_mac
// Project :        F-NIC
// Description :    Top-level module for the ehternet mac
//                    - instantiates Ethernet MAC
//                    - instantiates Ethernet CSR registers/logic
//

`include "platform_if.vh"

`include "nic_defs.vh"

module ethernet_mac (
    // CCI-P Clocks and Resets
    input           logic             clk,
    input           logic             reset,

    // Host interface
    input           t_if_ccip_Rx      sRx,
    output          t_if_ccip_Tx      sTx,

    // Networking interface
    // TX Avalon-ST interface
    output             tx_clk_out      ,// Avalon-ST TX clk
    output             tx_reset_out    ,// Avalon-ST TX reset
    output             tx_ready_out    ,// Avalon-ST TX ready
    input logic [255:0] tx_data_in    ,// Avalon-ST TX data
    input logic         tx_valid_in    ,// Avalon-ST TX data valid
    input logic         tx_sop_in      ,// Avalon-ST TX start-of-packet
    input logic         tx_eop_in     ,// Avalon-ST TX end-of-packet
    input logic [4:0]   tx_empty_in    ,// Avalon-ST TX empty
    input logic         tx_error_in    ,// Avalon-ST TX error

    // RX Avalon-ST interface
    output           rx_clk_out      ,// Avalon-ST RX clk
    output           rx_reset_out    ,// Avalon-ST RX reset
    output   [255:0] rx_data_out     ,// Avalon-ST RX data
    output           rx_valid_out    ,// Avalon-ST RX data valid
    output           rx_sop_out      ,// Avalon-ST RX start-of-packet
    output           rx_eop_out      ,// Avalon-ST RX end-of-packet
    output     [4:0] rx_empty_out    ,// Avalon-ST RX empty
    output     [5:0] rx_error_out    ,// Avalon-ST RX error
    input logic      rx_ready_in,     // Avalon-ST RX ready

    // Raw HSSI interface
    pr_hssi_if.to_fiu   hssi

    );

    //------------------------------------------------------------------------------
    // Internal signals
    //------------------------------------------------------------------------------
    logic         init_done_r;
    logic  [63:0] afu_scratch;
    logic  [63:0] afu_init;


    //------------------------------------------------------------------------------
    // CSR Address Map
    //------------------------------------------------------------------------------
    localparam AFU_DFH       = 16'h0000;
    localparam AFU_ID_L      = 16'h0008;
    localparam AFU_ID_H      = 16'h0010;
    localparam AFU_INIT      = 16'h0028;
    localparam ETH_CTRL_ADDR = 16'h0030;
    localparam ETH_WR_DATA   = 16'h0038;
    localparam ETH_RD_DATA   = 16'h0040;
    localparam AFU_SCRATCH   = 16'h0048;


    //------------------------------------------------------------------------------
    // Register PR <--> PR signals near interface before consuming it
    //------------------------------------------------------------------------------
    (* noprune *) logic [1:0]  pck_cp2af_pwrState_T1;
    (* noprune *) logic        pck_cp2af_error_T1;

    logic        pck_cp2af_softReset_T1;
    t_if_ccip_Rx pck_cp2af_sRx_T1;
    t_if_ccip_Tx pck_af2cp_sTx_T0;

    ccip_interface_reg inst_green_ccip_interface_reg
    (
        .pClk                   (clk),
        .pck_cp2af_softReset_T0 (reset),
        .pck_cp2af_pwrState_T0  (pck_cp2af_pwrState),
        .pck_cp2af_error_T0     (pck_cp2af_error),
        .pck_cp2af_sRx_T0       (sRx),
        .pck_af2cp_sTx_T0       (pck_af2cp_sTx_T0),

        .pck_cp2af_softReset_T1 (pck_cp2af_softReset_T1),
        .pck_cp2af_pwrState_T1  (pck_cp2af_pwrState_T1),
        .pck_cp2af_error_T1     (pck_cp2af_error_T1),
        .pck_cp2af_sRx_T1       (pck_cp2af_sRx_T1),
        .pck_af2cp_sTx_T1       (sTx)
    );


    //------------------------------------------------------------------------------
    // extracting/setting signals on CCIP interface structure
    //------------------------------------------------------------------------------
    t_ccip_c0_ReqMmioHdr    cp2csr_MmioHdr;
    logic                   cp2csr_MmioWrEn;
    logic                   cp2csr_MmioRdEn;
    t_ccip_mmioData         cp2csr_MmioDin;
    t_ccip_c2_RspMmioHdr    csr2cp_MmioHdr;
    t_ccip_mmioData         csr2cp_MmioDout;
    logic                   csr2cp_MmioDout_v;

    always_comb
    begin
        // Extract Cfg signals from C0 channel
        cp2csr_MmioHdr   = t_ccip_c0_ReqMmioHdr'(pck_cp2af_sRx_T1.c0.hdr);
        cp2csr_MmioWrEn  = pck_cp2af_sRx_T1.c0.mmioWrValid;
        cp2csr_MmioRdEn  = pck_cp2af_sRx_T1.c0.mmioRdValid;
        cp2csr_MmioDin   = pck_cp2af_sRx_T1.c0.data[CCIP_MMIODATA_WIDTH-1:0];
        // Setting Rsp signals to C2 channel
        pck_af2cp_sTx_T0                  = 'b0;
        pck_af2cp_sTx_T0.c2.hdr           = csr2cp_MmioHdr;
        pck_af2cp_sTx_T0.c2.data          = csr2cp_MmioDout;
        pck_af2cp_sTx_T0.c2.mmioRdValid   = csr2cp_MmioDout_v;
    end


    //------------------------------------------------------------------------------
    // CSR registers
    //------------------------------------------------------------------------------
    wire [15:0] csr_addr_4B = cp2csr_MmioHdr.address;
    wire [14:0] csr_addr_8B = cp2csr_MmioHdr.address[15:1];

    t_ccip_mmioData csr_rd_data;


    //------------------------------------------------------------------------------
    // Instantiate an Ethernet MAC
    //------------------------------------------------------------------------------
    logic [31:0] eth_ctrl_addr;
    logic [31:0] eth_wr_data;
    logic [31:0] eth_ctrl_addr_o;
    logic [31:0] eth_rd_data;
    logic   [31:0] ctrl_addr;
    logic   [31:0] wr_data;
    logic   [31:0] rd_data;
    logic init_start;
    logic init_done;

    logic eth_tx_clk;
    logic eth_tx_reset;
    logic eth_tx_ready;
    logic [255:0] eth_tx_data;
    logic eth_tx_valid;
    logic eth_tx_sop;
    logic eth_tx_eop;
    logic [4:0] eth_tx_empty;
    logic eth_tx_error;

    logic eth_rx_clk;
    logic eth_rx_reset;
    logic [255:0] eth_rx_data;
    logic eth_rx_valid;
    logic eth_rx_sop;
    logic eth_rx_eop;
    logic [4:0] eth_rx_empty;
    logic [5:0] eth_rx_error;
    logic eth_rx_ready;

    eth_e2e_e40 prz0 (
        // ETH CSR ports
        .eth_ctrl_addr(eth_ctrl_addr),
        .eth_wr_data(eth_wr_data),
        .eth_rd_data(eth_rd_data),
        .csr_init_start(init_start),
        .csr_init_done(init_done),

        // Connection to BBS
        .hssi(hssi),

        // Avalon networking streams
        .tx_clk_out   (tx_clk_out),
        .tx_reset_out (tx_reset_out),
        .tx_ready_out (tx_ready_out),
        .tx_data_in  (tx_data_in),
        .tx_valid_in (tx_valid_in),
        .tx_sop_in   (tx_sop_in),
        .tx_eop_in   (tx_eop_in),
        .tx_empty_in (tx_empty_in),
        .tx_error_in (tx_error_in),

        .rx_clk_out   (rx_clk_out),
        .rx_reset_out (rx_reset_out),
        .rx_data_out  (rx_data_out),
        .rx_valid_out (rx_valid_out),
        .rx_sop_out   (rx_sop_out),
        .rx_eop_out   (rx_eop_out),
        .rx_empty_out (rx_empty_out),
        .rx_error_out (rx_error_out),
        .rx_ready_in (rx_ready_in)
    );

    logic action_r = 0;
    always @(posedge hssi.f2a_prmgmt_ctrl_clk or posedge hssi.f2a_prmgmt_arst)
    begin
        if (hssi.f2a_prmgmt_arst) begin
            action_r <= 0;
        end else begin
            eth_ctrl_addr[31:16] <= 16'b0;
            if (~action_r & (eth_ctrl_addr_o[17] | eth_ctrl_addr_o[16])) begin
                eth_ctrl_addr <= eth_ctrl_addr_o;
                action_r <= 1'b1;
            end
            if (action_r & (~eth_ctrl_addr_o[17] & ~eth_ctrl_addr_o[16])) begin
                action_r <= 1'b0;
            end
        end
    end

    alt_sync_regs_m2 #(
        .WIDTH(64),
        .DEPTH(2)
    ) sy01(
        .clk(hssi.f2a_prmgmt_ctrl_clk),
        .din({ctrl_addr,wr_data}),
        .dout({eth_ctrl_addr_o,eth_wr_data})
    );

    alt_sync_regs_m2 #(
        .WIDTH(32),
        .DEPTH(2)
    ) sy02(
        .clk(clk),
        .din(eth_rd_data),
        .dout(rd_data)
    );

    always @(posedge clk)
    begin
        init_start    <= afu_init[0];
        init_done_r   <= init_done;
    end

    always @(posedge clk or posedge pck_cp2af_softReset_T1)
    begin
        if (pck_cp2af_softReset_T1)
        begin
            afu_init    <= 'b0;
            ctrl_addr   <= 'b0;
            wr_data     <= 'b0;
            afu_scratch <= 'b0;
        end
        else
        begin
            if (cp2csr_MmioWrEn)
                case (csr_addr_8B[3:0])
                    AFU_INIT     [6:3]: afu_init    <= cp2csr_MmioDin;
                    ETH_CTRL_ADDR[6:3]: ctrl_addr   <= cp2csr_MmioDin[31:0];
                    ETH_WR_DATA  [6:3]: wr_data     <= cp2csr_MmioDin[31:0];
                    AFU_SCRATCH  [6:3]: afu_scratch <= cp2csr_MmioDin;
                    default: ;
                endcase
        end
    end

    always @(posedge clk)
    begin
        case (csr_addr_8B[3:0])
            AFU_DFH      [6:3]: csr_rd_data <= 'h1000000000000001;
            AFU_ID_L     [6:3]: csr_rd_data <= 'hB3C151A1B62ED6C2;
            AFU_ID_H     [6:3]: csr_rd_data <= 'h26B40788034B4389;
            AFU_INIT     [6:3]: begin
                                csr_rd_data    <= afu_init;
                                csr_rd_data[1] <= init_done_r;
                                end
            ETH_CTRL_ADDR[6:3]: csr_rd_data <= 64'b0 | ctrl_addr;
            ETH_WR_DATA  [6:3]: csr_rd_data <= 64'b0 | wr_data;
            ETH_RD_DATA  [6:3]: csr_rd_data <= 64'b0 | rd_data;
            AFU_SCRATCH  [6:3]: csr_rd_data <= afu_scratch;
            default:            csr_rd_data <= 64'b0;
        endcase
    end


    //------------------------------------------------------------------------------
    // build the response signals for CCIP interface
    //------------------------------------------------------------------------------
    logic           csr_ren_T1;
    t_ccip_tid      csr_tid_T1;

    always @(posedge clk or posedge pck_cp2af_softReset_T1)
    begin
        if (pck_cp2af_softReset_T1)
        begin
            csr_ren_T1        <= 1'b0;
            csr2cp_MmioDout_v <= 1'b0;
        end
        else
        begin
            // Pipe Stage T1
            csr_ren_T1 <= cp2csr_MmioRdEn;
            // Pipe Stage T2
            csr2cp_MmioDout_v <= csr_ren_T1;
        end
    end

    always @(posedge clk)
    begin
        // Pipe Stage T1
        csr_tid_T1 <= cp2csr_MmioHdr.tid;
        // Pipe Stage T2
        csr2cp_MmioHdr      <= csr_tid_T1;
        csr2cp_MmioDout     <= csr_rd_data;
    end


endmodule
