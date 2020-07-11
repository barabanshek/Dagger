#ifndef _CONFIG_H_
#define _CONFIG_H_

#include <type_traits>

namespace frpc {
    namespace cfg {
        namespace nic {
            // Log tx queue size
            //   - in MTUs
            //   - see NicCCIP for MTU definition
            constexpr size_t l_tx_queue_size = 3;

            // Log rx batch size
            //   - in MTUs
            //   - see NicCCIP for MTU definition
            constexpr size_t l_rx_batch_size = 0;

            // Log rx queue size
            //   - in MTUs
            //   - see NicCCIP for MTU definition
            constexpr size_t l_rx_queue_size = 0;
            static_assert(l_rx_queue_size == l_rx_batch_size,
                          "rx queue size should be equal to rx batch size");

        } // namespace nic

    }  // namespace cgf

}  // namespace frpc

#endif
