/**
 * The module Hack is a blinking LED test
 * Blinks a single LED at 1 Hz (toggles every second)
 * It connects the external pins of our FPGA (Hack.pcf)
 * to test basic clock division and LED control
 */
`default_nettype none

`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
`include "../../modules/CLK_Divider.v"

module Hack (
    // Clock
    input wire CLK_100MHz,

    // GPIO (LED)
    output reg led
);

    // Internal signals
    wire clk_out;
    wire [31:0] clk_count;

    // Module instantiations
    
    // Divide the input clock frequency by 100 million to get a toggle every second
    CLK_Divider divider_inst (
        .CLK_IN(CLK_100MHz),
        .DIVISOR(100000000),
        .CLK_OUT(clk_out),
        .CLK_COUNT(clk_count)
    );

    // Combinational logic
    
    // Set the LED to follow the divided clock
    always @(*) begin
        led = clk_out;
    end

endmodule
