library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM is
	port(
		clk 	: in std_logic;
		nReset 	: in std_logic;

		-- Internal interface (i.e. Avalon slave).
		address 	: in std_logic_vector(1 downto 0); -- attention si 32 bits data
		write 		: in std_logic;
		--read 		: in std_logic;
		writedata 	: in std_logic_vector(15 downto 0);
		--readdata 	: out std_logic_vector(7 downto 0);

		-- External interface (i.e. conduit).
		PWM_out : out std_logic
	);
end PWM;


architecture comp of PWM is

	-- signal iRegDir 	: std_logic_vector(7 downto 0);
	-- signal iRegPort : std_logic_vector(7 downto 0);
	-- signal iRegPin 	: std_logic_vector(7 downto 0);

	-- parameters of the
	signal iRegPolarity : std_logic;
	signal iRegDuty 	: std_logic_vector(15 downto 0);
	signal iRegPeriod 	: std_logic_vector(15 downto 0);

	signal counter_reg, counter_next : unsigned(15 downto 0);
	signal enable_clk : std_logic;

	component clk_div is
		port(
			clk		: in std_logic;
			nReset	: in std_logic;

			-- enable that "slows the clock down"
			enable	: out std_logic
		);
	end component clk_div;

begin

	clk_div_inst : component clk_div
	port map(
		clk => clk,
		nReset => nReset,
		enable => enable_clk
	);

	PWM_out <= 	iRegPolarity when counter_reg < unsigned(iRegDuty) else
				not iRegPolarity;

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
