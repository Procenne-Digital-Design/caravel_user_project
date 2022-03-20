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
  output wire [  SRAM_DATA_WD-1:0] wb_dat_o        , // data input
  output reg                       wb_ack_o        , // acknowlegement
  // SRAM Interface
  // Port A
  output wire                      sram_csb_a      ,
  output wire [  SRAM_ADDR_WD-1:0] sram_addr_a     ,
  input  wire [  SRAM_DATA_WD-1:0] sram_dout_a     ,
  // Port B
  output reg                       sram_csb_b      ,
  output reg                       sram_web_b      ,
  output reg  [SRAM_DATA_WD/8-1:0] sram_mask_b     ,
  output reg  [  SRAM_ADDR_WD-1:0] sram_addr_b     ,
  output reg  [  SRAM_DATA_WD-1:0] sram_din_b      ,
  output wire                      master_key_ready,
  input  wire [              31:0] trng_i          ,
  input  wire                      alarm
);


  logic         master_key_en        ;
  logic [ 31:0] master_key_array[3:0];
  logic [127:0] master_key           ;
  logic [  1:0] counter              ;
  logic [  4:0] trng_count           ;

  assign master_key = {master_key_array[0], master_key_array[1], master_key_array[2], master_key_array[3]};

  assign master_key_en = rst ? 1'b0 :
    (alarm || ((wb_adr_i == 32'd0) && wb_cyc_i && wb_stb_i && wb_we_i)) ? 1'b1 : 1'b0;



  always @(posedge wb_clk_i) begin
    if(rst)
      begin
        master_key_array[0] <= 32'd0;
        master_key_array[1] <= 32'd0;
        master_key_array[2] <= 32'd0;
        master_key_array[3] <= 32'd0;
        counter             <= 2'd0;
        trng_count          <= 5'd0;
        master_key_ready    <= 1'b0;
      end
    else
      begin
        if(master_key_en)
          begin
            if(wb_dat_i)
              begin
                master_key_array[counter] <= wb_dat_i;
                counter                   <= counter + 2'd1;
              end
            else
              begin
                if(trng_count == 5'd0)
                  begin
                    master_key_array[counter] <= trng_in;
                    counter                   <= counter + 2'd1;
                  end
                trng_count <= trng_count + 5'd1;
              end

            if(counter == 2'h3)
              master_key_ready <= 1'b1;
            else
              master_key_ready <= 1'b0;
          end
      end

  end

// Memory Write Port
// assign sram_clk_b  = wb_clk_i;
  assign wb_dat_o = (wb_adr_i == 9'd1 && wb_cyc_i && wb_stb_i && !wb_we_i) ? SRAM_data_reg :
    (wb_adr_i == 9'd2 && wb_cyc_i && wb_stb_i && !wb_we_i) ? {30'd0,rd_busy, wr_busy} : 'h0;

// Memory Read Port
// assign sram_clk_a  = wb_clk_i;

  //assign sram_addr_a = wb_adr_i;






  /* FSM for reading ciphered Data from SRAM */
  /*******************************************/

  localparam INIT           = 0;
  localparam READ_DATA      = 1;
  localparam WAIT_AES_READY = 2;
  localparam WAIT_AES_DONE  = 3;
  localparam WR_TO_SRAM     = 4;


  logic [ 1:0] state_next_rd, state_reg_rd;
  logic [ 8:0] sram_addr_a_next, sram_addr_a_reg;
  logic [ 2:0] read_count_next, read_count_reg;
  logic [31:0] read_data_next  [3:0];
  logic [31:0] read_data_reg   [3:0];
  logic [31:0] SRAM_data_next, SRAM_data_reg;

  logic         read       ;
  logic         aes_init_rd;
  logic         enc_dec_rd ;
  logic         aes_next_rd;
  logic [127:0] aes_ptx_rd ;
  logic         rd_busy    ;
  logic         aes_ready  ;
  logic         aes_valid  ;
  logic [127:0] aes_ctx    ;
  always @(posedge wb_clk_i )
    begin
      if(reset)
        begin
          state_reg_rd     <= 2'd0;
          sram_addr_a_reg  <= 9'd0;
          read_data_reg[0] <= 32'd0;
          read_data_reg[1] <= 32'd0;
          read_data_reg[2] <= 32'd0;
          read_data_reg[3] <= 32'd0;
          SRAM_data_reg    <= 32'd0;
          read_count_reg   <= 3'd0;
        end
      else
        begin
          state_reg_rd     <= state_next_rd;
          sram_addr_a_reg  <= sram_addr_a_next;
          read_data_reg[0] <= read_data_next[0];
          read_data_reg[1] <= read_data_next[1];
          read_data_reg[2] <= read_data_next[2];
          read_data_reg[3] <= read_data_next[3];
          SRAM_data_reg    <= SRAM_data_next   ;
          read_count_reg   <= read_count_next ;
        end

    end

  assign read = (wb_stb_i == 1'b1 && wb_we_i == 1'b0 && wb_cyc_i == 1'b1 && !wr_busy) ? 1'b0 : 1'b1;
  always @(*)
  begin
    //default assignments
    rd_busy           = 1'b1;
    state_next_rd     = state_reg_rd;
    sram_addr_a_next  = sram_addr_a_reg;
    sram_csb_a        = 1'b1;
    read_count_next   = read_count_reg;
    read_data_next[0] = read_data_reg[0];
    read_data_next[1] = read_data_reg[1];
    read_data_next[2] = read_data_reg[2];
    read_data_next[3] = read_data_reg[3];
    SRAM_data_next    = SRAM_data_reg;
    aes_next_rd       = 1'b0;
    enc_dec_rd        = 1'b0;
    aes_init_rd       = 1'b0;


    case (state_reg_rd)
      INIT :
        begin
          if(read)
            begin
              sram_addr_a_next = wb_adr_i;
              state_next_rd    = READ_DATA;
            end
          else
            rd_busy = 1'b0;
        end
      READ_DATA :
        begin
          if(read_count_reg < 3'd5)
            begin
              sram_addr_a_next = sram_addr_a_reg + 1;
              sram_csb_a       = 1'b0;
              read_count_next  = read_count_reg + 1;
              if(read_count_reg > 3'd0)
                read_data_next[read_count-1] = sram_dout_a;
            end
          else
            begin
              state_next_rd   = WAIT_AES_READY;
              aes_init_rd     = 1'b1;
              enc_dec_rd      = 1'b0;
              read_count_next = 3'd0;
            end
        end
      WAIT_AES_READY :
        begin
          if(aes_ready)
            begin
              state_next_rd = WAIT_AES_DONE;
              aes_next_rd   = 1'b1;
              aes_ptx_rd    = read_data_reg;
            end
        end
      WRITE_AES_DONE :
        begin
          if(aes_valid)
            begin
              rd_busy        = 1'b0;
              state_next_rd  = INIT;
              SRAM_data_next = aes_ctx[31:0];
            end
        end
    endcase
  end
  /* FSM for reading ciphered Data from SRAM */
  /*******************************************/





  /* FSM for writing ciphered Data to SRAM */
  /*******************************************/

  logic [ 2:0] state_next_wr, state_reg_wr;
  logic [ 8:0] sram_addr_b_next, sram_addr_b_reg;
  logic [ 2:0] wr_count_next, wr_count_reg;
  logic [31:0] wr_data_next, wr_data_reg;
  logic [ 8:0] wr_addr_next, wr_addr_reg;


  logic        write           ;
  logic        aes_init_wr     ;
  logic        enc_dec_wr      ;
  logic        aes_next_wr     ;
  logic        aes_ptx_wr      ;
  logic        wr_busy         ;
  logic [31:0] aes_ctx_wr [3:0];

  assign aes_ctx_wr[0] = aex_ctx[31:0];
  assign aes_ctx_wr[1] = aex_ctx[63:32];
  assign aes_ctx_wr[2] = aex_ctx[95:64];
  assign aes_ctx_wr[3] = aex_ctx[127:96];

  assign write = (wb_stb_i == 1'b1 && wb_we_i == 1'b1 && wb_cyc_i == 1'b1 && !rd_busy) ? 1'b0 : 1'b1;

  always @(posedge wb_clk_i )
    begin
      if(reset)
        begin
          state_reg_wr <= INIT;
          wr_data_reg  <= 32'd0;
          wr_addr_reg  <= 9'd0;
          wr_count_reg <= 3'd0;
        end
      else
        begin
          state_reg_wr <= state_next_wr ;
          wr_data_reg  <= wr_data_next  ;
          wr_addr_reg  <= wr_addr_next  ;
          wr_count_reg <= wr_count_next ;
        end
    end



  always @(*)
    begin
      //default assignments
      wr_busy       = 1'b1;
      state_next_wr = state_reg_wr;
      sram_addr_b   = 9'd0;
      sram_csb_b    = 1'b1;
      sram_mask_b   = 4'h0;
      wr_count_next = wr_count_reg;
      aes_next_wr   = 1'b0;
      enc_dec_wr    = 1'b0;
      aes_init_wr   = 1'b0;
      wr_data_next  = wr_data_reg;
      wr_addr_next  = wr_addr_reg;

      case (state_reg_rd)
        INIT :
          begin
            if(write)
              begin
                aes_init_wr   = 1'b1;
                enc_dec_wr    = 1'b1;
                state_next_wr = WAIT_AES_READY;
                wr_data_next  = wb_dat_i;
                wr_addr_next  = wb_adr_i;
              end
            else
              wr_busy = 1'b0;
          end
        WAIT_AES_READY :
          begin
            if(aes_ready)
              begin
                state_next_wr = WAIT_AES_DONE;
                aes_next_wr   = 1'b1;
                aes_ptx_wr    = wr_data_reg;
              end
          end
        WRITE_AES_DONE :
          begin
            if(aes_valid)
              begin
                state_next_wr = WR_TO_SRAM;
                sram_addr_b   = wr_addr_reg;
                sram_din_b    = aes_ctx_wr[wr_count_reg];
                sram_csb_b    = 1'b0;
                sram_web_b    = 1'b0;
                sram_mask_b   = 4'hF;
                wr_count_next = wr_count_reg + 1;
              end
          end
        WR_TO_SRAM :
          begin
            if(wr_count_reg < 4)
              begin
                sram_addr_b   = wr_addr_reg + wr_count_reg;
                sram_din_b    = aes_ctx_wr[wr_count_reg];
                sram_csb_b    = 1'b0;
                sram_web_b    = 1'b0;
                sram_mask_b   = 4'hF;
                wr_count_next = wr_count_reg + 1;
              end
            else
              begin
                wr_busy       = 1'b0;
                wr_count_next = 3'd0;
                state_next_wr = INIT;
              end
          end


      endcase
    end
  /* FSM for writing ciphered Data to SRAM */
  /*******************************************/

  logic         aes_init = (write && !read) ? aes_init_wr : (!write && read) ? aes_init_rd : 'h0;
  logic         aes_next = (write && !read) ? aes_next_wr : (!write && read) ? aes_next_rd : 'h0;
  logic [127:0] aes_ptx  = (write && !read) ? aes_ptx_wr : (!write && read) ? aes_ptx_rd : 'h0  ;
  logic         enc_dec  = (write && !read) ? enc_dec_wr : (!write && read) ? enc_dec_rd : 'h0  ;


  aes_core core (
    .clk         (wb_clk_i            ),
    .reset_n     (~rst                ),
    
    .encdec      (enc_dec             ),
    .init        (aes_init            ),
    .next        (aes_next            ),
    .ready       (aes_ready           ),
    
    .key         ({128'd0, master_key}),
    .keylen      (2'd0                ),
    
    .block       (aes_ptx             ),
    .result      (aes_ctx             ),
    .result_valid(aes_valid           )
  );

// Generate once cycle delayed ACK to get the data from SRAM
  always @(posedge wb_clk_i)
    begin
      if ( rst == 1'b1 )
        begin
          wb_ack_o <= 1'b0;
        end else
      begin
        wb_ack_o <= (wb_stb_i == 1'b1) & (wb_cyc_i == 1'b1) & (wb_ack_o == 0);
      end
    end

endmodule
