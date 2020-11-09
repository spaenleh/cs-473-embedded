library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_clk_div is
end tb_clk_div;

architecture test of tb_clk_div is

	-- 50 MHZ clock of the FPGA
	constant CLK_PERIOD : time := 20 ns;

	-- Signal used to end simulation when testing is done
	signal sim_finished : boolean := false;

	-- adder_cobinational PORTS
	signal CLK : std_logic;
	signal nRST : std_logic;
	signal ENABLE : std_logic;

begin

	-- Instantiate DUT
	DUT : entity work.clk_div
	port map(
		CLK => clk,
		nReset => nRST,
		ENABLE => enable
	);

	-- generate the clock
	clk_gen : process
	begin
		if not sim_finished then
			CLK <= '1';
			wait for CLK_PERIOD / 2;
			CLK <= '0';
			wait for CLK_PERIOD / 2;
		else
			wait;
		end if;
	end process clk_gen;

	-- simulate inputs
	simulation : process
		procedure async_n_reset is
			begin
				wait until rising_edge(CLK);
				wait for CLK_PERIOD / 4;
				nRST <= '0';
				wait for CLK_PERIOD / 2;
				nRST <= '1';
		end procedure async_n_reset;

	begin
		-- default values
		nRST <= '1';
		wait for CLK_PERIOD;
		async_n_reset;

		wait;
	end process simulation;

end architecture test;
