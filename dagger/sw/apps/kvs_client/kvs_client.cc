#include <unistd.h>

#include <cassert>
#include <cinttypes>
#include <csignal>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>
#include <sstream>
#include <vector>

#include "benchmark.h"
#include "rpc_call.h"
#include "rpc_client.h"
#include "rpc_client_pool.h"
#include "rpc_types.h"
#include "utils.h"

// HW parameters
#define NIC_ADDR 0x20000

// Timeout
static constexpr size_t t_out = 1000;

// Ctl-C handler
static volatile int keepRunning = 1;

void intHandler(int dummy) {
    keepRunning = 0;
}

static void shell_loop(const std::vector<frpc::RpcClient*>& rpc_clients);

int main(int argc, char* argv[]) {
    size_t num_of_threads = atoi(argv[1]);

    frpc::RpcClientPool<frpc::RpcClient> rpc_client_pool(NIC_ADDR,
                                                         num_of_threads);

    // Init client pool
    int res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    // Start NIC with perf enabled
    res = rpc_client_pool.start_nic();
    if (res != 0)
        return res;

    sleep(1);

    // Provision RPC clients/threads
    // Open connections on each client
    std::vector<frpc::RpcClient*> rpc_clients;
    for (int i=0; i<num_of_threads; ++i) {
        frpc::RpcClient* rpc_client = rpc_client_pool.pop();
        assert(rpc_client != nullptr);

        rpc_clients.push_back(rpc_client);

        // Open connection
        frpc::IPv4 server_addr("192.168.0.1", 3136);
        if (rpc_client->connect(server_addr, i) != 0) {
            std::cout << "Failed to open connection on client" << std::endl;
            exit(1);
        } else {
            std::cout << "Connection is open on client" << std::endl;
        }
    }

    // Run interactive shell
    shell_loop(rpc_clients);

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

static void shell_loop(const std::vector<frpc::RpcClient*>& rpc_clients) {
    std::cout << "Welcome to Dagger KVS shell" << std::endl;

    size_t batch_size = 1 << frpc::cfg::nic::l_rx_batch_size;
    size_t dummy_requests = batch_size - 1;

    std::cout << "Nic is configured with the batch of " << batch_size
              << ", make sure to have enough of requests to fulfill the batch"
              << std::endl;

    while (keepRunning) {
        char cmd[100];

        std::cout << "> ";
        std::cin.getline(cmd, sizeof(cmd));

        std::istringstream iss(cmd);
        std::vector<std::string> words((std::istream_iterator<std::string>(iss)),
                                         std::istream_iterator<std::string>());

        if (words.size() < 1) {
            std::cout << "wrong comand" << std::endl;
            continue;
        }

        if (words[0] == "set") {
            // do set
            if (words.size() != 4) {
                std::cout << "wrong format of the `set` comand" << std::endl;
                continue;
            }

            int client_id = std::stoi(words[1]);
            std::string key = words[2];
            std::string value = words[3];

            if (client_id > rpc_clients.size() - 1) {
                std::cout << "client id is to high" << std::endl;
                continue;
            }

            SetRequest set_req;
            set_req.timestamp = static_cast<uint32_t>(frpc::utils::rdtsc());
            sprintf(set_req.key, key.c_str());
            sprintf(set_req.value, value.c_str());
            rpc_clients[client_id]->set(set_req);

            auto cq = rpc_clients[client_id]->get_completion_queue();

            size_t i = 0;
            while(cq->get_number_of_completed_requests() == 0 && i < t_out) {
                ++i;
                usleep(1000);
            }

            if (cq->get_number_of_completed_requests() == 0) {
                std::cout << "> set did not return anything" << std::endl;
            } else {
                std::cout << "> set returned: "
                          << reinterpret_cast<GetResponse*>(cq->pop_response().argv)->value << std::endl;
            }

        } else if (words[0] == "get") {
            // do get
            if (words.size() != 3) {
                std::cout << "wrong format of the `get` comand" << std::endl;
                continue;
            }

            int client_id = std::stoi(words[1]);
            std::string key = words[2];

            if (client_id > rpc_clients.size() - 1) {
                std::cout << "client id is to high" << std::endl;
                continue;
            }

            GetRequest get_req;
            get_req.timestamp = static_cast<uint32_t>(frpc::utils::rdtsc());
            sprintf(get_req.key, key.c_str());
            rpc_clients[client_id]->get(get_req);

            auto cq = rpc_clients[client_id]->get_completion_queue();

            size_t i = 0;
            while(cq->get_number_of_completed_requests() == 0 && i < t_out) {
                ++i;
                usleep(1000);
            }

            if (cq->get_number_of_completed_requests() == 0) {
                std::cout << "> get did not return anything" << std::endl;
            } else {
                std::cout << "> get returned: "
                          << reinterpret_cast<GetResponse*>(cq->pop_response().argv)->value << std::endl;
            }

        } else if (words[0] == "populate") {
            // do populate
            if (words.size() != 3) {
                std::cout << "wrong format of the `populate` comand" << std::endl;
                continue;
            }

            int client_id = std::stoi(words[1]);
            std::string dataset_path = words[2];

            if (client_id > rpc_clients.size() - 1) {
                std::cout << "client id is to high" << std::endl;
                continue;
            }

            if (batch_size > 1) {
                std::cout << "Dagger is configured with the batch size of " << batch_size
                          << ", the shell will add " << dummy_requests
                          << " dummy requests in each call" << std::endl;

                for(size_t i=0; i<dummy_requests; ++i) {
                    GetRequest get_req;
                    get_req.timestamp = static_cast<uint32_t>(frpc::utils::rdtsc());
                    sprintf(get_req.key, "");
                    rpc_clients[client_id]->get(get_req);
                    usleep(1000);
                }
            }

            PopulateRequest popul_req;
            sprintf(popul_req.dataset, dataset_path.c_str());
            rpc_clients[client_id]->populate(popul_req);

            auto cq = rpc_clients[client_id]->get_completion_queue();

            size_t i = 0;
            while(cq->get_number_of_completed_requests() < batch_size && i < t_out*60) {
                ++i;
                usleep(1000);
            }

            if (cq->get_number_of_completed_requests() < batch_size) {
                std::cout << "> populate did not return anything" << std::endl;
            } else {
                if (batch_size == 1) {
                    std::cout << "> populate returned: "
                              << reinterpret_cast<PopulateResponse*>(cq->pop_response().argv)->status << std::endl;
                }
            }

        } else if (words[0] == "benchmark") {
            // do benchmark
            if (benchmark(rpc_clients, words) != 0) {
                std::cout << "benchmark failed" << std::endl;
                continue;
            } else {
                std::cout << "benchmark finished" << std::endl;
            }

        } else {
            std::cout << "unknows command" << std::endl;
            continue;
        }
    }
}
