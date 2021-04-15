set_false_path -from [get_registers {*dcfifo*delayed_wrptr_g[*]}] -to [get_registers {*dcfifo*rs_dgwp*}]
set_false_path -from [get_registers {*dcfifo*rdptr_g[*]}] -to [get_registers {*dcfifo*ws_dgrp*}]

set_false_path -from * -to *dcfifo_|auto_generated|wraclr|dffe*a[0]
set_false_path -from * -to *dcfifo_|auto_generated|rdaclr|dffe*a[0]

set_false_path -from * -to [get_registers {*eth_*init_done_r*}]
set_false_path -from * -to [get_registers {*eth_*init_start*}]
