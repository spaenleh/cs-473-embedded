library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AvalonMaster is
	generic(
		ADDRBITS		: integer := 64;
		ADDRVALUE	: integer := 614400;	--320*240*2frames*4addrjump
		BURSTBITS  : integer := 4;	--5 bits to count to 15
		BURSTVALUE : integer := 15
	);
    port(
		clk : in std_logic;
		nReset : in std_logic;

		--Fifo
		fifoRead : in std_logic;
		fifoDataOut : out std_logic_vector(15 downto 0);
		fifoEmpty : out std_logic;

		--Avalon
		readDataValid : in std_logic;
		readData : in std_logic_vector(31 downto 0);
		waitRequest : in std_logic;
		beginBurst : out std_logic;
		burstCount : out std_logic_vector(BURSTBITS-1 downto 0);
		read : out std_logic;
		address : out std_logic_vector(ADDRBITS-1 downto 0)
    );
end entity AvalonMaster;

architecture rtl of AvalonMaster is

	type read_states_T is (IDLE, BURSTSTART, WAITFORBURST, CAPTUREDATA, WATCHDOG);

	signal currState, currState_N : read_states_T := IDLE;
	signal addr, addr_N : unsigned(ADDRBITS-1 downto 0) := (others => '0');
	signal readCounter, readCounter_N : unsigned(BURSTBITS-1 downto 0) := (others => '0');
	signal wtdTim, wtdTim_N : unsigned(25 downto 0) := (others => '0'); --Watchdog timer ~= 1sec
	signal wtdPixLacking, wtdPixLacking_N : unsigned(BURSTBITS-1 downto 0) := (others => '0');	--Downcounter to realign data after watchdog

	signal fifoWrite : std_logic;
	signal fifoAlmostEmpty : std_logic;

	component fifo
		PORT
		(
			aclr		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdreq		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			almost_empty		: OUT STD_LOGIC ;
			empty		: OUT STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	end component;

begin

	FIFO_0 : FIFO
	PORT MAP (
			aclr  => not nReset,
			clock => clk,
			data => readData(15 downto 0),
			rdreq => fifoRead,
			wrreq => fifoWrite,
			almost_empty => fifoAlmostEmpty,
			empty => fifoEmpty,
			q => fifoDataOut
		);

	currState_N <= 	BURSTSTART when currState = IDLE and fifoAlmostEmpty = '1' else
					WAITFORBURST when currState = BURSTSTART else
					CAPTUREDATA when currState = WAITFORBURST and waitRequest = '0' else
					IDLE when (currState = CAPTUREDATA and to_integer(readCounter) = BURSTVALUE) or
								(currState = WATCHDOG and to_integer(wtdPixLacking) = 0) else
					WATCHDOG when currState = CAPTUREDATA and to_integer(wtdTim) = 50000000 else    --1sec
					currState;	--Main state machine

	read <=	'1' when currState = BURSTSTART or currState = WAITFORBURST else	--Starts burst read
			'0';

	address <= std_logic_vector(addr);

	beginBurst <=	'1' when currState = BURSTSTART else
					'0';
	burstCount <=	std_logic_vector(to_unsigned(BURSTVALUE, burstCount'length));

	addr_N <=	addr + 4 when currState = CAPTUREDATA and readDataValid = '1' and to_integer(addr) < ADDRVALUE-4	else
				(others => '0') when currState = CAPTUREDATA and readDataValid = '1' else
				addr;

	readCounter_N <=	readCounter + 1 when currState = CAPTUREDATA and readDataValid = '1' and to_integer(readCounter) < BURSTVALUE else
						(others => '0') when currState = CAPTUREDATA and readDataValid = '1' else	
						readCounter;	--Counts until end of burst
						
	wtdTim_N <= wtdTim + 1 when currState = CAPTUREDATA else
				(others => '0');	--Counts 2^26 clock cycles (>1sec)
				
	wtdPixLacking_N <= wtdPixLacking - 1 when currState = WATCHDOG else
						BURSTVALUE - readCounter when currState = CAPTUREDATA else
						(others => '1');

	fifoWrite <=	'1' when (currState = CAPTUREDATA and readDataValid = '1') or		--Writes when data received
							(currState = WATCHDOG and to_integer(wtdPixLacking) /= 0) else	--Or when no data after 1sec (dummy write)
					'0';

	process(clk, nReset)
	begin
		if nReset = '0' then
			currState <= IDLE;
			addr <= (others => '0');
			readCounter <= (others => '0');
			wtdTim <= (others => '0');
			wtdPixLacking <= (others => '0');
			
		elsif rising_edge(clk) then
			currState <= currState_N;
			addr <= addr_N;
			readCounter <= readCounter_N;
			wtdTim <= wtdTim_N;
			wtdPixLacking <= wtdPixLacking_N;

		end if;
	end process;

end;
