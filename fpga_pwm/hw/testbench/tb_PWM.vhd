library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_PWM is
end tb_PWM;

architecture test of tb_PWM is

	-- 50 MHZ clock of the FPGA
	constant CLK_PERIOD : time := 20 ns;

	-- Signal used to end simulation when testing is done
	signal sim_finished : boolean := false;

	-- adder_cobinational PORTS
	signal CLK : std_logic;
	signal nRST : std_logic;
	signal ADRESSE : std_logic_vector(1 downto 0);
	signal WRITE : std_logic;
	signal WRITEDATA : std_logic_vector(15 downto 0);
	signal PWM_OUT : std_logic;

begin

	-- Instantiate DUT
	DUT : entity work.PWM
	port map(
		clk => CLK,
		nReset => nRST,
		address => ADRESSE,
		write => WRITE,
		writedata => WRITEDATA,
		PWM_out => PWM_OUT
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
				nRST <= '0';
				wait for CLK_PERIOD / 2;
				nRST <= '1';
		end procedure async_reset;

	begin
		-- default values
		nRST <= '1';
		wait for CLK_PERIOD;
		async_reset;

		wait until rising_edge(CLK);
		-- set Periode
		ADRESSE <= "00";
		WRITEDATA <= std_logic_vector(to_unsigned(5, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';

		wait until rising_edge(CLK);
		-- set Duty
		ADRESSE <= "01";
		WRITEDATA <= std_logic_vector(to_unsigned(2, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';

		wait until rising_edge(CLK);
		-- set polarity
		ADRESSE <= "10";
		WRITEDATA <= std_logic_vector(to_unsigned(1, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';

		wait for 1000*CLK_PERIOD;
		sim_finished <= true;
		wait;
	end process simulation;

end architecture test;
