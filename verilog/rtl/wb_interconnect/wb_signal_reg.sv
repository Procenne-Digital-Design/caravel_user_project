//-----------------------------------------------------------------------------
// @file      wb_signal_reg.vhd
//
// @brief     Register wishbone signals.
//
// @details   This logic create a holding FF for Wishbone interface.
//            This is usefull to break timing issue at interconnect
//			  
// @author    Sukru Uzun <sukru.uzun@procenne.com>
// @date      10.03.2022
//
// @todo 	  
// @warning	  
//
// @project   https://github.com/Procenne-Digital-Design/secure-memory.git
//
// @revision :
//    0.1 - 10 March 2022, Sukru Uzun
//          initial version
//-----------------------------------------------------------------------------

module wb_signal_reg (
    input logic	clk_i, 
    input logic rst_n,
    
    // WishBone Input master I/P
    input   logic [31:0] m_wb_dat_i,
    input   logic [31:0] m_wb_adr_i,
    input   logic [3:0]	 m_wb_sel_i,
    input   logic  	     m_wb_we_i,
    input   logic  	     m_wb_cyc_i,
    input   logic  	     m_wb_stb_i,
    input   logic [1:0]	 m_wb_tid_i,
    output  logic [31:0] m_wb_dat_o,
    output  logic		 m_wb_ack_o,
    output  logic		 m_wb_err_o,

    // Slave Interface
    input	logic [31:0] s_wb_dat_i,
    input	logic 	     s_wb_ack_i,
    input	logic 	     s_wb_err_i,
    output	logic [31:0] s_wb_dat_o,
    output	logic [31:0] s_wb_adr_o,
    output	logic [3:0]	 s_wb_sel_o,
    output	logic 	     s_wb_we_o,
    output	logic 	     s_wb_cyc_o,
    output	logic 	     s_wb_stb_o,
    output	logic [1:0]	 s_wb_tid_o
);

logic holding_busy   ; // Indicate Stagging for Free or not

always @(negedge rst_n or posedge clk_i)
begin
    if(rst_n == 1'b0) begin
        holding_busy   <= 1'b0;
        s_wb_dat_o <= 'h0;
        s_wb_adr_o <= 'h0;
        s_wb_sel_o <= 'h0;
        s_wb_we_o  <= 'h0;
        s_wb_cyc_o <= 'h0;
        s_wb_stb_o <= 'h0;
        s_wb_tid_o <= 'h0;
        m_wb_dat_o <= 'h0;
        m_wb_ack_o <= 'h0;
        m_wb_err_o <= 'h0;
    end else begin
        m_wb_dat_o <= s_wb_dat_i;
        m_wb_ack_o <= s_wb_ack_i;
        m_wb_err_o <= s_wb_err_i;
        if(m_wb_stb_i && holding_busy == 0 && m_wb_ack_o == 0) begin
            holding_busy   <= 1'b1;
            s_wb_dat_o <= m_wb_dat_i;
            s_wb_adr_o <= m_wb_adr_i;
            s_wb_sel_o <= m_wb_sel_i;
            s_wb_we_o  <= m_wb_we_i;
            s_wb_cyc_o <= m_wb_cyc_i;
            s_wb_stb_o <= m_wb_stb_i;
            s_wb_tid_o <= m_wb_tid_i;
        end 
        else if (holding_busy && s_wb_ack_i) begin
            holding_busy   <= 1'b0;
            s_wb_dat_o <= 'h0;
            s_wb_adr_o <= 'h0;
            s_wb_sel_o <= 'h0;
            s_wb_we_o  <= 'h0;
            s_wb_cyc_o <= 'h0;
            s_wb_stb_o <= 'h0;
            s_wb_tid_o <= 'h0;
        end
    end
end

endmodule
