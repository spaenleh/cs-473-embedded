library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_D5M is
end tb_D5M;

architecture tb of tb_D5M is
	signal tb_clk			    : std_logic := '0';
	signal tb_res			    : std_logic := '1';
	signal tb_waitrequest_MA    : std_logic := '0';
	signal tb_write_MA		    : std_logic;
	signal tb_read_MA			: std_logic;
	signal tb_beginburst_MA     : std_logic;
	signal tb_burstcount_MA     : std_logic_vector(7-1 downto 0);
	signal tb_address_MA 	    : std_logic_vector(64-1 downto 0);
	signal tb_writedata_MA 	    : std_logic_vector(32-1 downto 0);
	signal tb_readdata_MA	    : std_logic_vector(32-1 downto 0) := std_logic_vector(to_unsigned(404,32));
	signal tb_readDataVa_MA     : std_logic := '1';
	
	signal address_SL           : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(0,4));
	signal write_SL             : std_logic := '0';
	signal read_SL              : std_logic := '0';
	signal writedata_SL         : std_logic_vector(7 downto 0) := (others => '0');
	signal readdata_SL          : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(55,8));
	
	constant period: time := 1 ns;
begin
	
	DUT : entity work.D5M_top
    generic map(
        AvalonAddressDepth => 64,
        AvalonBustDepth => 7,
        AvalonBustN => 16,
        AvalonDataDepth => 32,
                
        LcdNPixel => 76800,
        PixelCountDepth => 20,
        PixelDepth => 16,
        
        FifoCountDepth => 7
    )
	port map(
		clk => tb_clk,
		nReset => tb_res,
	-- AVALON MASTER INTERFACE
		waitrequest_MA => tb_waitrequest_MA,
		write_MA => tb_write_MA,
		read_MA => tb_read_MA,
		beginburst_MA => tb_beginburst_MA,
		burstcount_MA => tb_burstcount_MA,
		address_MA => tb_address_MA,
		writedata_MA => tb_writedata_MA,
		readdata_MA => tb_readdata_MA,
		readDataVa_MA => tb_readDataVa_MA,
    -- AVALON SLAVE INTERFACE
    	address_SL => address_SL,
		write_SL => write_SL,
		read_SL => read_SL,
		writedata_SL => writedata_SL,
		readdata_SL => readdata_SL
	);


	P_CLK : process 
	begin
		tb_clk <= '0';
		wait for 0.5 ns;
		tb_clk <= '1';
		wait for 0.5 ns;
	end process;

    tb1 : process
        begin
		  
				tb_res <= '0';
            wait for (1.5+0.01)*period;
				tb_res <= '1';
		    wait for 1*period;
		        address_SL <= std_logic_vector(to_unsigned(1,4));
		        writedata_SL <= std_logic_vector(to_unsigned(55,8));
		        write_SL <= '1';
		    wait for 1*period;
		    	address_SL <= std_logic_vector(to_unsigned(2,4));
		        writedata_SL <= std_logic_vector(to_unsigned(55,8));
		    wait for 1*period;
		    	address_SL <= std_logic_vector(to_unsigned(3,4));
		        writedata_SL <= std_logic_vector(to_unsigned(55,8));
		    wait for 1*period;
		    	address_SL <= std_logic_vector(to_unsigned(4,4));
		        writedata_SL <= std_logic_vector(to_unsigned(54,8));
		    wait for 1*period;   
		    	address_SL <= std_logic_vector(to_unsigned(0,4));
		        writedata_SL <= "00001100";
		    wait for 1*period; 
		        write_SL <= '0';
		        
		   	wait for 420*period; 
		        read_SL <= '1';
		    wait for 1*period; 
		        read_SL <= '0';
		      
				
				
            wait; -- indefinitely suspend process
        end process;

end tb;
