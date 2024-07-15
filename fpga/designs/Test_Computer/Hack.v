`define RAMFILE "../designs/Test_Computer/empty_ram.ram"
// `define ROMFILE "../designs/Test_Computer/empty_rom.rom"
// `define ROMFILE "../designs/Test_Computer/programs/echo.hack"
// `define ROMFILE "../designs/Test_Computer/programs/helloworld.hack"
// `define ROMFILE "../designs/Test_Computer/programs/sys.hack"
`define ROMFILE "../designs/Test_Computer/programs/combined.hack"
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

    // GPIO (Buttons and LEDs)
    input [1:0] BUT,
    output [1:0] LED,

    // UART
    input UART_RX,
    output UART_TX,

    // SPI
    output SPI_SDO,
    input SPI_SDI,
    output SPI_SCK,
    output SPI_CSX
);
    wire [15:0] pc;
    wire [15:0] instruction;
    wire [15:0] addressM;
    wire [15:0] inM;
    wire loadM;
    wire [15:0] outM;

    // Invert the inputs
    wire inv_0, inv_1;
    Not BUT0(.in(BUT[0]), .out(inv_0));
    Not BUT1(.in(BUT[1]), .out(inv_1));

    wire CLK_CPU;
    wire [31:0] CLK_COUNT;
    CLK_Divider Clock_CPU (
        .clk_in(CLK_100MHz),
        .divisor(100000), // 1000
        .clk_out(CLK_CPU),
        .clk_count(CLK_COUNT)
    );


    // reset logic
    // wire reset;
    // Reset Reset_0(.CLK_100MHz(CLK_100MHz),.reset(reset));

    // rom stores hack code
    ROM ROM_0(
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(CLK_CPU),
        .CLK_COUNT(CLK_COUNT),
        .pc(pc),
        .instruction(instruction));

    // hack cpu (nand2tetris)
    CPU CPU(                        
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(CLK_CPU),
        .CLK_COUNT(CLK_COUNT),
        .reset(inv_0 | inv_1),
        .instruction(instruction),  // Instruction for execution
        .addressM(addressM),        // Address in data memory to Read(of M)
        .inM(inM),                  // M value input  (M = contents of RAM[A])
        .outM(outM),                // M value output
        .loadM(loadM),              // Write to M? 
        .pc(pc)                     // address of next instruction
    );

    // mem gives access to ram and io    
    MemoryMappedIO MemoryMappedIO(
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(CLK_CPU),
        .CLK_COUNT(CLK_COUNT),
        .address(addressM),
        .dataR(inM),
        .dataW(outM),
        .loadM(loadM),
        .but({inv_0, inv_1}),
        .led(LED),
        .UART_RX(UART_RX),
        .UART_TX(UART_TX),
        .SPI_SDO(SPI_SDO),
        .SPI_SDI(SPI_SDI),
        .SPI_SCK(SPI_SCK),
        .SPI_CSX(SPI_CSX)
    );

endmodule
