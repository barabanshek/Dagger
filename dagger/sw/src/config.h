#ifndef _CONFIG_H_
#define _CONFIG_H_

// Check build configuration
#ifdef NIC_PHY_NETWORK
#ifdef PLATFORM_BDX
    #error Physical networking can only be supported on PAC_A10 platform
#endif
#endif

#include <type_traits>

namespace frpc {
    namespace cfg {
        namespace sys {
            // Cache line size
            //   - in Bytes
            //   - do not change unless the system has changed
            constexpr size_t cl_size_bytes = 64;

        } // namespace sys

        namespace nic {
            // tx DMA batch size
            //   - in MTUs
            //   - see NicCCIP for MTU definition
            //   - only used with CCI-P DMA mode enabled
            constexpr size_t tx_batch_size = 0;

            // Log tx queue size
            //   - in MTUs
            //   - see NicCCIP for MTU definition
            // Constraints:
            //   - in UPI polling mode, any size allowed, but it should be at least
            //     log(RX_BATCH_SIZE) as defined in ccip_queue_polling.sv
            //   - in MMIO mode, must be equal to 0
            //   - in DMA mode, must be multiple of DMA batch size
            constexpr size_t l_tx_queue_size = 3;
            static_assert((1 << l_tx_queue_size) >= tx_batch_size,
                          "tx queue size should be multiple of tx batch size");
#ifdef NIC_CCIP_MMIO
            static_assert(l_tx_queue_size == 0, "tx queue size should be 0 for MMIO-based mode");
#endif

            // Log rx batch size
            //   - in MTUs
            //   - see NicCCIP for MTU definition
            constexpr size_t l_rx_batch_size = 0;

            // Log rx queue size
            //   - in MTUs
            //   - see NicCCIP for MTU definition
            // Constraints:
            //   - must be equal to rx batch size
            constexpr size_t l_rx_queue_size = 0;
            static_assert(l_rx_queue_size == l_rx_batch_size,
                          "rx queue size should be equal to rx batch size");

            // Polling rate
            //   - only used with CCI-P polling mode enabled
            //   - `30` is the empirical value when UPI demonstrates the lowest latency
            //   - if polling rate is low, requests need to wait until they get polled
            //   - if high, the UPI bus becomes congested and it negatively impacts the bus tail latency
            //   - TODO: think about an adaptive polling rate
            //   - TODO: better interconnects may allow to get rid of polling at all
            //   - TODO: CCI-P uMsg can be used here to avoid or reduce polling, but they are not supported on Broadwell;
            //           uMsg can essentially act as "interrupts", but for hardware, via Invalidation messages
            constexpr size_t polling_rate = 30;

        } // namespace nic

        namespace platform {
            // Bus ID of the first FPGA on PAC_A10
            constexpr uint8_t pac_a10_fpga_bus_1 = 0x18;

            // Bus ID of the second FPGA on PAC_A10
            constexpr uint8_t pac_a10_fpga_bus_2 = 0xaf;

        } // namespace platform

    }  // namespace cgf

}  // namespace frpc

#endif
