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
// ARE DISCLAIMEdesc.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS
// BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/**
 * \fpga_hssi.c
 * \brief HSSI E40 User-space APIs
 */
#include <stdlib.h>
#include <opae/fpga.h>
#include <time.h>
#include <string.h>
#include <safe_string/safe_string.h>
#include "fpga_hssi.h"
#include "fpga_hssi_e40.h"

static int err_cnt;

void prMgmtWrite(volatile struct afu_dfl *const dfl, pr_mgmt_cmd_e40_t cmd,
	pr_mgmt_data_e40_t data)
{
	dfl->eth_wr_data = (uint64_t)data.reg;
	dfl->eth_ctrl_addr = PR_WRITE_CMD | cmd;
	dfl->eth_ctrl_addr = 0;
}

void prMgmtRead(volatile struct afu_dfl *const dfl, pr_mgmt_cmd_e40_t cmd,
	pr_mgmt_data_e40_t *data)
{
	struct timespec time;
	time.tv_sec = 0;
	time.tv_nsec = 10000;
	data->reg = 0;
	dfl->eth_ctrl_addr = PR_READ_CMD | cmd;
	nanosleep(&time, &time);
	data->reg = (uint64_t)dfl->eth_rd_data;
	dfl->eth_ctrl_addr = 0;
}

// Public
fpga_result fpgaHssiOpen(fpga_handle fpga, fpga_hssi_handle *hssi)
{
	fpga_result res = FPGA_OK;
	fpga_guid guid;
	int i = 0;

	err_cnt = 0;

	if (!fpga)
		return FPGA_INVALID_PARAM;

	if (!hssi)
		return FPGA_INVALID_PARAM;

	if (uuid_parse(E40_AFU_ID, guid) < 0)
		return FPGA_EXCEPTION;

	struct _fpga_hssi_handle_t *h;

	h = (fpga_hssi_handle)malloc(sizeof(struct _fpga_hssi_handle_t));
	if (!h)
		return FPGA_NO_MEMORY;

	h->csr_cnt = sizeof(e40_csrs)/sizeof(struct _hssi_csr);
	h->csrs = malloc(sizeof(struct _hssi_csr *) * h->csr_cnt);
	if(!h->csrs) {
		res = FPGA_NO_MEMORY;
		ON_ERR_GOTO(res, out_h,
			    "Unable to allocate CSR memory in handle");
	}

	for (i = 0; i < h->csr_cnt; i++)
		h->csrs[i] = &e40_csrs[i];

	res = fpgaMapMMIO(fpga, 0, (uint64_t **)&h->mmio_ptr);
	ON_ERR_GOTO(res, out_csr, "fpgaMapMMIO");

	h->dfl = (struct afu_dfl *)h->mmio_ptr;

	// guid string is big-endian, switch to little-endian before comparison
	byte_reverse(guid);
	if (memcmp(guid, &(h->dfl->afu_id_lo), sizeof(h->dfl->afu_id_lo)) ||
		memcmp(&guid[sizeof(h->dfl->afu_id_lo)], &(h->dfl->afu_id_hi),
			sizeof(h->dfl->afu_id_hi))
	) {
		res = FPGA_EXCEPTION;
		fpgaUnmapMMIO(fpga, 0);
		ON_ERR_GOTO(res, out_csr, "Invalid UUID");
	}
	h->fpga_h = fpga;

	*hssi = h;
	return FPGA_OK;

out_csr:
	if (h->csrs)
		free(h->csrs);
out_h:
	if (h)
		free(h);

	return res;
}

fpga_result fpgaHssiClose(fpga_hssi_handle hssi)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	fpgaUnmapMMIO(hssi->fpga_h, 0);

	if (hssi->csrs)
		free(hssi->csrs);

	free(hssi);
	return FPGA_OK;
}

fpga_result fpgaHssiWriteCsr64(fpga_hssi_handle hssi, hssi_csr csr,
	uint64_t val)
{
	if (!hssi || !csr)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_e40_t wr_data = {0};

	wr_data.reg = val;
	wr_data.status_wr_data = val;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.status.status_addr = csr->offset;
	wr_data.status.status_wr = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS, wr_data);
	return FPGA_OK;
}

fpga_result fpgaHssiReadCsr64(fpga_hssi_handle hssi,
	hssi_csr csr, uint64_t *val)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_e40_t wr_data = {0};
	pr_mgmt_data_e40_t rd_data = {0};

	wr_data.status.status_addr = csr->offset;
	wr_data.status.status_rd = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS, wr_data);
	prMgmtRead(hssi->dfl, PR_MGMT_STATUS_RD_DATA, &rd_data);
	*val = rd_data.reg;
	return FPGA_OK;
}

fpga_result fpgaHssiReset(fpga_hssi_handle hssi)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_e40_t wr_data = {0};

	// Asssert reset
	wr_data.rst.reset_async = 1;
	wr_data.rst.reset_status = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_RST, wr_data);

	// Reset release sequence
	// reset TX and RX
	wr_data.rst.reset_async = 0;
	wr_data.rst.reset_status = 0;
	prMgmtWrite(hssi->dfl, PR_MGMT_RST, wr_data);

	return FPGA_OK;
}

fpga_result fpgaHssiCtrlLoopback(fpga_hssi_handle hssi,
	uint32_t channel_num, bool loopback_en)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	hssi_csr csr;
	fpgaHssiFilterCsrByName(hssi, "PHY_PMA_SLOOP", &csr);

	if (!csr)
		return FPGA_INVALID_PARAM;

	if (loopback_en)
		fpgaHssiWriteCsr64(hssi, csr, (uint64_t)0x3ff);	
	else
		fpgaHssiWriteCsr64(hssi, csr, (uint64_t)0x0);	

	return FPGA_OK;
}

fpga_result fpgaHssiGetLoopbackStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *loopback_en)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	hssi_csr csr;
	uint64_t val;
	fpgaHssiFilterCsrByName(hssi, "PHY_PMA_SLOOP", &csr);

	if (!csr)
		return FPGA_INVALID_PARAM;

	fpgaHssiReadCsr64(hssi, csr, &val);

	if(val == 0x3ff)
		*loopback_en = true;
	else
		*loopback_en = false;

	return FPGA_OK;
}

fpga_result fpgaHssiGetFreqLockStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *freq_locked)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	hssi_csr csr;
	uint64_t val;
	fpgaHssiFilterCsrByName(hssi, "PHY_EIOFREQ_LOCKED", &csr);

	if (!csr)
		return FPGA_INVALID_PARAM;

	fpgaHssiReadCsr64(hssi, csr, &val);
	if(val == 0xf)
		*freq_locked = true;
	else
		*freq_locked = false;

	return FPGA_OK;
}

fpga_result fpgaHssiGetWordLockStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *word_locked)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	hssi_csr csr;
	uint64_t val;

	fpgaHssiFilterCsrByName(hssi, "PHY_TX_PLL_LOCKED", &csr);

	if (!csr)
		return FPGA_INVALID_PARAM;

	fpgaHssiReadCsr64(hssi, csr, &val);
	if(val == 0xf)
		*word_locked = true;
	else
		*word_locked = false;

	return FPGA_OK;
}

fpga_result fpgaHssiSendPacket(fpga_hssi_handle hssi,
	uint32_t channel_num, uint64_t num_packets)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	if (channel_num > NUM_ETH_CHANNELS)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_e40_t wr_data = { 0 };
	// use broadcast traffic
	wr_data.reg = 0;
	wr_data.eth_traff_wdata = 0xFFFFFFFF;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.eth_traf.eth_traff_wr = 1;
	wr_data.eth_traf.eth_traff_addr = 0x0;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_CTRL, wr_data);
	wr_data.reg = 0;
	wr_data.eth_traff_wdata = 0xFFFF;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.eth_traf.eth_traff_wr = 1;
	wr_data.eth_traf.eth_traff_addr = 0x1;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_CTRL, wr_data);
	wr_data.eth_traff_wdata = num_packets;

	// number of packets
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.eth_traf.eth_traff_wr = 1;
	wr_data.eth_traf.eth_traff_addr = 0x4;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_CTRL, wr_data);

	// number of bytes
	wr_data.reg = 0;
	wr_data.eth_traff_wdata = 1500;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.eth_traf.eth_traff_wr = 1;
	wr_data.eth_traf.eth_traff_addr = 0x5;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_CTRL, wr_data);

	// packet delay
	wr_data.reg = 0;
	wr_data.eth_traff_wdata = 0;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.eth_traf.eth_traff_wr = 1;
	wr_data.eth_traf.eth_traff_addr = 0x6;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_CTRL, wr_data);

	// assert start
	wr_data.reg = 0;
	wr_data.eth_traff_wdata = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.eth_traf.eth_traff_wr = 1;
	wr_data.eth_traf.eth_traff_addr = 0x7;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_CTRL, wr_data);

	// deassert
	wr_data.reg = 0;
	wr_data.eth_traff_wdata = 0;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.eth_traf.eth_traff_wr = 1;
	wr_data.eth_traf.eth_traff_addr = 0x7;
	prMgmtWrite(hssi->dfl, PR_MGMT_ETH_CTRL, wr_data);

	return FPGA_OK;
}

fpga_result fpgaHssiPrintChannelStats(fpga_hssi_handle hssi_h,
	hssi_csr_type_t type, uint32_t channel_num)
{
	size_t count;
	hssi_csr *csrs;
	int i = 0;
	uint64_t val;

	fpgaHssiEnumerateCsr(hssi_h, &csrs, &count);
	printf("%50s\n", "CHANNEL STATISTICS");
	repeat('-', 100);
	printf("%-8s|%-50s|%-20s|%-50s\n", "OFFSET", "NAME", "VALUE",
		"DESCRIPTION");
	repeat('-', 100);
	for (i = 0; i < count; i++) {
		if (csrs[i]->type == type) {
			fpgaHssiReadCsr64(hssi_h, csrs[i], &val);
			printf("%#-8x|%-50s|%#-20lx|%-50s\n", csrs[i]->offset,
				csrs[i]->name, val, csrs[i]->desc);
		}
	}
	return FPGA_OK;
}

fpga_result fpgaHssiClearChannelStats(fpga_hssi_handle hssi,
	hssi_csr_type_t type, uint32_t channel_num)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	hssi_csr csr;

	if (type == TX) {
		fpgaHssiFilterCsrByName(hssi, "CNTR_TX_CONFIG", &csr);

		if (!csr)
			return FPGA_INVALID_PARAM;

		fpgaHssiWriteCsr64(hssi, csr, (uint64_t)1);
	} else if (type == RX) {
		fpgaHssiFilterCsrByName(hssi, "CNTR_RX_CONFIG", &csr);

		if (!csr)
			return FPGA_INVALID_PARAM;

		fpgaHssiWriteCsr64(hssi, csr, (uint64_t)1);
	} else
		return FPGA_INVALID_PARAM;

	return FPGA_OK;
}
