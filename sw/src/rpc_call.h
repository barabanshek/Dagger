/**
 * @file rpc_call.h
 * @brief Some definitions for RPC calls.
 * @author Nikita Lazarev
 */
#ifndef _RPC_CALL_H_
#define _RPC_CALL_H_

#include <stdint.h>

// Return codes of user-defined remote functions.
enum RpcRetCode { Success, Fail };

// RPC hander being passed to user-defined remote functions (always as the first
// argument).
struct CallHandler {
  uint16_t thread_id;  // thread_id the RPC call is binded to
};

#endif
