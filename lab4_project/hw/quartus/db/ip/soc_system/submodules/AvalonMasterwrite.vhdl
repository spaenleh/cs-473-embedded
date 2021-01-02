library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AvalonMasterWrite is
    generic(
    AvalonAddressDepth      : integer := 64;
    AvalonBustDepth         : integer := 4;
    AvalonBustN             : integer := 8;
    AvalonDataDepth         : integer := 32;
            
    LcdNPixel               : integer := 16;
    PixelDepth              : integer := 16;
    PixelCountDepth         : integer := 5;
    
    FifoCountDepth          : integer := 6
    );
	port(
		clk         : in std_logic; --
		nReset      : in std_logic; --
	-- AVALON MASTER INTERACE
		waitrequest : in std_logic; --
		write       : out std_logic; -- 
		read        : out std_logic; --
		beginburst  : out std_logic; --
		burstcount  : out std_logic_vector(AvalonBustDepth-1 downto 0); --
		address     : out std_logic_vector(AvalonAddressDepth-1 downto 0); --
		writedata   : out std_logic_vector(AvalonDataDepth-1 downto 0); --
		readdata    : in std_logic_vector(AvalonDataDepth-1 downto 0);
		readDataVa  : in std_logic;
    -- FIFO
        readRequ    : out std_logic; --
        empty       : in std_logic; --
        fifData     : in std_logic_vector(PixelDepth-1 downto 0); --
        countD      : in std_logic_vector(FifoCountDepth-1 downto 0); --
    -- Slave IN
        trigFram    : in std_logic_vector(PixelDepth-1 downto 0); --
        start       : in std_logic_vector(2-1 downto 0); --
        StAddress   : in std_logic_vector(AvalonAddressDepth-1 downto 0); --
        bussy       : out std_logic;
        En          : in std_logic
	);
end AvalonMasterWrite;

architecture comp of AvalonMasterWrite is

constant StateDepth     : integer := 4;
constant ST_NOTHING     : unsigned(StateDepth-1 downto 0)       := to_unsigned(0,StateDepth);
constant ST_END_F1      : unsigned(StateDepth-1 downto 0)       := to_unsigned(1,StateDepth);
constant ST_END_F2      : unsigned(StateDepth-1 downto 0)       := to_unsigned(2,StateDepth);
constant ST_W_NOT_EM    : unsigned(StateDepth-1 downto 0)       := to_unsigned(3,StateDepth);
constant ST_FIND_TRIG   : unsigned(StateDepth-1 downto 0)       := to_unsigned(4,StateDepth);
constant ST_W_NOT_AEM   : unsigned(StateDepth-1 downto 0)       := to_unsigned(5,StateDepth);
constant ST_STARTBURST  : unsigned(StateDepth-1 downto 0)       := to_unsigned(6,StateDepth);
constant ST_W_END_WR    : unsigned(stateDepth-1 downto 0)       := to_unsigned(7,StateDepth);
constant ST_SEND_N      : unsigned(stateDepth-1 downto 0)       := to_unsigned(8,stateDepth);

signal countB       : unsigned(AvalonBustDepth-1 downto 0) := (others => '0');
signal countB_N     : unsigned(AvalonBustDepth-1 downto 0);
signal countP       : unsigned(PixelCountDepth-1 downto 0) := (others => '0');
signal countP_N     : unsigned(PixelCountDepth-1 downto 0);
signal state        : unsigned(StateDepth-1 downto 0) := ST_NOTHING;
signal state_N      : unsigned(StateDepth-1 downto 0);

signal endBurst         : std_logic;
signal endFrame         : std_logic;
signal almostEmpty      : std_logic;
signal fifo_tmp         : std_logic_vector(PixelDepth-1 downto 0) := (others => '0');
signal fifo_tmp_N       : std_logic_vector(PixelDepth-1 downto 0);

signal write_N          : std_logic;
signal beginburst_N     : std_logic;
signal writedata_O      : std_logic_vector(AvalonDataDepth-1 downto 0) := (others => '0');
signal writedata_N      : std_logic_vector(AvalonDataDepth-1 downto 0);
signal readRequ_I       : std_logic;
signal bussy_N          : std_logic;
signal bussy_I          : std_logic := '0';

signal address_N        : unsigned(AvalonAddressDepth-1 downto 0);
signal address_O        : unsigned(AvalonAddressDepth-1 downto 0) := (others => '0');
signal address_I        : unsigned(AvalonAddressDepth-1 downto 0) := (others => '0');
signal address_IN       : unsigned(AvalonAddressDepth-1 downto 0);


begin


    endBurst <= '1' when countB >= to_unsigned(AvalonBustN,countB'length) else
                '0';
    
    endFrame <= '1' when countP >= to_unsigned(LcdNPixel,countP'length) else
                '0';
                
    almostEmpty <=  '1' when countD >= std_logic_vector(to_unsigned(AvalonBustN,countD'length)) else
                    '0';

    state_N <=  ST_W_NOT_EM     when    (state = ST_NOTHING and (start(0) xor start(1)) = '1') 
                                        or (state = ST_END_F1 and start = "10") 
                                        or (state = ST_END_F2 and start = "01") 
                                        or (state = ST_FIND_TRIG and fifo_tmp  /= trigFram  and empty = '1') else
                ST_FIND_TRIG    when    (state = ST_W_NOT_EM and empty = '0' and fifo_tmp  /= trigFram) else
                ST_W_NOT_AEM    when    (state = ST_FIND_TRIG and fifo_tmp  = trigFram)
                                        or (state = ST_W_NOT_EM and fifo_tmp = trigFram)
                                        or (state = ST_SEND_N and endBurst = '1' and endFrame = '0') else
                ST_STARTBURST   when    (state = ST_W_NOT_AEM and almostEmpty = '1') else
                ST_SEND_N       when    (state = ST_STARTBURST or state = ST_W_END_WR) and waitrequest = '0' else
                ST_W_END_WR     when    (state = ST_STARTBURST or (state = ST_SEND_N and endBurst = '0')) and waitrequest = '1' else
                ST_NOTHING      when    (state = ST_SEND_N and endBurst = '1' and endFrame = '1' and (start(0) xor start(1)) = '0') else
                ST_END_F1       when    (state = ST_SEND_N and endBurst = '1' and endFrame = '1' and start = "01") else
                ST_END_F2       when    (state = ST_SEND_N and endBurst = '1' and endFrame = '1' and start = "10") else
                state;
    
    
    readRequ_I <=   '1'     when  ((state_N = ST_NOTHING or state_N = ST_END_F1 or state_N = ST_END_F2) and empty = '0')
                            or (state_N = ST_FIND_TRIG or state_N = ST_STARTBURST or state_N = ST_SEND_N) else
                    '0';
                
    fifo_tmp_N <=   fifData     when readRequ_I = '1' else
                    fifo_tmp;
                    
    writedata_N(PixelDepth-1 downto 0) <=  fifo_tmp_N  when (state_N = ST_STARTBURST or state_N = ST_SEND_N) else
                                            writedata_O(PixelDepth-1 downto 0);

    writedata_N(AvalonDataDepth-1 downto PixelDepth) <= (others => '0');
    
    countB_N    <=  countB+1        when (state_N = ST_STARTBURST or state_N = ST_SEND_N) else
                    (others => '0') when (state_N = ST_W_NOT_AEM or state_N = ST_NOTHING or state_N = ST_END_F1 or state_N = ST_END_F2) else
                    countB;
                    
    countP_N    <=  countP+1        when (state_N = ST_STARTBURST or state_N = ST_SEND_N) else
                    (others => '0') when (state_N = ST_NOTHING or state_N = ST_END_F1 or state_N = ST_END_F2) else
                    countP;
                    
    write_N <=  '1' when (state_N = ST_STARTBURST or state_N = ST_SEND_N or state_N = ST_W_END_WR) else
                '0';
                
    beginburst_N <= '1' when state_N = ST_STARTBURST else
                    '0';
                    
    address_N   <=  unsigned(StAddress) when (state_N = ST_W_NOT_AEM and (state = ST_FIND_TRIG or state = ST_W_NOT_EM) and start = "01") else 
                    unsigned(StAddress) + to_unsigned(LcdNPixel*4,address_N'length)  when (state_N = ST_W_NOT_AEM and (state = ST_FIND_TRIG or state = ST_W_NOT_EM)) else
                    address_O + to_unsigned(AvalonBustN*4,address_N'length) when (state_N = ST_W_NOT_AEM and state = ST_SEND_N) else
                    address_O;
                   
    address_IN  <=  address_O when state_N = ST_STARTBURST else
                    address_I;
    
    bussy_N     <=  '1' when (state_N = ST_W_NOT_EM) else
                    '0' when (state_N = ST_NOTHING or state_N = ST_END_F1 or state_N = ST_END_F2) else
                    bussy_I; 
    
    
    process(clk,nreset,En)
	    begin
		    if nReset = '0' or En = '0' then
		        state <= ST_NOTHING;
		        fifo_tmp <= (others => '0');
		        writedata_O <= (others => '0');
		        countB <= (others => '0');
		        countP <= (others => '0');
		        write <= '0';
		        beginburst <= '0';
		        address_O <= (others => '0');
		        address_I <= (others => '0');
		        bussy_I <= '0';
		    elsif rising_edge(clk) then
                write <= write_N;
		        state <= state_N;
		        fifo_tmp <= fifo_tmp_N;
		        writedata_O <= writedata_N;
		        countB <= countB_N;
		        countP <= countP_N;
		        beginburst <= beginburst_N;
		        address_O <= address_N;
		        address_I <= address_IN;
		        bussy_I <= bussy_N;
		    end if;
    end process;
    
    writedata<= writedata_O;
    readRequ <= readRequ_I;
    read <= '0';
    burstcount <= std_logic_vector(to_unsigned(AvalonBustN,burstcount'length));
    address <= std_logic_vector(address_I);
    bussy <= bussy_I;
    
end comp;
