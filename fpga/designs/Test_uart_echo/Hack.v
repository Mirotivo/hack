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
 * The module Hack is a UART echo test
 * Receives data via UART RX and echoes it back via UART TX
 * Buttons can clear the receiver
 * It connects the external pins of our FPGA (Hack.pcf)
 * to test UART RX/TX functionality with echo
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

    // Internal signals - UART RX
    wire [15:0] uart_rx_data;
    wire uart_rx_ready;
    reg uart_rx_clear;

    // Internal signals - UART TX
    reg [15:0] uart_tx_data;
    reg uart_tx_load;
    wire uart_tx_busy;

    // Internal signals - Button processing
    wire inv_0;
    wire inv_1;

    // Module instantiations
    
    // GPIO - Button inversion (buttons are active low)
    Not not1(.IN(BUT[0]), .OUT(inv_0));
    Not not2(.IN(BUT[1]), .OUT(inv_1));

    // UART - Receiver
    UartRX uart_rx (
        .CLK_100MHz(CLK_100MHz),
        .RX(UART_RX),
        .CLEAR(uart_rx_clear),
        .OUT(uart_rx_data),
        .RX_READY(uart_rx_ready)
    );

    // UART - Transmitter
    UartTX uart_tx (
        .CLK_100MHz(CLK_100MHz),
        .LOAD(uart_tx_load),
        .IN(uart_tx_data),
        .TX(UART_TX),
        .TX_BUSY(uart_tx_busy)
    );

    // Sequential logic
    
    // UART echo control
    always @(posedge CLK_100MHz) begin
        // Clear the UART receiver if any button is pressed
        if (inv_0 || inv_1) begin
            uart_rx_clear <= 1;
        end else begin
            uart_rx_clear <= 0;
        end

        if (!uart_tx_busy) begin
            if (!uart_tx_load && uart_rx_ready) begin
                uart_tx_data <= uart_rx_data;   // Load received data into tx_data
                uart_tx_load <= 1;              // Trigger the UART transmitter
            end
        end else begin
            uart_tx_load <= 0;                  // De-assert the load signal
            uart_rx_clear <= 1;
        end
    end

    // Combinational logic
    
    // Connect status signals to LEDs
    assign LED[0] = uart_rx_clear;
    assign LED[1] = uart_rx_ready;

endmodule
