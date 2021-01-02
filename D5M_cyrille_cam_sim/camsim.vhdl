library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camsim is
    generic(
        NPixel                  : integer := 16;
        PixelCountDepth         : integer := 5
    );
	port(
		clk         : in std_logic;
		nReset      : in std_logic;
		
		clk_out     : out std_logic;
		data        : out std_logic_vector(16-1 downto 0);
		wrrequ      : out std_logic;
		trig        : in std_logic_vector(16-1 downto 0);
		full        : in std_logic
	);
end camsim;

architecture comp of camsim is
    constant color_RED      : std_logic_vector(16-1 downto 0) := "1111100000000000";
    constant color_GREEN    : std_logic_vector(16-1 downto 0) := "0000011111100000";
    constant color_BLUE     : std_logic_vector(16-1 downto 0) := "0000000000011111";
    constant color_WITE     : std_logic_vector(16-1 downto 0) := "1111111111111111";
    
    signal compt    : unsigned(PixelCountDepth-1 downto 0) := (others => '0');
    signal compt_N  : unsigned(PixelCountDepth-1 downto 0);
    
    signal tmp      : unsigned(3-1 downto 0) := (others => '0');
    signal tmp_N    : unsigned(3-1 downto 0);
    
    signal N        : std_logic;
    
    signal data_N   : std_logic_vector(16-1 downto 0);
    signal data_O   : std_logic_vector(16-1 downto 0);
    
    signal clk_i    : std_logic;
    
begin
	compt_N <=  compt+1         when full = '0' and compt<=to_unsigned(NPixel,compt'length) and N = '1' else
	            (others => '0') when full = '0' and N = '1' else
	            compt;
	            
	tmp_N <= tmp+1;
	
	clk_i <= std_logic(tmp(1));
	
	N <=    '1' when tmp(1) = '0' and tmp_N(1) = '1' else
	        '0';
	
	data_N <=   trig        when compt_N > NPixel else
	            color_RED   when compt_N < to_unsigned(NPixel/4,compt_N'length) else
	            color_GREEN when compt_N < to_unsigned(NPixel/4*2,compt_N'length) else
	            color_BLUE  when compt_N < to_unsigned(NPixel/4*3,compt_N'length) else
	            color_WITE  when compt_N < to_unsigned(NPixel,compt_N'length) else
	            data_O;
	
	process(clk)
	begin
		if nReset = '0' then
		    tmp <= (others => '0');
		    compt <= to_unsigned(NPixel-20,compt'length);
		    data_O <= (others => '0');
		elsif rising_edge(clk) then
		    tmp <= tmp_N;
		    compt <= compt_N;
		    data_O <= data_N;
		end if;
	end process;
	
	data <= data_O;
	clk_out <= clk_i;
	wrrequ <=   '1'     when full = '0' else
	            '0';
	
    
end comp;

