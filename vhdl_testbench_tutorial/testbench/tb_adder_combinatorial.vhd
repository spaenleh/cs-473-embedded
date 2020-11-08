library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_adder_combinatorial is
end tb_adder_combinatorial;

architecture test of tb_adder_combinatorial is

	-- "Time" constants elapsed between each test vector
	constant TIME_DELTA : time := 100 ns;

	-- generic constants
	constant N_BITS : positive range 2 to positive'right := 4;

	-- adder_cobinational PORTS
	signal OP1 : std_logic_vector(N_BITS - 1 downto 0);
	signal OP2 : std_logic_vector(N_BITS - 1 downto 0);
	signal SUM : std_logic_vector(N_BITS downto 0);
begin

	dut : entity work.adder_combinatorial
	generic map(N_BITS => N_BITS)
	port map(
		OP1 => OP1,
		OP2 => OP2,
		SUM => SUM
	);

	simulation : process

		procedure check_add(constant in1 : in natural;
							constant in2 : in natural;
							constant res_expected : in natural) is
			variable res : natural;
		begin
			OP1 <= std_logic_vector(to_unsigned(in1, OP1'length));
			OP2 <= std_logic_vector(to_unsigned(in2, OP2'length));

			wait for TIME_DELTA;

			-- Check the result
			res := to_integer(unsigned(SUM));
			assert res = res_expected
			report "Unexpected result: " &
					"OP1 = " & integer'image(in1) & "; " &
					"OP2 = " & integer'image(in2) & "; " &
					"SUM = " & integer'image(res) & "; " &
					"SUM_expected = " & integer'image(res_expected)
			severity error;
		end procedure check_add;

	begin

		check_add(12, 8, 20);
		check_add(10, 6, 16);
		check_add(4, 1, 5);
		check_add(11, 7, 18);
		check_add(10, 13, 23);
		check_add(1, 2, 3);
		check_add(5, 3, 8);
		check_add(8, 0, 8);

		wait;
	end process simulation;
end architecture test;
