library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cam_interface_v2 is
	port(
		nReset	: in std_logic;

		-- Signals given by the TRDB-D5M camera
		pclk    : in std_logic;                     --inout
		data    : in std_logic_vector(11 downto 0);
		fval    : in std_logic;
		lval    : in std_logic;

		-- Signal given by the main FIFO
		main_fifo_full  : in std_logic;

		-- Signal given by the "local" FIFO
		fifo_read_data  : in std_logic_vector(11 downto 0);

		-- Signal given by the Avalon slave
		en_cam          : in std_logic;
		start_frame_seq : in std_logic_vector(15 downto 0);
		forbidden       : in std_logic_vector(15 downto 0);
		not_forbidden   : in std_logic_vector(15 downto 0);

		-- Outputs
		fifo_write_data : out std_logic_vector(11 downto 0);
		fifo_read       : out std_logic;
		fifo_write      : out std_logic;
		fifo_clk        : out std_logic;

		rgb_data        : out std_logic_vector(15 downto 0);
		write_en        : out std_logic;
		main_fifo_clk   : out std_logic
	);
end cam_interface_v2;

architecture rtl of cam_interface_v2 is

	constant NROW : unsigned := to_unsigned(480, 10);
	constant NCOL : unsigned := to_unsigned(640, 10);
	------- FOR SIMULATION -----------------------------------------------------
	--constant NROW : unsigned := to_unsigned(4, 10);
	--constant NCOL : unsigned := to_unsigned(6, 10);
	------- FOR SIMULATION -----------------------------------------------------

	signal en_data, en_count : std_logic;
	signal store_pix : std_logic;
	signal count_col_reg, count_col_next, count_line_reg, count_line_next : std_logic_vector(9 downto 0);
	signal wait_mem_reg, wait_mem_next: std_logic;
	signal mem_col, mem_col_next, mem_line, mem_line_next : std_logic_vector(9 downto 0);
	signal last_full : std_logic;

	signal is_forbidden, last_pix, last_pix_reg, last_pix_next : std_logic;
	signal rgb_data_reg, rgb_data_next : std_logic_vector(15 downto 0);
	signal odd_row_reg, odd_row_next, even_row_reg : std_logic_vector(11 downto 0);
	signal last_odd_row, last_odd_row_next, last_even_row, last_even_row_next : std_logic_vector(11 downto 0);

begin

	REG : process(pclk, nReset)
	begin
		if nReset = '0' then
			count_col_reg   <= (others => '0');
			count_line_reg  <= (others => '0');
			mem_col         <= (others => '0');
			mem_line        <= (others => '0');
			wait_mem_reg    <= '0';
			last_full       <= '0';
			odd_row_reg     <= (others => '0');
			last_pix        <= '0';
			last_pix_reg    <= '0';
			last_even_row   <= (others => '0');
			last_odd_row    <= (others => '0');
			rgb_data_reg    <= (others => '0');
		elsif rising_edge(pclk) then
			count_col_reg   <= count_col_next;
			count_line_reg  <= count_line_next;
			mem_col         <= mem_col_next;
			mem_line        <= mem_line_next;
			wait_mem_reg    <= wait_mem_next;
			last_full       <= main_fifo_full;
			odd_row_reg     <= odd_row_next;
			last_pix        <= last_pix_reg;
			last_pix_reg    <= last_pix_next;
			last_even_row   <= last_even_row_next;
			last_odd_row    <= last_odd_row_next;
			rgb_data_reg    <= rgb_data_next;
		end if;
	end process;

	-- Controls registers ------------------------------------------------------
	en_data  <= '1' when en_cam = '1' and lval = '1' and fval = '1' and main_fifo_full = '0' and wait_mem_reg = '0' else '0';
	en_count <= '1' when en_cam = '1' and lval = '1' and fval = '1' and main_fifo_full = '0' else '0';

	is_forbidden  <= '1' when rgb_data_next = forbidden else '0';
	last_pix_next <= '1' when unsigned(count_col_reg) = NCOL-1 and unsigned(count_line_reg) = NROW-1 else '0';

	-- Storage controls---------------------------------------------------------
	store_pix       <= '1' when count_line_reg(0) = '0' and en_data = '1' else '0'; -- LSB = 0 means the number is even
	fifo_write      <= '1' when store_pix = '1' and en_data = '1' else '0';
	fifo_read       <= '1' when store_pix = '0' and en_data = '1' else '0';
	fifo_write_data <= data;
	main_fifo_clk   <= pclk;

	last_odd_row_next  <= odd_row_reg when count_col_reg(0) = '0' else last_odd_row;
	last_even_row_next <= even_row_reg when count_col_reg(0) = '0' else last_even_row;

    -- Counters logic ----------------------------------------------------------
	count_col_next  <= --(others => '0') when en_count = '1' and unsigned(count_col_reg) = NCOL-1 else
	                   (others => '0') when unsigned(count_col_reg) = NCOL else
					   std_logic_vector(unsigned(count_col_reg) + 1) when en_count = '1' else
					   count_col_reg;

	count_line_next <= (others => '0') when en_count = '1' and unsigned(count_line_reg) = NROW-1 and unsigned(count_col_reg) = NCOL-1 else
	                   std_logic_vector(unsigned(count_line_reg) + 1) when en_count = '1' and unsigned(count_col_reg) = NCOL-1 else
					   count_line_reg;


    -- Data outputs logic ------------------------------------------------------
    even_row_reg    <= fifo_read_data when store_pix = '0' else (others => '0');
	odd_row_next    <= data           when store_pix = '0' else (others => '0');

	-- data are sent only when count_col is an odd number (count_col(0) = '1')
	-- en vrai c'est        Vert                       Rouge		            Rouge                       
	rgb_data_next <= even_row_reg(11 downto 7) & odd_row_reg(11 downto 6) & last_odd_row(11 downto 7) when count_col_reg(0) = '1' else rgb_data_reg;

	write_en      <= '1' when count_line_reg(0) = '1' and to_integer(unsigned(count_col_reg)) mod 2 = 0 and to_integer(unsigned(count_col_reg)) /= 0 and to_integer(unsigned(count_col_reg)) /= 6 else
	                 '1' when count_line_reg(0) = '0' and to_integer(unsigned(count_col_reg)) = NCOL else
	                 '1' when last_pix = '1' else
	                 '0';
	fifo_clk      <= pclk;

    rgb_data <= start_frame_seq when last_pix = '1' else
                not_forbidden   when is_forbidden = '1' else
                rgb_data_reg;


    -- Memory in case of main FIFO full ----------------------------------------
    mem_col_next  <= count_col_reg  when main_fifo_full /= last_full and main_fifo_full = '1' else
                     mem_col;
	mem_line_next <= count_line_reg when main_fifo_full /= last_full and main_fifo_full = '1' else
	                 mem_line;

    wait_mem_next <= '1' when main_fifo_full /= last_full and main_fifo_full = '0' else
                     '0' when count_col_reg = mem_col and count_line_reg = mem_line else
                     wait_mem_reg;


end architecture rtl;
