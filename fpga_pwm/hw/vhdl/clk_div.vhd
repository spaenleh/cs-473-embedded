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

	constant MAX_COUNT : unsigned := to_unsigned(50, 6);

	signal counter_reg, counter_next : unsigned(5 downto 0) := (others => '0');

begin

	REG : process(clk, nReset)
	begin
		if nReset = '0' then
			counter_reg <= (others => '0');
		elsif rising_edge(clk) then
			counter_reg <= counter_next;
		end if;
	end process;

	-- counter_next <= std_logic_vector(unsigned(counter_reg) + 1) when counter_reg <= MAX_COUNT
	counter_next <= counter_reg + 1 when counter_reg < MAX_COUNT - 1 else
					(others => '0');

	enable <= '1' when counter_reg = 0 else '0';

end architecture comp;
