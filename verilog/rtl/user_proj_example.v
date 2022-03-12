// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

parameter WB_WIDTH        = 32; // WB ADDRESS/DARA WIDTH
parameter SRAM_ADDR_WD    = 9;
parameter SRAM_DATA_WD    = 32;
parameter SRAM_ADDR_START = 9'h000;
parameter SRAM_ADDR_END   = 9'h1F8;

parameter UART_ADDR_WD    = 9;
parameter UART_DATA_WD    = 32;
parameter UART_ADDR_START = 9'h000;
parameter UART_ADDR_END   = 9'h1F8;

//---------------------------------------------------------------------
// WB Master Interface
//---------------------------------------------------------------------
wire clk;
wire rst;
wire [`MPRJ_IO_PADS-1:0] io_in;
wire [`MPRJ_IO_PADS-1:0] io_out;
wire [`MPRJ_IO_PADS-1:0] io_oeb;

//---------------------------------------------------------------------
// SRAM
//---------------------------------------------------------------------
wire                       s0_wb_cyc_i;
wire                       s0_wb_stb_i;
wire [SRAM_ADDR_WD-1:0]    s0_wb_adr_i;
wire                       s0_wb_we_i;
wire [SRAM_DATA_WD-1:0]    s0_wb_dat_i;
wire [SRAM_DATA_WD/8-1:0]  s0_wb_sel_i;
wire [SRAM_DATA_WD-1:0]    s0_wb_dat_o;
wire                       s0_wb_ack_o;

//---------------------------------------------------------------------
// UART
//---------------------------------------------------------------------
wire                       s1_wb_cyc_i;
wire                       s1_wb_stb_i;
wire [UART_ADDR_WD-1:0]    s1_wb_adr_i;
wire                       s1_wb_we_i;
wire [UART_DATA_WD-1:0]    s1_wb_dat_i;
wire [UART_DATA_WD/8-1:0]  s1_wb_sel_i;
wire [UART_DATA_WD-1:0]    s1_wb_dat_o;
wire                       s1_wb_ack_o;



wb_interconnect interconnect
(
`ifdef USE_POWER_PINS
    .vccd1(vccd1),    // User area 1 1.8V supply
    .vssd1(vssd1),    // User area 1 digital ground
`endif
    .clk_i(wb_clk_i),
    .rst_n(wb_rst_i),

    // Master 0 Interface
    .m0_wb_dat_i(wbs_dat_i),
    .m0_wb_adr_i(wbs_adr_i),
    .m0_wb_sel_i(wbs_sel_i),
    .m0_wb_we_i (wbs_we_i),
    .m0_wb_cyc_i(wbs_cyc_i),
    .m0_wb_stb_i(wbs_stb_i),
    .m0_wb_dat_o(wbs_dat_o),
    .m0_wb_ack_o(wbs_ack_o),
    .m0_wb_err_o(),

    // Slave 0 Interface
    .s0_wb_dat_i(s0_wb_dat_i),
    .s0_wb_ack_i(s0_wb_ack_o),
    .s0_wb_dat_o(s0_wb_dat_i),
    .s0_wb_adr_o(s0_wb_adr_i),
    .s0_wb_sel_o(s0_wb_sel_i),
    .s0_wb_we_o (s0_wb_we_i),
    .s0_wb_cyc_o(s0_wb_cyc_i),
    .s0_wb_stb_o(s0_wb_stb_i),

    // Slave 1 Interface
    .s1_wb_dat_i(),
    .s1_wb_ack_i(),
    .s1_wb_dat_o(),
    .s1_wb_adr_o(),
    .s1_wb_sel_o(),
    .s1_wb_we_o (),
    .s1_wb_cyc_o(),
    .s1_wb_stb_o(),

    // Slave 2 Interface
    .s2_wb_dat_i(),
    .s2_wb_ack_i(),
    .s2_wb_dat_o(),
    .s2_wb_adr_o(),
    .s2_wb_sel_o(),
    .s2_wb_we_o (),
    .s2_wb_cyc_o(),
    .s2_wb_stb_o(),

    // Slave 3 Interface
    .s3_wb_dat_i(),
    .s3_wb_ack_i(),
    .s3_wb_dat_o(),
    .s3_wb_adr_o(),
    .s3_wb_sel_o(),
    .s3_wb_we_o (),
    .s3_wb_cyc_o(),
    .s3_wb_stb_o()
);

sram_wb_wrapper #(
`ifndef SYNTHESIS
    .SRAM_ADDR_WD   (SRAM_ADDR_WD   ),
    .SRAM_DATA_WD   (SRAM_DATA_WD   ),
    .SRAM_ADDR_START(SRAM_ADDR_START),
    .SRAM_ADDR_END  (SRAM_ADDR_END  ) 
`endif
    )
    wb_wrapper0 (
    .rst_n(wb_rst_i),
    // Wishbone Interface
    .wb_clk_i(wb_clk_i),     // System clock
    .wb_cyc_i(s0_wb_cyc_i),  // cycle enable
    .wb_stb_i(s0_wb_stb_i),  // strobe
    .wb_adr_i(s0_wb_adr_i),  // address
    .wb_we_i (s0_wb_we_i),   // write
    .wb_dat_i(s0_wb_dat_i),  // data output
    .wb_sel_i(s0_wb_sel_i),  // byte enable
    .wb_dat_o(s0_wb_dat_o),  // data input
    .wb_ack_o(s0_wb_ack_o)   // acknowlegement
);


wbuart 
#(
  .INITIAL_SETUP(31'd434 ), // 115200 baudrate for 50MHz clock
  .LGFLEN(4'h4 ),
  .HARDWARE_FLOW_CONTROL_PRESENT(1'b0 )
)
wbuart_dut (
  .i_clk (wb_clk_i ),
  .i_reset (wb_rst_i ),
  .i_wb_cyc (s1_wb_cyc_i ),
  .i_wb_stb (s1_wb_stb_i ),
  .i_wb_we (s1_wb_we_i ),
  .i_wb_addr (s1_wb_adr_i ),
  .i_wb_data (s1_wb_dat_i ),
  .i_wb_sel (s1_wb_sel_i ),
  .o_wb_stall ( ),
  .o_wb_ack (s1_wb_ack_o ),
  .o_wb_data (s1_wb_dat_o ),
  .i_uart_rx (io_in[0] ),
  .o_uart_tx (io_out[0] ),
  .i_cts_n (1'b0 ),
  .o_rts_n ( ),
  .o_uart_rx_int ( ),
  .o_uart_tx_int ( ),
  .o_uart_rxfifo_int ( ),
  .o_uart_txfifo_int  ( )
);


endmodule
`default_nettype wire
