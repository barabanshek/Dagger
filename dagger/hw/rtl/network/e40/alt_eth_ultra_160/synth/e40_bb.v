
module e40 (
	clk_ref,
	reset_async,
	rx_serial,
	tx_serial,
	clk_status,
	reset_status,
	status_write,
	status_read,
	status_addr,
	status_writedata,
	status_readdata,
	status_readdata_valid,
	status_waitrequest,
	status_read_timeout,
	clk_txmac,
	tx_lanes_stable,
	rx_pcs_ready,
	clk_rxmac,
	rx_inc_octetsOK,
	rx_inc_octetsOK_valid,
	rx_inc_runt,
	rx_inc_64,
	rx_inc_127,
	rx_inc_255,
	rx_inc_511,
	rx_inc_1023,
	rx_inc_1518,
	rx_inc_max,
	rx_inc_over,
	rx_inc_mcast_data_err,
	rx_inc_mcast_data_ok,
	rx_inc_bcast_data_err,
	rx_inc_bcast_data_ok,
	rx_inc_ucast_data_err,
	rx_inc_ucast_data_ok,
	rx_inc_mcast_ctrl,
	rx_inc_bcast_ctrl,
	rx_inc_ucast_ctrl,
	rx_inc_pause,
	rx_inc_fcs_err,
	rx_inc_fragment,
	rx_inc_jabber,
	rx_inc_sizeok_fcserr,
	rx_inc_pause_ctrl_err,
	rx_inc_mcast_ctrl_err,
	rx_inc_bcast_ctrl_err,
	rx_inc_ucast_ctrl_err,
	tx_inc_octetsOK,
	tx_inc_octetsOK_valid,
	tx_inc_64,
	tx_inc_127,
	tx_inc_255,
	tx_inc_511,
	tx_inc_1023,
	tx_inc_1518,
	tx_inc_max,
	tx_inc_over,
	tx_inc_mcast_data_err,
	tx_inc_mcast_data_ok,
	tx_inc_bcast_data_err,
	tx_inc_bcast_data_ok,
	tx_inc_ucast_data_err,
	tx_inc_ucast_data_ok,
	tx_inc_mcast_ctrl,
	tx_inc_bcast_ctrl,
	tx_inc_ucast_ctrl,
	tx_inc_pause,
	tx_inc_fcs_err,
	tx_inc_fragment,
	tx_inc_jabber,
	tx_inc_sizeok_fcserr,
	reconfig_clk,
	reconfig_reset,
	reconfig_write,
	reconfig_read,
	reconfig_address,
	reconfig_writedata,
	reconfig_readdata,
	reconfig_waitrequest,
	tx_serial_clk,
	tx_pll_locked,
	din_sop,
	din_eop,
	din_idle,
	din_eop_empty,
	din,
	din_req,
	tx_error,
	dout_valid,
	dout_d,
	dout_c,
	dout_sop,
	dout_eop,
	dout_eop_empty,
	dout_idle,
	rx_error,
	rx_status,
	rx_fcs_error,
	rx_fcs_valid);	

	input	[0:0]	clk_ref;
	input	[0:0]	reset_async;
	input	[3:0]	rx_serial;
	output	[3:0]	tx_serial;
	input	[0:0]	clk_status;
	input	[0:0]	reset_status;
	input	[0:0]	status_write;
	input	[0:0]	status_read;
	input	[15:0]	status_addr;
	input	[31:0]	status_writedata;
	output	[31:0]	status_readdata;
	output	[0:0]	status_readdata_valid;
	output	[0:0]	status_waitrequest;
	output	[0:0]	status_read_timeout;
	output	[0:0]	clk_txmac;
	output	[0:0]	tx_lanes_stable;
	output	[0:0]	rx_pcs_ready;
	output	[0:0]	clk_rxmac;
	output	[15:0]	rx_inc_octetsOK;
	output	[0:0]	rx_inc_octetsOK_valid;
	output	[0:0]	rx_inc_runt;
	output	[0:0]	rx_inc_64;
	output	[0:0]	rx_inc_127;
	output	[0:0]	rx_inc_255;
	output	[0:0]	rx_inc_511;
	output	[0:0]	rx_inc_1023;
	output	[0:0]	rx_inc_1518;
	output	[0:0]	rx_inc_max;
	output	[0:0]	rx_inc_over;
	output	[0:0]	rx_inc_mcast_data_err;
	output	[0:0]	rx_inc_mcast_data_ok;
	output	[0:0]	rx_inc_bcast_data_err;
	output	[0:0]	rx_inc_bcast_data_ok;
	output	[0:0]	rx_inc_ucast_data_err;
	output	[0:0]	rx_inc_ucast_data_ok;
	output	[0:0]	rx_inc_mcast_ctrl;
	output	[0:0]	rx_inc_bcast_ctrl;
	output	[0:0]	rx_inc_ucast_ctrl;
	output	[0:0]	rx_inc_pause;
	output	[0:0]	rx_inc_fcs_err;
	output	[0:0]	rx_inc_fragment;
	output	[0:0]	rx_inc_jabber;
	output	[0:0]	rx_inc_sizeok_fcserr;
	output	[0:0]	rx_inc_pause_ctrl_err;
	output	[0:0]	rx_inc_mcast_ctrl_err;
	output	[0:0]	rx_inc_bcast_ctrl_err;
	output	[0:0]	rx_inc_ucast_ctrl_err;
	output	[15:0]	tx_inc_octetsOK;
	output	[0:0]	tx_inc_octetsOK_valid;
	output	[0:0]	tx_inc_64;
	output	[0:0]	tx_inc_127;
	output	[0:0]	tx_inc_255;
	output	[0:0]	tx_inc_511;
	output	[0:0]	tx_inc_1023;
	output	[0:0]	tx_inc_1518;
	output	[0:0]	tx_inc_max;
	output	[0:0]	tx_inc_over;
	output	[0:0]	tx_inc_mcast_data_err;
	output	[0:0]	tx_inc_mcast_data_ok;
	output	[0:0]	tx_inc_bcast_data_err;
	output	[0:0]	tx_inc_bcast_data_ok;
	output	[0:0]	tx_inc_ucast_data_err;
	output	[0:0]	tx_inc_ucast_data_ok;
	output	[0:0]	tx_inc_mcast_ctrl;
	output	[0:0]	tx_inc_bcast_ctrl;
	output	[0:0]	tx_inc_ucast_ctrl;
	output	[0:0]	tx_inc_pause;
	output	[0:0]	tx_inc_fcs_err;
	output	[0:0]	tx_inc_fragment;
	output	[0:0]	tx_inc_jabber;
	output	[0:0]	tx_inc_sizeok_fcserr;
	input	[0:0]	reconfig_clk;
	input	[0:0]	reconfig_reset;
	input	[0:0]	reconfig_write;
	input	[0:0]	reconfig_read;
	input	[11:0]	reconfig_address;
	input	[31:0]	reconfig_writedata;
	output	[31:0]	reconfig_readdata;
	output	[0:0]	reconfig_waitrequest;
	input	[3:0]	tx_serial_clk;
	input	[0:0]	tx_pll_locked;
	input	[1:0]	din_sop;
	input	[1:0]	din_eop;
	input	[1:0]	din_idle;
	input	[5:0]	din_eop_empty;
	input	[127:0]	din;
	output		din_req;
	input	[1:0]	tx_error;
	output		dout_valid;
	output	[127:0]	dout_d;
	output	[15:0]	dout_c;
	output	[1:0]	dout_sop;
	output	[1:0]	dout_eop;
	output	[5:0]	dout_eop_empty;
	output	[1:0]	dout_idle;
	output	[5:0]	rx_error;
	output	[2:0]	rx_status;
	output		rx_fcs_error;
	output		rx_fcs_valid;
endmodule
