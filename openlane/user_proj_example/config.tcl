# User config
set ::env(DESIGN_NAME) user_proj_example

set ::env(SDC_FILE) $::env(DESIGN_DIR)/base.sdc
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc

set script_dir [file dirname [file normalize [info script]]]

# Change if needed
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/wb_interconnect/wb_interconnect.sv \
	$::env(DESIGN_DIR)/../../verilog/rtl/user_proj_example.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/sram/sram_wb_wrapper_xor.sv \
	$::env(DESIGN_DIR)/../../verilog/rtl/aes/aes.v \ 
	$::env(DESIGN_DIR)/../../verilog/rtl/simpleUART/simple_uart.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/spi/tiny_spi.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/security_monitor/lfsr.v"

# Fill this
set ::env(CLOCK_PERIOD) "50.0"
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "wb_clk_i"

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set ::env(DESIGN_IS_CORE) 0

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(SYNTH_MAX_FANOUT) 4
set ::env(SYNTH_DRIVING_CELL) "sky130_fd_sc_hd__inv_8"
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Preserve gate instances in the rtl of the design.

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1000 1500"

#set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.50

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]
#set ::env(GLB_RT_MAXLAYER) 5
set ::env(RT_MAX_LAYER) {met4}
#set ::env(DIODE_INSERTION_STRATEGY) 4
set ::env(RUN_CVC) 1
set ::env(ROUTING_CORES) "8"
