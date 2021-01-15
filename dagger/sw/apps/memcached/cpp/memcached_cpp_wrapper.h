// Use this file as a C-compatible wrapper for the RpcThreadedServer

#ifndef _RPC_THREADED_SERVER_WRAPPER_H_
#define _RPC_THREADED_SERVER_WRAPPER_H_

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif

#include <stdint.h>
#include "rpc_call.h"
#include "rpc_types.h"

EXTERNC int memcached_wrapper_init_and_start_server();

EXTERNC int memcached_wrapper_open_connection(const char* client_ip,
                                              uint16_t client_port,
                                              uint32_t c_id);

EXTERNC int memcached_wrapper_register_functions(
                                int (*set)(struct CallHandler,
                                           struct SetRequest,
                                           struct SetResponse*),
                                int (*get)(struct CallHandler,
                                           struct GetRequest,
                                           struct GetResponse*),
                                int (*populate)(struct CallHandler,
                                                struct PopulateRequest,
                                                struct PopulateResponse*));

EXTERNC int memcached_wrapper_run_new_listening_thread();

#undef EXTERNC

#endif
