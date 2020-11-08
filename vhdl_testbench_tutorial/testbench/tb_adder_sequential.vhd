library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_adder_sequential is
end tb_adder_sequential;

architecture test of tb_adder_sequential is

	constant CLK_PERIOD : time := 100 ns;

	-- Signal used to end simulation when testing is done
	signal sim_finished : boolean := false;

	-- generic constants
	constant N_BIT : positive range 2 to positive'right := 4;

	-- adder_cobinational PORTS
	signal CLK : std_logic;
	signal RST : std_logic;
	signal START : std_logic;
	signal OP1 : std_logic_vector(N_BIT - 1 downto 0);
	signal OP2 : std_logic_vector(N_BIT - 1 downto 0);
	signal SUM : std_logic_vector(N_BIT downto 0);
	signal DONE : std_logic;

begin

	-- Instantiate DUT
	dut : entity work.adder_sequential
	generic map(N_BITS => N_BIT)
	port map(
		CLK => CLK,
		RST => RST,
		START => START,
		OP1 => OP1,
		OP2 => OP2,
		SUM => SUM,
		DONE => DONE
	);

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

	simulation : process
		procedure async_reset is
			begin
				wait until rising_edge(CLK);
				wait for CLK_PERIOD / 4;
				RST <= '1';
				wait for CLK_PERIOD / 2;
				RST <= '0';
		end procedure async_reset;

		procedure check_add(constant in1 : in natural;
							constant in2 : in natural;
							constant res_expected : in natural) is
			variable res : natural;
		begin

			wait until rising_edge(CLK);

			OP1 <= std_logic_vector(to_unsigned(in1, OP1'length));
			OP2 <= std_logic_vector(to_unsigned(in2, OP2'length));
			START <= '1';

			wait until rising_edge(CLK);

			OP1 <= (others => '0');
			OP2 <= (others => '0');
			START <= '0';

			wait until DONE = '1';

			-- Check the result
			res := to_integer(unsigned(SUM));
			assert res = res_expected
			report "Unexpected result: " &
					"OP1 = " & integer'image(in1) & "; " &
					"OP2 = " & integer'image(in2) & "; " &
					"SUM = " & integer'image(res) & "; " &
					"SUM_expected = " & integer'image(res_expected)
			severity error;

			wait until DONE = '0';
		end procedure check_add;
	begin
		-- default values
		OP1 <= (others => '0');
		OP2 <= (others => '0');
		RST <= '0';
		START <= '0';
		wait for CLK_PERIOD;
		async_reset;

		check_add(12, 8, 20);
		check_add(10, 6, 16);
		check_add(4, 1, 5);
		check_add(11, 7, 18);
		check_add(10, 13, 23);
		check_add(1, 2, 3);
		check_add(5, 3, 8);
		check_add(8, 0, 8);

		sim_finished <= true;
		wait;
	end process simulation;

end architecture test;
