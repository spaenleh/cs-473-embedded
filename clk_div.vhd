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

	constant MAX_COUNT : std_logic_vector(5 downto 0) := std_logic_vector(50, 6);
	 
