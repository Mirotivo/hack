`define RAMFILE "../designs/Test_Computer/empty_ram.ram"
// `define ROMFILE "../designs/Test_Computer/empty_rom.rom"
// `define ROMFILE "../designs/Test_Computer/programs/echo.hack"
// `define ROMFILE "../designs/Test_Computer/programs/helloworld.hack"
// `define ROMFILE "../designs/Test_Computer/programs/sys.hack"
`define ROMFILE "../designs/Test_Computer/programs/combined.hack"
// `define ROMFILE "../designs/Test_Computer/programs/bluescreen.hack"
`include "include.v"

/**
 * The module Hack is our top-level module
 * It connects the external pins of our FPGA (Hack.pcf)
 * to the internal components (CPU, Memory, Clock, Reset, ROM)
 *
 */
`default_nettype none
module Hack (
    // Clock
    input CLK_100MHz,

    // GPIO (Buttons and LEDs)
    input [1:0] BUT,
    output [1:0] LED,

    // UART
    input UART_RX,
    output UART_TX,

    // LCD/TFT Display
    output TFT_CS,
    output TFT_RESET,
    output TFT_SDI,
    output TFT_SCK,
    output TFT_DC
);

    // Internal signals - CPU and Memory
    wire [15:0] pc;
    wire [15:0] instruction;
    wire [15:0] address_m;
    wire [15:0] in_m;
    wire load_m;
    wire [15:0] out_m;

    // Internal signals - Clock
    wire clk_cpu;
    wire [31:0] clk_count;

    // GPIO - Button processing
    wire inv_0;
    wire inv_1;
    wire reset;

    // Module instantiations
    
    // GPIO - Button inversion (buttons are active low)
    Not not_but0(.IN(BUT[0]), .OUT(inv_0));
    Not not_but1(.IN(BUT[1]), .OUT(inv_1));

    // Clock divider: 100MHz -> 50Hz
    // clk_cpu acts as clock enable signal, not separate clock domain
    // 50Hz = 20ms per instruction, slower than LCD (10ms per byte)
    // This eliminates the need for busy-wait loops!
    CLK_Divider clk_divider_inst (
        .CLK_IN(CLK_100MHz),
        .DIVISOR(2000000),          // Divide by 2,000,000 to get 50 Hz (20ms per instruction)
        .CLK_OUT(clk_cpu),
        .CLK_COUNT(clk_count)
    );

    // Instruction ROM
    ROM rom_inst(
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(clk_cpu),
        .CLK_COUNT(clk_count),
        .PC(pc),
        .INSTRUCTION(instruction)
    );

    // CPU - Hack CPU (nand2tetris)
    CPU cpu_inst(
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(clk_cpu),
        .CLK_COUNT(clk_count),
        .RESET(reset),
        .INSTRUCTION(instruction),
        .PC(pc),
        .IN_M(in_m),
        .LOAD_M(load_m),
        .OUT_M(out_m),
        .ADDRESS_M(address_m)
    );

    // Memory-mapped I/O (RAM and peripherals)
    MemoryMappedIO mem_io_inst(
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(clk_cpu),
        .CLK_COUNT(clk_count),
        .ADDRESS(address_m),
        .DATA_R(in_m),
        .DATA_W(out_m),
        .LOAD_M(load_m),
        .BUT({inv_0, inv_1}),
        .LED(LED),
        .UART_RX(UART_RX),
        .UART_TX(UART_TX),
        .TFT_CS(TFT_CS),
        .TFT_RESET(TFT_RESET),
        .TFT_SDI(TFT_SDI),
        .TFT_SCK(TFT_SCK),
        .TFT_DC(TFT_DC)
    );

    // Combinational logic
    
    // Reset signal (any button pressed generates reset)
    assign reset = inv_0 | inv_1;

endmodule
