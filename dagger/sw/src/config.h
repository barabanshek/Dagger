#ifndef _CONFIG_H_
#define _CONFIG_H_

#include <type_traits>

namespace frpc {
    namespace cfg {
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
            constexpr size_t l_tx_queue_size = 5;
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

        } // namespace nic

    }  // namespace cgf

}  // namespace frpc

#endif
