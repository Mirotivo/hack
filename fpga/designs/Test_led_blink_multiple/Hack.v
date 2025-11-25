/**
 * The module Hack is a multi-LED blinking test
 * Blinks 4 LEDs with alternating patterns at 1 Hz
 * It connects the external pins of our FPGA (Hack.pcf)
 * to test basic clock division and multiple LED control
 */
`default_nettype none

`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
`include "../../modules/CLK_Divider.v"

module Hack (
    // Clock
    input wire clk_in,

    // GPIO (LEDs)
    output reg [3:0] leds
);

    // Internal signals
    wire clk_out;
    wire [31:0] clk_count;

    // Module instantiations
    
    // Divide the input clock frequency by 100 million to get a toggle every second
    CLK_Divider divider_inst (
        .CLK_IN(clk_in),
        .DIVISOR(100000000),
        .CLK_OUT(clk_out),
        .CLK_COUNT(clk_count)
    );

    // Combinational logic
    
    // Set LEDs to follow alternating pattern based on divided clock
    always @(*) begin
        leds[0] = clk_out;
        leds[1] = ~clk_out;
        leds[2] = clk_out;
        leds[3] = ~clk_out;
    end

endmodule
