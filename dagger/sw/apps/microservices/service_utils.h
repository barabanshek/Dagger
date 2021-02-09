#include <mutex>
#include <random>

#include "utils.h"

class RndGen {
private:
    std::random_device rand_dev;
    std::mt19937_64 mt;
    std::uniform_int_distribution<uint64_t> dist;
    uint64_t seed;
    char* alphanum = "abcdefghijklmnopqrstuvwxyz";

public:
    RndGen(uint64_t seed): seed(seed) {
    }

    inline uint32_t next_u32() {
        seed = seed * 1103515245 + 12345;
        return static_cast<uint32_t>(seed >> 32);
    }

    inline std::string next_str(size_t len) {
        char* str = reinterpret_cast<char*>(malloc((len+1)*sizeof(char)));
        for (size_t i=0; i<len; ++i) {
            char rnd_char = alphanum[next_u32() % sizeof(alphanum)];
            str[i] = rnd_char;
        }
        str[len] = '\0';

        std::string string(str);
        delete[] str;
        return string;
    }
};

static double rdtsc_in_ns() {
    uint64_t a = frpc::utils::rdtsc();
    sleep(1);
    uint64_t b = frpc::utils::rdtsc();

    return (b - a)/1000000000.0;
}

static uint32_t trace_id = 0;
static std::mutex trace_id_lock;
static double gen_trace_id() {
    trace_id_lock.lock();
    uint32_t t_id = trace_id;
    ++trace_id;
    trace_id_lock.unlock();

    return t_id;
}

static int pin_to_cpu(int cpu_id) {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(cpu_id, &cpuset);
    pthread_t thread;
    thread = pthread_self();
    int rc = pthread_setaffinity_np(thread,
                                    sizeof(cpu_set_t), &cpuset);
    if (rc != 0) {
        std::cout << "Failed to pin to CPU " << cpu_id << std::endl;
        return 1;
    }

    std::cout << "Successfully pinned to CPU " << cpu_id << std::endl;

    return 0;
}
