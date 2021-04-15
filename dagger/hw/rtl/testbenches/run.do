#
# Compile Design
#
# sources
vlog -reportprogress 300 -work work ../nic_defs.vh
vlog -reportprogress 300 -work work ../general_defs.vh
vlog -reportprogress 300 -work work ../async_fifo_channel.sv
vlog -reportprogress 300 -work work ../udp_ip.sv

# testbenches
vlog -reportprogress 300 -work work udp_ip_tb.sv

##
## Load Design
##
vsim work.udp_ip_tb -L altera_mf_ver -L altera_mf

##
## Run simulation
##
run -all
