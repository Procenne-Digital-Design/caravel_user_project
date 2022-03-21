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

module wb_interconnect (
`ifdef USE_POWER_PINS
  input  wire        vccd1      , // User area 1 1.8V supply
  input  wire        vssd1      , // User area 1 digital ground
`endif
  input  wire        clk_i      ,
  input  wire        rst        ,
  // Master 0 Interface
  input  wire [31:0] m0_wb_dat_i,
  input  wire [31:0] m0_wb_adr_i,
  input  wire [ 3:0] m0_wb_sel_i,
  input  wire        m0_wb_we_i ,
  input  wire        m0_wb_cyc_i,
  input  wire        m0_wb_stb_i,
  output wire [31:0] m0_wb_dat_o,
  output wire        m0_wb_ack_o,
  // Slave 0 Interface
  input  wire [31:0] s0_wb_dat_i,
  input  wire        s0_wb_ack_i,
  output wire [31:0] s0_wb_dat_o,
  output wire [ 8:0] s0_wb_adr_o,
  output wire [ 3:0] s0_wb_sel_o,
  output wire        s0_wb_we_o ,
  output wire        s0_wb_cyc_o,
  output wire        s0_wb_stb_o,
  // Slave 1 Interface
  input  wire [31:0] s1_wb_dat_i,
  input  wire        s1_wb_ack_i,
  output wire [31:0] s1_wb_dat_o,
  output wire [8:0] s1_wb_adr_o,
  output wire [ 3:0] s1_wb_sel_o,
  output wire        s1_wb_we_o ,
  output wire        s1_wb_cyc_o,
  output wire        s1_wb_stb_o,
  // Slave 2 Interface
  input	logic [31:0]   s2_wb_dat_i,
  input	logic 	       s2_wb_ack_i,
  output	wire  [31:0]   s2_wb_dat_o,
  output	wire  [8:0]    s2_wb_adr_o,
  output	wire  [3:0]    s2_wb_sel_o,
  output	wire  	       s2_wb_we_o,
  output	wire  	       s2_wb_cyc_o,
  output	wire  	       s2_wb_stb_o,
  // Slave 3 Interface
  input	logic [31:0]   s3_wb_dat_i,
  input	logic 	       s3_wb_ack_i,
  output	wire  [31:0]   s3_wb_dat_o,
  output	wire  [8:0]    s3_wb_adr_o,
  output	wire  [3:0]    s3_wb_sel_o,
  output	wire  	       s3_wb_we_o,
  output	wire  	       s3_wb_cyc_o,
  output	wire  	       s3_wb_stb_o
  
  
);



  reg [31:0] m0_wb_dat_i_reg;
  reg [31:0] m0_wb_adr_reg  ;
  reg [ 3:0] m0_wb_sel_reg  ;
  reg        m0_wb_we_reg   ;
  reg        m0_wb_cyc_reg  ;
  reg        m0_wb_stb_reg  ;
  reg [ 1:0] m0_wb_tid_reg  ;



  wire [31:0] s_bus_rd_wb_dat = (m0_wb_adr_i[13:12] == 2'b00) ? s0_wb_dat_i :
    (m0_wb_adr_i[13:12] == 2'b01) ? s1_wb_dat_i :  
    (m0_wb_adr_i[13:12] == 2'b10) ? s2_wb_dat_i :
    (m0_wb_adr_i[13:12] == 2'b11) ? s3_wb_dat_i : 32'd0;
  wire        s_bus_rd_wb_ack = (m0_wb_adr_i[13:12] == 2'b00) ? s0_wb_ack_i :
    (m0_wb_adr_i[13:12] == 2'b01) ? s1_wb_ack_i :
    (m0_wb_adr_i[13:12] == 2'b10) ? s2_wb_ack_i :
    (m0_wb_adr_i[13:12] == 2'b11) ? s3_wb_ack_i : 1'b0 ; // :

  //wire [31:0] s_bus_rd_wb_dat = s0_wb_dat_i;
  //wire        s_bus_rd_wb_ack = s0_wb_ack_i;

  //-------------------------------------------------------------------
  // EXTERNAL MEMORY MAP
  // 0x0000_0000 to 0x0000_0FFF  - SRAM
  // 0x0000_1000 to 0x0000_1FFF  - UART
  // 0x0000_2000 to 0x0000_2FFF  - TRNG
  // 0x0000_3000 to 0x0000_3FFF  - SPI
  //------------------------------------------------------------------
  wire [1:0] m0_wb_tid_i = m0_wb_adr_i[13:12];

  //----------------------------------------
  // Slave Mapping
  //---------------------------------------
  //assign s0_wb_dat_o = m0_wb_dat_i_reg;
  //assign s0_wb_adr_o = m0_wb_adr_reg[8:0];
  //assign s0_wb_sel_o = m0_wb_sel_reg;
  //assign s0_wb_we_o  = m0_wb_we_reg;
  //assign s0_wb_cyc_o = m0_wb_cyc_reg;
  //assign s0_wb_stb_o = m0_wb_stb_reg;

  assign s0_wb_dat_o = (m0_wb_tid_reg == 2'b00) ? m0_wb_dat_i_reg : 32'd00;
  assign s0_wb_adr_o = (m0_wb_tid_reg == 2'b00) ? m0_wb_adr_reg : 9'd0;
  assign s0_wb_sel_o = (m0_wb_tid_reg == 2'b00) ? m0_wb_sel_reg : 4'd0;
  assign s0_wb_we_o  = (m0_wb_tid_reg == 2'b00) ? m0_wb_we_reg  : 1'b0;
  assign s0_wb_cyc_o = (m0_wb_tid_reg == 2'b00) ? m0_wb_cyc_reg : 1'b0;
  assign s0_wb_stb_o = (m0_wb_tid_reg == 2'b00) ? m0_wb_stb_reg : 1'b0;

  assign s1_wb_dat_o = (m0_wb_tid_reg == 2'b01) ? m0_wb_dat_i_reg : 32'd0;
  assign s1_wb_adr_o = (m0_wb_tid_reg == 2'b01) ? m0_wb_adr_reg : 9'd0;
  assign s1_wb_sel_o = (m0_wb_tid_reg == 2'b01) ? m0_wb_sel_reg : 4'd0;
  assign s1_wb_we_o  = (m0_wb_tid_reg == 2'b01) ? m0_wb_we_reg  : 1'b0;
  assign s1_wb_cyc_o = (m0_wb_tid_reg == 2'b01) ? m0_wb_cyc_reg : 1'b0;
  assign s1_wb_stb_o = (m0_wb_tid_reg == 2'b01) ? m0_wb_stb_reg : 1'b0;

  assign s2_wb_dat_o = (m0_wb_tid_reg == 2'b10) ? m0_wb_dat_i_reg : 'h0;
  assign s2_wb_adr_o = (m0_wb_tid_reg == 2'b10) ? m0_wb_adr_reg :   'h0;
  assign s2_wb_sel_o = (m0_wb_tid_reg == 2'b10) ? m0_wb_sel_reg :   'h0;
  assign s2_wb_we_o  = (m0_wb_tid_reg == 2'b10) ? m0_wb_we_reg  :   'h0;
  assign s2_wb_cyc_o = (m0_wb_tid_reg == 2'b10) ? m0_wb_cyc_reg :   'h0;
  assign s2_wb_stb_o = (m0_wb_tid_reg == 2'b10) ? m0_wb_stb_reg :   'h0;

  assign s3_wb_dat_o = (m0_wb_tid_reg == 2'b11) ? m0_wb_dat_i_reg : 32'd0;
  assign s3_wb_adr_o = (m0_wb_tid_reg == 2'b11) ? m0_wb_adr_reg : 9'd0;
  assign s3_wb_sel_o = (m0_wb_tid_reg == 2'b11) ? m0_wb_sel_reg : 4'd0;
  assign s3_wb_we_o  = (m0_wb_tid_reg == 2'b11) ? m0_wb_we_reg  : 1'b0;
  assign s3_wb_cyc_o = (m0_wb_tid_reg == 2'b11) ? m0_wb_cyc_reg : 1'b0;
  assign s3_wb_stb_o = (m0_wb_tid_reg == 2'b11) ? m0_wb_stb_reg : 1'b0;

  assign m0_wb_dat_o = s_bus_rd_wb_dat;
  assign m0_wb_ack_o = s_bus_rd_wb_ack;

  always @(posedge clk_i)
    begin
      if(rst == 1'b1)
        begin
          // holding_busy    <= 1'b0;
          m0_wb_dat_i_reg <= 'h0;
          m0_wb_adr_reg   <= 'h0;
          m0_wb_sel_reg   <= 'h0;
          m0_wb_we_reg    <= 'h0;
          m0_wb_cyc_reg   <= 'h0;
          m0_wb_stb_reg   <= 'h0;
          m0_wb_tid_reg   <= 'h0;


        end
      else
        begin
          m0_wb_dat_i_reg <= 'h0;
          m0_wb_adr_reg   <= 'h0;
          m0_wb_sel_reg   <= 'h0;
          m0_wb_we_reg    <= 'h0;
          m0_wb_cyc_reg   <= 'h0;
          m0_wb_stb_reg   <= 'h0;
          m0_wb_tid_reg   <= 'h0;

          if(m0_wb_stb_i && m0_wb_cyc_i && s_bus_rd_wb_ack == 0)
            begin
              // holding_busy    <= 1'b1;
              m0_wb_dat_i_reg <= m0_wb_dat_i;
              m0_wb_adr_reg   <= {2'b00,m0_wb_adr_i[31:2]};
              m0_wb_sel_reg   <= m0_wb_sel_i;
              m0_wb_we_reg    <= m0_wb_we_i;
              m0_wb_cyc_reg   <= m0_wb_cyc_i;
              m0_wb_stb_reg   <= m0_wb_stb_i;
              m0_wb_tid_reg   <= m0_wb_tid_i;

            end
        end
    end

endmodule
