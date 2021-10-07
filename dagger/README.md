# PoC RPC Framework with FPGA-Based NUMA-Attached NICs




### Introduction
This is a simple PoC HW-accelerated RPC framework primarily designed for efficient transfer of millions of small (few cache lines) RPC requests. The following key design principles underlie in the concept:
 1. abstraction: application-level RPC calls with Google Protobuf-like schema definition (limited support for the PoC)
 2. hardware offload of networking and RPC layers onto an FPGA-based NIC;
 3. direct zero-copy and CPU-free communication between HW flows on the NIC and applications;
 4. exchange of ready-to-use RPC messages and objects between application threads and the NIC;
 5. leveraging new **customized** and **flexible** CPU-NIC communication protocols based on coherent Intel UPI NUMA interconnect to reinforce 2 - 4:
    * supported CPU -> NIC mechanisms
        * commodity: strongly-ordered MMIO + DMA over PCIe
        * low-latency, for small requests: strongly-ordered pure MMIO writes to the device
        * low-latency, CPU-free, NIC-driven polling: weakly-ordered memory polling over PCIe or UPI
        * low-latency, CPU-free, NIC-driven "interrupts": weakly-ordered invalidation-based pre-fetch over UPI
        * combined throughput-adoptive invalidation based pre-fetch + pooling over UPI
    * NIC -> CPU mechanisms
        *  commodity: strongly-ordered PCIe writes with DDIO
        *  weakly-ordered push-writes over UPI, refer: https://www.intel.com/content/www/us/en/programmable/documentation/buf1506187769663.html
 6. supported modes if operation:
    * L1 loopback (NIC terminated) - to test end-to-end system excluding networking on a single machine
    * physical networking (requires multiple machines)
 7. supported platforms:
    * Intel Broadwell CPU/FPGA Hybrid (loopback only), refer: https://wiki.intel-research.net/FPGA.html#fpga-system-classes
    * Intel Skylake CPU/FPGA Hybrid
    * Intel PAC A10 multi-FPGA system (PCIe only), refer: https://wiki.intel-research.net/FPGA.html#multi-fpga-config-label




### High-Level Overview

![Top-Level Architecture](https://github.com/cornell-zhang/accelerated-cloud/blob/master/Resources/TopLevel.png)

Dagger stack consists of software and hardware parts. The main design principle is to reduce the amount of CPU work required to transfer RPC objects, so the software is only responsible for writing/reding the objects in/from the specified memory locations where the hardware is then accessing them. The latter runs on an FPGA, inside the green region of the Intel HARP shell (https://wiki.intel-research.net/FPGA.html). The HW communicates with the SW over the shared memory abstraction provided by HARP and implemented via their CCI-P protocol stack (https://www.intel.com/content/www/us/en/programmable/documentation/buf1506187769663.html) which encapsulates both PCIe and UPI. The HW runs all the layers necessary for over-the-network transfer such as L1 - L3 networking, connection management, etc., as well as the auxiliary RPC-specific layers like request load balancer.

For more information and technical details, please, read our ASPLOS'21 paper (https://www.csl.cornell.edu/~delimitrou/papers/2021.asplos.dagger.pdf), and also check out the recent slide deck on Dagger: https://github.com/cornell-zhang/accelerated-cloud/blob/master/Resources/Dagger_Slides.pdf.




### Recent Performance Results
TODO




### Showcase: in-Memory KVS Store

At the application level, Dagger provides the standard RPC API as defined by the IDL shown bellow. The IDL is used to compile RPC client and server stubs for communication with the hardware. The stubs is nothing but the memory layout of RPC objects with a small amount of metadata. The showcase below is based on the KVS example in https://github.com/cornell-zhang/accelerated-cloud/tree/master/dagger/sw/apps/kvs_client, please, refer to the source code for the completed system.

#### Example of Interface Definition
```C++
message SetRequest {
    int32 timestamp;
    char[16] key;
    char[32] value;
}

message SetResponse {
    int32 timestamp;
    int8 status;
}

message GetRequest {
    int32 timestamp;
    char[16] key;
}

message GetResponse {
    int32 timestamp;
    int8 status;
    char[32] value;
}
```

#### Example client
```C++
int main() {
    frpc::RpcClientPool rpc_client_pool(NIC_ADDR, NUMBER_OF_THREADS);
    rpc_client_pool.init_nic();
    rpc_client_pool.start_nic();

    frpc::RpcClient* rpc_client = rpc_client_pool.pop();
    assert(rpc_client != nullptr);

    // Call remote procedure
    rpc_client->set(set_req);

    ...
}
```

#### Example server
```C++
// Remote procedure set
static RpcRetCode set(CallHandler handler, SetRequest args, SetResponse* ret);

// Remote procedure get
static RpcRetCode get(CallHandler handler, GetRequest args, GetResponse* ret);

int main() {
    frpc::RpcThreadedServer rpc_server(NIC_ADDR, NUMBER_OF_THREADS);
    rpc_server.init_nic();
    rpc_server.start_nic();

    // Register RPC functions
    std::vector<const void*> fn_ptrs;
    fn_ptrs.push_back(reinterpret_cast<const void*>(&set));
    fn_ptrs.push_back(reinterpret_cast<const void*>(&get));

    // Listen
    // This blocks the main thread and creates separate processing
    // threads for every rpc_client
    rpc_server.run_new_listening_thread(fn_ptr);

    ...
}
```




### How to Build and Run This Design

We strongly encourage to run the design in the Intel vLab Academic Compute Environment: https://wiki.intel-research.net/Introduction.html. All the further instruction are based on this assumption, although the system should work in any HARP-enabled settings.

#### Repository Structure
* dagger/sw
    * src: source code of the software part
        * network_ctl: functions to control Intel HSSI MAC/PHY networking functions
        * nic_impl: drivers for different types of supported Host-NIC interfaces
        * utils: aux utils
    * microbenchmarks: benchmarks of latency and throughput on idle requests
    * codegen: python-based RPC stub generator
    * ase_sample: Intel ASE-based simulation application
    * apps: ported application
        * kvs_client: KVS client for all types of KVS servers we implemented
        * memcached KVS server: https://github.com/memcached/memcached
        * MICA KVS server: https://github.com/efficient/mica
        * microservices: synthetic microservices to showcase multitenancy
    * tests: gTest-based unit and integration tests
* dagger/hw
    * rtl: SystemVerilog source code of the hardware part
        * build_configs: configurations of the hardware build for different platforms and Host-NIC interfaces
        * network: Intel HSSI MAC/PHY infrastructure
        * testbenches: unit tests for some of the components


#### Building Hardware
```bash
cd
source /export/fpga/bin/setup-fpga-env <TARGET_PLATFORM>
cd dagger/hw
afu_synth_setup -s rtl/build_configs/<CONFIGURATION>.txt build_<NAME>
cd build_<NAME>
qsub-synth
# Monitor the build
tail -f build.log
```

Target platforms available in vLab and supported configuration:
* <TARGET_PLATFORM> = fpga-bdx-opae (Intel Broadwell CPU/FPGA hybrid), supported configurations:
    * loopback_mmio_bdx.txt: MMIO-based Host-NIC interface, loopback mode
    * loopback_upi_bdx.txt: UPI-based Host-NIC interface, loopback mode
* <TARGET_PLATFORM> = fpga-pac-a10 (Intel PAC A10 multi-FPGA system), supported configuration:
    * loopback_mmio_pac_a10.txt: MMIO-based Host-NIC interface, loopback mode
    * network_mmio_pac_a10.txt: MMIO-based Host-NIC interface, physical networking mode

Note: more supported platform/configuration combinations are on the way!
Note: Intel Skylake CPU/FPGA Hybrid machines are not in the vLab, please, use your own local cluster for experiments.

For more information on building on HARP, please, refer to the original documentation: https://wiki.intel-research.net/FPGA.html#.


#### Running in Simulation
The ASE simulation environment is a little limited, so only the loopback mode (no physical networking) can be tested.

```bash
cd
source /export/fpga/bin/setup-fpga-env <TARGET_PLATFORM>
cd dagger/hw
afu_sim_setup -s rtl/build_configs/<CONFIGURATION>.txt build_sim_<NAME>
# Enter simulation environment
qsub-sim
# Split session
rmux
^b%
# Build and run simulated hardware in ASE
cd dagger/hw/build_sim_<NAME>
make
make sim
## Remember what export in $ASE_WORKDIR env variable (make sim will print it)
# Switch to the other tmux panel
# Build software
cd dagger/sw
mkdir build; cd build
cmake ..
make -j
# Run software in simulation mode
## export ASE_WORKDIR=<WHATEVER MAKE SIM REPORTED TO EXPORT>
./ase_samples/dagger_ase_sample
```

Check for error logs during the simulation phase and after.
Please, feel free to experiment with any arbitrary numbers of threads and request by modifying the corresponding variables in the dagger/sw/ase_samples/joint_ase_process.cc.


#### Running on Real Hardware: Configuring FPGA and Building Software on the Target Platform
Before configuring, make sure the built design does not have timing violations!!! Do `tail -f build.log` and ensure the whole design meets timings.

```bash
cd
source /export/fpga/bin/setup-fpga-env <TARGET_PLATFORM>
# Enable GCC-9
source  /opt/rh/devtoolset-9/enable
# Enter target platform
qsub-fpga
# Configure FPGA
fpgaconf dagger/hw/build_<NAME>/ccip_std_afu.gbs
# Build software
cd dagger/sw
mkdir build; cd build
cmake ..
make -j

# Run tests
./tests/dagger_unit_tests
./tests/dagger_sys_tests

# Run performance microbenchmark
# Split session
rmux
^b%
# Run server
# ./microbenchmarks/benchmark_latency_throughput/dagger_benchmark_server --threads=<NUM_OF_THREADS> --load-balancer=<LOAD_BALANCER_ID>
./microbenchmarks/benchmark_latency_throughput/dagger_benchmark_server --threads=1 --load-balancer=0
# Switch to the other tmux panel
# Run client
# ./microbenchmarks/benchmark_latency_throughput/dagger_benchmark_client --threads=<NUM_OF_THREADS> --requests=<NUM_OF_REQUESTS> --delay=<DELAY_BETWEEN_REQUESTS> --function=<RPC_F_TO_CALL>
./microbenchmarks/benchmark_latency_throughput/dagger_benchmark_client --threads=1 --requests=1000000000 --delay=20 --function=loopback
```

For more information on the available benchmark runtime arguments, please, check out the README in the benchmark folder.
To run applications, please, check out the corresponding application folders as the procedure might vary from application to application.




### Papers and Talks
* Papers:
    * https://ieeexplore.ieee.org/document/9180035
    * https://www.csl.cornell.edu/~delimitrou/papers/2021.asplos.dagger.pdf
* Talks:
    * https://www.youtube.com/watch?v=ONnR6Mg6t4E
* https://github.com/cornell-zhang/accelerated-cloud/blob/master/Resources/Dagger_Slides.pdf




### Citation
If you are using/evaluating this design in your research work, please, cite one of our papers listed above. Thanks!
