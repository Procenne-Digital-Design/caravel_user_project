# User config

set ::env(DESIGN_NAME) wbuart

# Change if needed
set ::env(VERILOG_FILES) "\
        $::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
        $::env(DESIGN_DIR)/../../verilog/rtl/wbuart32/*.v"

# Fill this
set ::env(CLOCK_PERIOD) "25.0"
set ::env(CLOCK_PORT) "i_clk"

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

# Preserve gate instances in the rtl of the design.

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 400 800"

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) 0.60

set ::env(ROUTING_CORES) "8"
set ::env(RT_MAX_LAYER) {met4}
set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]
set ::env(DIODE_INSERTION_STRATEGY) 4 
# If you're going to use multiple power domains, then disable cvc run.
set ::env(RUN_CVC) 1
