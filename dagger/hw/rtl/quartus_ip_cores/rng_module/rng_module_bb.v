
module rng_module (
	start,
	clock,
	rand_num_data,
	rand_num_ready,
	rand_num_valid,
	resetn);	

	input		start;
	input		clock;
	output	[31:0]	rand_num_data;
	input		rand_num_ready;
	output		rand_num_valid;
	input		resetn;
endmodule
