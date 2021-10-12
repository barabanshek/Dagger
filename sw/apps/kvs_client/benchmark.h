#ifndef _BENCHMARK_H_
#define _BENCHMARK_H_

#include "rpc_call.h"
#include "rpc_client.h"
#include "rpc_types.h"

int benchmark(const std::vector<dagger::RpcClient*>& rpc_clients,
                     const std::vector<std::string>& param);

int run_set_get_benchmark(dagger::RpcClient* rpc_client,
	                             const std::vector<std::pair<std::string, std::string>>& dataset,
                                 int thread_id,
                                 size_t num_iterations,
                                 double cycles_in_ns,
                                 uint64_t starting_key,
                                 const std::vector<uint32_t>& set_get_distr,
                                 size_t set_get_fraction,
                                 size_t set_get_req_delay);

void print_latency(std::vector<uint32_t>& latency_records,
                          size_t thread_id,
                          double cycles_in_ns);

double rdtsc_in_ns();

#endif
