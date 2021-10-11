/**
 * @file rpc_client_nonblocking_base.h
 * @brief Base class to implement non-blocking RPC stubs. The auto-generated
 * RPC stubs extent this class to implement application-specific (interface
 * definition specific) interfaces.
 * @author Nikita Lazarev
 */
#ifndef _RPC_CLIENT_NBLOCK_BASE_H_
#define _RPC_CLIENT_NBLOCK_BASE_H_

#include <utility>
#include <vector>

#include "completion_queue.h"
#include "connection_manager.h"
#include "nic.h"
#include "rpc_header.h"
#include "tx_queue.h"

namespace dagger {

/// Non-blocking RPC client. Does not block the calling thread, returns the
/// result through an async CompletionQueue.
/// The RPC codegenerator extends (implements) this abstract class to define the
/// client RPC stubs.
/// The main putpose of this abstract class is to encapsulate interfaces with
/// the hardware.
class RpcClientNonBlock_Base {
 public:
  /// Forbid instantiation.
  virtual void abstract_class() const = 0;

  /// Construct a non-blocking client based on the nic's @param nic flow id
  /// @param nic_flow_id. The @param client_id is a part of the RPC header of
  /// all the requests coming from this client.
  RpcClientNonBlock_Base(const Nic* nic, size_t nic_flow_id,
                         uint16_t client_id);
  virtual ~RpcClientNonBlock_Base();

  /// Get associated bound completion queue.
  CompletionQueue* get_completion_queue() const;

  /// A wrapper on top of the nic's connection management functions.
  int connect(const IPv4& server_addr, ConnectionId c_id);
  int disconnect();

 protected:
  /// client_id - a part of the rpc_id in the RPC header.
  uint16_t client_id_;

  /// Backed nic and flow id.
  const Nic* nic_;
  size_t nic_flow_id_;

  /// Backed tx queue where the client writes requests into.
  TxQueue tx_queue_;

  // rpc_id counter - a part of the RPC header.
  uint16_t rpc_id_cnt_;

#ifdef NIC_CCIP_DMA
  uint32_t current_batch_ptr;
  size_t batch_counter;
#endif

  // Connection ID associated with this client.
  // TODO(Nikita): so far, we only support a single connection per client;
  //       multiple connections will also work, but it's up to client
  //       to handle all responses.
  ConnectionId c_id_;

 private:
  // Binded completion queue.
  std::unique_ptr<CompletionQueue> cq_;
};

}  // namespace dagger

#endif  // _RPC_CLIENT_NBLOCK_BASE_H_
