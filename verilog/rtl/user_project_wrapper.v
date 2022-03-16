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
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
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

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

parameter WB_WIDTH        = 32; // WB ADDRESS/DATA WIDTH
parameter SRAM_ADDR_WD    = 8;
parameter SRAM_DATA_WD    = 32;
parameter UART_ADDR_WD    = 2;
parameter UART_DATA_WD    = 32;

//---------------------------------------------------------------------
// WB Master Interface
//---------------------------------------------------------------------
wire rst_n = ~wb_rst_i;
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




// Port A
wire                      sram_clk_a;
wire                      sram_csb_a;
wire [SRAM_ADDR_WD-1:0]   sram_addr_a;
wire [SRAM_DATA_WD-1:0]   sram_dout_a;

// Port B
wire                      sram_clk_b;
wire                      sram_csb_b;
wire                      sram_web_b;
wire [SRAM_DATA_WD/8-1:0] sram_mask_b;
wire [SRAM_ADDR_WD-1:0]   sram_addr_b;
wire [SRAM_DATA_WD-1:0]   sram_din_b;

wb_interconnect interconnect
(
`ifdef USE_POWER_PINS
    .vccd1(vccd1),    // User area 1 1.8V supply
    .vssd1(vssd1),    // User area 1 digital ground
`endif
    .clk_i(wb_clk_i),
    .rst_n(rst_n),

       // Master 0 Interface
    .m0_wb_dat_i(wbs_dat_i),
    .m0_wb_adr_i(wbs_adr_i),
    .m0_wb_sel_i(wbs_sel_i),
    .m0_wb_we_i (wbs_we_i),
    .m0_wb_cyc_i(wbs_cyc_i),
    .m0_wb_stb_i(wbs_stb_i),
    .m0_wb_dat_o(wbs_dat_o),
    .m0_wb_ack_o(wbs_ack_o),

    // Slave 0 Interface
    .s0_wb_dat_i(s0_wb_dat_o),
    .s0_wb_ack_i(s0_wb_ack_o),
    .s0_wb_dat_o(s0_wb_dat_i),
    .s0_wb_adr_o(s0_wb_adr_i),
    .s0_wb_sel_o(s0_wb_sel_i),
    .s0_wb_we_o (s0_wb_we_i),
    .s0_wb_cyc_o(s0_wb_cyc_i),
    .s0_wb_stb_o(s0_wb_stb_i),

    // Slave 1 Interface
    .s1_wb_dat_i(s1_wb_dat_o),
    .s1_wb_ack_i(s1_wb_ack_o),
    .s1_wb_dat_o(s1_wb_dat_i),
    .s1_wb_adr_o(s1_wb_adr_i),
    .s1_wb_sel_o(s1_wb_sel_i),
    .s1_wb_we_o (s1_wb_we_i),
    .s1_wb_cyc_o(s1_wb_cyc_i),
    .s1_wb_stb_o(s1_wb_stb_i)

    // Slave 2 Interface
    // .s2_wb_dat_i(),
    // .s2_wb_ack_i(),
    // .s2_wb_dat_o(),
    // .s2_wb_adr_o(),
    // .s2_wb_sel_o(),
    // .s2_wb_we_o (),
    // .s2_wb_cyc_o(),
    // .s2_wb_stb_o(),

    // Slave 3 Interface
    // .s3_wb_dat_i(),
    // .s3_wb_ack_i(),
    // .s3_wb_dat_o(),
    // .s3_wb_adr_o(),
    // .s3_wb_sel_o(),
    // .s3_wb_we_o (),
    // .s3_wb_cyc_o(),
    // .s3_wb_stb_o()
);

sram_wb_wrapper #(
`ifndef SYNTHESIS
    .SRAM_ADDR_WD   (SRAM_ADDR_WD),
    .SRAM_DATA_WD   (SRAM_DATA_WD) 
`endif
    )
    wb_wrapper0 (
`ifdef USE_POWER_PINS
    .vccd1 (vccd1), // User area 1 1.8V supply
    .vssd1 (vssd1), // User area 1 digital ground
`endif
    .rst_n(rst_n),
    // Wishbone Interface
    .wb_clk_i(wb_clk_i),     // System clock
    .wb_cyc_i(s0_wb_cyc_i),  // cycle enable
    .wb_stb_i(s0_wb_stb_i),  // strobe
    .wb_adr_i(s0_wb_adr_i),  // address
    .wb_we_i (s0_wb_we_i),   // write
    .wb_dat_i(s0_wb_dat_i),  // data output
    .wb_sel_i(s0_wb_sel_i),  // byte enable
    // .wb_dat_o(s0_wb_dat_o),  // data input
    .wb_ack_o(s0_wb_ack_o),  // acknowlegement
    // SRAM Interface
    // Port A
    .sram_csb_a(sram_csb_a),
    .sram_addr_a(sram_addr_a),

    // Port B
    .sram_csb_b(sram_csb_b),
    .sram_web_b(sram_web_b),
    .sram_mask_b(sram_mask_b),
    .sram_addr_b(sram_addr_b),
    .sram_din_b(sram_din_b)
);

sky130_sram_1kbyte_1rw1r_32x256_8 u_sram1_1kb(
`ifdef USE_POWER_PINS
    .vccd1 (vccd1), // User area 1 1.8V supply
    .vssd1 (vssd1), // User area 1 digital ground
`endif
    // Port 0: RW
    .clk0     (wb_clk_i),
    .csb0     (sram_csb_b),
    .web0     (sram_web_b),
    .wmask0   (sram_mask_b),
    .addr0    (sram_addr_b),
    .din0     (sram_din_b),
    .dout0    (),   // dont read from Port B
    // Port 1: R
    .clk1     (wb_clk_i),
    .csb1     (sram_csb_a),
    .addr1    (sram_addr_a),
    .dout1    (sram_dout_a)
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
  .i_uart_rx (io_in[15] ),
  .o_uart_tx (io_out[16] ),
  .i_cts_n (1'b0 ),
  .o_rts_n ( ),
  .o_uart_rx_int ( ),
  .o_uart_tx_int ( ),
  .o_uart_rxfifo_int ( ),
  .o_uart_txfifo_int  ( )
);
assign io_oeb = {(`MPRJ_IO_PADS){1'b0}};

endmodule	// user_project_wrapper

`default_nettype wire
