# TCL File Generated by Component Editor 18.1
# Wed Dec 30 19:59:35 CET 2020
# DO NOT MODIFY


# 
# D5M_top "D5M_top" v1.0
#  2020.12.30.19:59:35
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module D5M_top
# 
set_module_property DESCRIPTION ""
set_module_property NAME D5M_top
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME D5M_top
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL D5M_top
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file D5M_top.vhdl VHDL PATH hdl/D5M_top.vhdl TOP_LEVEL_FILE
add_fileset_file AvalonMasterwrite.vhdl VHDL PATH hdl/AvalonMasterwrite.vhdl
add_fileset_file AvalonSlave.vhdl VHDL PATH hdl/AvalonSlave.vhdl
add_fileset_file MyFIFO.vhd VHDL PATH hdl/MyFIFO.vhd
add_fileset_file cam_interface_v2.vhd VHDL PATH hdl/cam_interface_v2.vhd
add_fileset_file clk_gen.vhd VHDL PATH hdl/clk_gen.vhd
add_fileset_file interface_fifo.vhd VHDL PATH hdl/interface_fifo.vhd


# 
# parameters
# 
add_parameter AvalonAddressDepth INTEGER 64
set_parameter_property AvalonAddressDepth DEFAULT_VALUE 64
set_parameter_property AvalonAddressDepth DISPLAY_NAME AvalonAddressDepth
set_parameter_property AvalonAddressDepth TYPE INTEGER
set_parameter_property AvalonAddressDepth UNITS None
set_parameter_property AvalonAddressDepth HDL_PARAMETER true
add_parameter AvalonBustDepth INTEGER 7 ""
set_parameter_property AvalonBustDepth DEFAULT_VALUE 7
set_parameter_property AvalonBustDepth DISPLAY_NAME AvalonBustDepth
set_parameter_property AvalonBustDepth TYPE INTEGER
set_parameter_property AvalonBustDepth UNITS None
set_parameter_property AvalonBustDepth ALLOWED_RANGES -2147483648:2147483647
set_parameter_property AvalonBustDepth DESCRIPTION ""
set_parameter_property AvalonBustDepth HDL_PARAMETER true
add_parameter AvalonBustN INTEGER 16 ""
set_parameter_property AvalonBustN DEFAULT_VALUE 16
set_parameter_property AvalonBustN DISPLAY_NAME AvalonBustN
set_parameter_property AvalonBustN TYPE INTEGER
set_parameter_property AvalonBustN UNITS None
set_parameter_property AvalonBustN ALLOWED_RANGES -2147483648:2147483647
set_parameter_property AvalonBustN DESCRIPTION ""
set_parameter_property AvalonBustN HDL_PARAMETER true
add_parameter AvalonDataDepth INTEGER 32
set_parameter_property AvalonDataDepth DEFAULT_VALUE 32
set_parameter_property AvalonDataDepth DISPLAY_NAME AvalonDataDepth
set_parameter_property AvalonDataDepth TYPE INTEGER
set_parameter_property AvalonDataDepth UNITS None
set_parameter_property AvalonDataDepth HDL_PARAMETER true
add_parameter LcdNPixel INTEGER 76800 ""
set_parameter_property LcdNPixel DEFAULT_VALUE 76800
set_parameter_property LcdNPixel DISPLAY_NAME LcdNPixel
set_parameter_property LcdNPixel TYPE INTEGER
set_parameter_property LcdNPixel UNITS None
set_parameter_property LcdNPixel ALLOWED_RANGES -2147483648:2147483647
set_parameter_property LcdNPixel DESCRIPTION ""
set_parameter_property LcdNPixel HDL_PARAMETER true
add_parameter PixelCountDepth INTEGER 20 ""
set_parameter_property PixelCountDepth DEFAULT_VALUE 20
set_parameter_property PixelCountDepth DISPLAY_NAME PixelCountDepth
set_parameter_property PixelCountDepth TYPE INTEGER
set_parameter_property PixelCountDepth UNITS None
set_parameter_property PixelCountDepth ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PixelCountDepth DESCRIPTION ""
set_parameter_property PixelCountDepth HDL_PARAMETER true
add_parameter PixelDepth INTEGER 16 ""
set_parameter_property PixelDepth DEFAULT_VALUE 16
set_parameter_property PixelDepth DISPLAY_NAME PixelDepth
set_parameter_property PixelDepth TYPE INTEGER
set_parameter_property PixelDepth UNITS None
set_parameter_property PixelDepth ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PixelDepth DESCRIPTION ""
set_parameter_property PixelDepth HDL_PARAMETER true
add_parameter FifoCountDepth INTEGER 7 ""
set_parameter_property FifoCountDepth DEFAULT_VALUE 7
set_parameter_property FifoCountDepth DISPLAY_NAME FifoCountDepth
set_parameter_property FifoCountDepth TYPE INTEGER
set_parameter_property FifoCountDepth UNITS None
set_parameter_property FifoCountDepth ALLOWED_RANGES -2147483648:2147483647
set_parameter_property FifoCountDepth DESCRIPTION ""
set_parameter_property FifoCountDepth HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point sl
# 
add_interface sl avalon end
set_interface_property sl addressUnits WORDS
set_interface_property sl associatedClock clock
set_interface_property sl associatedReset reset_sink
set_interface_property sl bitsPerSymbol 8
set_interface_property sl burstOnBurstBoundariesOnly false
set_interface_property sl burstcountUnits WORDS
set_interface_property sl explicitAddressSpan 0
set_interface_property sl holdTime 0
set_interface_property sl linewrapBursts false
set_interface_property sl maximumPendingReadTransactions 0
set_interface_property sl maximumPendingWriteTransactions 0
set_interface_property sl readLatency 0
set_interface_property sl readWaitTime 1
set_interface_property sl setupTime 0
set_interface_property sl timingUnits Cycles
set_interface_property sl writeWaitTime 0
set_interface_property sl ENABLED true
set_interface_property sl EXPORT_OF ""
set_interface_property sl PORT_NAME_MAP ""
set_interface_property sl CMSIS_SVD_VARIABLES ""
set_interface_property sl SVD_ADDRESS_GROUP ""

add_interface_port sl address_SL address Input 4
add_interface_port sl write_SL write Input 1
add_interface_port sl read_SL read Input 1
add_interface_port sl writedata_SL writedata Input 8
add_interface_port sl readdata_SL readdata Output 8
set_interface_assignment sl embeddedsw.configuration.isFlash 0
set_interface_assignment sl embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment sl embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment sl embeddedsw.configuration.isPrintableDevice 0


# 
# connection point avalon_master
# 
add_interface avalon_master avalon start
set_interface_property avalon_master addressUnits SYMBOLS
set_interface_property avalon_master associatedClock clock
set_interface_property avalon_master associatedReset reset_sink
set_interface_property avalon_master bitsPerSymbol 8
set_interface_property avalon_master burstOnBurstBoundariesOnly false
set_interface_property avalon_master burstcountUnits WORDS
set_interface_property avalon_master doStreamReads false
set_interface_property avalon_master doStreamWrites false
set_interface_property avalon_master holdTime 0
set_interface_property avalon_master linewrapBursts false
set_interface_property avalon_master maximumPendingReadTransactions 0
set_interface_property avalon_master maximumPendingWriteTransactions 0
set_interface_property avalon_master readLatency 0
set_interface_property avalon_master readWaitTime 1
set_interface_property avalon_master setupTime 0
set_interface_property avalon_master timingUnits Cycles
set_interface_property avalon_master writeWaitTime 0
set_interface_property avalon_master ENABLED true
set_interface_property avalon_master EXPORT_OF ""
set_interface_property avalon_master PORT_NAME_MAP ""
set_interface_property avalon_master CMSIS_SVD_VARIABLES ""
set_interface_property avalon_master SVD_ADDRESS_GROUP ""

add_interface_port avalon_master address_MA address Output avalonaddressdepth
add_interface_port avalon_master burstcount_MA burstcount Output avalonbustdepth
add_interface_port avalon_master readDataVa_MA readdatavalid Input 1
add_interface_port avalon_master readdata_MA readdata Input avalondatadepth
add_interface_port avalon_master waitrequest_MA waitrequest Input 1
add_interface_port avalon_master writedata_MA writedata Output avalondatadepth
add_interface_port avalon_master write_MA write Output 1
add_interface_port avalon_master read_MA read Output 1
add_interface_port avalon_master beginburst_MA beginbursttransfer Output 1


# 
# connection point camera_interface
# 
add_interface camera_interface conduit end
set_interface_property camera_interface associatedClock ""
set_interface_property camera_interface associatedReset reset_sink
set_interface_property camera_interface ENABLED true
set_interface_property camera_interface EXPORT_OF ""
set_interface_property camera_interface PORT_NAME_MAP ""
set_interface_property camera_interface CMSIS_SVD_VARIABLES ""
set_interface_property camera_interface SVD_ADDRESS_GROUP ""

add_interface_port camera_interface mclk mclk Output 1
add_interface_port camera_interface pclk pclk Input 1
add_interface_port camera_interface data data Input 12
add_interface_port camera_interface fval fval Input 1
add_interface_port camera_interface lval lval Input 1
add_interface_port camera_interface cam_reset cam_reset Output 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink nReset reset_n Input 1

