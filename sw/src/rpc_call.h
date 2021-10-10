#ifndef _RPC_CALL_H_
#define _RPC_CALL_H_

#include <stdint.h>

// Return codes of user-defined remote functions
enum RpcRetCode {
    Success,
    Fail
};

// RPC hander being passed to user-defined remote functions as firt argument
struct CallHandler {
	uint16_t thread_id;	// thread_id the RPC call is binded to
};

#endif
