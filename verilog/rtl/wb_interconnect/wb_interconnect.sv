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
    output  logic [31:0]   m0_wb_dat_o,
    output  logic	       m0_wb_ack_o,
    output  logic	       m0_wb_err_o,

    // Slave 0 Interface
    input	logic [31:0]   s0_wb_dat_i,
    input	logic 	       s0_wb_ack_i,
    output	logic [31:0]   s0_wb_dat_o,
    output	logic [7:0]	   s0_wb_adr_o,
    output	logic [3:0]	   s0_wb_sel_o,
    output	logic 	       s0_wb_we_o,
    output	logic 	       s0_wb_cyc_o,
    output	logic 	       s0_wb_stb_o,

    // Slave 1 Interface
    input	logic [31:0]   s1_wb_dat_i,
    input	logic 	       s1_wb_ack_i,
    output	logic [31:0]   s1_wb_dat_o,
    output	logic [10:0]   s1_wb_adr_o,
    output	logic [3:0]	   s1_wb_sel_o,
    output	logic 	       s1_wb_we_o,
    output	logic 	       s1_wb_cyc_o,
    output	logic 	       s1_wb_stb_o,

    // Slave 2 Interface
    input	logic [31:0]   s2_wb_dat_i,
    input	logic 	       s2_wb_ack_i,
    output	logic [31:0]   s2_wb_dat_o,
    output	logic [10:0]   s2_wb_adr_o,
    output	logic [3:0]    s2_wb_sel_o,
    output	logic 	       s2_wb_we_o,
    output	logic 	       s2_wb_cyc_o,
    output	logic 	       s2_wb_stb_o,

    // Slave 3 Interface
    input	logic [31:0]   s3_wb_dat_i,
    input	logic 	       s3_wb_ack_i,
    output	logic [31:0]   s3_wb_dat_o,
    output	logic [10:0]   s3_wb_adr_o,
    output	logic [3:0]    s3_wb_sel_o,
    output	logic 	       s3_wb_we_o,
    output	logic 	       s3_wb_cyc_o,
    output	logic 	       s3_wb_stb_o
);

// WishBone Wr Interface
typedef struct packed {
    logic [31:0] wb_dat;
    logic [31:0] wb_adr;
    logic [3:0]	 wb_sel;
    logic  	     wb_we;
    logic  	     wb_cyc;
    logic  	     wb_stb;
    logic [1:0]  wb_tid; // target id
} type_wb_wr_intf;

// WishBone Rd Interface
typedef struct packed {
    logic [31:0] wb_dat;
    logic        wb_ack;
    logic        wb_err;
} type_wb_rd_intf;

// Master Write Interface
type_wb_wr_intf  m0_wb_wr;

// Master Read Interface
type_wb_rd_intf  m0_wb_rd;

// Slave Write Interface
type_wb_wr_intf  s0_wb_wr;
type_wb_wr_intf  s1_wb_wr;
type_wb_wr_intf  s2_wb_wr;
type_wb_wr_intf  s3_wb_wr;

// Slave Read Interface
type_wb_rd_intf  s0_wb_rd;
type_wb_rd_intf  s1_wb_rd;
type_wb_rd_intf  s2_wb_rd;
type_wb_rd_intf  s3_wb_rd;

type_wb_wr_intf  s_bus_wr;  // Multiplexed Master I/F
type_wb_rd_intf  s_bus_rd;  // Multiplexed Slave I/F

//-------------------------------------------------------------------
// EXTERNAL MEMORY MAP
// 0x0000_0000 to 0x0000_0FFF  - SRAM
// 0x0000_1000 to 0x0000_1FFF  - UART
// 0x0000_2000 to 0x0000_2FFF  - TRNG
// 0x0000_3000 to 0x0000_3FFF  - SPI
// ------------------------------------------------------------------
wire [1:0] m0_wb_tid_i = m0_wb_adr_i[13:12];

//----------------------------------------
// Master Mapping
// ---------------------------------------
assign m0_wb_wr.wb_dat = m0_wb_dat_i;
assign m0_wb_wr.wb_adr = {m0_wb_adr_i[31:2],2'b00};
assign m0_wb_wr.wb_sel = m0_wb_sel_i;
assign m0_wb_wr.wb_we  = m0_wb_we_i;
assign m0_wb_wr.wb_cyc = m0_wb_cyc_i;
assign m0_wb_wr.wb_stb = m0_wb_stb_i;
assign m0_wb_wr.wb_tid = m0_wb_tid_i;

assign m0_wb_dat_o = m0_wb_rd.wb_dat;
assign m0_wb_ack_o = m0_wb_rd.wb_ack;
assign m0_wb_err_o = m0_wb_rd.wb_err;

//----------------------------------------
// Slave Mapping
// -------------------------------------
// 2KB SRAM
assign s0_wb_dat_o = s0_wb_wr.wb_dat;
assign s0_wb_adr_o = s0_wb_wr.wb_adr[8:0];
assign s0_wb_sel_o = s0_wb_wr.wb_sel;
assign s0_wb_we_o  = s0_wb_wr.wb_we;
assign s0_wb_cyc_o = s0_wb_wr.wb_cyc;
assign s0_wb_stb_o = s0_wb_wr.wb_stb;

assign s0_wb_rd.wb_dat = s0_wb_dat_i;
assign s0_wb_rd.wb_ack = s0_wb_ack_i;
assign s0_wb_rd.wb_err = 1'b0;

// UART
assign s1_wb_dat_o = s1_wb_wr.wb_dat;
assign s1_wb_adr_o = s1_wb_wr.wb_adr[10:0];
assign s1_wb_sel_o = s1_wb_wr.wb_sel;
assign s1_wb_we_o  = s1_wb_wr.wb_we;
assign s1_wb_cyc_o = s1_wb_wr.wb_cyc;
assign s1_wb_stb_o = s1_wb_wr.wb_stb;

assign s1_wb_rd.wb_dat = s1_wb_dat_i;
assign s1_wb_rd.wb_ack = s1_wb_ack_i;
assign s1_wb_rd.wb_err = 1'b0;

// TRNG
assign s2_wb_dat_o = s2_wb_wr.wb_dat;
assign s2_wb_adr_o = s2_wb_wr.wb_adr[10:0];
assign s2_wb_sel_o = s2_wb_wr.wb_sel;
assign s2_wb_we_o  = s2_wb_wr.wb_we;
assign s2_wb_cyc_o = s2_wb_wr.wb_cyc;
assign s2_wb_stb_o = s2_wb_wr.wb_stb;

assign s2_wb_rd.wb_dat = s2_wb_dat_i;
assign s2_wb_rd.wb_ack = s2_wb_ack_i;
assign s2_wb_rd.wb_err = 1'b0;

// SPI
assign s3_wb_dat_o = s3_wb_wr.wb_dat;
assign s3_wb_adr_o = s3_wb_wr.wb_adr[10:0];
assign s3_wb_sel_o = s3_wb_wr.wb_sel;
assign s3_wb_we_o  = s3_wb_wr.wb_we;
assign s3_wb_cyc_o = s3_wb_wr.wb_cyc;
assign s3_wb_stb_o = s3_wb_wr.wb_stb;

assign s3_wb_rd.wb_dat = s3_wb_dat_i;
assign s3_wb_rd.wb_ack = s3_wb_ack_i;
assign s3_wb_rd.wb_err = 1'b0;

// Generate Multiplexed Slave Interface based on target Id
wire [3:0] s_wb_tid = s_bus_wr.wb_tid; // to fix iverilog warning

always begin
    case(s_wb_tid)
        2'b00: s_bus_rd = s0_wb_rd;
        2'b01: s_bus_rd = s1_wb_rd;
        2'b10: s_bus_rd = s2_wb_rd;
        2'b11: s_bus_rd = s3_wb_rd;
    endcase
end

// Connect Master => Slave
assign  s0_wb_wr = (s_wb_tid == 2'b00) ? s_bus_wr : 2'b00;
assign  s1_wb_wr = (s_wb_tid == 2'b01) ? s_bus_wr : 2'b00;
assign  s2_wb_wr = (s_wb_tid == 2'b10) ? s_bus_wr : 2'b00;
assign  s3_wb_wr = (s_wb_tid == 2'b11) ? s_bus_wr : 2'b00;

// Stagging FF to break write and read timing path
wb_stagging u_m_wb_stage(
    .clk_i            (clk_i),
    .rst_n            (rst_n),

    // WishBone Input master I/P
    .m_wb_dat_i      (m0_wb_wr.wb_dat),
    .m_wb_adr_i      (m0_wb_wr.wb_adr),
    .m_wb_sel_i      (m0_wb_wr.wb_sel),
    .m_wb_we_i       (m0_wb_wr.wb_we ),
    .m_wb_cyc_i      (m0_wb_wr.wb_cyc),
    .m_wb_stb_i      (m0_wb_wr.wb_stb),
    .m_wb_tid_i      (m0_wb_wr.wb_tid),
    .m_wb_dat_o      (m0_wb_rd.wb_dat),
    .m_wb_ack_o      (m0_wb_rd.wb_ack),
    .m_wb_err_o      (m0_wb_rd.wb_err),

    // Slave Interface
    .s_wb_dat_i      (s_bus_rd.wb_dat),
    .s_wb_ack_i      (s_bus_rd.wb_ack),
    .s_wb_err_i      (s_bus_rd.wb_err),
    .s_wb_dat_o      (s_bus_wr.wb_dat),
    .s_wb_adr_o      (s_bus_wr.wb_adr),
    .s_wb_sel_o      (s_bus_wr.wb_sel),
    .s_wb_we_o       (s_bus_wr.wb_we ),
    .s_wb_cyc_o      (s_bus_wr.wb_cyc),
    .s_wb_stb_o      (s_bus_wr.wb_stb),
    .s_wb_tid_o      (s_bus_wr.wb_tid)
);

endmodule
