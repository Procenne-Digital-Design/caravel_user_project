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
//    0.3 - 20 March 2022, Emre Goncu
//          adding ciphering mechanism
//-----------------------------------------------------------------------------

module sram_wb_wrapper #(
  parameter SRAM_ADDR_WD = 8 ,
  parameter SRAM_DATA_WD = 32
) (
`ifdef USE_POWER_PINS
  input  wire                      vccd1           , // User area 1 1.8V supply
  input  wire                      vssd1           , // User area 1 digital ground
`endif
  input  wire                      rst             ,
  // Wishbone Interface
  input  wire                      wb_clk_i        , // System clock
  input  wire                      wb_cyc_i        , // strobe/request
  input  wire                      wb_stb_i        , // strobe/request
  input  wire [  SRAM_ADDR_WD-1:0] wb_adr_i        , // address
  input  wire                      wb_we_i         , // write
  input  wire [  SRAM_DATA_WD-1:0] wb_dat_i        , // data output
  input  wire [SRAM_DATA_WD/8-1:0] wb_sel_i        , // byte enable
  output wire  [  SRAM_DATA_WD-1:0] wb_dat_o        , // data input
  output reg                       wb_ack_o        , // acknowlegement
  // SRAM Interface
  // Port A
  output wire                       sram_csb_a      ,
  output wire [  SRAM_ADDR_WD-1:0] sram_addr_a     ,
  input  wire [  SRAM_DATA_WD-1:0] sram_dout_a     ,
  // Port B
  output wire                       sram_csb_b      ,
  output wire                       sram_web_b      ,
  output wire  [SRAM_DATA_WD/8-1:0] sram_mask_b     ,
  output wire  [  SRAM_ADDR_WD-1:0] sram_addr_b     ,
  output wire  [  SRAM_DATA_WD-1:0] sram_din_b      ,
  output reg                       master_key_ready,
  input  wire [              31:0] trng_i          ,
  input  wire                      alarm           ,
  output reg                       alarm_set
);


  wire         master_key_en        ;
  reg [31:0]   master_key           ;
  reg  [  1:0] counter              ;
  reg  [  4:0] trng_count           ;

  reg [8:0] wb_adr_reg;


  assign master_key_en = rst ? 1'b0 :
    ((alarm)|| ((wb_adr_i == 32'd0) && wb_cyc_i && wb_stb_i && wb_we_i && !wb_ack_o)) ? 1'b1 : 1'b0;

  always @(posedge wb_clk_i ) begin
    if(rst)
      begin
        alarm_set <= 1'b0;
      end
    else
      if((wb_adr_i == 32'd3) && wb_cyc_i && wb_stb_i && wb_we_i && !wb_ack_o)
        begin
          alarm_set <= ~alarm_set;
        end
  end

  always @(posedge wb_clk_i) begin
    if(rst)
      begin
        master_key       <= 32'd0;
        trng_count       <= 5'd0;
        master_key_ready <= 1'b0;
      end
    else
      begin
        master_key_ready <= 1'b0;
        if(master_key_en)
          begin
            if(wb_dat_i)
              begin
                master_key       <= wb_dat_i;
                master_key_ready <= 1'b1;
              end
            else
              begin
                master_key <= trng_i;
              end
          end
      end
  end


  assign sram_csb_b  = !wb_stb_i;
  assign sram_web_b  = !wb_we_i;
  assign sram_mask_b = wb_sel_i;
  assign sram_addr_b = wb_adr_i;
  assign sram_din_b  = wb_dat_i ^ master_key;


  assign sram_csb_a  = (wb_stb_i == 1'b1 && wb_we_i == 1'b0 && wb_cyc_i == 1'b1) ? 1'b0 : 1'b1;
  assign sram_addr_a = wb_adr_i;

  assign wb_dat_o = (wb_adr_reg == 9'd1 && wb_ack_o == 1'b1) ? {31'd0,alarm} : 
                    (wb_ack_o == 1'b1) ? sram_dout_a ^ master_key : 32'd0; 


// Generate once cycle delayed ACK to get the data from SRAM
  always @(posedge wb_clk_i)
    begin
      if ( rst == 1'b1 )
        begin
          wb_ack_o <= 1'b0;
          wb_adr_reg <= 9'd0;
        end
      else
        begin
          if((wb_stb_i == 1'b1) && (wb_cyc_i == 1'b1))
          begin
            wb_ack_o <= 1'b1 ;
            wb_adr_reg <= wb_adr_i;
          end
          else 
            wb_ack_o <= 1'b0 ;
       end
    end

endmodule
