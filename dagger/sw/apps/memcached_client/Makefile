CC=g++
CFLAGS=-I. -I../../src/ -I../../src/nic_impl -DNIC_CCIP_POLLING -DPROFILE_LATENCY=1
LDFLAGS=-L/homes/nikita/dagger/sw/build -ldagger -lhugetlbfs -levent -pthread

client: client.cc
	$(CC) -o memcached_dagger_client client.cc $(CFLAGS) $(LDFLAGS)

clean: memcached_dagger_client
	rm memcached_dagger_client
