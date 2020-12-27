	component rng_module is
		port (
			start          : in  std_logic                     := 'X'; -- enable
			clock          : in  std_logic                     := 'X'; -- clk
			rand_num_data  : out std_logic_vector(31 downto 0);        -- data
			rand_num_ready : in  std_logic                     := 'X'; -- ready
			rand_num_valid : out std_logic;                            -- valid
			resetn         : in  std_logic                     := 'X'  -- reset_n
		);
	end component rng_module;

	u0 : component rng_module
		port map (
			start          => CONNECTED_TO_start,          --     call.enable
			clock          => CONNECTED_TO_clock,          --    clock.clk
			rand_num_data  => CONNECTED_TO_rand_num_data,  -- rand_num.data
			rand_num_ready => CONNECTED_TO_rand_num_ready, --         .ready
			rand_num_valid => CONNECTED_TO_rand_num_valid, --         .valid
			resetn         => CONNECTED_TO_resetn          --    reset.reset_n
		);

