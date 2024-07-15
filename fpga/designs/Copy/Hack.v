`define RAMFILE "../designs/Test_Computer/empty_ram.ram"
`define ROMFILE "../designs/Test_Computer/empty_rom.rom"
`include "include.v"
/** 
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk,rst,rom)
 *
 */

`default_nettype none
module Hack (
    input CLK_100MHz,

    // Buttons and LEDs
    input [1:0] BUT,
    output [1:0] LED,

    // UART
    input UART_RX,
    output UART_TX,

    // SPI
    output SPI_SDO,
    input SPI_SDI,
    output SPI_SCK,
    output SPI_CSX,

    // SRAM
    output [17:0] SRAM_ADDR,
    output [15:0] SRAM_DATA,
    output SRAM_WEX,
    output SRAM_OEX,
    output SRAM_CSX,

    // LCD
    output LCD_DCX,
    output LCD_SDO,
    output LCD_SCK,
    output LCD_CSX,

    // RTP
    input RTP_SDI,
    output RTP_SDO,
    output RTP_SCK
);


endmodule
