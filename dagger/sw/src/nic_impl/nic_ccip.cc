#include "nic_ccip.h"

#include <assert.h>
#include <thread>
#include <unistd.h>

#include "logger.h"

// Hardware congifuration
// NIC's JSON file, extracted using OPAE's afu_json_mgr script
#include "afu_json_info.h"

namespace frpc {

// Timeouts
#define NIC_INIT_DELAY_S 1
#define NIC_INIT_TIMEOUT 5 // in # of iteration of NIC_INIT_DELAY_S
#define NIC_PERF_DELAY_S 2


NicCCIP::NicCCIP(uint64_t base_nic_addr, bool master_nic = true):
    base_nic_addr_(base_nic_addr),
    master_nic_(master_nic),
    connected_(false),
    initialized_(false),
    started_(false),
    collect_perf_(false) {

}

NicCCIP::~NicCCIP() {
    if (started_) {
        stop_nic();
    }

    if (connected_ && master_nic_) {
        fpgaClose(accel_handle_);
    }

    FRPC_INFO("Nic is disconnected\n");
}

int NicCCIP::connect_to_nic() {
    assert(connected_ == false);

    // Connect to FPGA
    accel_handle_ = connect_to_accel(AFU_ACCEL_UUID);
    if (accel_handle_ == 0) {
        FRPC_ERROR("Failed to connect to nic\n");
        return 1;
    }

    connected_ = true;
    return 0;
}

int NicCCIP::initialize_nic() {
    assert(connected_ == true);

    // Assert initial hw state
    NicHwStatus status;
    int res = get_nic_hw_status(status);
    if (res != 0)
        return res;
    assert(status.ready == 0);
    assert(status.running == 0);
    assert(status.error == 0);

    // Run initialization
    fpga_result ret = fpgaWriteMMIO64(accel_handle_,
                                      0,
                                      base_nic_addr_ + iRegNicInit,
                                      iConstNicInit);
    if (ret != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to configure iRegNicInit"
                    "nic returned %d\n", ret);
        return 1;
    }

    // Wait until NIC is initialized
    int wait_iteration = 0;
    do {
        int res = get_nic_hw_status(status);
        if (res != 0)
            return res;
        ++wait_iteration;
        sleep(NIC_INIT_DELAY_S);
    } while (status.ready == 0 && wait_iteration < NIC_INIT_TIMEOUT);

    if (status.ready == 0) {
        FRPC_ERROR("Nic configuration error, failed to initialize nic: timeout reached\n");
        return 1;
    }

    assert(status.ready == 1);
    assert(status.running == 0);
    assert(status.error == 0);

    initialized_ = true;
    FRPC_INFO("Nic is initialized\n");
    return 0;
}

int NicCCIP::start_nic(bool perf) {
    assert(connected_ == true);
    assert(initialized_ == true);
    assert(started_ == false);

    // Assert initial hw state
    NicHwStatus status;
    int res = get_nic_hw_status(status);
    if (res != 0)
        return res;
    assert(status.ready == 1);
    assert(status.running == 0);
    assert(status.error == 0);

    // Run
    fpga_result ret = fpgaWriteMMIO64(accel_handle_,
                                      0,
                                      base_nic_addr_ + iRegNicStart,
                                      iConstNicStart);
    if (ret != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to configure start bit,"
                    "nic returned %d\n", ret);
        return 1;
    }

    // Wait until NIC is running
    int wait_iteration = 0;
    do {
        int res = get_nic_hw_status(status);
        if (res != 0)
            return res;
        ++wait_iteration;
        sleep(NIC_INIT_DELAY_S);
    } while (status.running == 0 && wait_iteration < NIC_INIT_TIMEOUT);

    if (status.running == 0) {
        FRPC_ERROR("Nic configuration error, failed to run nic: timeout reached\n");
        return 1;
    }

    assert(status.ready == 1);
    assert(status.running == 1);
    assert(status.error == 0);

    // Start perf thread if required
    if (perf) {
        collect_perf_ = true;
        perf_thread_ = std::thread{&NicCCIP::get_perf, this};
    }

    started_ = true;
    return 0;
}

int NicCCIP::stop_nic() {
    assert(connected_ == true);
    assert(initialized_ == true);
    assert(started_ == true);

    // Assert initial hw state
    NicHwStatus status;
    int res = get_nic_hw_status(status);
    if (res != 0)
        return res;
    assert(status.ready == 1);
    assert(status.running == 1);
    assert(status.error == 0);

    // Stop perf if running
    if (collect_perf_) {
        collect_perf_ = false;
        perf_thread_.join();
    }

    // Stop
    fpga_result ret = fpgaWriteMMIO64(accel_handle_,
                                      0,
                                      base_nic_addr_ + iRegNicStart,
                                      iConstNicStop);
    if (ret != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to configure start bit,"
                    "nic returned %d\n", ret);
        return 1;
    }

    // Wait until NIC is stopped
    int wait_iteration = 0;
    do {
        int res = get_nic_hw_status(status);
        if (res != 0) {
            return res;
        }
        ++wait_iteration;
        sleep(NIC_INIT_DELAY_S);
    } while (status.running == 1 && wait_iteration < NIC_INIT_TIMEOUT);

    if (status.running == 1) {
        FRPC_ERROR("Nic configuration error, failed to stop nic: timeout reached\n");
        return 1;
    }

    assert(status.ready == 1);
    assert(status.running == 0);
    assert(status.error == 0);

    started_ = false;
    return 0;
}

int NicCCIP::check_hw_errors() const {
    NicHwStatus status;
    int res = get_nic_hw_status(status);
    if (res != 0) {
        return res;
    }

    if (status.error != 0) {
        FRPC_ERROR("Hardware errors are found in nic %d \n", status.nic_id);
        FRPC_ERROR("%s\n", dump_nic_hw_status(status).c_str());
        return 1;
    }

    return 0;
}

int NicCCIP::get_nic_hw_status(NicHwStatus& status) const {
    assert(connected_ == true);

    NicHwStatus status_;
    uint64_t raw_status = 0;
    fpga_result res = fpgaReadMMIO64(accel_handle_,
                                     0,
                                     base_nic_addr_ + iRegNicStatus,
                                     &raw_status);
    if (res != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to read status register"
                    "nic returned: %d\n", res);
        return 1;
    }

    status_ = *reinterpret_cast<NicHwStatus*>(reinterpret_cast<char*>(&raw_status));

    status = status_;
    return 0;
}

std::string NicCCIP::dump_nic_hw_status(const NicHwStatus& status) const {
    std::string ret;
    ret += "*** Nic hw status dump ***\n";
    ret += "  nic_id= "           + std::to_string(status.nic_id)           + "\n";
    ret += "  ready= "            + std::to_string(status.ready)            + "\n";
    ret += "  running= "          + std::to_string(status.running)          + "\n";
    ret += "  error= "            + std::to_string(status.error)            + "\n";
    ret += "  err_rpcRxFifoOvf= " + std::to_string(status.err_rpcRxFifoOvf) + "\n";
    ret += "  err_rpcTxFifoOvf= " + std::to_string(status.err_rpcTxFifoOvf) + "\n";
    ret += "  err_ccip= "         + std::to_string(status.err_ccip)         + "\n";

    return ret;
}

void NicCCIP::get_perf() const {
    assert(connected_ == true);

    while(collect_perf_) {
        // Get perf
        uint64_t perf_cnt = 0;
        fpga_result res = fpgaReadMMIO64(accel_handle_,
                                         0,
                                         base_nic_addr_ + iRegCcipRps,
                                         &perf_cnt);
        if (res != FPGA_OK) {
            FRPC_ERROR("Nic configuration error, failed to read performance counter"
                        "nic returned: %d\n", res);
        }
        FRPC_INFO("Nic #%x returned performance counter(ccip rps)= %d\n", base_nic_addr_, perf_cnt);

        // Get status
        NicHwStatus status;
        int ret = get_nic_hw_status(status);
        if (ret != 0) {
            FRPC_ERROR("NIC configuration error, failed to get status, "
                        "NIC returned %d\n", ret);
        }
        FRPC_INFO("%s\n", dump_nic_hw_status(status).c_str());

        // Get packet counters
        std::string counters_str;
        counters_str += "*** Nic hw counters dump ***\n";
        for (uint8_t cnt_id=0; cnt_id<iNumOfPckCnt; ++cnt_id) {
            fpga_result res = fpgaWriteMMIO64(accel_handle_,
                                              0,
                                              base_nic_addr_ + iRegGetPckCnt,
                                              cnt_id);
            if (res != FPGA_OK) {
                FRPC_ERROR("Nic configuration error, failed to read packet counters"
                            "nic returned: %d\n", res);
            }

            // Wait until fpgaWrite propagates and counter is read
            usleep(1000);
            uint64_t pck_cnt = 0;
            res = fpgaReadMMIO64(accel_handle_,
                                 0,
                                 base_nic_addr_ + iRegPckCnt,
                                 &pck_cnt);
            if (res != FPGA_OK) {
                FRPC_ERROR("Nic configuration error, failed to read packet counters"
                            "nic returned: %d\n", res);
            }
            counters_str += "  counter[" + std::to_string(cnt_id) + "] = " +
                                           std::to_string(pck_cnt) + "\n";
        }
        FRPC_INFO("%s\n", counters_str.c_str());

        sleep(NIC_PERF_DELAY_S);
    }
}

size_t NicCCIP::round_up_to_pagesize(size_t val) const {
    size_t page_size_bytes = getpagesize();
    size_t remainder = val % page_size_bytes;

    if (remainder == 0)
        return val;

    size_t res = val + page_size_bytes - remainder;
    assert(res % page_size_bytes == 0);

    return res;
}

// Taken from Intel Corporation, OPAE example; modified by Nikita
volatile void* NicCCIP::alloc_buffer(fpga_handle accel_handle, ssize_t size,
                                 uint64_t *wsid, uint64_t *io_addr) const {
    fpga_result res;
    volatile void* buf;

    res = fpgaPrepareBuffer(accel_handle,
                            size,
                            const_cast<void**>(&buf), wsid, 0);
    if (res != FPGA_OK) return nullptr;

    // Get the physical address of the buffer in the accelerator
    res = fpgaGetIOAddress(accel_handle, *wsid, io_addr);
    assert(res == FPGA_OK);

    return buf;
}

// Taken from Intel Corporation, OPAE example; modified by Nikita
fpga_handle NicCCIP::connect_to_accel(const char *accel_uuid) const {
    fpga_properties filter = nullptr;
    fpga_guid guid;
    fpga_token accel_token;
    uint32_t num_matches;
    fpga_handle accel_handle;
    fpga_result res;

    // Don't print verbose messages in ASE by default
    setenv("ASE_LOG", "0", 0);

    // Set up a filter that will search for an accelerator
    fpgaGetProperties(NULL, &filter);
    fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);

    // Add the desired UUID to the filter
    uuid_parse(accel_uuid, guid);
    fpgaPropertiesSetGUID(filter, guid);

    // Do the search across the available FPGA contexts
    num_matches = 1;
    fpgaEnumerate(&filter, 1, &accel_token, 1, &num_matches);

    // Not needed anymore
    fpgaDestroyProperties(&filter);

    if (num_matches < 1) {
        FRPC_ERROR("Accelerator %s not found!\n", accel_uuid);
        return 0;
    }

    // Open accelerator
    res = fpgaOpen(accel_token, &accel_handle, FPGA_OPEN_SHARED);
    assert(res == FPGA_OK);

    // Done with token
    fpgaDestroyToken(&accel_token);

    return accel_handle;
}

}  // namespace frpc
