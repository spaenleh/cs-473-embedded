# TCL File Generated by Component Editor 18.1
# Fri Dec 18 11:03:51 CET 2020
# DO NOT MODIFY


# 
# display_ip "display_ip" v1.1
#  2020.12.18.11:03:51
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module display_ip
# 
set_module_property DESCRIPTION ""
set_module_property NAME display_ip
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME display_ip
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL display_ip
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file avalonMaster.vhd VHDL PATH ../vhdl/avalonMaster.vhd
add_fileset_file display_ip.vhd VHDL PATH ../vhdl/display_ip.vhd TOP_LEVEL_FILE
add_fileset_file pixel_send.vhd VHDL PATH ../vhdl/pixel_send.vhd
add_fileset_file fifo.vhd VHDL PATH ../vhdl/fifo.vhd


# 
# parameters
# 
add_parameter ADDRBITS INTEGER 64
set_parameter_property ADDRBITS DEFAULT_VALUE 64
set_parameter_property ADDRBITS DISPLAY_NAME ADDRBITS
set_parameter_property ADDRBITS TYPE INTEGER
set_parameter_property ADDRBITS UNITS None
set_parameter_property ADDRBITS ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ADDRBITS HDL_PARAMETER true
add_parameter ADDRVALUE INTEGER 614400
set_parameter_property ADDRVALUE DEFAULT_VALUE 614400
set_parameter_property ADDRVALUE DISPLAY_NAME ADDRVALUE
set_parameter_property ADDRVALUE TYPE INTEGER
set_parameter_property ADDRVALUE UNITS None
set_parameter_property ADDRVALUE ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ADDRVALUE HDL_PARAMETER true
add_parameter BURSTBITS INTEGER 4
set_parameter_property BURSTBITS DEFAULT_VALUE 4
set_parameter_property BURSTBITS DISPLAY_NAME BURSTBITS
set_parameter_property BURSTBITS TYPE INTEGER
set_parameter_property BURSTBITS UNITS None
set_parameter_property BURSTBITS ALLOWED_RANGES -2147483648:2147483647
set_parameter_property BURSTBITS HDL_PARAMETER true
add_parameter BURSTVALUE INTEGER 15
set_parameter_property BURSTVALUE DEFAULT_VALUE 15
set_parameter_property BURSTVALUE DISPLAY_NAME BURSTVALUE
set_parameter_property BURSTVALUE TYPE INTEGER
set_parameter_property BURSTVALUE UNITS None
set_parameter_property BURSTVALUE ALLOWED_RANGES -2147483648:2147483647
set_parameter_property BURSTVALUE HDL_PARAMETER true


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


# 
# connection point conduit_end
# 
add_interface conduit_end conduit end
set_interface_property conduit_end associatedClock clock
set_interface_property conduit_end associatedReset ""
set_interface_property conduit_end ENABLED true
set_interface_property conduit_end EXPORT_OF ""
set_interface_property conduit_end PORT_NAME_MAP ""
set_interface_property conduit_end CMSIS_SVD_VARIABLES ""
set_interface_property conduit_end SVD_ADDRESS_GROUP ""

add_interface_port conduit_end LT24_CS_N lt24_cs_n Output 1
add_interface_port conduit_end LT24_D lt24_d Output 16
add_interface_port conduit_end LT24_LCD_ON lt24_lcd_on Output 1
add_interface_port conduit_end LT24_RD_N lt24_rd_n Output 1
add_interface_port conduit_end LT24_RESET_N lt24_reset_n Output 1
add_interface_port conduit_end LT24_RS_D_Cx lt24_rs_d_cx Output 1
add_interface_port conduit_end LT24_WR_N lt24_wr_n Output 1


# 
# connection point avalon_master_0
# 
add_interface avalon_master_0 avalon start
set_interface_property avalon_master_0 addressUnits SYMBOLS
set_interface_property avalon_master_0 associatedClock clock
set_interface_property avalon_master_0 associatedReset reset_sink
set_interface_property avalon_master_0 bitsPerSymbol 8
set_interface_property avalon_master_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_master_0 burstcountUnits WORDS
set_interface_property avalon_master_0 doStreamReads false
set_interface_property avalon_master_0 doStreamWrites false
set_interface_property avalon_master_0 holdTime 0
set_interface_property avalon_master_0 linewrapBursts false
set_interface_property avalon_master_0 maximumPendingReadTransactions 0
set_interface_property avalon_master_0 maximumPendingWriteTransactions 0
set_interface_property avalon_master_0 readLatency 0
set_interface_property avalon_master_0 readWaitTime 1
set_interface_property avalon_master_0 setupTime 0
set_interface_property avalon_master_0 timingUnits Cycles
set_interface_property avalon_master_0 writeWaitTime 0
set_interface_property avalon_master_0 ENABLED true
set_interface_property avalon_master_0 EXPORT_OF ""
set_interface_property avalon_master_0 PORT_NAME_MAP ""
set_interface_property avalon_master_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_master_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_master_0 AM_readDataValid readdatavalid Input 1
add_interface_port avalon_master_0 AM_readData readdata Input 32
add_interface_port avalon_master_0 AM_waitRequest waitrequest Input 1
add_interface_port avalon_master_0 AM_beginBurst beginbursttransfer Output 1
add_interface_port avalon_master_0 AM_burstCount burstcount Output burstbits
add_interface_port avalon_master_0 AM_read read Output 1
add_interface_port avalon_master_0 AM_address address Output addrbits


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock
set_interface_property avalon_slave_0 associatedReset reset_sink
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 maximumPendingWriteTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitTime 1
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 address_S address Input 2
add_interface_port avalon_slave_0 write_S write Input 1
add_interface_port avalon_slave_0 writedata_S writedata Input 16
add_interface_port avalon_slave_0 read_S read Input 1
add_interface_port avalon_slave_0 readdata_S readdata Output 16
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0
