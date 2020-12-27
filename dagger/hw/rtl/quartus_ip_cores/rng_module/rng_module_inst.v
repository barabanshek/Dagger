	rng_module u0 (
		.start          (<connected-to-start>),          //     call.enable
		.clock          (<connected-to-clock>),          //    clock.clk
		.rand_num_data  (<connected-to-rand_num_data>),  // rand_num.data
		.rand_num_ready (<connected-to-rand_num_ready>), //         .ready
		.rand_num_valid (<connected-to-rand_num_valid>), //         .valid
		.resetn         (<connected-to-resetn>)          //    reset.reset_n
	);

