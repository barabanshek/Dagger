## Generate dataset
python3 gen_dataset.py /homes/nikita/kvs_dataset_tiny.data 10000000 8 8 _ +
python3 gen_dataset.py /homes/nikita/kvs_dataset_small.data 10000000 16 32 _ +

## Run memcached as server
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/homes/nikita/dagger/sw/build/apps/memcached
./../apps/memcached/memcached/memcached --threads=1 --memory-limit=2048

## Run client
./apps/kvs_client/dagger_kvs_client 1
// 1 is the number of provisioned threads

# Set
set 0 key value

# Get
get 0 key

# Populate
populate 0 /homes/nikita/kvs_dataset_tiny.data
populate 1 /homes/nikita/kvs_dataset_tiny.data
populate 2 /homes/nikita/kvs_dataset_tiny.data
populate 3 /homes/nikita/kvs_dataset_tiny.data
populate 0 /homes/nikita/kvs_dataset_small.data

# Benchmark
benchmark 4 10000000 /homes/nikita/kvs_dataset_tiny.data /homes/nikita/memcached_get.dst 20 6000

benchmark 4 10000000 /homes/nikita/kvs_dataset_tiny.data /homes/nikita/memcached_get.dst 20 6000

benchmark 4 100000000 /homes/nikita/kvs_dataset_tiny.data /homes/nikita/memcached_get.dst 20 1000
benchmark 1 50000000 /homes/nikita/kvs_dataset_small.data /homes/nikita/memcached_get.dst 20 1000
// 1 here is the number of actual threads which should be <= number of provisioned threads
