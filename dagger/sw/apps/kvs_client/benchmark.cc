#include "benchmark.h"

#include <algorithm>
#include <cstring>
#include <fstream>
#include <unistd.h>
#include <iostream>

#include "../mica/mica/zipf.h"

#include "utils.h"

double rdtsc_in_ns() {
    uint64_t a = frpc::utils::rdtsc();
    sleep(1);
    uint64_t b = frpc::utils::rdtsc();

    return (b - a)/1000000000.0;
}

bool sortbysec(const uint64_t &a, const uint64_t &b) {
    return a < b;
}

void print_latency(std::vector<uint32_t>& latency_records,
                          size_t thread_id,
                          double cycles_in_ns) {
    std::sort(latency_records.begin(), latency_records.end(), sortbysec);

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

int benchmark(const std::vector<frpc::RpcClient*>& rpc_clients,
                     const std::vector<std::string>& param) {
    if (param.size() != 7) {
        std::cout << "wrong format of the `benchmark` comand" << std::endl;
        return 1;
    }

    double cycles_in_ns = rdtsc_in_ns();
    std::cout << "benchmark > cycles in ns: " << cycles_in_ns << std::endl;

    // Params
    size_t num_of_benchmark_threads = std::stoi(param[1]);
    size_t num_of_requests = std::stoi(param[2]);
    const char* dataset_file_name = param[3].c_str();
    const char* dst_file_name = param[4].c_str();
    size_t set_get_fraction = std::stoi(param[5]);
    size_t set_get_req_delay = std::stoi(param[6]);

    if (num_of_benchmark_threads > rpc_clients.size()) {
        std::cout << "benchmark > trying to run benchmark with more threads"
                                        " than actually provisioned" << std::endl;
        return 1;
    }

    // Load dataset
    std::cout << "benchmark > loading dataset" << std::endl;
    std::vector<std::pair<std::string, std::string>> dataset;
    std::ifstream dataset_file;
    dataset_file.open(dataset_file_name);

    std::string line;
    if (dataset_file.is_open()) {
        // read sizes
        if (!getline(dataset_file, line)) {
            std::cout << "benchmark > first line is not found" << std::endl;
            return 1;
        }
        size_t key_size = std::stoi(line);

        if (!getline(dataset_file, line)) {
            std::cout << "benchmark > second line is not found" << std::endl;
            return 1;
        }
        size_t value_size = std::stoi(line);

        if (!getline(dataset_file, line)) {
            std::cout << "benchmark > third line is not found" << std::endl;
            return 1;
        }
        size_t number_of_samples = std::stoi(line);

        while (getline(dataset_file, line)) {
            size_t d = line.find(':');
            dataset.push_back(std::make_pair(line.substr(0, d),
                                             line.substr(d+1, line.size())));
        }

        assert(dataset.size() == number_of_samples);
        assert(dataset[0].first.size() == key_size);
        assert(dataset[0].second.size() == value_size);

    } else {
        std::cout << "benchmark > failed to open dataset file" << std::endl;
        return 1;
    }

    std::cout << "benchmark > dataset loaded, size= " << dataset.size() << std::endl;
    for(int i=0; i<10; ++i) {
        std::cout << "<" << dataset[i].first << ", " << dataset[i].second << ">" << std::endl;
    }
    std::cout << "..." << std::endl;

    // Load distribution
    std::cout << "benchmark > loading distribution" << std::endl;
    std::vector<uint32_t> set_get_distr;

    struct zipf_gen_state zipf_state;
    mehcached_zipf_init(&zipf_state, 10000000, 0.9999, 123456);

    for(size_t i=0; i<10000000; ++i) {
        set_get_distr.push_back(mehcached_zipf_next(&zipf_state) % 10000000);
    }

    //std::ifstream distr_file;
    //distr_file.open(dst_file_name);
//
    //if (distr_file.is_open()) {
    //    while (getline(distr_file, line)) {
    //        set_get_distr.push_back(std::stoi(line.c_str()));
    //    }
    //} else {
    //    std::cout << "benchmark > failed to open distribution file" << std::endl;
    //    return 1;
    //}

    std::cout << "benchmark > distribution loaded" << std::endl;
    for(int i=0; i<100; ++i) {
        std::cout << set_get_distr[i] << " ";
    }
    std::cout << "..." << std::endl;

    // Run client threads
    std::vector<std::thread> threads;
    for (int thread_id=0; thread_id<num_of_benchmark_threads; ++thread_id) {
        std::thread thr = std::thread(&run_set_get_benchmark,
                                      rpc_clients[thread_id],
                                      std::ref(dataset),
                                      thread_id,
                                      num_of_requests,
                                      cycles_in_ns,
                                      thread_id*num_of_requests,
                                      std::ref(set_get_distr),
                                      set_get_fraction,
                                      set_get_req_delay);

        threads.push_back(std::move(thr));
    }

    for (auto& thr: threads) {
        thr.join();
    }

    return 0;
}

int run_set_get_benchmark(frpc::RpcClient* rpc_client,
                          const std::vector<std::pair<std::string, std::string>>& dataset,
                          int thread_id,
                          size_t num_iterations,
                          double cycles_in_ns,
                          uint64_t starting_key,
                          const std::vector<uint32_t>& set_get_distr,
                          size_t set_get_fraction,
                          size_t set_get_req_delay) {
    // Warm-up benchmark
//    std::cout << "benchmark > doing warm-up" << std::endl;
//    static const size_t warm_up_iterations = 100000;
//    static const size_t warm_up_delay = 1000;
//
//    for(int i=0; i<warm_up_iterations; ++i) {
//        if (i%5 == 0) {
//            SetRequest req;
//            req.timestamp = frpc::utils::rdtsc();
//            sprintf(req.key, dataset[i].first.c_str());
//            sprintf(req.value, dataset[i].second.c_str());
//            rpc_client->set(req);
//        } else {
//            GetRequest req;
//            req.timestamp = frpc::utils::rdtsc();
//            sprintf(req.key, dataset[i].first.c_str());
//            rpc_client->get(req);
//        }
//
//        // Blocking delay to control rps rate
//        for (int delay=0; delay<warm_up_delay; ++delay) {
//            asm("");
//        }
//    }

    auto cq = rpc_client->get_completion_queue();
    cq->clear_queue();
    cq->clear_latency_records();

    std::cout << "benchmark > doing set/get = " << 100/set_get_fraction << "/"
              << 100 - (100/set_get_fraction) << std::endl;

    for(int i=0; i<num_iterations; ++i) {
        if (i%set_get_fraction != 0) {
            GetRequest req;
            req.timestamp = frpc::utils::rdtsc();
           // sprintf(req.key, dataset[set_get_distr[i%50000000]+1000*thread_id].first.c_str());
            size_t data = set_get_distr[i%10000000]+1000000*thread_id;
            memcpy(req.key, &data, 8);
            rpc_client->get(req);
        } else {
            SetRequest req;
            req.timestamp = frpc::utils::rdtsc();
            //sprintf(req.key, dataset[set_get_distr[i%50000000]+1000*thread_id].first.c_str());
            //sprintf(req.value, dataset[set_get_distr[i%50000000]+1000*thread_id].second.c_str());
            size_t data = set_get_distr[i%10000000]+1000000*thread_id;
            memcpy(req.key, &data, 8);
            memcpy(req.value, &data, 8);
            rpc_client->set(req);
        }

        // Blocking delay to control rps rate
        for (int delay=0; delay<set_get_req_delay; ++delay) {
            asm("");
        }
    }

    // Wait a bit
    sleep(5);

    // Get data
    size_t cq_size = cq->get_number_of_completed_requests();
    std::cout << "Thread #" << thread_id
              << ": CQ size= " << cq_size << std::endl;
//    if (cq_size > 100) {
//        for (int i=0; i<100; ++i) {
//            std::cout << *(size_t*)(reinterpret_cast<GetResponse*>(cq->pop_response().argv)->value) << std::endl;
//        }
//    }
//    std::cout << "..." << std::endl;

    // Check for correctness
    size_t errors = 0;
    for(size_t i=0; i<cq_size; ++i) {
        if ((reinterpret_cast<SetResponse*>(cq->pop_response().argv)->status) == 1) {
            ++errors;
        }
    }

    std::cout << "Errors found: " << errors << std::endl;

    // Print Latencies
    auto latency_records = cq->get_latency_records();
    print_latency(latency_records, thread_id, cycles_in_ns);

    return 0;
}
