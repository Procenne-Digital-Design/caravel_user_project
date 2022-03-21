# User config
set ::env(DESIGN_NAME) trng_wb_wrapper

# Change if needed
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/trng/trng_wb_wrapper.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/trng/ringosc_macro.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/trng/ring_osc2x13.v"

# Black-box verilog and views
# set ::env(VERILOG_FILES_BLACKBOX) "\
# 	$::env(DESIGN_DIR)/../../verilog/rtl/trng/ringosc_macro.v"

# set ::env(EXTRA_LEFS) "\
# 	$::env(DESIGN_DIR)/../../lef/ringosc_macro.lef"

# set ::env(EXTRA_GDS_FILES) "\
# 	$::env(DESIGN_DIR)/../../gds/ringosc_macro.gds"

# Fill this
set ::env(CLOCK_PERIOD) "25.0"
set ::env(CLOCK_PORT) "wb_clk_i"

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

# set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
# if { [file exists $filename] == 1} {
# 	source $filename
# }

# set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(SDC_FILE) $::env(DESIGN_DIR)/base.sdc
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc

# Preserve manually instantiated stdcells.
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Disable optimizations and CTS to preserve our hand picked stdcells.
set ::env(SYNTH_BUFFERING) 0
set ::env(SYNTH_SIZING) 0
set ::env(SYNTH_SHARE_RESOURCES) 0
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 0

set ::env(DESIGN_IS_CORE) 0

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 200 300"

set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.50

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]
set ::env(RT_MAX_LAYER) {met4}
set ::env(DIODE_INSERTION_STRATEGY) 4
