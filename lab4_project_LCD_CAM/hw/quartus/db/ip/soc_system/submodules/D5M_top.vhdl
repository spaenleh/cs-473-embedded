library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity D5M_top is
    generic(
        AvalonAddressDepth      : integer := 64;
        AvalonBustDepth         : integer := 7;
        AvalonBustN             : integer := 16;
        AvalonDataDepth         : integer := 32;
                
        LcdNPixel               : integer := 76800;
        PixelCountDepth         : integer := 20;
        PixelDepth              : integer := 16;
        
        FifoCountDepth          : integer := 7
    );
	port(
		clk             : in std_logic;
		nReset          : in std_logic;
	-- AVALON MASTER INTERFACE
		waitrequest_MA  : in std_logic;
		write_MA        : out std_logic;
		read_MA         : out std_logic;
		beginburst_MA   : out std_logic;
		burstcount_MA   : out std_logic_vector(AvalonBustDepth-1 downto 0);
		address_MA      : out std_logic_vector(AvalonAddressDepth-1 downto 0);
		writedata_MA    : out std_logic_vector(AvalonDataDepth-1 downto 0);
		readdata_MA     : in std_logic_vector(AvalonDataDepth-1 downto 0);
		readDataVa_MA   : in std_logic;
    -- AVALON SLAVE INTERFACE
    	address_SL      : in std_logic_vector(3 downto 0);
		write_SL        : in std_logic;
		read_SL         : in std_logic;
		writedata_SL    : in std_logic_vector(7 downto 0);
		readdata_SL     : out std_logic_vector(7 downto 0);
	-- CLOCK GENERATION
        mclk            : out std_logic;
        cam_reset       : out std_logic;
	-- CAMERA INTERFACE 
		pclk            : in std_logic;                    
		data            : in std_logic_vector(11 downto 0);
		fval            : in std_logic;
		lval            : in std_logic
	);
end D5M_top;

architecture comp of D5M_top is

    signal readRequ_I   : std_logic;
    signal empty_I      : std_logic;
    signal fifData_I    : std_logic_vector(PixelDepth-1 downto 0);
    signal countD_I     : std_logic_vector(FifoCountDepth-1 downto 0);
    
    signal clk_I        : std_logic;
    signal fifData_O    : std_logic_vector(PixelDepth-1 downto 0);
    signal wrrequ       : std_logic;
    signal full         : std_logic;
    
    signal trigFram     : std_logic_vector(PixelDepth-1 downto 0);
    signal replace      : std_logic_vector(PixelDepth-1 downto 0);
    signal start        : std_logic_vector(2-1 downto 0);
    signal StAddress    : std_logic_vector(AvalonAddressDepth-1 downto 0);
    signal bussy        : std_logic;
    signal EnAvMa       : std_logic;
    signal EnClkGen     : std_logic;
	signal EnCam        : std_logic;
	
	signal fifo_clk        : std_logic;
	signal fifo_read_data  : std_logic_vector(11 downto 0);
	signal fifo_write_data : std_logic_vector(11 downto 0);
	signal fifo_read       : std_logic;
	signal fifo_write      : std_logic;
	signal empty_fifo      : std_logic;

begin

    vaMast: entity work.AvalonMasterWrite
        generic map(
            AvalonAddressDepth=>AvalonAddressDepth,
            AvalonBustDepth=>AvalonBustDepth,
            AvalonBustN=>AvalonBustN,
            AvalonDataDepth=>AvalonDataDepth,
            LcdNPixel=>LcdNPixel,
            PixelDepth => PixelDepth,
            PixelCountDepth=>PixelCountDepth,
            FifoCountDepth=>FifoCountDepth
        )
        port map(
	        clk         => clk,
	        nReset      => nReset,
	        waitrequest => waitrequest_MA,
	        write       => write_MA,
	        read        => read_MA,
	        beginburst  => beginburst_MA,
	        burstcount  => burstcount_MA,
	        address     => address_MA,
	        writedata   => writedata_MA,
	        readdata    => readdata_MA,
	        readDataVa  => readDataVa_MA,
    -- FIFO
            readRequ    => readRequ_I,
            empty       => empty_I,
            fifData     => fifData_I,
            countD      => countD_I,
    -- Slave IN
            trigFram    => trigFram,
            start       => start,
            StAddress   => StAddress,
            bussy       => bussy,
            En          => EnAvMa
        );
        
    clk_gen_inst : entity work.clk_gen
        port map (
            clk       => clk,
            nReset    => nReset,
            en_clkGen => EnClkGen,
            mclk      => mclk,
            cam_reset => cam_reset
        );    
    
    cam_interface_inst : entity work.cam_interface_v2
        port map (
            nReset          => nReset,
            pclk            => pclk,
		    data            => data,
		    fval            => fval,
		    lval            => lval,
		    main_fifo_full  => full,
		    fifo_read_data  => fifo_read_data,  
		    en_cam          => EnCam,
		    start_frame_seq => trigFram, 
		    forbidden       => trigFram,       
		    not_forbidden   => replace,
		    fifo_write_data => fifo_write_data,
		    fifo_read       => fifo_read,      
		    fifo_write      => fifo_write,    
		    fifo_clk        => fifo_clk,        
		    rgb_data        => fifData_O,
		    write_en        => wrrequ, 
		    main_fifo_clk   => clk_I       
		    );  
		      
    interface_fifo_inst : entity work.interface_fifo
        port map (
            clock => fifo_clk,
		    data  => fifo_write_data,
		    rdreq => fifo_read,
		    wrreq => fifo_write,
		    empty => empty_fifo,
		    q	  => fifo_read_data
		    );  
	    
	avSlave: entity  work.AvalonSlave
	    port map (
	    	clk     => clk,
		    nReset => nReset,
		-- Internal interface (i.e. Avalon slave).
		address => address_SL,
		write => write_SL,
		read => read_SL,
		writedata => writedata_SL,
		readdata => readdata_SL,
		-- External interface (i.e. conduit).
		bussy => bussy,
		start_frame => start,
		EnAvMa => EnAvMa,
		EnClkGen => EnClkGen,
		EnCam => EnCam,
		trig_frame => trigFram,
		replace => replace,
		AddressSt => StAddress
		);
	
	
    MyFIFO_inst : entity work.MyFIFO 
        port map (
		    data	    => fifData_O,
		    rdclk	    => clk,
		    rdreq	    => readRequ_I,
		    wrclk	    => clk_I,
		    wrreq	    => wrrequ,
		    q	        => fifData_I,
		    rdempty	    => empty_I,
		    rdusedw	    => countD_I,
		    wrfull	    => full
	    );

end comp;

