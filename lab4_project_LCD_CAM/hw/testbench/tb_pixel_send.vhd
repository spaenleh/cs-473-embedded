library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pixel_send is
end tb_pixel_send;

architecture test of tb_pixel_send is

	-- 50 MHZ clock of the FPGA
	constant CLK_PERIOD : time := 20 ns;

	-- Signal used to end simulation when testing is done
	signal sim_finished : boolean := false;

	-- display_ip PORTS
	signal CLK : std_logic;
	signal nRST : std_logic;
	signal ENABLE : std_logic;
	signal BUSY : std_logic;
	signal FIFO_DATA : std_logic_vector(15 downto 0);
	signal FIFO_READ : std_logic;
    signal LCD_D     : std_logic_vector(15 downto 0);
    signal LCD_RS_D_Cx : std_logic;
    signal LCD_WR_N    : std_logic;

begin

	-- Instantiate DUT
	DUT : entity work.pixel_send
	port map(
		clk => CLK,
		nReset => nRST,
		enable => ENABLE,
		busy => BUSY,
		Fifo_data => FIFO_DATA,
		Fido_read => FIFO_READ,
		LCD_D => LCD_D,
		LCD_RS_D_Cx => LCD_RS_D_Cx,
		LCD_WR_N => LCD_WR_N
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
		ENABLE <= '0';
		FIFO_DATA <= (others => '0');
		wait for CLK_PERIOD;
		async_reset;

		wait until rising_edge(CLK);
		-- send enable
		ENABLE <= '1';
		FIFO_DATA <= (others => '0');
		wait for 50*CLK_PERIOD;

		FIFO_DATA <= "0000011111100000";
		wait until falling_edge(BUSY);
		wait until rising_edge(CLK);
		ENABLE <= '0';

		wait for 10*CLK_PERIOD;
		sim_finished <= true;
		wait;
	end process simulation;

end architecture test;
