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
 * \fpga_hssi_common.c
 * \brief HSSI Common APIs
 */
#include <stdlib.h>
#include <opae/fpga.h>
#include <string.h>
#include <safe_string/safe_string.h>
#include "fpga_hssi_common.h"

void byte_reverse(fpga_guid guid)
{
	char t;
	int i;

	for (i = 0; i < sizeof(fpga_guid)/2; i++) {
		t = guid[sizeof(fpga_guid)-i-1];
		guid[sizeof(fpga_guid)-i-1] = guid[i];
		guid[i] = t;
	}
}

void repeat(char c, int cnt)
{
	while (cnt-- > 0)
		printf("%c", c);
	printf("\n");
}

fpga_result fpgaHssiEnumerateCsr(fpga_hssi_handle hssi, hssi_csr **csrs_p,
	size_t *count)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	if (!count)
		return FPGA_INVALID_PARAM;

	if (!csrs_p)
		return FPGA_INVALID_PARAM;

	*csrs_p = hssi->csrs;
	*count = hssi->csr_cnt;
	return FPGA_OK;
}

fpga_result fpgaHssiFilterCsrByName(fpga_hssi_handle hssi,
	const char *name, hssi_csr *csr_p)
{
	int indicator;
	if (!hssi || !csr_p)
		return FPGA_INVALID_PARAM;

	int i = 0;

	for (i = 0; i < hssi->csr_cnt; i++) {
		strcmp_s(name, MAX_NAME_LEN, hssi->csrs[i]->name, &indicator);
		if(indicator == 0) {
			*csr_p = hssi->csrs[i];
			return FPGA_OK;
		}
	}
	*csr_p = NULL;
	return FPGA_NOT_FOUND;
}

fpga_result fpgaHssiFilterCsrByOffset(fpga_hssi_handle hssi,
	uint64_t offset, hssi_csr *csr_p)
{
	if (!hssi || !csr_p)
		return FPGA_INVALID_PARAM;

	int i = 0;

	for (i = 0; i < hssi->csr_cnt; i++) {
		if (offset == hssi->csrs[i]->offset) {
			*csr_p = hssi->csrs[i];
			return FPGA_OK;
		}
	}
	*csr_p = NULL;
	return FPGA_NOT_FOUND;
}
