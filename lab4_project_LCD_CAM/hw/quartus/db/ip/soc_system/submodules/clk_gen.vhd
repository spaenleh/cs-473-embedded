library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_gen is
	port(
		clk		: in std_logic;
		nReset	: in std_logic;

		en_clkGen : in std_logic;     -- clock enable signal received by the Avalon slave
		
		mclk      : out std_logic;     -- clock signal for the camera module
		cam_reset : out std_logic
	);
end clk_gen;

architecture rtl of clk_gen is

	constant DIVIDER : unsigned := to_unsigned(2, 2);
	signal counter_reg, counter_next : unsigned(1 downto 0) := (others => '0');
	signal mclk_next : std_logic := '0';
	
    type fsm_states is (IDLE, RESET, CLK_PROVIDED);  
    signal state_reg, state_next : fsm_states; 

begin

	REG : process(clk, nReset)
	begin
		if nReset = '0' then
			counter_reg <= (others => '0');
			state_reg   <= IDLE;
			mclk        <= '0';
		elsif rising_edge(clk) then
			counter_reg <= counter_next;
			state_reg   <= state_next;
			mclk        <= mclk_next;
		end if;
	end process;
	
	FSM : process(state_reg, en_clkGen)
	begin
	    state_next <= state_reg;
	    case state_reg is
         when IDLE => 
            if en_clkGen = '1' then 
                state_next <= RESET;
            else 
                state_next <= IDLE;
            end if;
         when RESET => state_next <= CLK_PROVIDED;
         when CLK_PROVIDED =>
            if en_clkGen = '1' then 
                state_next <= CLK_PROVIDED;
            else 
                state_next <= IDLE;
            end if;
         --when others => state_next <= IDLE;
     end case;
		
	end process;

	counter_next <= counter_reg + 1 when state_reg = CLK_PROVIDED and counter_reg < DIVIDER - 1 else
					(others => '0');

	mclk_next    <= '1' when state_reg = CLK_PROVIDED and counter_reg = 0 else
			        '0';
	
	cam_reset    <= '0' when state_reg = IDLE else
	                '1';
			     
end architecture rtl;
