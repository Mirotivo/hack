/**
 * The module Hack is a blinking LED test for GateMate A1 FPGA
 * Blinks a single LED at 1 Hz (toggles every second)
 * It connects the external pins of our FPGA (Hack.ccf)
 * to test basic clock division and LED control
 * 
 * Target: GateMate A1 FPGA on Olimex board
 * Toolchain: OSS CAD Suite
 */
`default_nettype none

`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
`include "../../modules/CLK_Divider.v"

module Hack (
    // Clock - GateMate A1 typical clock is 10 MHz on Olimex board
    input wire CLK,

    // GPIO (LED)
    output reg LED
);

    // Internal signals
    wire clk_out;
    wire [31:0] clk_count;

    // Module instantiations
    
    // Divide the input clock frequency by 10 million to get a toggle every second
    // (10 MHz clock / 10,000,000 = 1 Hz)
    CLK_Divider divider_inst (
        .CLK_IN(CLK),
        .DIVISOR(10000000),
        .CLK_OUT(clk_out),
        .CLK_COUNT(clk_count)
    );

    // Combinational logic
    
    // Set the LED to follow the divided clock
    always @(*) begin
        LED = clk_out;
    end

endmodule
