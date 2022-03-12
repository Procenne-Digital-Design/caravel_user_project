//-----------------------------------------------------------------------------
// @file      wb_interconnect.vhd
//
// @brief     Convey wishbone signals to corresponding module.
//
// @details   1 masters and 4 slaves share bus Wishbone connection
//               M0 - WB_PORT
//               S0 - SRAM
//               S1 - UART
//               S2 - TRNG
//               S3 - SPI 
//			  
// @author    Sukru Uzun <sukru.uzun@procenne.com>
// @date      10.03.2022
//
// @todo 	  add other modules 
// @warning	  be careful about chip select
//
// @project   https://github.com/Procenne-Digital-Design/secure-memory.git
//
// @revision :
//    0.1 - 10 March 2022, Sukru Uzun
//          initial version
//-----------------------------------------------------------------------------

module wb_interconnect
(
`ifdef USE_POWER_PINS
    input logic            vccd1,    // User area 1 1.8V supply
    input logic            vssd1,    // User area 1 digital ground
`endif
    input logic		       clk_i,
    input logic            rst_n,

    // Master 0 Interface
    input   logic [31:0]   m0_wb_dat_i,
    input   logic [31:0]   m0_wb_adr_i,
    input   logic [3:0]    m0_wb_sel_i,
    input   logic          m0_wb_we_i,
    input   logic          m0_wb_cyc_i,
    input   logic          m0_wb_stb_i,
    output  wire [31:0]    m0_wb_dat_o,
    output  wire	       m0_wb_ack_o,
    output  wire	       m0_wb_err_o,

    // Slave 0 Interface
    input	logic [31:0]   s0_wb_dat_i,
    input	logic 	       s0_wb_ack_i,
    output	wire  [31:0]   s0_wb_dat_o,
    output	wire  [8:0]	   s0_wb_adr_o,
    output	wire  [3:0]	   s0_wb_sel_o,
    output	wire  	       s0_wb_we_o,
    output	wire  	       s0_wb_cyc_o,
    output	wire  	       s0_wb_stb_o,

    // Slave 1 Interface
    input	logic [31:0]   s1_wb_dat_i,
    input	logic 	       s1_wb_ack_i,
    output	wire  [31:0]   s1_wb_dat_o,
    output	wire  [10:0]   s1_wb_adr_o,
    output	wire  [3:0]	   s1_wb_sel_o,
    output	wire  	       s1_wb_we_o,
    output	wire  	       s1_wb_cyc_o,
    output	wire  	       s1_wb_stb_o,

    // Slave 2 Interface
    input	logic [31:0]   s2_wb_dat_i,
    input	logic 	       s2_wb_ack_i,
    output	wire  [31:0]   s2_wb_dat_o,
    output	wire  [10:0]   s2_wb_adr_o,
    output	wire  [3:0]    s2_wb_sel_o,
    output	wire  	       s2_wb_we_o,
    output	wire  	       s2_wb_cyc_o,
    output	wire  	       s2_wb_stb_o,

    // Slave 3 Interface
    input	logic [31:0]   s3_wb_dat_i,
    input	logic 	       s3_wb_ack_i,
    output	wire  [31:0]   s3_wb_dat_o,
    output	wire  [10:0]   s3_wb_adr_o,
    output	wire  [3:0]    s3_wb_sel_o,
    output	wire  	       s3_wb_we_o,
    output	wire  	       s3_wb_cyc_o,
     output	wire  	       s3_wb_stb_o
);

wire [31:0] m0_wb_wr_wb_dat = m0_wb_dat_i;
wire [31:0] m0_wb_wr_wb_adr = {m0_wb_adr_i[31:2],2'b00};
wire [3:0]	m0_wb_wr_wb_sel = m0_wb_sel_i;
wire  	    m0_wb_wr_wb_we  = m0_wb_we_i;
wire  	    m0_wb_wr_wb_cyc = m0_wb_cyc_i;
wire  	    m0_wb_wr_wb_stb = m0_wb_stb_i;
wire [1:0]  m0_wb_wr_wb_tid = m0_wb_tid_i; // target id

wire [31:0] s_bus_wr_wb_dat;
wire [31:0] s_bus_wr_wb_adr;
wire [3:0]	s_bus_wr_wb_sel;
wire  	    s_bus_wr_wb_we;
wire  	    s_bus_wr_wb_cyc;
wire  	    s_bus_wr_wb_stb;
wire [1:0]  s_bus_wr_wb_tid; // target id

wire [31:0] s_bus_rd_wb_dat = (s_wb_tid == 2'b00) ? s0_wb_dat_i :
                              (s_wb_tid == 2'b01) ? s1_wb_dat_i :
                              (s_wb_tid == 2'b10) ? s2_wb_dat_i : 
                              s3_wb_dat_i;
wire        s_bus_rd_wb_ack = (s_wb_tid == 2'b00) ? s0_wb_ack_i :
                              (s_wb_tid == 2'b01) ? s1_wb_ack_i :
                              (s_wb_tid == 2'b10) ? s2_wb_ack_i : 
                              s3_wb_ack_i;
wire        s_bus_rd_wb_err = 1'b0;

//-------------------------------------------------------------------
// EXTERNAL MEMORY MAP
// 0x0000_0000 to 0x0000_0FFF  - SRAM
// 0x0000_1000 to 0x0000_1FFF  - UART
// 0x0000_2000 to 0x0000_2FFF  - TRNG
// 0x0000_3000 to 0x0000_3FFF  - SPI
// ------------------------------------------------------------------
wire [1:0] m0_wb_tid_i = m0_wb_adr_i[13:12];

// Generate Multiplexed Slave Interface based on target Id
wire [1:0] s_wb_tid = s_bus_wr_wb_tid; // to fix iverilog warning

//----------------------------------------
// Slave Mapping
// ---------------------------------------
assign s0_wb_dat_o = (s_wb_tid == 2'b00) ? s_bus_wr_wb_dat : 2'b00;
assign s0_wb_adr_o = (s_wb_tid == 2'b00) ? s_bus_wr_wb_adr : 2'b00;
assign s0_wb_sel_o = (s_wb_tid == 2'b00) ? s_bus_wr_wb_sel : 2'b00;
assign s0_wb_we_o  = (s_wb_tid == 2'b00) ? s_bus_wr_wb_we  : 2'b00;
assign s0_wb_cyc_o = (s_wb_tid == 2'b00) ? s_bus_wr_wb_cyc : 2'b00;
assign s0_wb_stb_o = (s_wb_tid == 2'b00) ? s_bus_wr_wb_stb : 2'b00;

assign s1_wb_dat_o = (s_wb_tid == 2'b01) ? s_bus_wr_wb_dat : 2'b00;
assign s1_wb_adr_o = (s_wb_tid == 2'b01) ? s_bus_wr_wb_adr : 2'b00;
assign s1_wb_sel_o = (s_wb_tid == 2'b01) ? s_bus_wr_wb_sel : 2'b00;
assign s1_wb_we_o  = (s_wb_tid == 2'b01) ? s_bus_wr_wb_we  : 2'b00;
assign s1_wb_cyc_o = (s_wb_tid == 2'b01) ? s_bus_wr_wb_cyc : 2'b00;
assign s1_wb_stb_o = (s_wb_tid == 2'b01) ? s_bus_wr_wb_stb : 2'b00;

assign s2_wb_dat_o = (s_wb_tid == 2'b10) ? s_bus_wr_wb_dat : 2'b00;
assign s2_wb_adr_o = (s_wb_tid == 2'b10) ? s_bus_wr_wb_adr : 2'b00;
assign s2_wb_sel_o = (s_wb_tid == 2'b10) ? s_bus_wr_wb_sel : 2'b00;
assign s2_wb_we_o  = (s_wb_tid == 2'b10) ? s_bus_wr_wb_we  : 2'b00;
assign s2_wb_cyc_o = (s_wb_tid == 2'b10) ? s_bus_wr_wb_cyc : 2'b00;
assign s2_wb_stb_o = (s_wb_tid == 2'b10) ? s_bus_wr_wb_stb : 2'b00;

assign s3_wb_dat_o = (s_wb_tid == 2'b11) ? s_bus_wr_wb_dat : 2'b00;
assign s3_wb_adr_o = (s_wb_tid == 2'b11) ? s_bus_wr_wb_adr : 2'b00;
assign s3_wb_sel_o = (s_wb_tid == 2'b11) ? s_bus_wr_wb_sel : 2'b00;
assign s3_wb_we_o  = (s_wb_tid == 2'b11) ? s_bus_wr_wb_we  : 2'b00;
assign s3_wb_cyc_o = (s_wb_tid == 2'b11) ? s_bus_wr_wb_cyc : 2'b00;
assign s3_wb_stb_o = (s_wb_tid == 2'b11) ? s_bus_wr_wb_stb : 2'b00;

// Stagging FF to break write and read timing path
wb_signal_reg u_m_wb_stage(
    .clk_i           (clk_i),
    .rst_n           (rst_n),

    // WishBone Input master I/P
    .m_wb_dat_i      (m0_wb_wr_wb_dat),
    .m_wb_adr_i      (m0_wb_wr_wb_adr),
    .m_wb_sel_i      (m0_wb_wr_wb_sel),
    .m_wb_we_i       (m0_wb_wr_wb_we ),
    .m_wb_cyc_i      (m0_wb_wr_wb_cyc),
    .m_wb_stb_i      (m0_wb_wr_wb_stb),
    .m_wb_tid_i      (m0_wb_wr_wb_tid),
    .m_wb_dat_o      (m0_wb_dat_o),
    .m_wb_ack_o      (m0_wb_ack_o),
    .m_wb_err_o      (m0_wb_err_o),

    // Slave Interface
    .s_wb_dat_i      (s_bus_rd_wb_dat),
    .s_wb_ack_i      (s_bus_rd_wb_ack),
    .s_wb_err_i      (s_bus_rd_wb_err),
    .s_wb_dat_o      (s_bus_wr_wb_dat),
    .s_wb_adr_o      (s_bus_wr_wb_adr),
    .s_wb_sel_o      (s_bus_wr_wb_sel),
    .s_wb_we_o       (s_bus_wr_wb_we ),
    .s_wb_cyc_o      (s_bus_wr_wb_cyc),
    .s_wb_stb_o      (s_bus_wr_wb_stb),
    .s_wb_tid_o      (s_bus_wr_wb_tid)
);

endmodule
