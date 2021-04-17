set_false_path -from [get_registers {*dcfifo*delayed_wrptr_g[*]}] -to [get_registers {*dcfifo*rs_dgwp*}]
set_false_path -from [get_registers {*dcfifo*rdptr_g[*]}] -to [get_registers {*dcfifo*ws_dgrp*}]

set_false_path -from * -to *dcfifo_|auto_generated|wraclr|dffe*a[0]
set_false_path -from * -to *dcfifo_|auto_generated|rdaclr|dffe*a[0]

set_false_path -from * -to [get_registers {*eth_*init_done_r*}]
set_false_path -from * -to [get_registers {*eth_*init_start*}]

set_false_path -from [get_registers {*udp_*drop_cnt*}] -to [get_registers {*udp_*drop_cnt_sync*}]
set_false_path -from [get_registers {*udp_*rx_fifo_drop*}] -to [get_registers {*udp_*rx_fifo_drop_sync*}]
set_false_path -from [get_registers {*udp_*tx_fifo_drop*}] -to [get_registers {*udp_*tx_fifo_drop_sync*}]
set_false_path -from [get_registers {*udp_*dest_mac_error_cnt*}] -to [get_registers {*udp_*dest_mac_error_cnt_sync*}]
set_false_path -from [get_registers {*udp_*dest_ip_error_cnt*}] -to [get_registers {*udp_*dest_ip_error_cnt_sync*}]
set_false_path -from [get_registers {*udp_*protocol_id_err_cnt*}] -to [get_registers {*udp_*protocol_id_err_cnt_sync*}]
set_false_path -from [get_registers {*udp_*ip_version_err_cnt*}] -to [get_registers {*udp_*ip_version_err_cnt_sync*}]

set_false_path -from * -to [get_registers {*udp_*host_phy_addr_sync_rx*}]
set_false_path -from * -to [get_registers {*udp_*host_ipv4_addr_sync_rx*}]
set_false_path -from * -to [get_registers {*udp_*host_phy_addr_sync_tx*}]
set_false_path -from * -to [get_registers {*udp_*host_ipv4_addr_sync_tx*}]
