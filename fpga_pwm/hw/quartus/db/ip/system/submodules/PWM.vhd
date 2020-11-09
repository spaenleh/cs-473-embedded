library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM is
	port(
		clk 	: in std_logic;
		nReset 	: in std_logic;

		-- Internal interface (i.e. Avalon slave).
		address 	: in std_logic_vector(1 downto 0);	-- 3 registers so only 2 bits
		write 		: in std_logic;						-- procesor wants to write
		writedata 	: in std_logic_vector(15 downto 0);	-- data to write sent from the processor

		-- External interface (i.e. conduit).
		PWM_out : out std_logic							-- to wire to a pinto control the motor
	);
end PWM;


architecture comp of PWM is

	-- Register map
	signal iRegPeriod 	: std_logic_vector(15 downto 0) := (others => '0');	-- Periode
	signal iRegDuty 	: std_logic_vector(15 downto 0) := (others => '0');	-- Duty cycle
	signal iRegPolarity : std_logic := '1';									-- T_on

	-- counter
	signal counter_reg, counter_next : unsigned(15 downto 0);

	-- clk_div component to "slow" the clock
	component clk_div is
		port(
			clk		: in std_logic;
			nReset	: in std_logic;
			enable	: out std_logic
		);
	end component clk_div;

	-- internal signal for the clk_div module
	signal enable_clk : std_logic;

begin

	clk_div_inst : component clk_div
	port map(
		clk => clk,
		nReset => nReset,
		enable => enable_clk
	);

	-- OUT logic for the PWM
	PWM_out <= 	iRegPolarity when counter_reg < unsigned(iRegDuty) else
				not iRegPolarity;

	-- incerement the counter
	counter_next <= counter_reg + 1 when counter_reg < unsigned(iRegPeriod) - 1 else
					(others => '0');

	-- Avalon slave write to registers.
	process(clk, nReset)
	begin
		if nReset = '0' then
			iRegPeriod <= (others => '0');
			iRegDuty <= (others => '0');
			iRegPolarity <= '1';		-- T_on
		elsif rising_edge(clk) then
			if write = '1' then
				case address is
					when "00" 	=> iRegPeriod 	<= writedata;
					when "01" 	=> iRegDuty 	<= writedata;
					when "10" 	=> iRegPolarity <= writedata(0);
					when others => null;
				end case;
			elsif enable_clk = '1' then
				counter_reg <= counter_next;
			end if;
		end if;
	end process;

end comp;
