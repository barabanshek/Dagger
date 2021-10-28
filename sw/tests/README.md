## Test suit for Dagger

### Unit Tests
Standard unit tests to verify different parts of the software stack. These tests do not check the hardware or end-to-end system functionality. These tests can be run on any machine, even without an FPGA.

To run the test suit, execute the following command:
```bash
./tests/dagger_unit_tests
```

The tests should pass no matter what the system configuration looks like!




### System Tests
The tests verify the functionality of the whole Dagger system, i.e. it's kind of integration testing. They require the FPGA to be programmed with the basic Dagger configuration (see bellow) and test both the software and hardware parts at the high level.

To run the test suit, execute the following command:
```bash
# Make sure, the FPGA is programmed with the right image
# The whole test suit
./tests/dagger_unit_tests
# A single test
./tests/dagger_sys_tests --gtest_filter=ThreadedServerTest.*
# A single test case
./tests/dagger_sys_tests --gtest_filter=ThreadedServerTest.ListenSingleThreadTest
```

The behaviour of the system tests depend A LOT on the configuration of the system. For some configurations, it is total OK for the tests to fail. Bellow, some possible software configurations (as defined in src/config.h) when **all** tests should pass:
- *tx_batch_size = 0* (important, some tests will fail if not met);
- *l_rx_batch_size = 0* (important as well);
- *l_rx_queue_size, l_rx_queue_size* should fit in the currently configured in dagger::cfg::sys page size, you should use *enable_hugepages = true* if deeper queues need to be tested;
- *polling_rate < 50* (just a suggestion)
- *llc_anti_aliasing_offset = 4x1024* (suggestion)

In addition, the hardware configuration should also meet certain requirements:
- *min number of flows should be at least 8* (for the multithreading tests to pass)
- *min connection capacity on the nic should be at least 32* (for the connection test to pass)
- tests work stability with the *pooling* and *mmio* based Host-Nic interfaces as of now; no DMA/Doorbell mode was tested in the recent branch

**IMPORTANT:** As the current system implements undeliable transport and certain other structures, it is OK for tests to fail sometimes. An actual indication of errors is when the same tests keep failing across multiple runs. Sometimes, tests can fail due to scheduling issues, more careful core pinning might help. But again, tests should not **keep** failing all the time!
