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

`timescale 1 ns / 1 ps

`define PER 25 // period


module wb_spi_tb ();
  reg clock ;
  reg RSTB  ;
  reg CSB   ;
  reg power1, power2;
  reg power3, power4;

  wire        gpio     ;
  wire [37:0] mprj_io  ;
  wire [ 7:0] mprj_io_0;
  wire [15:0] checkbits;


  integer fd ;
  integer tmp;

  reg [8*10:0] uart_data_in = "de 1b2";

  reg [23:0] dec_baud;
  reg [ 7:0] dec_data;


  reg [7:0] tx_data;

  wire sck_pin;
  wire mosi_pin;
  reg miso_pin;

  task  spi_transaction;
    begin : task_block
      integer i;
      miso_pin = 1'b0;
      for ( i=7 ;i > -1; i=i-1 )
        begin : for_block
          @(posedge sck_pin);
          miso_pin = tx_data[i];
          rx_data = {rx_data[6:0],mosi_pin}; 
        end
        @(negedge sck_pin);
        miso_pin = 1'b0;
    end
  endtask

  wire        rx                ;
  reg  [23:0] baud_clk =  8; // clk_freq is divided by for 
  reg  [ 7:0] rx_data  = 8'd0   ;

  // task spi_receive;
  //   begin : rx_block
  //     repeat(8)
  //     begin
  //       @(posedge sck_pin); 
  //       rx_data = {rx_data[6:0],mosi_pin};
  //     end
  //   end
  // endtask




  assign checkbits = mprj_io[31:16];

  assign mprj_io[3] = 1'b1;
  assign mosi_pin = mprj_io[12];
  assign sck_pin = mprj_io[13];
  assign mprj_io[14] = miso_pin;

  // External clock is used by default.  Make this artificially fast for the
  // simulation.  Normally this would be a slow clock and the digital PLL
  // would be the fast clock.

  //50MHz
  always #(`PER/2) clock <= (clock === 1'b0);

  initial
    begin
      clock = 0;
    end

  initial
    begin
      $dumpfile("wb_spi.vcd");
      $dumpvars(0, wb_spi_tb);

      // Repeat cycles of 1000 clock edges as needed to complete testbench
      repeat (70)
        begin
          repeat (10000) @(posedge clock);
          // $display("+1000 cycles");
        end
      $display("%c[1;31m",27);
`ifdef GL

      $display ("Monitor: Timeout, Test Mega-Project WB Port (GL) Failed");
`else
      $display ("Monitor: Timeout, Test Mega-Project WB Port (RTL) Failed");
`endif

      $display("%c[0m",27);
      $finish;
    end

  assign rx = uut.mprj.io_out[16];

  initial
    begin
      tx_data = 8'd0;
      wait(checkbits[15:4] == 12'hAB6);
      $display("Monitor: MPRJ-Logic WB Started");
      while(checkbits[15:4] != 12'hAB7)
        begin
          spi_transaction();
          tx_data = rx_data;
        end

    end


  initial
    begin
      wait(checkbits[15:4] == 12'hAB7 || checkbits[15:4] == 12'hAB8 );

      if(checkbits[15:4] == 12'hAB8)
        begin
          $display("SPI failed!");
          $finish;
        end
        else
          begin
    `ifdef GL
            $display("Monitor: Mega-Project WB (GL) Passed");
    `else
            $display("Monitor: Mega-Project WB (RTL) Passed");
    `endif
            $finish;
          end
    end

  initial
    begin
      RSTB <= 1'b0;
      CSB  <= 1'b1;		// Force CSB high
      #2000;
      RSTB <= 1'b1;	    	// Release reset
      #100000;
      CSB = 1'b0;		// CSB can be released
    end

  initial
    begin		// Power-up sequence
      power1 <= 1'b0;
      power2 <= 1'b0;
      #200;
      power1 <= 1'b1;
      #200;
      power2 <= 1'b1;
    end



  wire flash_csb;
  wire flash_clk;
  wire flash_io0;
  wire flash_io1;

  wire VDD3V3      = power1;
  wire VDD1V8      = power2;
  wire USER_VDD3V3 = power3;
  wire USER_VDD1V8 = power4;
  wire VSS         = 1'b0  ;

  caravel uut (
    .vddio    (VDD3V3   ),
    .vddio_2  (VDD3V3   ),
    .vssio    (VSS      ),
    .vssio_2  (VSS      ),
    .vdda     (VDD3V3   ),
    .vssa     (VSS      ),
    .vccd     (VDD1V8   ),
    .vssd     (VSS      ),
    .vdda1    (VDD3V3   ),
    .vdda1_2  (VDD3V3   ),
    .vdda2    (VDD3V3   ),
    .vssa1    (VSS      ),
    .vssa1_2  (VSS      ),
    .vssa2    (VSS      ),
    .vccd1    (VDD1V8   ),
    .vccd2    (VDD1V8   ),
    .vssd1    (VSS      ),
    .vssd2    (VSS      ),
    .clock    (clock    ),
    .gpio     (gpio     ),
    .mprj_io  (mprj_io  ),
    .flash_csb(flash_csb),
    .flash_clk(flash_clk),
    .flash_io0(flash_io0),
    .flash_io1(flash_io1),
    .resetb   (RSTB     )
  );

  spiflash #(.FILENAME("wb_spi.hex")) spiflash (
    .csb(flash_csb),
    .clk(flash_clk),
    .io0(flash_io0),
    .io1(flash_io1),
    .io2(         ), // not used
    .io3(         )  // not used
  );



endmodule

`default_nettype wire
