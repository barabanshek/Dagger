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
 * \fpga_hssi_common.h
 * \brief HSSI Commons
 *
 */
#ifndef __FPGA_HSSI_COMMON_H__
#define __FPGA_HSSI_COMMON_H__

#include <stdint.h>
#include <stdbool.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>

#define MAX_NAME_LEN 256
#define MAX_DESC_LEN 2048

#define HSSI_BIT(n) (UINT32_C(1) << (n))
#define PR_READ_CMD  HSSI_BIT(17)
#define PR_WRITE_CMD HSSI_BIT(16)

/*
 * macro for checking return codes
 */
#define ON_ERR_GOTO(res, label, desc)\
	do {\
		if ((res) != FPGA_OK) {\
			err_cnt++;\
			fprintf(stderr, "Error %s: %s\n",\
				(desc), fpgaErrStr(res));\
			goto label;\
		} \
	} while (0)

typedef enum {
	RW = 0,
	RO,
	RWC,
	RSVD
} hssi_reg_perms_t;

typedef enum {
	TX,
	RX,
	PHY,
	NA
} hssi_csr_type_t;

// Defintion of HSSI CSR
typedef const struct _hssi_csr {
	// TODO: make offsets relative to BBB base
	uint32_t offset; // absolute offset
	hssi_csr_type_t type;
	uint32_t width;
	char name[MAX_NAME_LEN];
	uint32_t val;
	hssi_reg_perms_t perms;
	char desc[MAX_DESC_LEN];
} *hssi_csr;

struct afu_dfl {
	uint64_t afu_dfh_reg;
	uint64_t afu_id_lo;
	uint64_t afu_id_hi;
	uint64_t afu_next;
	uint64_t afu_rsvd;
	uint64_t afu_init;
	uint64_t eth_ctrl_addr;
	uint64_t eth_wr_data;
	uint64_t eth_rd_data;
	uint64_t afu_scratch;
};

struct _fpga_hssi_handle_t {
	fpga_handle fpga_h;
	hssi_csr *csrs;
	size_t csr_cnt;
	struct afu_dfl *dfl;
	volatile uint64_t *mmio_ptr;
};

typedef struct _fpga_hssi_handle_t *fpga_hssi_handle;

void byte_reverse(fpga_guid guid);
void repeat(char c, int cnt);

#endif // __FPGA_HSSI_COMMON_H__