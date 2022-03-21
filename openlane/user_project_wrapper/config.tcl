# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

# Base Configurations. Don't Touch
# section begin

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1

#set ::env(PDN_CFG) $script_dir/pdn.tcl

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/user_project_wrapper.v"

set ::env(SYNTH_READ_BLACKBOX_LIB) 1

## Clock configurations
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "wb_clk_i"

set ::env(CLOCK_PERIOD) "25"

## Internal Macros
### Macro PDN Connections
set ::env(FP_PDN_MACRO_HOOKS) "\
	mprj vccd1 vssd1 \
	u_sram1_2kb vccd1 vssd1" 
### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro.cfg

### Black-box verilog and views
set ::env(KLAYOUT_XOR_GDS) 0
set ::env(RUN_KLAYOUT_XOR) 0
set ::env(MAGIC_DRC_USE_GDS) 0

set ::env(VERILOG_FILES_BLACKBOX) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/sram/sky130_sram_2kbyte_1rw1r_32x512_8.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/user_proj_example.v \ 
	$::env(DESIGN_DIR)/../../verilog/rtl/trng/trng_wb_wrapper.v" 

set ::env(EXTRA_LEFS) "\
	$::env(DESIGN_DIR)/../../lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef \
	$::env(DESIGN_DIR)/../../lef/user_proj_example.lef \
	$::env(DESIGN_DIR)/../../lef/trng_wb_wrapper.lef"


set ::env(EXTRA_GDS_FILES) "\
	$::env(DESIGN_DIR)/../../gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds \
	$::env(DESIGN_DIR)/../../gds/user_proj_example.gds \
	$::env(DESIGN_DIR)/../../gds/trng_wb_wrapper.gds"


set ::env(EXTRA_LIBS) "\
	$::env(DESIGN_DIR)/../../lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib"


set ::env(GLB_RT_OBS) "li1  500.00 2000.00 1183.1 2416.54, \
               	       met1 500.00 2000.00 1183.1 2416.54, \
	                   met2 500.00 2000.00 1183.1 2416.54, \
	                   met3 500.00 2000.00 1183.1 2416.54, \
	                   met4 500.00 2000.00 1183.1 2416.54" 

set ::env(MAGIC_DRC_USE_GDS) 0
#set ::env(GLB_RT_MAXLAYER) 4
set ::env(RT_MAX_LAYER) {met4}

#set ::env(GLB_RT_L2_ADJUSTMENT) 0.9
#set ::env(GLB_RT_L3_ADJUSTMENT) 0.7

# disable pdn check nodes becuase it hangs with multiple power domains.
# any issue with pdn connections will be flagged with LVS so it is not a critical check.
set ::env(FP_PDN_CHECK_NODES) 0 

# The following is because there are no std cells in the example wrapper project.
set ::env(SYNTH_TOP_LEVEL) 1
set ::env(PL_RANDOM_GLB_PLACEMENT) 1

#set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
#set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
#set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
#set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0


#set ::env(GLB_RT_ALLOW_CONGESTION) "1"
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(FP_PDN_ENABLE_RAILS) 0

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0

set ::env(QUIT_ON_LVS_ERROR) 0
set ::env(ROUTING_CORES) 8
