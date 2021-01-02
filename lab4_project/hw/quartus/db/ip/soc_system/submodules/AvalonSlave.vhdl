library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AvalonSlave is
	port(
		clk         : in std_logic;
		nReset      : in std_logic;
		-- Internal interface (i.e. Avalon slave).
		address     : in std_logic_vector(3 downto 0);
		write       : in std_logic;
		read        : in std_logic;
		writedata   : in std_logic_vector(7 downto 0);
		readdata    : out std_logic_vector(7 downto 0);
		-- External interface (i.e. conduit).
		bussy       : in std_logic;
		start_frame : out std_logic_vector(2-1 downto 0);
		EnAvMa      : out std_logic;
		EnClkGen    : out std_logic;
		EnCam       : out std_logic;
		trig_frame  : out std_logic_vector(16-1 downto 0);
		replace     : out std_logic_vector(16-1 downto 0);
		AddressSt   : out std_logic_vector(64-1 downto 0)
	);
end AvalonSlave;

architecture comp of AvalonSlave is
	signal reg0  	: std_logic_vector(7 downto 0);
	signal reg1  	: std_logic_vector(7 downto 0);
	signal reg2  	: std_logic_vector(7 downto 0);
	signal reg3  	: std_logic_vector(7 downto 0);
	signal reg4  	: std_logic_vector(7 downto 0);
	signal reg5  	: std_logic_vector(7 downto 0);
	signal reg6  	: std_logic_vector(7 downto 0);
	signal reg7  	: std_logic_vector(7 downto 0);
	signal reg8  	: std_logic_vector(7 downto 0);
    signal reg9  	: std_logic_vector(7 downto 0);
	signal reg10 	: std_logic_vector(7 downto 0);
	signal reg11 	: std_logic_vector(7 downto 0);
	signal reg12 	: std_logic_vector(7 downto 0);
	
	signal reg0_N   : std_logic_vector(7 downto 0);
	
begin

    reg0_N(7 downto 6) <= "00";
    reg0_N(5) <= bussy;
    reg0_N(4 downto 0) <= reg0(4 downto 0);
    
    start_frame <= reg0(4 downto 3);
    EnAvMa <= reg0(2);
    EnClkGen <= reg0(1);
    EnCam <= reg0(0);
    
    trig_frame(7 downto 0) <= reg1;
    trig_frame(15 downto 8) <= reg2;
    replace(7 downto 0) <= reg3;
    replace(15 downto 8) <= reg4;
    
    AddressSt(7 downto 0) <= reg5;
    AddressSt(15 downto 8) <= reg6;
    AddressSt(23 downto 16) <= reg7;
    AddressSt(31 downto 24) <= reg8;
    AddressSt(39 downto 32) <= reg9;
    AddressSt(47 downto 40) <= reg10;
    AddressSt(55 downto 48) <= reg11;
    AddressSt(63 downto 56) <= reg12;            
-- Avalon write to registers
	process(clk, nReset)
	begin
		if nReset = '0' then
			reg0    <= (others => '0');
			reg1    <= (others => '0');
			reg2    <= (others => '0');
			reg3    <= (others => '0');
			reg4    <= (others => '0');
			reg5    <= (others => '0');
			reg6    <= (others => '0');
			reg7    <= (others => '0');
			reg8    <= (others => '0');
			reg9    <= (others => '0');
			reg10   <= (others => '0');
			reg11   <= (others => '0');
			reg12   <= (others => '0');
			
			
		elsif rising_edge(clk) then
			if write = '1' then
				case Address is
					when "0000" => reg0	<= writedata;
					when "0001" => reg1	<= writedata;
					when "0010" => reg2	<= writedata;
					when "0011" => reg3	<= writedata;
					when "0100" => reg4	<= writedata;
					when "0101" => reg5	<= writedata;
					when "0110" => reg6	<= writedata;
					when "0111" => reg7	<= writedata;
					when "1000" => reg8	<= writedata;
					when "1001" => reg9	<= writedata;
					when "1010" => reg10<= writedata;
					when "1011" => reg11<= writedata;
					when "1100" => reg12<= writedata;
					when others => null;
				end case;
			end if;
		end if;
	end process;
-- Avalon read from registers.
	process(clk)
	begin
		if rising_edge(clk) then
			readdata <= (others => '0');
		
			if read = '1' then
				case address is
					when "0000" => readdata <= reg0_N;
					when "0001" => readdata <= reg1;
					when "0010" => readdata <= reg2;
					when "0011" => readdata <= reg3;
					when "0100" => readdata <= reg4;
					when "0101" => readdata <= reg5;
					when "0110" => readdata <= reg6;
					when "0111" => readdata <= reg7;
					when "1000" => readdata <= reg8;
					when "1001" => readdata <= reg9;
					when "1010" => readdata <= reg10;
					when "1011" => readdata <= reg11;
					when "1100" => readdata <= reg12;
					when others => null;
				end case;
			end if;
		end if;
	end process;
 
    
end comp;

