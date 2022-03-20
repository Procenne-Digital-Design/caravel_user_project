//-----------------------------------------------------------------------------
// @file      sram_wb_wrapper.vhd
//
// @brief     This block is a wishbone wrapper for SRAM signal mapping
//
// @details   This wrapper gets signal from master if it is selected
//			  and convey to the SRAM module and vice versa.
//
// @author    Sukru Uzun <sukru.uzun@procenne.com>
// @date      10.03.2022
//
// @todo 	  SRAM signalization should be checked
// @warning	  SRAM signalization
//
// @project   https://github.com/Procenne-Digital-Design/secure-memory.git
//
// @revision :
//    0.1 - 10 March 2022, Sukru Uzun
//          initial version
//    0.2 - 16 March 2022, Sukru Uzun
//          remove SRAM design
//-----------------------------------------------------------------------------

module sram_wb_wrapper #(
    parameter SRAM_ADDR_WD = 8 ,
    parameter SRAM_DATA_WD = 32
) (
`ifdef USE_POWER_PINS
    input  wire                      vccd1      , // User area 1 1.8V supply
    input  wire                      vssd1      , // User area 1 digital ground
`endif
    input  wire                      rst_i      ,
    // Wishbone Interface
    input  wire                      wb_clk_i   , // System clock
    input  wire                      wb_cyc_i   , // strobe/request
    input  wire                      wb_stb_i   , // strobe/request
    input  wire [  SRAM_ADDR_WD-1:0] wb_adr_i   , // address
    input  wire                      wb_we_i    , // write
    input  wire [  SRAM_DATA_WD-1:0] wb_dat_i   , // data output
    input  wire [SRAM_DATA_WD/8-1:0] wb_sel_i   , // byte enable
    // output  wire  [SRAM_DATA_WD-1:0]    wb_dat_o,  // data input
    output reg                       wb_ack_o   , // acknowlegement
    // SRAM Interface
    // Port A
    output wire                      sram_csb_a ,
    output wire [  SRAM_ADDR_WD-1:0] sram_addr_a,
    // Port B
    output wire                      sram_csb_b ,
    output wire                      sram_web_b ,
    output wire [SRAM_DATA_WD/8-1:0] sram_mask_b,
    output wire [  SRAM_ADDR_WD-1:0] sram_addr_b,
    output wire [  SRAM_DATA_WD-1:0] sram_din_b
);

// // Port A
// wire                      sram_clk_a;
// wire                      sram_csb_a;
// wire [SRAM_ADDR_WD-1:0]   sram_addr_a;
// wire [SRAM_DATA_WD-1:0]   sram_dout_a;

// // Port B
// wire                      sram_clk_b;
// wire                      sram_csb_b;
// wire                      sram_web_b;
// wire [SRAM_DATA_WD/8-1:0] sram_mask_b;
// wire [SRAM_ADDR_WD-1:0]   sram_addr_b;
// wire [SRAM_DATA_WD-1:0]   sram_din_b;

// Memory Write Port
// assign sram_clk_b  = wb_clk_i;
assign sram_csb_b  = !wb_stb_i;
assign sram_web_b  = !wb_we_i;
assign sram_mask_b = wb_sel_i;
assign sram_addr_b = wb_adr_i;
assign sram_din_b  = wb_dat_i;

// Memory Read Port
// assign sram_clk_a  = wb_clk_i;
assign sram_csb_a  = (wb_stb_i == 1'b1 && wb_we_i == 1'b0 && wb_cyc_i == 1'b1) ? 1'b0 : 1'b1;
assign sram_addr_a = wb_adr_i;

// assign wb_dat_o    = sram_dout_a;

// sky130_sram_1kbyte_1rw1r_32x256_8 u_sram1_1kb(
// `ifdef USE_POWER_PINS
//     .vccd1 (vccd1), // User area 1 1.8V supply
//     .vssd1 (vssd1), // User area 1 digital ground
// `endif
//     // Port 0: RW
//     .clk0     (sram_clk_b),
//     .csb0     (sram_csb_b),
//     .web0     (sram_web_b),
//     .wmask0   (sram_mask_b),
//     .addr0    (sram_addr_b),
//     .din0     (sram_din_b),
//     .dout0    (),   // dont read from Port B
//     // Port 1: R
//     .clk1     (sram_clk_a),
//     .csb1     (sram_csb_a),
//     .addr1    (sram_addr_a),
//     .dout1    (sram_dout_a)
// );

// Generate once cycle delayed ACK to get the data from SRAM
always @(posedge wb_clk_i)
    begin
      if ( rst_i == 1'b1 ) begin
        wb_ack_o <= 1'b0;
    end 
    else begin
        wb_ack_o <= (wb_stb_i == 1'b1) & (wb_cyc_i == 1'b1) & (wb_ack_o == 0);
    end
end

endmodule
