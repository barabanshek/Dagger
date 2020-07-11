# PoC RPC framework on FPGA-based tightly coupled NICs

### Introduction
This is a simple PoC HW-accelerated RPC framework primarly designed for efficient transfer of millions of small (few cache lines) RPC requests. The following key design principles underlie in the concept:
 1. harwdare offlaod of networking and RPC layers onto an FPGA-based NIC;
 2. direct zero-copy and CPU-free communication between HW flows on the NIC and applications;
 3. exchange of ready-to-use RPC messages and objects between application threads and the NIC;
 4. leveraging **customized** and **flexible** CPU-NIC communication protocols based on coherent Intel UPI interconnect to reinforce 1 - 3:
    * CPU -> NIC
        * commodity: MMIO + DMA over PCIe
        * low-latency, for small requests: pure MMIO
        * low-latency, CPU-free, NIC-driven polling: memory polling over PCIe or Intel UPI
        * low-latency, CPU-free, NIC-driven "interrupts": invalidation-based prefetch over Intel UPI
    * NIC -> CPU
        *  commodity: PCIe write with Intel DDIO
        *  WritePushInvalid over Intel UPI

### Example client
```C++
int main() {
    frpc::RpcClientPool rpc_client_pool(NIC_ADDR, NUMBER_OF_THREADS);
    rpc_client_pool.init_nic();
    rpc_client_pool.start_nic();
    
    frpc::RpcClient* rpc_client = rpc_client_pool.pop();
    assert(rpc_client != nullptr);
    
    // Call remote procedure
    uint32_t rpc_ret = rpc_client->boo(12);

    ...
}
```

### Example server
```C++
// Remote procedure foo
static uint32_t foo(uint32_t a, uint32_t b) {
    std::cout << "foo is called with a= " << a << ", b= " << b << std::endl;
    return a + b;
}
// Remote procedure boo
static uint32_t boo(uint32_t a) {
    std::cout << "boo is called with a= " << a << std::endl;
    return a + 10;
}

int main() {
    frpc::RpcThreadedServer rpc_server(NIC_ADDR, NUMBER_OF_THREADS);
    rpc_server.init_nic();
    rpc_server.start_nic();

    // Register RPC functions
    std::vector<const void*> fn_ptrs;
    fn_ptrs.push_back(reinterpret_cast<const void*>(&foo));
    fn_ptrs.push_back(reinterpret_cast<const void*>(&boo));
    
    // Listen
    // This blocks the main thread and creates separate processing
    // threads for every rpc_client
    rpc_server.run_new_listening_thread(fn_ptr);

    ...
}
```

### How to build and run this design
#### Building hardware
```bash
cd
source /export/fpga/bin/setup-fpga-env fpga-bdx-opae
cd harp_rpc/hw
afu_synth_setup -s rtl/sources.txt build_fpga
cd build_fpga
qsub-synth
# Monitor the build
tail -f build.log
```

#### Running on real harwdare: configuring FPGA and building software on target platform
Before configuring, make sure the built design does not have timing violations.
```bash
cd
source /export/fpga/bin/setup-fpga-env fpga-bdx-opae
# Enable GCC-9
source  /opt/rh/devtoolset-9/enable
# Enter target platform
qsub-fpga
# Configure FPGA
fpgaconf harp_rpc/hw/build_fpga/ccip_std_afu.gbs
# Build software
cd harp_rpc/sw
mkdir build; cd build
cmake ..
make
# Run tests
./rpc_tests
# Run examples
tmux
# Split session
^b%
# Run client and server
./rpc_server
./rpc_client
```

#### Running in simulation
TODO: ...
