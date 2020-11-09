library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_div is
	port(
		clk		: in std_logic;
		nReset	: in std_logic;

		-- enable that "slows the clock down"
		enable	: out std_logic
	);
end clk_div;

architecture comp of clk_div is

	-- Clock dividing constant to go from 50MHz to 1MHz -> periode will be 1us
	constant MAX_COUNT : unsigned := to_unsigned(50, 6);

	-- counting registers : up to 50 so 6 bits are needed
	signal counter_reg, counter_next : unsigned(5 downto 0) := (others => '0');

begin

	-- reset and synchronusly manage registers
	REG : process(clk, nReset)
	begin
		if nReset = '0' then
			counter_reg <= (others => '0');
		elsif rising_edge(clk) then
			counter_reg <= counter_next;
		end if;
	end process;

	-- count up or reset when max value is reached
	counter_next <= counter_reg + 1 when counter_reg < MAX_COUNT - 1 else
					(others => '0');

	-- out signal to be fed to a "slower module" as CLK enable
	enable <= '1' when counter_reg = 0 else '0';

end architecture comp;
