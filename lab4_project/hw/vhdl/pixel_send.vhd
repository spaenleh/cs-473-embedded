library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pixel_send is
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
end pixel_send;


architecture comp of pixel_send is

	-- counter
	constant LINE_MAX : unsigned := to_unsigned(240, 8); -- length of the line
	constant COL_MAX : unsigned := to_unsigned(320, 9); -- length of the columns

	signal D_Cx_pixel, next_D_Cx_pixel : std_logic := '0';	-- is it data or command ?
	signal WR_N_pixel, next_WR_N_pixel : std_logic := '0';
	signal iReg, next_iReg : std_logic_vector(15 downto 0);
	constant MEM_WRITE : std_logic_vector(15 downto 0) := "0000000000101100"; -- Memory write command

	-- State register
    type state_type is (STATE_IDLE, STATE_OUT, STATE_OUT_WAIT, STATE_VALID, STATE_GET_PIX, STATE_HAVE_PIX);
    signal reg_state, next_reg_state : state_type;

	signal busy_pixel, next_busy_pixel : std_logic := '0';
	signal fifo_read_pixel, next_fifo_read_pixel : std_logic := '0';

	-- signal reg_counter, next_reg_counter : unsigned(2 downto 0) := (others => '0');
	signal line_reg_counter, next_line_reg_counter : unsigned(7 downto 0) := (others => '0');
	signal col_reg_counter, next_col_reg_counter : unsigned(8 downto 0) := (others => '0');



begin


	REG : process(clk, nReset)
	begin
		if nReset = '0' then
			iReg <= (others => '0');
			D_Cx_pixel <= '0';
			WR_N_pixel <= '1';
			reg_state <= STATE_IDLE;
			-- reg_counter <= (others => '0');
			line_reg_counter <= (others => '0');
			col_reg_counter <= (others => '0');
			busy_pixel <= '0';
			fifo_read_pixel <= '0';
		elsif rising_edge(clk) then
			iReg <= next_iReg;
			D_Cx_pixel <= next_D_Cx_pixel;
			WR_N_pixel <= next_WR_N_pixel;
			reg_state <= next_reg_state;
			-- reg_counter <= next_reg_state;
			line_reg_counter <= next_line_reg_counter;
			col_reg_counter <= next_col_reg_counter;
			busy_pixel <= next_busy_pixel;
			fifo_read_pixel <= next_fifo_read_pixel;
		end if;
	end process;

	LCD_D 		<= iReg;
	LCD_RS_D_Cx <= D_Cx_pixel;
	LCD_WR_N 	<= WR_N_pixel;
	busy		<= busy_pixel;
	Fido_read	<= fifo_read_pixel;

	next_line_reg_counter <= (others => '0') when line_reg_counter = LINE_MAX else line_reg_counter+1 when col_reg_counter >= COL_MAX and reg_state = STATE_HAVE_PIX and line_reg_counter < LINE_MAX else line_reg_counter;
	next_col_reg_counter <= (others => '0') when col_reg_counter = COL_MAX and reg_state = STATE_HAVE_PIX else col_reg_counter+1 when reg_state = STATE_HAVE_PIX and col_reg_counter < COL_MAX else col_reg_counter;

	process(reg_state, enable)
	begin
		next_reg_state <= reg_state;
		next_iReg <= iReg;
		next_D_Cx_pixel <= D_Cx_pixel;
		next_WR_N_pixel <= WR_N_pixel;
		next_busy_pixel <= busy_pixel;
		next_fifo_read_pixel <= fifo_read_pixel;
		case( reg_state ) is
			when STATE_IDLE =>
				if enable = '1' then
					next_busy_pixel <= '1';
					next_iReg <= MEM_WRITE;
					next_D_Cx_pixel <= '0'; -- Command
					next_WR_N_pixel <= '0';
					next_reg_state <= STATE_OUT;
				else
					next_reg_state <= STATE_IDLE;
					next_busy_pixel <= '0';
				end if;

			when STATE_GET_PIX =>
				next_D_Cx_pixel <= '1'; -- Data
				next_fifo_read_pixel <= '0'; -- deactivate pixl read from fifo
				next_reg_state <= STATE_HAVE_PIX;

			when STATE_HAVE_PIX =>
				next_iReg <= Fifo_data;
				next_WR_N_pixel <= '0';
				next_reg_state <= STATE_OUT;

			when STATE_OUT =>
				next_reg_state <= STATE_OUT_WAIT;

			when STATE_OUT_WAIT =>
				next_WR_N_pixel <= '1';
				next_reg_state <= STATE_VALID;

			when STATE_VALID =>
				if enable = '0' then
					next_reg_state <= STATE_IDLE;
					next_busy_pixel <= '0';
				else
					if line_reg_counter = LINE_MAX then
						next_busy_pixel <= '0';
						next_reg_state <= STATE_IDLE;
					else
						next_reg_state <= STATE_GET_PIX;
						next_fifo_read_pixel <= '1';
					end if;
				end if;

			when others => null;

		end case;
	end process;



end comp;
