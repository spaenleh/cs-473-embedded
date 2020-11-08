	component system is
		port (
			clk_clk         : in  std_logic := 'X'; -- clk
			pwm_out_conduit : out std_logic;        -- conduit
			reset_reset_n   : in  std_logic := 'X'  -- reset_n
		);
	end component system;

	u0 : component system
		port map (
			clk_clk         => CONNECTED_TO_clk_clk,         --     clk.clk
			pwm_out_conduit => CONNECTED_TO_pwm_out_conduit, -- pwm_out.conduit
			reset_reset_n   => CONNECTED_TO_reset_reset_n    --   reset.reset_n
		);

