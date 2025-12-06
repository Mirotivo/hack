`define RAMFILE "empty_ram.ram"
`define ROMFILE "blinker.hack"

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
 * The module Hack is a UART transmit test module
 * Continuously sends data via UART
 * It connects the external pins of our FPGA (Hack.pcf)
 * to test UART TX functionality with continuous transmission
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
    output UART_TX
);

    // Internal signals - UART
    reg [15:0] uart_data;
    reg uart_load;
    reg tx_busy;

    // Internal signals - Button processing
    wire inv_0;
    wire inv_1;

    // Module instantiations
    
    // GPIO - Button inversion (buttons are active low)
    Not not1(.IN(BUT[0]), .OUT(inv_0));
    Not not2(.IN(BUT[1]), .OUT(inv_1));

    // UART - Transmitter
    UartTX uart_tx (
        .CLK_100MHz(CLK_100MHz),
        .LOAD(uart_load),
        .IN(uart_data),
        .TX(UART_TX),
        .TX_BUSY(tx_busy)
    );

    // Sequential logic
    
    initial begin
        uart_data = 16'h0AFF;
        uart_load = 0;
    end
    
    // Clear the uart_load signal on the next clock cycle to ensure a pulse
    always @(posedge CLK_100MHz) begin
        if (uart_load && !tx_busy)
            uart_load <= 0;
    end

    // Combinational logic
    
    // Connect inverted button signals to LEDs
    assign LED[0] = inv_0;
    assign LED[1] = inv_1;

endmodule
