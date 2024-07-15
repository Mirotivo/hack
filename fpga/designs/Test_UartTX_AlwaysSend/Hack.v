`define RAMFILE "empty_ram.ram"
// `define ROMFILE "empty_rom.rom"
`define ROMFILE "blinker.hack"
// `define ROMFILE "blinker.slow.hack"
// `define ROMFILE "counter_no_loop.hack"
// `define ROMFILE "counter_keys.hack"
// `define ROMFILE "memory.hack"
// `define ROMFILE "counter.hack"
// `define ROMFILE "keys_leds.hack"

`include "../../modules/CLK_Divider.v"
`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
`include "../../modules/Xor.v"
`include "../../modules/Mux.v"
`include "../../modules/Or8Way.v"
`include "../../modules/Nand16.v"
`include "../../modules/Not16.v"
`include "../../modules/Add16.v"
`include "../../modules/And16.v"
`include "../../modules/Mux16.v"
`include "../../modules/ALU.v"
`include "../../modules/HalfAdder.v"
`include "../../modules/FullAdder.v"
`include "../../modules/Reset.v"
`include "../../modules/CPU.v"
`include "../../modules/ROM.v"
`include "../../modules/Memory.v"
`include "../../modules/Bit.v"
`include "../../modules/PC.v"
`include "../../modules/DFF.v"
`include "../../modules/BitShift9R.v"
`include "../../modules/Register.v"
`include "../../modules/UartRX.v"
`include "../../modules/UartTX.v"
`include "../../modules/MemoryMappedIO.v"
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
    output UART_TX
);


    // UART TX module
    reg [15:0] uart_data = 16'h0AFF; // 16-bit data, start with 16'b0
    reg uart_load = 0;
    reg tx_busy;

    UartTX uart_tx (
        .CLK_100MHz(CLK_100MHz),
        .load(uart_load),  // Control load signal to start transmission
        .in(uart_data),    // Input data to be transmitted (16 bits)
        .TX(UART_TX),
        .tx_busy(tx_busy)
    );

    // Clear the uart_load signal on the next clock cycle to ensure a pulse
    always @(posedge CLK_100MHz) begin
        if (uart_load && !tx_busy)
            uart_load <= 0;
    end


    // Invert the inputs (example)
    wire inv_0, inv_1;
    Not Not1(.in(BUT[0]), .out(inv_0));
    Not Not2(.in(BUT[1]), .out(inv_1));

    // Connect the inverted signals to LEDs (example)
    assign LED[0] = inv_0;
    assign LED[1] = inv_1;

endmodule

