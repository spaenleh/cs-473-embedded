library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_ip is
	generic(
		ADDRBITS		: integer := 64;
		ADDRVALUE	: integer := 614400;	--320*240*2frames*4addrjump
		BURSTBITS  : integer := 4;	--5 bits to count to 15
		BURSTVALUE : integer := 15
	);
	port (
	clk 	: in std_logic;
	nReset 	: in std_logic;

	-- Avalon slave
	address_S 	: in std_logic_vector(1 downto 0);	-- 3 registers so only 2 bits
	write_S 		: in std_logic;						-- procesor wants to write
	writedata_S 	: in std_logic_vector(15 downto 0);	-- data to write sent from the processor
	read_S 		: in std_logic;						-- procesor wants to write
	readdata_S 	: out std_logic_vector(15 downto 0);	-- data to write sent from the processor

	-- External interface (i.e. conduit).
	LT24_CS_N         : out std_logic;
	LT24_D            : out std_logic_vector(15 downto 0);
	LT24_LCD_ON       : out std_logic;
	LT24_RD_N         : out std_logic;
	LT24_RESET_N      : out std_logic;
	LT24_RS_D_Cx           : out std_logic;
	LT24_WR_N         : out std_logic;

	-- Avalon MASTER
	AM_readDataValid : in std_logic;
	AM_readData : in std_logic_vector(31 downto 0);
	AM_waitRequest : in std_logic;
	AM_beginBurst : out std_logic;
	AM_burstCount : out std_logic_vector(BURSTBITS-1 downto 0);
	AM_read : out std_logic;
	AM_address : out std_logic_vector(ADDRBITS-1 downto 0)
	);
end display_ip;


architecture comp of display_ip is

	-- Register map
	-- signal iReg_LCD_Command, next_iReg_LCD_Command : std_logic_vector(15 downto 0) := (others => '0');	-- Command
	signal iReg, next_iReg : std_logic_vector(15 downto 0) := (others => '0');	-- Command
	-- signal iReg_LCD_Data, next_iReg_LCD_Data	: std_logic_vector(15 downto 0) := (others => '0');	-- Data
	signal iReg_Frame_Wait, next_iReg_Frame_Wait	: std_logic_vector(7 downto 0) := (others => '0');	-- instructions to be written by the Nios
	signal oReg_Frame_State, next_oReg_Frame_State	: std_logic_vector(7 downto 0) := (others => '0');	-- state to be read by the Nios
	signal D_Cx_lcd, next_D_Cx_lcd 	: std_logic := '0';		-- is it data or command ?
	signal WR_N_lcd, next_WR_N_lcd	: std_logic := '1';		-- write signal

	-- State register
    type state_type is (STATE_IDLE_CFG, STATE_OUT, STATE_OUT_1, STATE_OUT_2, STATE_OUT_3, STATE_OUT_WAIT, STATE_VALID, STATE_VALID_1, STATE_VALID_2, STATE_VALID_3, STATE_REG, STATE_REG_WAIT, STATE_IDLE_SEND);
    signal reg_state, next_reg_state : state_type;

	signal enable_send, next_enable_send : std_logic := '0';
	signal busy_pixel : std_logic;
	signal fifo_read : std_logic;
	signal fifo_data	: std_logic_vector(15 downto 0) := (others => '1');
	signal Data_pixel	: std_logic_vector(15 downto 0) := (others => '1'); -- from pixel_send module
	signal D_Cx_pixel		: std_logic := '0'; -- from pixel_send module
	signal WR_N_pixel		: std_logic := '1'; -- from pixel_send module
	signal poubelle			: std_logic;
	-- counter
	-- constant COUNTER_MAX : unsigned := to_unsigned(3, 3); -- to be defined
	-- signal reg_counter, next_reg_counter : unsigned(2 downto 0) := (others => '0');
	component pixel_send is
		port (
			clk 	: in std_logic;
			nReset 	: in std_logic;
			-- signals
			enable 	: in std_logic;
			-- frame_wait	: in std_logic_vector(1 downto 0);
			busy	: out std_logic;
			-- frame_state : out std_logic_vector(1 downto 0);
			-- from other modules
			Fifo_data : in std_logic_vector(15 downto 0);
			Fido_read : out std_logic;
			-- External interface (i.e. conduit).
			LCD_D            : out std_logic_vector(15 downto 0);
			LCD_RS_D_Cx      : out std_logic;
			LCD_WR_N         : out std_logic
		);
	end component pixel_send;

	component AvalonMaster is
		generic(
			ADDRBITS		: integer := 18;	--18 bits to store 2 frames in ram
			ADDRVALUE	: integer := 153600;
			BURSTBITS  : integer := 5;	--5 bits to count to 20
			BURSTVALUE : integer := 20
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
	end component AvalonMaster;


begin

	pixel_send_inst : component pixel_send

	port map(
		clk 	=> clk,
		nReset 	=> nReset,
		-- signals
		enable => enable_send,
		busy => busy_pixel,
		-- from other modules
		Fifo_data => fifo_data,
		Fido_read => fifo_read,
		-- External interface (i.e. conduit).
		LCD_D => Data_pixel,
		LCD_RS_D_Cx => D_Cx_pixel,
		LCD_WR_N => WR_N_pixel
	);

	avalonMaster_inst : component AvalonMaster
	generic map(
		ADDRBITS => ADDRBITS,
		ADDRVALUE => ADDRVALUE,	--320*240*2frames*4addrjump
		BURSTBITS => BURSTBITS,	--5 bits to count to 15
		BURSTVALUE => BURSTVALUE
	)
	port map(
		clk => clk,
		nReset => nReset,
		--Fifo
		fifoRead => fifo_read,
		fifoDataOut => fifo_data,
		fifoEmpty => poubelle, -- modify if you need it
		--Avalon
		readDataValid => AM_readDataValid,
		readData => AM_readData,
		waitRequest => AM_waitRequest,
		beginBurst => AM_beginBurst,
		burstCount => AM_burstCount,
		read => AM_read,
		address => AM_address
	);

	-- Avalon slave write to registers.
	REG : process(clk, nReset)
	begin
		if nReset = '0' then
			iReg <= (others => '0');
			D_Cx_lcd <= '0';
			WR_N_lcd <= '1';
			iReg_Frame_Wait <= (others => '0');
			oReg_Frame_State <= (others => '0');
			reg_state <= STATE_IDLE_CFG;
			enable_send <= '0';
		elsif rising_edge(clk) then
			iReg <= next_iReg;
			D_Cx_lcd <= next_D_Cx_lcd;
			WR_N_lcd <= next_WR_N_lcd;
			iReg_Frame_Wait <= next_iReg_Frame_Wait;
			oReg_Frame_State <= next_oReg_Frame_State;
			reg_state <= next_reg_state;
			enable_send <= next_enable_send;
		end if;
	end process;

	-- LT24_D <= LCD_pins
	LT24_CS_N 		<= '0'; -- always selected
    LT24_D 			<= iReg when enable_send = '0' else Data_pixel;
    -- LT24_D 			<= iReg when enable_send = '0' else "0000011111100000";
    LT24_LCD_ON 	<= '1'; -- maybe change to a switch
    LT24_RD_N		<= '1'; -- never read from screen
    LT24_RESET_N 	<= not iReg_Frame_Wait(6); -- Reset active low of the LCD
    LT24_RS_D_Cx	<= D_Cx_lcd when enable_send = '0' else D_Cx_pixel;
    LT24_WR_N       <= WR_N_lcd when enable_send = '0' else WR_N_pixel;

	process(reg_state, write_S, address_S, writedata_S, iReg, D_Cx_lcd, WR_N_lcd, iReg_Frame_Wait, oReg_Frame_State, enable_send, busy_pixel)
	begin
		next_reg_state <= reg_state;
		next_iReg <= iReg;
		next_D_Cx_lcd <= D_Cx_lcd;
		next_WR_N_lcd <= WR_N_lcd;
		next_iReg_Frame_Wait <= iReg_Frame_Wait;
		next_oReg_Frame_State <= oReg_Frame_State;
		next_enable_send <= enable_send;
		case( reg_state ) is
			when STATE_IDLE_CFG =>
				next_WR_N_lcd <= '1';
				if write_S = '1' then
					case( address_S ) is
						when "00" => -- Command -> D_Cx = 0
							next_iReg <= writedata_S;
							next_D_Cx_lcd <= '0';			-- Command
							next_WR_N_lcd <= '0';
							next_reg_state <= STATE_OUT;
						when "01" =>
							next_iReg <= writedata_S;
							next_D_Cx_lcd <= '1';			-- Data
							next_WR_N_lcd <= '0';
							next_reg_state <= STATE_OUT;
						when "10" =>
							-- next_iReg_Frame_Wait <= (others => '1');
							next_iReg_Frame_Wait <= writedata_S(7 downto 0);
							next_reg_state <= STATE_REG;
						when others =>
							next_reg_state <= STATE_IDLE_CFG;
					end case;
				end if;

			when STATE_OUT =>
				-- next_reg_state <= STATE_OUT_WAIT;
				next_reg_state <= STATE_OUT_1;

-- modified 24 dec
			when STATE_OUT_1 =>
				next_reg_state <= STATE_OUT_2;

			when STATE_OUT_2 =>
				next_reg_state <= STATE_OUT_3;

			when STATE_OUT_3 =>
				next_reg_state <= STATE_OUT_WAIT;
-- end modified 24 dec

			when STATE_OUT_WAIT =>
				next_WR_N_lcd <= '1';
				-- next_reg_state <= STATE_VALID;
				next_reg_state <= STATE_VALID_1;

-- modified 24 dec
			when STATE_VALID_1 =>
				next_reg_state <= STATE_VALID_2;

			when STATE_VALID_2 =>
				next_reg_state <= STATE_VALID_3; -- attention

			when STATE_VALID_3 =>
				next_reg_state <= STATE_VALID;
-- modified 24 dec

			when STATE_VALID =>
				-- write_lcd <= '1';
				next_reg_state <= STATE_IDLE_CFG;

			when STATE_REG =>
				if iReg_Frame_Wait(7) = '0' then
					next_reg_state <= STATE_IDLE_CFG;
					next_enable_send <= '0';
				else
					next_reg_state <= STATE_IDLE_SEND;
					next_enable_send <= '1';
				end if;

			-- when STATE_REG_WAIT =>
			-- 	next_reg_state <= STATE_IDLE_SEND;

			when STATE_IDLE_SEND =>
				-- next_enable_send <= '1';
				-- here the module to send the pixels has the focus
				next_oReg_Frame_State(0) <= busy_pixel;
				if write_S = '1' then
					if address_S = "10" then
						next_iReg_Frame_Wait <= writedata_S(7 downto 0);
						next_reg_state <= STATE_REG;
					end if;
				-- elsif busy_pixel = '0' then
				-- 	next_enable_send <= '0';
				-- 	next_reg_state <= STATE_IDLE_CFG;
				end if;
			when others =>
				next_reg_state <= STATE_IDLE_CFG;
		end case;
	end process;

	-- Avalon slave read from registers.
	process(clk)
	begin
		if rising_edge(clk) then
			readdata_S <= (others => '0');
			if read_S = '1' then
				case address_S is
					when "11" 	=> readdata_S <= (15 downto 8 => '0') & oReg_Frame_State;
					when others => null;
				end case;
			end if;
		end if;
	end process;


end comp;
