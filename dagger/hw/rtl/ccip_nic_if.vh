// Author: Cornell University
//
// Module Name :    ccip_nic_if
// Project :        F-NIC
// Description :    CCI-P NIC interface


`ifndef CCIP_NIC_IF_VH
`define CCIP_NIC_IF_VH

`include "platform_if.vh"

interface ccip_nic_if (
    );


    t_if_ccip_c0_Tx c0Tx;
    logic           c0TxAlmFull;

    t_if_ccip_c1_Tx c1Tx;
    logic           c1TxAlmFull;

    t_if_ccip_c2_Tx c2Tx;

    t_if_ccip_c0_Rx c0Rx;
    t_if_ccip_c1_Rx c1Rx;


    // *************** Data Flow ***************
    //
    // CCI-P --------> ccip_nic_if --------> NIC
    //      to_ccip ->             <- to_nic
    // CCI-P <-------- ccip_nic_if <-------- NIC
    //

    // Source (CCI-P) side view
    modport to_ccip (
        // Memory read requests
        output c0Tx,
        input  c0TxAlmFull,

        // Memory write requests
        output c1Tx,
        input  c1TxAlmFull,

        // MMIO read request
        output c2Tx,

        // Read/Write responses;
        // MMIO requests;
        // UMsgs
        input  c0Rx,    // Read responses
        input  c1Rx     // Write responses
    );

    // Sink (NIC) side view
    modport to_nic (
        // Memory read requests
        input  c0Tx,
        output c0TxAlmFull,

        // Memory write requests
        input  c1Tx,
        output c1TxAlmFull,

        // MMIO read request
        input c2Tx,

        // Read/Write responses;
        // MMIO requests;
        // UMsgs
        output c0Rx,    // Read responses
        output c1Rx     // Write responses
    );

endinterface

`endif //  CCIP_NIC_IF_VH
