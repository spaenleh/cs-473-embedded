	component system is
		port (
			clk_clk              : in    std_logic                    := 'X';             -- clk
			reset_reset_n        : in    std_logic                    := 'X';             -- reset_n
			parallel_port_export : inout std_logic_vector(7 downto 0) := (others => 'X')  -- export
		);
	end component system;

	u0 : component system
		port map (
			clk_clk              => CONNECTED_TO_clk_clk,              --           clk.clk
			reset_reset_n        => CONNECTED_TO_reset_reset_n,        --         reset.reset_n
			parallel_port_export => CONNECTED_TO_parallel_port_export  -- parallel_port.export
		);

