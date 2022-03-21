/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include "seed.h"
#include <stub.c>

/*
    Wishbone Test:
        - Configures MPRJ lower 8-IO pins as outputs
        - Checks counter value through the wishbone port
*/

#define reg_SRAM ((volatile uint32_t *)0x30000000)

// Register space for wbuart32
// #define reg_UART_SETUP (*(volatile uint32_t *)0x30001000)
// #define reg_UART_FIFO (*(volatile uint32_t *)0x30001004)
// #define reg_UART_RX_DATA (*(volatile uint32_t *)0x30001008)
// #define reg_UART_TX_DATA (*(volatile uint32_t *)0x3000100C)


// Register space for simpleUART
#define reg_UART_CLKDIV (*(volatile uint32_t *)0x30001000)
#define reg_UART_DATA   (*(volatile uint32_t *)0x30001004)
#define reg_UART_CONFIG (*(volatile uint32_t *)0x30001008)
void main()
{

    /*
    IO Control Registers
    | DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
    | 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
    Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
    | DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
    | 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |


    Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
    | DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
    | 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
    */

    /* Set up the housekeeping SPI to be connected internally so	*/
    /* that external pin changes don't affect it.			*/

    reg_spi_enable = 1;
    reg_wb_enable = 1;
    // reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
    // connect to housekeeping SPI

    // Connect the housekeeping SPI to the SPI master
    // so that the CSB line is not left floating.  This allows
    // all of the GPIO pins to be used for user functions.

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_15 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    // reg_mprj_io_14 = GPIO_MODE_MGMT_STD_OUTPUT;



    //Verify SRAM
    // for (int i = 0; i < 32; i++)
    // {
    //    *(reg_SRAM+(i*4)) = i*1024;
    // }

    // for (int i = 0; i < 32; i++)
    // {
    //    if(*(reg_SRAM+(i*4)) != i * 1024 )
    //     reg_mprj_datal = 0xAB800000;
    // }
    


    /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1)
        ;

    reg_la2_oenb = reg_la2_iena = 0x00000000; // [95:64]

    // Flag start of the test
    reg_mprj_datal = 0xAB600000;

    /* UART Setup: */
    /* 8-N-1 115200B for 50Mhz System Clock */
    int i = 0;
    unsigned baud, data;
    unsigned lfsr = seed;
    unsigned bit;
    unsigned period = 0;

    unsigned rx_status = 0;
    
    //reg_UART_SETUP = 434; //115200 for 50MHz clock
    reg_UART_CLKDIV = 434-2;
    reg_UART_CONFIG = 1; //dummy write to CFG // todo: get rid of that changing the RTL

    bool error = false;
    do
    {
        rx_status = 0xFFFFFFFF;
        /* taps: 16 14 13 11; characteristic polynomial: x^16 + x^14 + x^13 + x^11 + 1 */
        bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1;
        lfsr = (lfsr >> 1) | (bit << 15);
        ++period;
        data = lfsr % 256;     
        reg_UART_DATA = data;
        
        while(rx_status == 0xFFFFFFFF)
            rx_status = reg_UART_DATA;

        if(rx_status != data)
        {
            error = true;
            break;
        }
    } while (period < 2 && lfsr != seed && rx_status == data);

    if(error)
        reg_mprj_datal = 0xAB800000;
    else
        reg_mprj_datal = 0xAB700000;
    


}

