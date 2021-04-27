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
            //   - in UPI polling mode, any size allowed
            //   - in MMIO mode, must be equal to 0
            //   - in DMA mode, must be multiple of DMA batch size
            constexpr size_t l_tx_queue_size = 3;
            static_assert((1 << l_tx_queue_size) >= tx_batch_size,
                          "tx queue size should be multiple of tx batch size");

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
            constexpr size_t polling_rate = 10;

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
