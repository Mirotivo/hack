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


    // UART RX module
    wire [15:0] uart_rx_data;
    wire uart_rx_ready;
    reg uart_rx_clear;;

    UartRX uart_rx (
        .CLK_100MHz(CLK_100MHz),
        .RX(UART_RX),
        .clear(uart_rx_clear),
        .out(uart_rx_data),
        .rx_ready(uart_rx_ready)
    );

    // UART TX module
    wire [15:0] uart_tx_data;
    wire uart_tx_load;
    wire uart_tx_busy;

    UartTX uart_tx (
        .CLK_100MHz(CLK_100MHz),
        .load(uart_tx_load),  // Control load signal to start transmission
        .in(uart_tx_data), // Input data to be transmitted (8 bits)
        .TX(UART_TX),
        .tx_busy(uart_tx_busy)
    );

    always @(posedge CLK_100MHz) begin
        // Clear the UART receiver if any button is pressed
        if (inv_0 || inv_1) begin
            uart_rx_clear <= 1;
        end else begin
            uart_rx_clear <= 0;
        end

        if (!uart_tx_busy) begin
            if (!uart_tx_load && uart_rx_ready) begin
                uart_tx_data <= uart_rx_data; // Load received data into tx_data
                uart_tx_load <= 1;               // Trigger the UART transmitter
            end
        end else begin
            uart_tx_load <= 0;               // De-assert the load signal
            uart_rx_clear <= 1;
        end
    end

    // Invert the inputs (example)
    wire inv_0, inv_1;
    Not Not1(.in(BUT[0]), .out(inv_0));
    Not Not2(.in(BUT[1]), .out(inv_1));

    // Connect the inverted signals to LEDs (example)
    // assign LED[0] = inv_0;
    // assign LED[1] = inv_1;
    assign LED[0] = uart_rx_clear;
    assign LED[1] = uart_rx_ready;

endmodule

