#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <vector>

#include "service_utils.h"

#include "rpc_call.h"
#include "rpc_client_pool.h"

#include "../check_in_service/CheckInService_rpc_client.h"
#include "../check_in_service/CheckInService_rpc_types.h"


//
// Main Part
//
#define NIC_ADDR 0x00000
static constexpr char* check_in_service_host_addr = "0.0.0.1";

static int run_workload_thread(frpc::RpcClient* rpc_client,
                               int thread_id,
                               size_t num_iterations,
                               size_t req_delay,
                               double cycles_in_ns);

int main(int argc, char* argv[]) {
    double cycles_in_ns = rdtsc_in_ns();
    std::cout << "Cycles in ns: " << cycles_in_ns << std::endl;

    // Parse input
    size_t num_of_threads = atoi(argv[1]);
    size_t num_of_requests = atoi(argv[2]);
    size_t req_delay = atoi(argv[3]);

    // Run RPC clients
    frpc::RpcClientPool<frpc::RpcClient> rpc_client_pool(NIC_ADDR,
                                                         num_of_threads);

    int res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    res = rpc_client_pool.start_nic();
    if (res != 0)
        return res;

    res = rpc_client_pool.run_perf_thread({true, true, true}, nullptr);
    if (res != 0)
        return res;

    // Open connections and run client threads
    std::vector<std::thread> threads;
    frpc::IPv4 server_addr(check_in_service_host_addr, 3136);
    for (int i=0; i<num_of_threads; ++i) {
        frpc::RpcClient* rpc_client = rpc_client_pool.pop();
        assert(rpc_client != nullptr);

        if (rpc_client->connect(server_addr, i) != 0) {
            std::cout << "Failed to open connection on client" << std::endl;
            exit(1);
        } else {
            std::cout << "Connection is open on client" << std::endl;
        }

        std::thread thr = std::thread(&run_workload_thread,
                                      rpc_client,
                                      i,
                                      num_of_requests,
                                      req_delay,
                                      cycles_in_ns);
        threads.push_back(std::move(thr));
    }

    for (auto& thr: threads) {
        thr.join();
    }

    // Check for HW errors
    res = rpc_client_pool.check_hw_errors();
    if (res != 0)
        std::cout << "HW errors found, check error log" << std::endl;
    else
        std::cout << "No HW errors found" << std::endl;

    // Stop NIC
    res = rpc_client_pool.stop_nic();
    if (res != 0)
        return res;

    return 0;
}

static bool sortbysec(const uint64_t &a, const uint64_t &b) {
    return a < b;
}

static int run_workload_thread(frpc::RpcClient* rpc_client,
                               int thread_id,
                               size_t num_iterations,
                               size_t req_delay,
                               double cycles_in_ns) {
    constexpr int max_flight_number = 220;

    RndGen rnd_gen(123456789);
    for (size_t i=0; i<num_iterations; ++i) {
        RegistrationPassengerData req;
        req.timestamp = frpc::utils::rdtsc();
        req.trace_id = gen_trace_id();
        sprintf(req.first_name, rnd_gen.next_str(12).c_str());
        sprintf(req.last_name, rnd_gen.next_str(12).c_str());
        req.flight_number = rnd_gen.next_u32() % max_flight_number;
#ifdef _SERVICE_VERBOSE_
        std::cout << "#" << req.trace_id << " Frontend>"
                  << " registering passenger <" << req.first_name << ", " << req.last_name
                  << ">, fligh #" << static_cast<int>(req.flight_number) << std::endl;
#else
        if (i%1000 == 0) {
            std::cout << "#" << req.trace_id << " Frontend>"
                      << " registering passenger <" << req.first_name << ", " << req.last_name
                      << ">, fligh #" << static_cast<int>(req.flight_number) << std::endl;
        }
#endif
        rpc_client->register_passenger(req);

        // Blocking delay to control rps rate
        for (size_t delay=0; delay<req_delay; ++delay) {
            asm("");
        }
    }

    // Wait a bit
    sleep(10);

    // Get registration status
    auto cq = rpc_client->get_completion_queue();
    size_t cq_size = cq->get_number_of_completed_requests();
    std::cout << "Thread #" << thread_id << ": CQ size= " << cq_size << std::endl;

    size_t num_errors = 0;
    for (int i=0; i<cq_size; ++i) {
        RegistrationStatus* status = reinterpret_cast<RegistrationStatus*>(cq->pop_response().argv);
#ifdef _SERVICE_VERBOSE_
        std::cout << "Registration status for trace #" << status->trace_id << " "
                  << status->status << ", seat number #" << static_cast<int>(status->seat_number) << std::endl;
#endif

        // Check status
        if (strcmp(status->status, "OK") != 0) {
            std::cout << "Fail detected in trace #" << status->trace_id << ", status= "
                      << status->status << std::endl;
            ++num_errors;
        }
    }

    std::cout << "Number of failed requests: " << num_errors << std::endl;

    // Get latency profile
    auto latency_records = cq->get_latency_records();

    std::sort(latency_records.begin(), latency_records.end(), sortbysec);

    if (latency_records.size() != 0) {
        std::cout << "***** latency results for thread #" << thread_id
                  << " *****" << std::endl;
        std::cout << "  total records= " << latency_records.size() << std::endl;
        std::cout << "  median= "
                  << latency_records[latency_records.size()*0.5]/cycles_in_ns
                  << " ns" << std::endl;
        std::cout << "  90th= "
                  << latency_records[latency_records.size()*0.9]/cycles_in_ns
                  << " ns" << std::endl;
        std::cout << "  99th= "
                  << latency_records[latency_records.size()*0.99]/cycles_in_ns
                  << " ns" << std::endl;
    }

    return 0;
}
