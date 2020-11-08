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

		-- procedure check_add(constant in1 : in natural;
		-- 					constant in2 : in natural;
		-- 					constant res_expected : in natural) is
		-- 	variable res : natural;
		-- begin
		--
		-- 	wait until rising_edge(CLK);
		--
		-- 	OP1 <= std_logic_vector(to_unsigned(in1, OP1'length));
		-- 	OP2 <= std_logic_vector(to_unsigned(in2, OP2'length));
		-- 	START <= '1';
		--
		-- 	wait until rising_edge(CLK);
		--
		-- 	OP1 <= (others => '0');
		-- 	OP2 <= (others => '0');
		-- 	START <= '0';
		--
		-- 	wait until DONE = '1';
		--
		-- 	-- Check the result
		-- 	res := to_integer(unsigned(SUM));
		-- 	assert res = res_expected
		-- 	report "Unexpected result: " &
		-- 			"OP1 = " & integer'image(in1) & "; " &
		-- 			"OP2 = " & integer'image(in2) & "; " &
		-- 			"SUM = " & integer'image(res) & "; " &
		-- 			"SUM_expected = " & integer'image(res_expected)
		-- 	severity error;
		--
		-- 	wait until DONE = '0';
		-- end procedure check_add;
	begin
		-- default values
		nRST <= '1';
		wait for CLK_PERIOD;
		async_n_reset;

		-- sim_finished <= true;
		wait;
	end process simulation;

end architecture test;
