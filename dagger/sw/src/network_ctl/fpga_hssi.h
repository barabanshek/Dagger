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
 * \fpga_hssi.h
 * \brief HSSI API Header
 *
 */
#ifndef __FPGA_HSSI_H__
#define __FPGA_HSSI_H__

#include <stdint.h>
#include <stdbool.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include "afu_json_info.h"


#ifdef __cplusplus
extern "C" {
#endif

#include "fpga_hssi_common.h"

#define E40_AFU_ID AFU_ACCEL_UUID

#define MAX_NAME_LEN 256
#define MAX_DESC_LEN 2048
	
/**
 * fpgaHssiOpen
 *
 * @brief           Open HSSI handle
 *                  Scans the device feature chain for HSSI BBB.
 *                  The BBB consists of E10 MAC, traffic generator
 *                  and checker
 *
 * @param[in]  fpga Handle to the FPGA AFU object obtained via fpgaOpen()
 * @param[out] hssi Pointer to HSSI handle
 * @returns         FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiOpen(fpga_handle fpga, fpga_hssi_handle *hssi);

/**
 * fpgaHssiClose
 *
 * @brief           Close HSSI handle.
 *
 * @param[in] hssi  HSSI object handle
 * @returns         FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiClose(fpga_hssi_handle hssi);

/**
 * fpgaHssiWriteCsr64
 *
 * @brief           Write value to CSR
 *
 * @param[in] hssi  HSSI handle
 * @param[in] csr   CSR
 * @param[in] val   Value to write
 *
 * @returns         FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiWriteCsr64(fpga_hssi_handle hssi, hssi_csr csr,
	uint64_t val);

/**
 * fpgaHssiReadCsr64
 *
 * @brief           Read value from CSR
 *
 * @param[in] hssi  HSSI handle
 * @param[in] csr   CSR
 * @param[out] val  Read value
 *
 * @returns         FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiReadCsr64(fpga_hssi_handle hssi, hssi_csr csr,
	uint64_t *val);


/**
 * fpgaHssiReset
 *
 * @brief           Issue HSSI channel reset
 * @param[in] hssi  HSSI object handle
 *
 * @returns         FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiReset(fpga_hssi_handle hssi);

/**
 * fpgaHssiCtrlLoopback
 *
 * @brief                 Enable/Disable channel loopback
 *
 * @param[in] hssi        HSSI handle
 * @param[in] channel_num Channel number
 * @param[in] loopback_en Channel loopback control
 *                        (true=enable loopback)
 *
 * @returns               FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiCtrlLoopback(fpga_hssi_handle hssi, uint32_t channel_num,
	bool loopback_en);

/**
 * fpgaHssiGetLoopbackStatus
 *
 * @brief                  Get channel loopback status
 *
 * @param[in] hssi         HSSI handle
 * @param[in] channel_num  Channel number
 * @param[out] loopback_en Loopback status
 *                         (true=loopback enabled)
 *
 * @returns                FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiGetLoopbackStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *loopback_en);

/**
 * fpgaHssiGetFreqLockStatus
 *
 * @brief                  Get channel freq. lock status
 *
 * @param[in] hssi         HSSI handle
 * @param[in] channel_num  Channel number
 * @param[out] freq_locked Frequency locked status
 *                         (true=frequency locked)
 *
 * @returns                FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiGetFreqLockStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *freq_locked);

/**
 * fpgaHssiGetWordLockStatus
 *
 * @brief                  Get channel word lock status
 *
 * @param[in] hssi         HSSI handle
 * @param[in] channel_num  Channel number
 * @param[out] word_locked Word lock status
 *                         (true=word locked)
 *
 * @returns                FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiGetWordLockStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *word_locked);

/**
 * fpgaSendPacket
 *
 * @brief                 Transmit packets on a channel
 *
 * @param[in] hssi        HSSI handle
 * @param[in] channel_num Channel number
 * @param[in] num_packets Total number of packets to send
 *
 * @returns               FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiSendPacket(fpga_hssi_handle hssi,
	uint32_t channel_num, uint64_t num_packets);

/**
 * fpgaPrintChannelStats
 *
 * @brief                 Print all channel CSRs
 *
 * @param[in] hssi        HSSI handle
 * @param[in] type        Channel type
 * @param[in] channel_num Channel number
 *
 * @returns               FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiPrintChannelStats(fpga_hssi_handle hssi_h,
	hssi_csr_type_t type, uint32_t channel_num);

/**
 * fpgaHssiClearChannelStats
 *
 * @brief                 Clear channel statistics
 * @param[in] hssi        HSSI object handle
 * @param[in] channel_num Channel number
 * @returns               FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiClearChannelStats(fpga_hssi_handle hssi,
	hssi_csr_type_t type, uint32_t channel_num);

/**
 * fpgaHssiEnumerateCsr
 *
 * @brief             Retrieve all available CSRs
 *
 * @param[in] hssi    HSSI object handle
 * @param[out] csrs_p Pointer to enumerated list of CSRs
 * @param[out] count  Count of available CSRs
 *
 * @returns           FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiEnumerateCsr(fpga_hssi_handle hssi, hssi_csr **csrs_p,
	size_t *count);

/**
 * fpgaHssiFilterCsrByName
 *
 * @brief            Retrieve CSR by name string
 *
 * @param[in] hssi   HSSI handle
 * @param[in] name   CSR name string
 * @param[out] csr_p Pointer to csr
 *
 * @returns          FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiFilterCsrByName(fpga_hssi_handle hssi, const char *name,
	hssi_csr *csr_p);

/**
 * fpgaHssiFilterCsrByOffset
 *
 * @brief            Retrieve CSR by offset
 *
 * @param[in] hssi   HSSI handle
 * @param[in] offset CSR offset
 * @param[out] csr_p Pointer to csr
 *
 * @returns          FPGA_OK on success, return code otherwise
 */
fpga_result fpgaHssiFilterCsrByOffset(fpga_hssi_handle hssi, uint64_t offset,
	hssi_csr *csr_p);



#ifdef __cplusplus
}
#endif

#endif // __FPGA_HSSI_H__
