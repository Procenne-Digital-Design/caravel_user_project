//-----------------------------------------------------------------------------
// @file      trng_wb_wrapper.vhd
//
// @brief     This block is a wishbone wrapper for TRNG macro
//
// @details   This wrapper gets signal from master if it is selected
//			  and convey to the TRNG module and vice versa.
//
// @author    Sukru Uzun <sukru.uzun@procenne.com>
// @date      19.03.2022
//
// @todo 	  TRNG buffer size can be changed.
// @warning	  Wrapper should not convey data unless buffer is full.
//
// @project   https://github.com/Procenne-Digital-Design/secure-memory.git
//
// @revision :
//    0.1 - 19 March 2022, Sukru Uzun
//          initial version
//-----------------------------------------------------------------------------

module trng_wb_wrapper #(
    parameter BUFFER_SIZE = 32
  ) (
  `ifdef USE_POWER_PINS
    input  wire vccd1,
    input  wire vssd1,
  `endif
    input  wire rst_i,
    // Wishbone Interface
    input  wire wb_clk_i,
    input  wire wb_cyc_i,
    input  wire wb_stb_i,
    input  wire [8:0] wb_adr_i,
    input  wire wb_we_i,
    input  wire [31:0] wb_dat_i,
    // input  wire [3:0] wb_sel_i,
    output wire [31:0] wb_dat_o,
    output reg  wb_ack_o,
    output reg  trng_valid_o,
    output reg  [BUFFER_SIZE-1:0] trng_buffer_o
);

wire        read_trng;
wire        trim_select;
wire        trim_write_en;
reg  [25:0] trim_fast, trim_slow;
reg  [5:0]  trng_counter;
wire        trng_o;

// Wishbone to TRNG signalization and vice versa.
assign read_trng  = (wb_stb_i == 1'b1 && wb_we_i == 1'b0 && wb_cyc_i == 1'b1) ? 1'b1 : 1'b0;
assign wb_dat_o   = (trng_valid_o == 1'b1 && read_trng == 1'b1) ? trng_buffer_o : 'h0;

ringosc_macro #(.TRIM_BITS(26))
ringosc_macro_dut (
`ifdef USE_POWER_PINS
    .vccd1     (vccd1),
    .vssd1     (vssd1),
`endif
    .rst_i     (rst_i),
    .trim_fast (trim_fast),
    .trim_slow (trim_slow),
    .trng_o    (trng_o)
);

assign trim_select   = wb_dat_i[5];
assign trim_write_en = (wb_stb_i == 1'b1 && wb_we_i == 1'b1 && wb_cyc_i == 1'b1) ? 1'b1 : 1'b0;

always @(posedge wb_clk_i)
begin
    if (rst_i == 1'b1) begin
        trim_slow <= 26'b11111111111111111111111111;
        trim_fast <= 26'b00000000000000000000000000;
    end
    else begin
        if (trim_write_en) begin
            if(trim_select)
                case(wb_dat_i[4:0])
                    5'b00000: trim_fast = 26'b00000000000000000000000000;
                    5'b00001: trim_fast = 26'b00000000000000000000000001;
                    5'b00010: trim_fast = 26'b00000000000000000000000011;
                    5'b00011: trim_fast = 26'b00000000000000000000000111;
                    5'b00100: trim_fast = 26'b00000000000000000000001111;
                    5'b00101: trim_fast = 26'b00000000000000000000011111;
                    5'b00110: trim_fast = 26'b00000000000000000000111111;
                    5'b00111: trim_fast = 26'b00000000000000000001111111;
                    5'b01000: trim_fast = 26'b00000000000000000011111111;
                    5'b01001: trim_fast = 26'b00000000000000000111111111;
                    5'b01010: trim_fast = 26'b00000000000000001111111111;
                    5'b01011: trim_fast = 26'b00000000000000011111111111;
                    5'b01100: trim_fast = 26'b00000000000000111111111111;
                    5'b01101: trim_fast = 26'b00000000000001111111111111;
                    5'b01110: trim_fast = 26'b00000000000011111111111111;
                    5'b01111: trim_fast = 26'b00000000000111111111111111;
                    5'b10000: trim_fast = 26'b00000000001111111111111111;
                    5'b10001: trim_fast = 26'b00000000011111111111111111;
                    5'b10010: trim_fast = 26'b00000000111111111111111111;
                    5'b10011: trim_fast = 26'b00000001111111111111111111;
                    5'b10100: trim_fast = 26'b00000011111111111111111111;
                    5'b10101: trim_fast = 26'b00000111111111111111111111;
                    5'b10110: trim_fast = 26'b00001111111111111111111111;
                    5'b10111: trim_fast = 26'b00011111111111111111111111;
                    5'b11000: trim_fast = 26'b00111111111111111111111111;
                    5'b11001: trim_fast = 26'b01111111111111111111111111;
                    5'b11010: trim_fast = 26'b11111111111111111111111111;
                    default:  trim_fast = 26'b11111111111111111111111111;
                endcase
            else begin
                case(wb_adr_i[4:0])
                    5'b00000: trim_slow = 26'b00000000000000000000000000;
                    5'b00001: trim_slow = 26'b00000000000000000000000001;
                    5'b00010: trim_slow = 26'b00000000000000000000000011;
                    5'b00011: trim_slow = 26'b00000000000000000000000111;
                    5'b00100: trim_slow = 26'b00000000000000000000001111;
                    5'b00101: trim_slow = 26'b00000000000000000000011111;
                    5'b00110: trim_slow = 26'b00000000000000000000111111;
                    5'b00111: trim_slow = 26'b00000000000000000001111111;
                    5'b01000: trim_slow = 26'b00000000000000000011111111;
                    5'b01001: trim_slow = 26'b00000000000000000111111111;
                    5'b01010: trim_slow = 26'b00000000000000001111111111;
                    5'b01011: trim_slow = 26'b00000000000000011111111111;
                    5'b01100: trim_slow = 26'b00000000000000111111111111;
                    5'b01101: trim_slow = 26'b00000000000001111111111111;
                    5'b01110: trim_slow = 26'b00000000000011111111111111;
                    5'b01111: trim_slow = 26'b00000000000111111111111111;
                    5'b10000: trim_slow = 26'b00000000001111111111111111;
                    5'b10001: trim_slow = 26'b00000000011111111111111111;
                    5'b10010: trim_slow = 26'b00000000111111111111111111;
                    5'b10011: trim_slow = 26'b00000001111111111111111111;
                    5'b10100: trim_slow = 26'b00000011111111111111111111;
                    5'b10101: trim_slow = 26'b00000111111111111111111111;
                    5'b10110: trim_slow = 26'b00001111111111111111111111;
                    5'b10111: trim_slow = 26'b00011111111111111111111111;
                    5'b11000: trim_slow = 26'b00111111111111111111111111;
                    5'b11001: trim_slow = 26'b01111111111111111111111111;
                    5'b11010: trim_slow = 26'b11111111111111111111111111;
                    default:  trim_slow = 26'b00000000000000000000000000;
                endcase
            end
        end
    end
end

always @(posedge wb_clk_i)
begin
    if (rst_i == 1'b1) begin
        wb_ack_o     <= 1'b0;
        trng_valid_o <= 1'b0;
        trng_counter <= 'h0;
        trng_buffer_o  <= 'h0;
    end
    else begin
        // TRNG signalization
        wb_ack_o     <= 1'b0;
        trng_counter <= trng_counter + 1;
        trng_valid_o <= trng_valid_o;

        if(trim_write_en == 1'b1 && wb_ack_o == 1'b0) begin
            wb_ack_o <= 1'b1;
        end

        if(trng_counter == 6'b100000) begin
            trng_counter <= 'h0;
            trng_valid_o <= 1'b1;
        end

        if(read_trng == 1'b1 && trng_valid_o == 1'b1) begin
            wb_ack_o     <= 1'b1;
            trng_counter <= 'h0;
            trng_valid_o <= 1'b0;
        end

        trng_buffer_o <= {trng_buffer_o[30:0],trng_o};
    end
end

endmodule
