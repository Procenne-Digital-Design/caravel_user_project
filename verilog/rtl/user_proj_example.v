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

module user_proj_example #(parameter BITS = 32) (
`ifdef USE_POWER_PINS
  inout                      vccd1      , // User area 1 1.8V supply
  inout                      vssd1      , // User area 1 digital ground
`endif
  // Wishbone Slave ports (WB MI A)
  input                      wb_clk_i   ,
  input                      wb_rst_i   ,
  input                      wbs_stb_i  ,
  input                      wbs_cyc_i  ,
  input                      wbs_we_i   ,
  input  [              3:0] wbs_sel_i  ,
  input  [             31:0] wbs_dat_i  ,
  input  [             31:0] wbs_adr_i  ,
  output                     wbs_ack_o  ,
  output [             31:0] wbs_dat_o  ,
  // Logic Analyzer Signals
  input  [            127:0] la_data_in ,
  output [            127:0] la_data_out,
  input  [            127:0] la_oenb    ,
  // IOs
  input  [`MPRJ_IO_PADS-1:0] io_in      ,
  output [`MPRJ_IO_PADS-1:0] io_out     ,
  output [`MPRJ_IO_PADS-1:0] io_oeb     ,
  // IRQ
  output [              2:0] irq        ,
  // Port A
  output                     sram_csb_a ,
  output [              8:0] sram_addr_a,
  input  [             31:0] sram_dout_a,
  // Port B
  output                     sram_csb_b ,
  output                     sram_web_b ,
  output [              3:0] sram_mask_b,
  output [              8:0] sram_addr_b,
  output [             31:0] sram_din_b,
  //TRNG
  output        trng_wb_cyc_o, 
  output        trng_wb_stb_o,
  output [8:0]  trng_wb_adr_o,
  output        trng_wb_we_o ,
  input  [31:0] trng_wb_dat_i,
  output [31:0] trng_wb_dat_o,
  input         trng_wb_ack_i,
  input  [31:0] trng_buffer_i

);
  /*--------------------------------------*/
  /* User project is instantiated  here   */
  /*--------------------------------------*/

  localparam WB_WIDTH     = 32; // WB ADDRESS/DATA WIDTH
  localparam SRAM_ADDR_WD = 9 ;
  localparam SRAM_DATA_WD = 32;
  localparam UART_ADDR_WD = 2 ;
  localparam UART_DATA_WD = 32;

  //---------------------------------------------------------------------
  // WB Master Interface
  //---------------------------------------------------------------------
  wire [`MPRJ_IO_PADS-1:0] io_in ;
  wire [`MPRJ_IO_PADS-1:0] io_out;
  wire [`MPRJ_IO_PADS-1:0] io_oeb;

  //---------------------------------------------------------------------
  // SRAM
  //---------------------------------------------------------------------
  wire                      s0_wb_cyc_i;
  wire                      s0_wb_stb_i;
  wire [  SRAM_ADDR_WD-1:0] s0_wb_adr_i;
  wire                      s0_wb_we_i ;
  wire [  SRAM_DATA_WD-1:0] s0_wb_dat_i;
  wire [SRAM_DATA_WD/8-1:0] s0_wb_sel_i;
  wire [  SRAM_DATA_WD-1:0] s0_wb_dat_o;
  wire                      s0_wb_ack_o;


  //---------------------------------------------------------------------
  // UART
  //---------------------------------------------------------------------
  wire                      s1_wb_cyc_i;
  wire                      s1_wb_stb_i;
  wire [               8:0] s1_wb_adr_o;
  wire                      s1_wb_we_i ;
  wire [WB_WIDTH-1:0] s1_wb_dat_i;
  wire [WB_WIDTH/8-1:0] s1_wb_sel_i;
  wire [WB_WIDTH-1:0] s1_wb_dat_o;
  wire                      s1_wb_ack_o;

  //---------------------------------------------------------------------
  // SPI
  //---------------------------------------------------------------------
  wire                s3_wb_cyc_i;
  wire                s3_wb_stb_i;
  wire [         8:0] s3_wb_adr_o;
  wire                s3_wb_we_i ;
  wire [WB_WIDTH-1:0] s3_wb_dat_i;
  //wire [UART_DATA_WD/8-1:0] s3_wb_sel_i;
  wire [WB_WIDTH-1:0] s3_wb_dat_o;
  wire                s3_wb_ack_o;


  wire alarm;
  wire alarm_set;
  wire master_key_ready;
  wire [31:0] o_LFSR_Data;

  wire [31:0] trng_i = 32'd0;



  wb_interconnect interconnect (
    `ifdef USE_POWER_PINS
    .vccd1      (vccd1      ), // User area 1 1.8V supply
    .vssd1      (vssd1      ), // User area 1 digital ground
    `endif
    .clk_i      (wb_clk_i   ),
    .rst        (wb_rst_i   ),
    
    // Master 0 Interface
    .m0_wb_dat_i(wbs_dat_i  ),
    .m0_wb_adr_i(wbs_adr_i  ),
    .m0_wb_sel_i(wbs_sel_i  ),
    .m0_wb_we_i (wbs_we_i   ),
    .m0_wb_cyc_i(wbs_cyc_i  ),
    .m0_wb_stb_i(wbs_stb_i  ),
    .m0_wb_dat_o(wbs_dat_o  ),
    .m0_wb_ack_o(wbs_ack_o  ),
    
    // Slave 0 Interface
    .s0_wb_dat_i(s0_wb_dat_o),
    .s0_wb_ack_i(s0_wb_ack_o),
    .s0_wb_dat_o(s0_wb_dat_i),
    .s0_wb_adr_o(s0_wb_adr_i),
    .s0_wb_sel_o(s0_wb_sel_i),
    .s0_wb_we_o (s0_wb_we_i ),
    .s0_wb_cyc_o(s0_wb_cyc_i),
    .s0_wb_stb_o(s0_wb_stb_i),
    
    // Slave 1 Interface
    .s1_wb_dat_i(s1_wb_dat_o),
    .s1_wb_ack_i(s1_wb_ack_o),
    .s1_wb_dat_o(s1_wb_dat_i),
    .s1_wb_adr_o(s1_wb_adr_o),
    .s1_wb_sel_o(s1_wb_sel_i),
    .s1_wb_we_o (s1_wb_we_i ),
    .s1_wb_cyc_o(s1_wb_cyc_i),
    .s1_wb_stb_o(s1_wb_stb_i),
    
    // Slave 2 Interface
    .s2_wb_dat_i(trng_wb_dat_i),
    .s2_wb_ack_i(trng_wb_ack_i),
    .s2_wb_dat_o(trng_wb_dat_o),
    .s2_wb_adr_o(trng_wb_adr_o),
    .s2_wb_sel_o(),
    .s2_wb_we_o (trng_wb_we_o),
    .s2_wb_cyc_o(trng_wb_cyc_o),
    .s2_wb_stb_o(trng_wb_stb_o),
    
    // Slave 3 Interface
    .s3_wb_dat_i(s3_wb_dat_o),
    .s3_wb_ack_i(s3_wb_ack_o),
    .s3_wb_dat_o(s3_wb_dat_i),
    .s3_wb_adr_o(s3_wb_adr_o),
    .s3_wb_sel_o(),
    .s3_wb_we_o (s3_wb_we_i ),
    .s3_wb_cyc_o(s3_wb_cyc_i),
    .s3_wb_stb_o(s3_wb_stb_i)
  );


  sram_wb_wrapper #(
    `ifndef SYNTHESIS
    .SRAM_ADDR_WD(SRAM_ADDR_WD),
    .SRAM_DATA_WD(SRAM_DATA_WD)
    `endif
  ) wb_wrapper0 (
    `ifdef USE_POWER_PINS
    .vccd1      (vccd1      ), // User area 1 1.8V supply
    .vssd1      (vssd1      ), // User area 1 digital ground
    `endif
    .rst        (wb_rst_i   ),
    // Wishbone Interface
    .wb_clk_i   (wb_clk_i   ), // System clock
    .wb_cyc_i   (s0_wb_cyc_i), // cycle enable
    .wb_stb_i   (s0_wb_stb_i), // strobe
    .wb_adr_i   (s0_wb_adr_i), // address
    .wb_we_i    (s0_wb_we_i ), // write
    .wb_dat_i   (s0_wb_dat_i), // data output
    .wb_sel_i   (s0_wb_sel_i), // byte enable
    .wb_dat_o   (s0_wb_dat_o),  // data input
    .wb_ack_o   (s0_wb_ack_o), // acknowlegement
    // SRAM Interface
    // Port A
    .sram_csb_a (sram_csb_a ),
    .sram_addr_a(sram_addr_a),
    .sram_dout_a (sram_dout_a),
    // Port B
    .sram_csb_b (sram_csb_b ),
    .sram_web_b (sram_web_b ),
    .sram_mask_b(sram_mask_b),
    .sram_addr_b(sram_addr_b),
    .sram_din_b (sram_din_b ),
    .trng_i(trng_buffer_i),
    .alarm(alarm),
    .master_key_ready(master_key_ready),
    .alarm_set(alarm_set)
  );

  assign io_oeb = {(`MPRJ_IO_PADS){1'b0}};

  

  simpleuartA_wb   
  simpleuartA_wb_dut (
    `ifdef USE_POWER_PINS
    .vccd1      (vccd1      ), // User area 1 1.8V supply
    .vssd1      (vssd1      ), // User area 1 digital ground
    `endif
    .wb_clk_i (wb_clk_i ),
    .wb_rst_i (wb_rst_i ),
    .wb_adr_i (s1_wb_adr_o[1:0]),
    .wb_dat_i (s1_wb_dat_i ),
    .wb_sel_i (s1_wb_sel_i ),
    .wb_we_i  (s1_wb_we_i ),
    .wb_cyc_i (s1_wb_cyc_i ),
    .wb_stb_i (s1_wb_stb_i ),
    .wb_ack_o (s1_wb_ack_o ),
    .wb_dat_o (s1_wb_dat_o ),
    .uart_enabled ( ),
    .ser_tx (io_out[16] ),
    .ser_rx  (io_in[15])
  );


  assign io_out[18] = o_LFSR_Data[0];

  LFSR 
  #(
    .NUM_BITS (32)
  )
  LFSR_dut (
    .i_Clk (wb_clk_i ),
    .i_Enable (1'b1 ),
    .i_alarm_set (alarm_set),
    .i_Seed_DV (trng_wb_cyc_o),
    .i_Seed_Data (trng_buffer_i ),
    .o_LFSR_Data (o_LFSR_Data ),
    .o_LFSR_Done  (),
    .i_LFSR ( io_in[17]),
    .master_key_ready(master_key_ready),
    .i_rst(wb_rst_i),
    .o_alarm(alarm)
  );




  tiny_spi #(
    .BAUD_WIDTH(0),
    .BAUD_DIV  (8),
    .SPI_MODE  (0),
    .BC_WIDTH  (3),
    .DIV_WIDTH (2),
    .IDLE      (0)
  ) tiny_spi_inst (
    `ifdef USE_POWER_PINS
    .vccd1(vccd1           ), // User area 1 1.8V supply
    .vssd1(vssd1           ), // User area 1 digital ground
    `endif
    .rst_i(wb_rst_i        ),
    .clk_i(wb_clk_i        ),
    .stb_i(s3_wb_stb_i     ),
    .we_i (s3_wb_we_i      ),
    .dat_o(s3_wb_dat_o     ),
    .dat_i(s3_wb_dat_i     ),
    .int_o(                ),
    .adr_i(s3_wb_adr_o[2:0]),
    .cyc_i(s3_wb_cyc_i     ),
    .ack_o(s3_wb_ack_o     ),
    .MOSI (io_out[12]      ),
    .SCLK (io_out[13]      ),
    .MISO (io_in[14]       )
  );


endmodule
`default_nettype wire
