# User config
set ::env(DESIGN_NAME) wb_interconnect

# Change if needed
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/wb_interconnect/wb_interconnect.sv"

# Fill this
set ::env(CLOCK_PERIOD) "20.0"
set ::env(CLOCK_PORT) "clk_i"

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"


# Preserve gate instances in the rtl of the design.


set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 200 400"

set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.50

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]

set ::env(RT_MAX_LAYER) {met4}
set ::env(DIODE_INSERTION_STRATEGY) 4
set ::env(RUN_CVC) 1
set ::env(ROUTING_CORES) "8"
