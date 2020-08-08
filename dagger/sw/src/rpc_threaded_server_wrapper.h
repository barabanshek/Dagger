// Use this file as a C-compatible wrapper for the RpcThreadedServer

#ifndef _RPC_THREADED_SERVER_WRAPPER_H_
#define _RPC_THREADED_SERVER_WRAPPER_H_

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif

EXTERNC int rpc_server_thread_wrapper_init_and_start_server();
EXTERNC int rpc_server_thread_wrapper_register_new_listening_thread(int (*foo)(int, int));

#undef EXTERNC

#endif
