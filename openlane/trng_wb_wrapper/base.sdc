# Randsack digital top macro timing constraints.
#
# SPDX-FileCopyrightText: (c) 2021 Harrison Pham <harrison@harrisonpham.com>
# SPDX-License-Identifier: Apache-2.0
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

set ::env(WB_CLOCK_PERIOD)    "25"
set ::env(WB_CLOCK_PORT)      "wb_clk_i"

set ::env(RING0_CLOCK_PERIOD) "10"
set ::env(RING0_CLOCK_PORT)   "clockp[0]"

set ::env(RING1_CLOCK_PERIOD) "10"
set ::env(RING1_CLOCK_PORT)   "clockp[1]"

set ::env(RING2_CLOCK_PERIOD) "10"
set ::env(RING2_CLOCK_PORT)   "clockp[2]"

set ::env(RING3_CLOCK_PERIOD) "10"
set ::env(RING3_CLOCK_PORT)   "clockp[3]"

# if {[info exists ::env(WB_CLOCK_PORT)] && $::env(WB_CLOCK_PORT) != ""} {
#     create_clock [get_ports $::env(WB_CLOCK_PORT)]  -name $::env(WB_CLOCK_PORT)  -period $::env(CLOCK_PERIOD)
# } else {
#     create_clock -name VIRTUAL_CLK -period $::env(CLOCK_PERIOD)
#     set ::env(WB_CLOCK_PORT) VIRTUAL_CLK
# }

# set input_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_PCT)]
# set output_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_PCT)]
# puts "\[INFO\]: Setting output delay to: $output_delay_value"
# puts "\[INFO\]: Setting input delay to: $input_delay_value"

# set_max_fanout $::env(SYNTH_MAX_FANOUT) [current_design]

# set clk_indx [lsearch [all_inputs] [get_port $::env(WB_CLOCK_PORT)]]
#set rst_indx [lsearch [all_inputs] [get_port resetn]]
# set all_inputs_wo_clk [lreplace [all_inputs] $clk_indx $clk_indx]
#set all_inputs_wo_clk_rst [lreplace $all_inputs_wo_clk $rst_indx $rst_indx]
# set all_inputs_wo_clk_rst $all_inputs_wo_clk

# TODO set this as parameter
# set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
# set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
# puts "\[INFO\]: Setting load to: $cap_load"
# set_load  $cap_load [all_outputs]

# Extra clocks for macros.
# NOTE: These don't need any input/output delays since this design just uses it for clock counting.
create_clock [get_ports $::env(RING0_CLOCK_PORT)] -name $::env(RING0_CLOCK_PORT) -period $::env(RING0_CLOCK_PERIOD)
create_clock [get_ports $::env(RING1_CLOCK_PORT)] -name $::env(RING1_CLOCK_PORT) -period $::env(RING1_CLOCK_PERIOD)
create_clock [get_ports $::env(RING2_CLOCK_PORT)] -name $::env(RING2_CLOCK_PORT) -period $::env(RING2_CLOCK_PERIOD)
create_clock [get_ports $::env(RING3_CLOCK_PORT)] -name $::env(RING3_CLOCK_PORT) -period $::env(RING3_CLOCK_PERIOD)

set_false_path -from [get_clocks $::env(WB_CLOCK_PORT)] -to [get_clocks $::env(RING0_CLOCK_PORT)]
set_false_path -from [get_clocks $::env(WB_CLOCK_PORT)] -to [get_clocks $::env(RING1_CLOCK_PORT)]
set_false_path -from [get_clocks $::env(WB_CLOCK_PORT)] -to [get_clocks $::env(RING2_CLOCK_PORT)]
set_false_path -from [get_clocks $::env(WB_CLOCK_PORT)] -to [get_clocks $::env(RING3_CLOCK_PORT)]

set_false_path -from [get_clocks $::env(RING0_CLOCK_PORT)] -to [get_clocks $::env(WB_CLOCK_PORT)]
set_false_path -from [get_clocks $::env(RING1_CLOCK_PORT)] -to [get_clocks $::env(WB_CLOCK_PORT)]
set_false_path -from [get_clocks $::env(RING2_CLOCK_PORT)] -to [get_clocks $::env(WB_CLOCK_PORT)]
set_false_path -from [get_clocks $::env(RING3_CLOCK_PORT)] -to [get_clocks $::env(WB_CLOCK_PORT)]
