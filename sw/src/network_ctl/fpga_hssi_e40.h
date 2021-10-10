// Copyright(c) 2018, Intel Corporation
//
// Redistribution  and  use  in source  and  binary  forms,  with  or  without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of  source code  must retain the  above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name  of Intel Corporation  nor the names of its contributors
//   may be used to  endorse or promote  products derived  from this  software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
// IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/**
 * \fpga_hssi_e40.h
 * \brief HSSI E40 Internal Header
 *
 */
#ifndef __FPGA_HSSI_E40_H__
#define __FPGA_HSSI_E40_H__

#include "fpga_hssi.h"


const struct _hssi_csr e40_csrs[] = {
	// Decribe E40 PHY registers
	{0x0300,
	PHY,
	32,
	"PHY_REVID",
	0x02062015,
	RO,
	"IP core PHY module revision ID"},

	{0x0301,
	PHY,
	32,
	"PHY_SCRATCH",
	0,
	RW,
	"Scratch register available for testing"},

	{0x0302,
	PHY,
	32,
	"PHY_NAME_0",
	0,
	RO,
	"First 4 characters of IP core variation identifier string \"40GE pcs\" or \"100GE pcs\""},

	{0x0303,
	PHY,
	32,
	"PHY_NAME_1",
	0,
	RO,
	"Next 4 characters of IP core variation identifier string \"40GE pcs\" or \"100GE pcs\""},

	{0x0304,
	PHY,
	32,
	"PHY_NAME_2",
	0,
	RO,
	"Final 4 characters of IP core variation identifier string \"40GE pcs\" or \"100GE pcs\""},

	{0x0310,
	PHY,
	6,
	"PHY_CONFIG",
	0,
	RW,
	"set_data_lock(5), set_ref_lock(4), rxp_ignore_freq(3), soft_rxp_rst(2), soft_txp_rst(1), eio_sys_rst(0)"},

	{0x0313,
	PHY,
	10,
	"PHY_PMA_SLOOP",
	0,
	RW,
	"Serial PMA loopback"},

	{0x0314,
	PHY,
	3,
	"PHY_PCS_INDIRECT_ADDR",
	0,
	RW,
	"Indirect addressing of individual FIFO flags in the 10G PCS Native PHY IP core"},

	{0x0315,
	PHY,
	10,
	"PHY_PCS_INDIRECT_DATA",
	0,
	RO,
	"PCS indirect data"},

	{0x0320,
	PHY,
	10,
	"PHY_TX_PLL_LOCKED",
	0,
	RO,
	"Each bit that is asserted indicates that the corresponding lane TX PLL is locked"},

	{0x0321,
	PHY,
	10,
	"PHY_EIOFREQ_LOCKED",
	0,
	RO,
	"Each bit that is asserted indicates that the corresponding lane RX CDR PLL is locked."},

	{0x0322,
	PHY,
	3,
	"PHY_TX_COREPLL_LOCKED",
	0,
	RO,
	"RX PLL is locked(2), TX PLL is locked(1), TX PCS is ready(0)"},

	{0x0323,
	PHY,
	3,
	"PHY_FRAME_ERROR",
	20,
	RO,
	"Each bit that is asserted indicates that the corresponding virtual lane has a frame error"},

	{0x0324,
	PHY,
	3,
	"PHY_SCLR_FRAME_ERROR",
	1,
	RW,
	"Synchronous clear for PHY_FRAME_ERROR register"},

	{0x0325,
	PHY,
	3,
	"PHY_EIO_SFTRESET",
	0,
	RW,
	"Clear the RX FIFO(1), RX PCS reset (0)"},

	{0x0326,
	PHY,
	2,
	"PHY_RXPCS_STATUS",
	0,
	RO,
	" RX PCS is fully aligned and ready to accept traffic"},

	{0x0340,
	PHY,
	32,
	"PHY_REFCLK_KHZ",
	0,
	RO,
	"Reference clock frequency in KHz"},

	{0x0341,
	PHY,
	32,
	"PHY_RXCLK_KHZ",
	0,
	RO,
	"RX clock (clk_rxmac) frequency in KHz"},

	{0x0342,
	PHY,
	32,
	"PHY_TXCLK_KHZ",
	0,
	RO,
	"TX clock (clk_txmac) frequency in KHz"},

	{0x0343,
	PHY,
	32,
	"PHY_RECCLK_KHZ",
	0,
	RO,
	"RX recovered clock frequency in KHz"},

	{0x0344,
	PHY,
	32,
	"PHY_TXIOCLK_KHZ",
	0,
	RO,
	"TX PMA clock frequency in KHz"},

	// TX MAC Configuration registers
	{0x0400,
	NA,
	32,
	"TXMAC_REVID",
	0x02062015,
	RO,
	"TX MAC revision ID"},

	{0x0401,
	NA,
	32,
	"TXMAC_SCRATCH",
	0,
	RW,
	"Scratch register available for testing"},

	{0x0402,
	NA,
	32,
	"TXMAC_NAME_0",
	0,
	RO,
	"First 4 characters of IP core variation identifier string \"40gMACTxCSR\" or \"100gMACTxCSR\""},

	{0x0403,
	NA,
	32,
	"TXMAC_NAME_1",
	0,
	RO,
	"Next 4 characters of IP core variation identifier string \"40gMACTxCSR\" or \"100gMACTxCSR\""},

	{0x0404,
	NA,
	32,
	"TXMAC_NAME_2",
	0,
	RO,
	"Final 4 characters of IP core variation identifier string \"40gMACTxCSR\" or \"100gMACTxCSR\""},

	{0x0406,
	NA,
	32,
	"IPG_COL_REM",
	0,
	RW,
	"Number of IDLE columns to be removed in every Alignment Marker"},

	{0x0407,
	NA,
	32,
	"MAX_TX_SIZE_CONFIG",
	0,
	RW,
	"Maximum size of Ethernet frames for CNTR_TX_OVERSIZE"},

	// RX MAC Configuration registers
	{0x0500,
	NA,
	32,
	"RXMAC_REVID",
	0x02062015,
	RO,
	"RX MAC revision ID"},

	{0x0501,
	NA,
	32,
	"RXMAC_SCRATCH",
	0,
	RW,
	"Scratch register available for testing"},

	{0x0502,
	NA,
	32,
	"RXMAC_NAME_0",
	0,
	RO,
	"First 4 characters of IP core variation identifier string \"40gMACRxCSR\" or \"100gMACRxCSR\""},

	{0x0503,
	NA,
	32,
	"RXMAC_NAME_1",
	0,
	RO,
	"Next 4 characters of IP core variation identifier string \"40gMACRxCSR\" or \"100gMACRxCSR\""},

	{0x0504,
	NA,
	32,
	"RXMAC_NAME_2",
	0,
	RO,
	"Final 4 characters of IP core variation identifier string \"40gMACRxCSR\" or \"100gMACRxCSR\""},

	{0x0506,
	NA,
	16,
	"MAX_RX_SIZE_CONFIG",
	0,
	RW,
	"Maximum size of Ethernet frames for CNTR_RX_OVERSIZE"},

	{0x0507,
	NA,
	32,
	"MAC_CRC_CONFIG",
	0,
	RW,
	"RX CRC forwarding configuration register"},

	{0x050A,
	NA,
	32,
	"CFG_PLEN_CHECK",
	0,
	RW,
	"Enables payload length checking"},

	// Transmit side statistics registers
	{0x0800,
	TX,
	32,
	"CNTR_TX_FRAGMENTS_LO",
	0,
	RO,
	"#TX frames < 64 bytes and reporting a CRC error (lower 32 bits)"},

	{0x0801,
	TX,
	32,
	"CNTR_TX_FRAGMENTS_HI",
	0,
	RO,
	"#TX frames < 64 bytes and reporting a CRC error (upper 32 bits)"},

	{0x0802,
	TX,
	32,
	"CNTR_TX_JABBERS_LO",
	0,
	RO,
	"#TX oversized frames reporting a CRC error (lower 32 bits)"},

	{0x0803,
	TX,
	32,
	"CNTR_TX_JABBERS_HI",
	0,
	RO,
	"#TX oversized frames reporting a CRC error (upper 32 bits)"},

	{0x0804,
	TX,
	32,
	"CNTR_TX_FCS_LO",
	0,
	RO,
	"#TX packets with FCS errors. (lower 32 bits)"},

	{0x0805,
	TX,
	32,
	"CNTR_TX_FCS_HI",
	0,
	RO,
	"#TX packets with FCS errors. (upper 32 bits)"},

	{0x0806,
	TX,
	32,
	"CNTR_TX_CRCERR_LO",
	0,
	RO,
	"#TX frames with a frame of length at least 64 reporting a CRC error (lower 32 bits)"},

	{0x0807,
	TX,
	32,
	"CNTR_TX_CRCERR_HI",
	0,
	RO,
	"#TX frames with a frame of length at least 64 reporting a CRC error (upper 32 bits)"},

	{0x0808,
	TX,
	32,
	"CNTR_TX_MCAST_DATA_ERR_LO",
	0,
	RO,
	"Number of errored multicast frames transmitted, excluding control frames (lower 32 bits)"},

	{0x0809,
	TX,
	32,
	"CNTR_TX_MCAST_DATA_ERR_HI",
	0,
	RO,
	"Number of errored multicast frames transmitted, excluding control frames (upper 32 bits)"},

	{0x080A,
	TX,
	32,
	"CNTR_TX_BCAST_DATA_ERR_LO",
	0,
	RO,
	"Number of errored broadcast frames transmitted, excluding control frames (lower 32 bits)"},

	{0x080B,
	TX,
	32,
	"CNTR_TX_BCAST_DATA_ERR_HI",
	0,
	RO,
	"Number of errored broadcast frames transmitted, excluding control frames (upper 32 bits)"},

	{0x080C,
	TX,
	32,
	"CNTR_TX_UCAST_DATA_ERR_LO",
	0,
	RO,
	"Number of errored unicast frames transmitted, excluding control frames (lower 32 bits)"},

	{0x080D,
	TX,
	32,
	"CNTR_TX_UCAST_DATA_ERR_HI",
	0,
	RO,
	"Number of errored unicast frames transmitted, excluding control frames (upper 32 bits)"},

	{0x080E,
	TX,
	32,
	"CNTR_TX_MCAST_CTRL_ERR_LO",
	0,
	RO,
	"Number of errored multicast control frames transmitted (lower 32 bits)"},

	{0x080F,
	TX,
	32,
	"CNTR_TX_MCAST_CTRL_ERR_HI",
	0,
	RO,
	"Number of errored multicast control frames transmitted (upper 32 bits)"},

	{0x0810,
	TX,
	32,
	"CNTR_TX_BCAST_CTRL_ERR_LO",
	0,
	RO,
	"Number of errored broadcast control frames transmitted (lower 32 bits)"},

	{0x0811,
	TX,
	32,
	"CNTR_TX_BCAST_CTRL_ERR_HI",
	0,
	RO,
	"Number of errored broadcast control frames transmitted (upper 32 bits)"},

	{0x0812,
	TX,
	32,
	"CNTR_TX_UCAST_CTRL_ERR_LO",
	0,
	RO,
	"Number of errored unicast control frames transmitted (lower 32 bits)"},

	{0x0813,
	TX,
	32,
	"CNTR_TX_UCAST_CTRL_ERR_HI",
	0,
	RO,
	"Number of errored unicast control frames transmitted (upper 32 bits)"},

	{0x0814,
	TX,
	32,
	"CNTR_TX_PAUSE_ERR_LO",
	0,
	RO,
	"Number of errored pause frames transmitted (lower 32 bits)"},

	{0x0815,
	TX,
	32,
	"CNTR_TX_PAUSE_ERR_HI",
	0,
	RO,
	"Number of errored pause frames transmitted (upper 32 bits)"},

	{0x0816,
	TX,
	32,
	"CNTR_TX_64B_LO",
	0,
	RO,
	"Number of 64-byte transmitted frames (lower 32 bits)"},

	{0x0817,
	TX,
	32,
	"CNTR_TX_64B_HI",
	0,
	RO,
	"Number of 64-byte transmitted frames (upper 32 bits)"},

	{0x0818,
	TX,
	32,
	"CNTR_TX_65to127B_LO",
	0,
	RO,
	"#TX frames between 65–127 bytes (lower 32 bits)"},

	{0x0819,
	TX,
	32,
	"CNTR_TX_65to127B_HI",
	0,
	RO,
	"#TX frames between 65–127 bytes (upper 32 bits)"},

	{0x081A,
	TX,
	32,
	"CNTR_TX_128to255B_LO",
	0,
	RO,
	"#TX frames between 128 –255 bytes (lower 32 bits)"},

	{0x081B,
	TX,
	32,
	"CNTR_TX_128to255B_LO",
	0,
	RO,
	"#TX frames between 128 –255 bytes (upper 32 bits)"},

	{0x081C,
	TX,
	32,
	"CNTR_TX_256to511B_LO",
	0,
	RO,
	"#TX frames between 256 –511 bytes (lower 32 bits)"},

	{0x081D,
	TX,
	32,
	"CNTR_TX_256to511B_LO",
	0,
	RO,
	"#TX frames between 256 –511 bytes (upper 32 bits)"},

	{0x081E,
	TX,
	32,
	"CNTR_TX_512to1023B_LO",
	0,
	RO,
	"#TX frames between 512–1023 bytes (lower 32 bits)"},

	{0x081F,
	TX,
	32,
	"CNTR_TX_512to1023B_HI",
	0,
	RO,
	"#TX frames between 512 –1023 bytes (upper 32 bits)"},

	{0x0820,
	TX,
	32,
	"CNTR_TX_1024to1518B_LO",
	0,
	RO,
	"#TX frames between 1024–1518 bytes (lower 32 bits)"},

	{0x0821,
	TX,
	32,
	"CNTR_TX_1024to1518B_HI",
	0,
	RO,
	"#TX frames between 1024–1518 bytes (upper 32 bits)"},

	{0x0822,
	TX,
	32,
	"CNTR_TX_1519toMAXB_LO",
	0,
	RO,
	"#TX frames of size between 1519 bytes \
and MAX_TX_SIZE_CONFIG register (lower 32 bits)"},

	{0x0823,
	TX,
	32,
	"CNTR_TX_1519toMAXB_HI",
	0,
	RO,
	"#TX frames of size between 1519 bytes \
and MAX_TX_SIZE_CONFIG register (upper 32 bits)"},

	{0x0824,
	TX,
	32,
	"CNTR_TX_OVERSIZE_LO",
	0,
	RO,
	"Frames with bytes > \
MAX_TX_SIZE_CONFIG transmitted (lower 32 bits)"},

	{0x0825,
	TX,
	32,
	"CNTR_TX_OVERSIZE_HI",
	0,
	RO,
	"Frames with bytes >\
MAX_TX_SIZE_CONFIG) transmitted (upper 32 bits)"},

	{0x0826,
	TX,
	32,
	"CNTR_TX_MCAST_DATA_OK_LO",
	0,
	RO,
	"Number of valid multicast frames transmitted, excluding \
control frames (lower 32 bits)"},

	{0x0827,
	TX,
	32,
	"CNTR_TX_MCAST_DATA_OK_HI",
	0,
	RO,
	"Number of valid multicast frames transmitted, excluding \
control frames (upper 32 bits)"},

	{0x0828,
	TX,
	32,
	"CNTR_TX_BCAST_DATA_OK_LO",
	0,
	RO,
	"Number of valid broadcast frames transmitted, excluding \
control frames (lower 32 bits)"},

	{0x0829,
	TX,
	32,
	"CNTR_TX_BCAST_DATA_OK_HI",
	0,
	RO,
	"Number of valid broadcast frames transmitted, excluding \
control frames (upper 32 bits)"},

	{0x082A,
	TX,
	32,
	"CNTR_TX_UCAST_DATA_OK_LO",
	0,
	RO,
	"Number of valid unicast frames transmitted, excluding \
control frames (lower 32 bits)"},

	{0x082B,
	TX,
	32,
	"CNTR_TX_UCAST_DATA_OK_HI",
	0,
	RO,
	"Number of valid unicast frames transmitted, excluding \
control frames (upper 32 bits)"},

	{0x082C,
	TX,
	32,
	"CNTR_TX_MCAST_CTRL_LO",
	0,
	RO,
	"Number of valid multicast frames transmitted, excluding \
data frames (lower 32 bits)"},

	{0x082D,
	TX,
	32,
	"CNTR_TX_MCAST_CTRL_HI",
	0,
	RO,
	"Number of valid multicast frames transmitted, excluding \
data frames (upper 32 bits)"},

	{0x082E,
	TX,
	32,
	"CNTR_TX_BCAST_CTRL_LO",
	0,
	RO,
	"Number of valid broadcast frames transmitted, excluding \
data frames (lower 32 bits)"},

	{0x082F,
	TX,
	32,
	"CNTR_TX_BCAST_CTRL_HI",
	0,
	RO,
	"Number of valid broadcast frames transmitted, excluding \
data frames (upper 32 bits)"},

	{0x0830,
	TX,
	32,
	"CNTR_TX_UCAST_CTRL_LO",
	0,
	RO,
	"Number of valid unicast frames transmitted, excluding data \
frames (lower 32 bits)"},

	{0x0831,
	TX,
	32,
	"CNTR_TX_UCAST_CTRL_HI",
	0,
	RO,
	"Number of valid unicast frames transmitted, excluding data \
frames (upper 32 bits)"},

	{0x0832,
	TX,
	32,
	"CNTR_TX_PAUSE_LO",
	0,
	RO,
	"Number of valid pause frames transmitted (lower 32 bits)"},

	{0x0833,
	TX,
	32,
	"CNTR_TX_PAUSE_HI",
	0,
	RO,
	"Number of valid pause frames transmitted (upper 32 bits)"},

	{0x0834,
	TX,
	32,
	"CNTR_TX_RUNT_LO",
	0,
	RO,
	"#TX runt packets (lower 32 bits)"},

	{0x0835,
	TX,
	32,
	"CNTR_TX_RUNT_HI",
	0,
	RO,
	"#TX runt packets (upper 32 bits)"},

	{0x0836,
	TX,
	32,
	"CNTR_TX_ST_LO",
	0,
	RO,
	"#TX frame starts (lower 32 bits)"},

	{0x0837,
	TX,
	32,
	"CNTR_TX_ST_HI",
	0,
	RO,
	"#TX frame starts (upper 32 bits)"},

	{0x0840,
	TX,
	32,
	"TXSTAT_REVID",
	0,
	RO,
	"TX statistics module revision ID"},

	{0x0841,
	TX,
	32,
	"TXSTAT_SCRATCH",
	0,
	RW,
	"Scratch register available for testing. Default value is 0x08"},

	{0x0842,
	TX,
	32,
	"TXSTAT_NAME_0",
	0,
	RW,
	"First 4 characters of IP core variation identifier string \"040gMacStats\" or \"100gMacStats\""},

	{0x0843,
	TX,
	32,
	"TXSTAT_NAME_1",
	0,
	RW,
	"Next 4 characters of IP core variation identifier string \"040gMacStats\" or \"100gMacStats\""},

	{0x0844,
	TX,
	32,
	"TXSTAT_NAME_2",
	0,
	RW,
	"Final 4 characters of IP core variation identifier string \"040gMacStats\" or \"100gMacStats\""},

	{0x0845,
	TX,
	32,
	"CNTR_TX_CONFIG",
	0,
	RW,
	"Configuration of TX statistics counters"},

	{0x0846,
	TX,
	32,
	"CNTR_TX_STATUS",
	0,
	RO,
	"TX statistics registers paused (1), At-least one parity error (0)"},

	{0x0860,
	TX,
	32,
	"TxOctetsOK_LO",
	0,
	RO,
	"#TX payload bytes in frames with no \
FCS, undersized, oversized, or payload length errors)"},

	{0x0861,
	TX,
	32,
	"TxOctetsOK_HI",
	0,
	RO,
	"#TX payload bytes in frames with no \
FCS, undersized, oversized, or payload length errors"},

	// Receive side statistics registers
	{0x0900,
	RX,
	32,
	"CNTR_RX_FRAGMENTS_LO",
	0,
	RO,
	"#RX frames < 64 bytes and reporting a CRC error (lower 32 bits)"},

	{0x0901,
	RX,
	32,
	"CNTR_RX_FRAGMENTS_HI",
	0,
	RO,
	"#RX frames < 64 bytes and reporting a CRC error (upper 32 bits)"},

	{0x0902,
	RX,
	32,
	"CNTR_RX_JABBERS_LO",
	0,
	RO,
	"#RX oversized frames reporting a CRC error (lower 32 bits)"},

	{0x0903,
	RX,
	32,
	"CNTR_RX_JABBERS_HI",
	0,
	RO,
	"#RX oversized frames reporting a CRC error (upper 32 bits)"},

	{0x0904,
	RX,
	32,
	"CNTR_RX_FCS_LO",
	0,
	RO,
	"#RX packets with FCS errors. (lower 32 bits)"},

	{0x0905,
	RX,
	32,
	"CNTR_RX_FCS_HI",
	0,
	RO,
	"#RX packets with FCS errors. (upper 32 bits)"},

	{0x0906,
	RX,
	32,
	"CNTR_RX_CRCERR_LO",
	0,
	RO,
	"#RX frames with a frame of length at least 64 reporting a CRC error (lower 32 bits)"},

	{0x0907,
	RX,
	32,
	"CNTR_RX_CRCERR_HI",
	0,
	RO,
	"#RX frames with a frame of length at least 64 reporting a CRC error (upper 32 bits)"},

	{0x0908,
	RX,
	32,
	"CNTR_RX_MCAST_DATA_ERR_LO",
	0,
	RO,
	"Number of errored multicast frames received, excluding control frames (lower 32 bits)"},

	{0x0909,
	RX,
	32,
	"CNTR_RX_MCAST_DATA_ERR_HI",
	0,
	RO,
	"Number of errored multicast frames received, excluding control frames (upper 32 bits)"},

	{0x090A,
	RX,
	32,
	"CNTR_RX_BCAST_DATA_ERR_LO",
	0,
	RO,
	"Number of errored broadcast frames received, excluding control frames (lower 32 bits)"},

	{0x090B,
	RX,
	32,
	"CNTR_RX_BCAST_DATA_ERR_HI",
	0,
	RO,
	"Number of errored broadcast frames received, excluding control frames (upper 32 bits)"},

	{0x090C,
	RX,
	32,
	"CNTR_RX_UCAST_DATA_ERR_LO",
	0,
	RO,
	"Number of errored unicast frames received, excluding control frames (lower 32 bits)"},

	{0x090D,
	RX,
	32,
	"CNTR_RX_UCAST_DATA_ERR_HI",
	0,
	RO,
	"Number of errored unicast frames received, excluding control frames (upper 32 bits)"},

	{0x090E,
	RX,
	32,
	"CNTR_RX_MCAST_CTRL_ERR_LO",
	0,
	RO,
	"Number of errored multicast control frames received (lower 32 bits)"},

	{0x090F,
	RX,
	32,
	"CNTR_RX_MCAST_CTRL_ERR_HI",
	0,
	RO,
	"Number of errored multicast control frames received (upper 32 bits)"},

	{0x0910,
	RX,
	32,
	"CNTR_RX_BCAST_CTRL_ERR_LO",
	0,
	RO,
	"Number of errored broadcast control frames received (lower 32 bits)"},

	{0x0911,
	RX,
	32,
	"CNTR_RX_BCAST_CTRL_ERR_HI",
	0,
	RO,
	"Number of errored broadcast control frames received (upper 32 bits)"},

	{0x0912,
	RX,
	32,
	"CNTR_RX_UCAST_CTRL_ERR_LO",
	0,
	RO,
	"Number of errored unicast control frames received (lower 32 bits)"},

	{0x0913,
	RX,
	32,
	"CNTR_RX_UCAST_CTRL_ERR_HI",
	0,
	RO,
	"Number of errored unicast control frames received (upper 32 bits)"},

	{0x0914,
	RX,
	32,
	"CNTR_RX_PAUSE_ERR_LO",
	0,
	RO,
	"Number of errored pause frames received (lower 32 bits)"},

	{0x0915,
	RX,
	32,
	"CNTR_RX_PAUSE_ERR_HI",
	0,
	RO,
	"Number of errored pause frames received (upper 32 bits)"},

	{0x0916,
	RX,
	32,
	"CNTR_RX_64B_LO",
	0,
	RO,
	"Number of 64-byte received frames (lower 32 bits)"},

	{0x0917,
	RX,
	32,
	"CNTR_RX_64B_HI",
	0,
	RO,
	"Number of 64-byte received frames (upper 32 bits)"},

	{0x0918,
	RX,
	32,
	"CNTR_RX_65to127B_LO",
	0,
	RO,
	"#RX frames between 65–127 bytes (lower 32 bits)"},

	{0x0919,
	RX,
	32,
	"CNTR_RX_65to127B_HI",
	0,
	RO,
	"#RX frames between 65–127 bytes (upper 32 bits)"},

	{0x091A,
	RX,
	32,
	"CNTR_RX_128to255B_LO",
	0,
	RO,
	"#RX frames between 128 –255 bytes (lower 32 bits)"},

	{0x091B,
	RX,
	32,
	"CNTR_RX_128to255B_LO",
	0,
	RO,
	"#RX frames between 128 –255 bytes (upper 32 bits)"},

	{0x091C,
	RX,
	32,
	"CNTR_RX_256to511B_LO",
	0,
	RO,
	"#RX frames between 256 –511 bytes (lower 32 bits)"},

	{0x091D,
	RX,
	32,
	"CNTR_RX_256to511B_LO",
	0,
	RO,
	"#RX frames between 256 –511 bytes (upper 32 bits)"},

	{0x091E,
	RX,
	32,
	"CNTR_RX_512to1023B_LO",
	0,
	RO,
	"#RX frames between 512–1023 bytes (lower 32 bits)"},

	{0x091F,
	RX,
	32,
	"CNTR_RX_512to1023B_HI",
	0,
	RO,
	"#RX frames between 512 –1023 bytes (upper 32 bits)"},

	{0x0920,
	RX,
	32,
	"CNTR_RX_1024to1518B_LO",
	0,
	RO,
	"#RX frames between 1024–1518 bytes (lower 32 bits)"},

	{0x0921,
	RX,
	32,
	"CNTR_RX_1024to1518B_HI",
	0,
	RO,
	"#RX frames between 1024–1518 bytes (upper 32 bits)"},

	{0x0922,
	RX,
	32,
	"CNTR_RX_1519toMAXB_LO",
	0,
	RO,
	"#RX frames of size between 1519 bytes \
and MAX_RX_SIZE_CONFIG register (lower 32 bits)"},

	{0x0923,
	RX,
	32,
	"CNTR_RX_1519toMAXB_HI",
	0,
	RO,
	"#RX frames of size between 1519 bytes \
and MAX_RX_SIZE_CONFIG \
register (upper 32 bits)"},

	{0x0924,
	RX,
	32,
	"CNTR_RX_OVERSIZE_LO",
	0,
	RO,
	"Frames with more bytes than \
MAX_RX_SIZE_CONFIG register \
received (lower 32 bits)"},

	{0x0925,
	RX,
	32,
	"CNTR_RX_OVERSIZE_HI",
	0,
	RO,
	"Frames with more bytes than \
the MAX_RX_SIZE_CONFIG register \
received (upper 32 bits)"},

	{0x0926,
	RX,
	32,
	"CNTR_RX_MCAST_DATA_OK_LO",
	0,
	RO,
	"Number of valid multicast frames received, excluding \
control frames (lower 32 bits)"},

	{0x0927,
	RX,
	32,
	"CNTR_RX_MCAST_DATA_OK_HI",
	0,
	RO,
	"Number of valid multicast frames received, excluding \
control frames (upper 32 bits)"},

	{0x0928,
	RX,
	32,
	"CNTR_RX_BCAST_DATA_OK_LO",
	0,
	RO,
	"Number of valid broadcast frames received, excluding \
control frames (lower 32 bits)"},

	{0x0929,
	RX,
	32,
	"CNTR_RX_BCAST_DATA_OK_HI",
	0,
	RO,
	"Number of valid broadcast frames received, excluding \
control frames (upper 32 bits)"},

	{0x092A,
	RX,
	32,
	"CNTR_RX_UCAST_DATA_OK_LO",
	0,
	RO,
	"Number of valid unicast frames received, excluding \
control frames (lower 32 bits)"},

	{0x092B,
	RX,
	32,
	"CNTR_RX_UCAST_DATA_OK_HI",
	0,
	RO,
	"Number of valid unicast frames received, excluding \
control frames (upper 32 bits)"},

	{0x092C,
	RX,
	32,
	"CNTR_RX_MCAST_CTRL_LO",
	0,
	RO,
	"Number of valid multicast frames received, excluding \
data frames (lower 32 bits)"},

	{0x092D,
	RX,
	32,
	"CNTR_RX_MCAST_CTRL_HI",
	0,
	RO,
	"Number of valid multicast frames received, excluding \
data frames (upper 32 bits)"},

	{0x092E,
	RX,
	32,
	"CNTR_RX_BCAST_CTRL_LO",
	0,
	RO,
	"Number of valid broadcast frames received, excluding \
data frames (lower 32 bits)"},

	{0x092F,
	RX,
	32,
	"CNTR_RX_BCAST_CTRL_HI",
	0,
	RO,
	"Number of valid broadcast frames received, excluding \
data frames (upper 32 bits)"},

	{0x0930,
	RX,
	32,
	"CNTR_RX_UCAST_CTRL_LO",
	0,
	RO,
	"Number of valid unicast frames received, excluding data \
frames (lower 32 bits)"},

	{0x0931,
	RX,
	32,
	"CNTR_RX_UCAST_CTRL_HI",
	0,
	RO,
	"Number of valid unicast frames received, excluding data \
frames (upper 32 bits)"},

	{0x0932,
	RX,
	32,
	"CNTR_RX_PAUSE_LO",
	0,
	RO,
	"Number of valid pause frames received (lower 32 bits)"},

	{0x0933,
	RX,
	32,
	"CNTR_RX_PAUSE_HI",
	0,
	RO,
	"Number of valid pause frames received (upper 32 bits)"},

	{0x0934,
	RX,
	32,
	"CNTR_RX_RUNT_LO",
	0,
	RO,
	"#RX runt packets (lower 32 bits)"},

	{0x0935,
	RX,
	32,
	"CNTR_RX_RUNT_HI",
	0,
	RO,
	"#RX runt packets (upper 32 bits)"},

	{0x0936,
	RX,
	32,
	"CNTR_RX_ST_LO",
	0,
	RO,
	"#RX frame starts (lower 32 bits)"},

	{0x0937,
	RX,
	32,
	"CNTR_RX_ST_HI",
	0,
	RO,
	"#RX frame starts (upper 32 bits)"},

	{0x0940,
	RX,
	32,
	"RXSTAT_REVID",
	0,
	RO,
	"RX statistics module revision ID"},

	{0x0941,
	RX,
	32,
	"RXSTAT_SCRATCH",
	0,
	RW,
	"Scratch register available for testing. Default value is 0x08"},

	{0x0942,
	RX,
	32,
	"RXSTAT_NAME_0",
	0,
	RW,
	"First 4 characters of IP core variation identifier string \"040gMacStats\" or \"100gMacStats\""},

	{0x0943,
	RX,
	32,
	"RXSTAT_NAME_1",
	0,
	RW,
	"Next 4 characters of IP core variation identifier string \"040gMacStats\" or \"100gMacStats\""},

	{0x0944,
	RX,
	32,
	"RXSTAT_NAME_2",
	0,
	RW,
	"Final 4 characters of IP core variation identifier string \"040gMacStats\" or \"100gMacStats\""},

	{0x0945,
	RX,
	32,
	"CNTR_RX_CONFIG",
	0,
	RW,
	"Configuration of RX statistics counters"},

	{0x0946,
	RX,
	32,
	"CNTR_RX_STATUS",
	0,
	RO,
	"RX statistics registers paused (1), At-least one parity error (0)"},

	{0x0960,
	RX,
	32,
	"RXOctetsOK_LO",
	0,
	RO,
	"#RX payload bytes in frames with no \
FCS, undersized, oversized, or payload length errors)"},

	{0x0961,
	RX,
	32,
	"RXOctetsOK_HI",
	0,
	RO,
	"#RX payload bytes in frames with no \
FCS, undersized, oversized, or payload length errors"},

	// Decribe traffic generator CSRs
	{0x03c00,
	NA,
	32,
	"number_of_packets",
	0,
	RW,
	"Number of packets to be transmitted"},

	{0x03c01,
	NA,
	32,
	"random_length",
	0,
	RW,
	"Select what type of packet length:0=fixed, 1=random"},

	{0x03c02,
	NA,
	32,
	"random_payload",
	0,
	RW,
	"Select what type of data pattern:0=incremental, 1=random"},

	{0x03c03,
	NA,
	32,
	"start",
	0,
	RW,
	"Start traffic generation"},

	{0x03c04,
	NA,
	32,
	"stop",
	0,
	RW,
	"Stop traffic generation"},

	{0x03c05,
	NA,
	32,
	"source_addr0",
	0,
	RW,
	"MAC source address 31:0"},

	{0x03c06,
	NA,
	32,
	"source_addr1",
	0,
	RW,
	"MAC source address 47:32"},

	{0x03c07,
	NA,
	32,
	"destination_addr0",
	0,
	RW,
	"MAC destination address 31:0"},

	{0x03c08,
	NA,
	32,
	"destination_addr1",
	0,
	RW,
	"MAC destination address 47:32"},

	{0x03c09,
	NA,
	32,
	"packet_tx_count",
	0,
	RW,
	"#TX packets"},

	{0x03c0a,
	NA,
	32,
	"rnd_seed0",
	0,
	RW,
	"Seed number for prbs generator [31:0]"},

	{0x03c0b,
	NA,
	32,
	"rnd_seed1",
	0,
	RW,
	"Seed number for prbs generator [63:32]"},

	{0x03c0c,
	NA,
	32,
	"rnd_seed2",
	0,
	RW,
	"Seed number for prbs generator [91:64]"},

	{0x03c0d,
	NA,
	32,
	"pkt_length",
	0,
	RW,
	"Number of succesfully transmitted packets"},

	// Decribe traffic monitor CSRs (TBD mapping address)
	{0x03d00,
	NA,
	32,
	"mac_da0",
	0,
	RW,
	"MAC destination address [31:0]"},

	{0x03d01,
	NA,
	32,
	"mac_da1",
	0,
	RW,
	"MAC destination address [47:32]"},

	{0x03d02,
	NA,
	32,
	"mac_sa0",
	0,
	RW,
	"MAC source address [31:0]"},

	{0x03d03,
	NA,
	32,
	"mac_sa1",
	0,
	RW,
	"MAC destination address [47:32]"},

	{0x03d04,
	NA,
	32,
	"pkt_numb",
	0,
	RW,
	"Number of packets received"},

	{0x03d05,
	NA,
	32,
	"mon_ctrl",
	0,
	RW,
	"Monitor control - continuous (bit 2), \
	stop_reg (bit 1), init_reg (bit 0)"},

	{0x03d06,
	NA,
	32,
	"mon_stat",
	0,
	RW,
	"Monitor status [0] Monitoring completed (Received \
number of packets), [1] - Destination Address error, \
[2] - Source Address error, [3] - Packet Length error, \
[4] - Packet CRC payload error"},

	{0x03d07,
	NA,
	32,
	"pkt_good",
	0,
	RW,
	"Good packets"},

	{0x03d08,
	NA,
	32,
	"pkt_bad",
	0,
	RW,
	"Bad packets"},
};

// PR Managment commands
typedef enum pr_mgmt_cmd_e40 {
	PR_MGMT_SCRATCH          = 0x0,
	PR_MGMT_RST              = 0x1,
	PR_MGMT_STATUS           = 0x2,
	PR_MGMT_STATUS_WR_DATA   = 0x3,
	PR_MGMT_STATUS_RD_DATA   = 0x4,
	PR_MGMT_PORT_SEL         = 0x5,
	PR_MGMT_SLOOP            = 0x6,
	PR_MGMT_LOCK_STATUS      = 0x7,
	PR_MGMT_I2C_SEL_WDATA    = 0x8,
	PR_MGMT_I2C_SEL_RDATA    = 0x9,
	PR_MGMT_ETH_CTRL         = 0xa,
	PR_MGMT_ETH_WR_DATA      = 0xb,
	PR_MGMT_ETH_RD_DATA      = 0xc,
	PR_MGMT_ERR_INIT_DONE    = 0xd
} pr_mgmt_cmd_e40_t;

#define NUM_ETH_CHANNELS 1

// PR Management Data
// Data is interpreted in HW according to pr_mgmt_cmd
typedef volatile union pr_mgmt_data_e40 {
	uint64_t reg;

	// 0x0
	uint64_t scratch;

	// 0x1
	struct rst {
		uint64_t reset_async:1;
		uint64_t reset_status:1;		
	} rst;

	// 0x2
	struct status {
		uint64_t status_addr:16;
		uint64_t status_wr:1;
		uint64_t status_rd:1;
	} status;

	// 0x3
	uint64_t status_wr_data;

	// 0x4
	uint64_t status_rd_data;

	// 0x8
	struct i2c {
		uint64_t i2c_ctrl_wdata_r:16;
		uint64_t i2c_inst_sel_r:2;
	} i2c;

	// 0x9
	uint64_t i2c_rdata;

	// 0xa
	struct eth_traf {
		uint64_t eth_traff_addr:16;
		uint64_t eth_traff_wr:1;
		uint64_t eth_traff_rd:1;
	} eth_traf;

	// 0xb
	uint64_t eth_traff_wdata;

	// 0xc
	uint64_t eth_traff_rdata;

	// 0xd
	// Miscallaneous status signals
	struct misc_status {
		uint64_t f2a_init_done:1;
		uint64_t a2f_prmgmt_fatal_err:1;
		uint64_t rsvd:2;
		uint64_t rx_pcs_ready:1;
		uint64_t tx_lanes_stable:1;
		uint64_t l4_rx_ready:1;
		uint64_t l4_tx_ready:1;
	} misc_status;

} pr_mgmt_data_e40_t;

#endif // __FPGA_HSSI_E40_H__
