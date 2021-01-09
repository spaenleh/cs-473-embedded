library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_display_ip is
end tb_display_ip;

architecture test of tb_display_ip is

	-- 50 MHZ clock of the FPGA
	constant CLK_PERIOD : time := 20 ns;

	-- Signal used to end simulation when testing is done
	signal sim_finished : boolean := false;

	-- display_ip PORTS
	signal CLK : std_logic;
	signal nRST : std_logic;
	signal ADRESSE : std_logic_vector(1 downto 0);
	signal WRITE : std_logic;
	signal WRITEDATA : std_logic_vector(15 downto 0);
	signal READ : std_logic;
	signal READDATA : std_logic_vector(15 downto 0);
	signal LT24_CS_N : std_logic;
    signal LT24_D            : std_logic_vector(15 downto 0);
    signal LT24_LCD_ON       : std_logic;
    signal LT24_RD_N         : std_logic;
    signal LT24_RESET_N      : std_logic;
    signal LT24_RS_D_Cx      : std_logic;
    signal LT24_WR_N         : std_logic;

begin

	-- Instantiate DUT
	DUT : entity work.display_ip
	port map(
		clk => CLK,
		nReset => nRST,
		address_S => ADRESSE,
		write_S => WRITE,
		writedata_S => WRITEDATA,
		read_S => READ,
		readdata_S => READDATA,
		LT24_CS_N => LT24_CS_N,
		LT24_D => LT24_D,
		LT24_LCD_ON => LT24_LCD_ON,
		LT24_RD_N => LT24_RD_N,
		LT24_RESET_N => LT24_RESET_N,
		LT24_RS_D_Cx => LT24_RS_D_Cx,
		LT24_WR_N => LT24_WR_N
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
		READ <= '0';
		WRITE <= '0';
		wait for CLK_PERIOD;
		async_reset;

		wait until rising_edge(CLK);
		-- send dommand
		ADRESSE <= "00";
		WRITEDATA <= std_logic_vector(to_unsigned(5, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';
		wait for 3*CLK_PERIOD;

		wait until rising_edge(CLK);

		-- sent Data
		ADRESSE <= "01";
		WRITEDATA <= std_logic_vector(to_unsigned(16, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';
		wait for 3*CLK_PERIOD;

		wait until rising_edge(CLK);

		-- set Params
		ADRESSE <= "10";
		WRITEDATA <= std_logic_vector(to_unsigned(255, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';
		wait for 4*CLK_PERIOD;

		wait until rising_edge(CLK);

		-- set Params
		ADRESSE <= "01";
		WRITEDATA <= std_logic_vector(to_unsigned(255, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';
		wait for 6*CLK_PERIOD;

		wait until rising_edge(CLK);

		ADRESSE <= "10";
		WRITEDATA <= std_logic_vector(to_unsigned(127, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';
		wait for 2*CLK_PERIOD;

		wait until rising_edge(CLK);

		ADRESSE <= "00";
		WRITEDATA <= std_logic_vector(to_unsigned(250, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';
		wait for 3*CLK_PERIOD;

		wait until rising_edge(CLK);

		ADRESSE <= "01";
		WRITEDATA <= std_logic_vector(to_unsigned(52, 16));
		WRITE <= '1';
		wait until rising_edge(CLK);
		WRITE <= '0';
		wait for 3*CLK_PERIOD;

		wait until rising_edge(CLK);

		wait for 10*CLK_PERIOD;
		sim_finished <= true;
		wait;
	end process simulation;

end architecture test;
