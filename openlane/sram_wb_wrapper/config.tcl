# User config
set ::env(DESIGN_NAME) sram_wb_wrapper

# Change if needed
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/sram/sram_wb_wrapper.sv"

# Fill this
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "wb_clk_i"

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

# Black-box verilog and views
# set ::env(VERILOG_FILES_BLACKBOX) "\
# 	$::env(DESIGN_DIR)/../../verilog/rtl/sram/sky130_sram_1kbyte_1rw1r_32x256_8.v"

# set ::env(EXTRA_LEFS) "\
# 	$::env(DESIGN_DIR)/../../lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef"

# set ::env(EXTRA_GDS_FILES) "\
# 	$::env(DESIGN_DIR)/../../gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds"

# Preserve gate instances in the rtl of the design.

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 100 333"

set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.50

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]
set ::env(RT_MAX_LAYER) {met4}
set ::env(DIODE_INSERTION_STRATEGY) 4
set ::env(RUN_CVC) 1
set ::env(ROUTING_CORES) "8"
