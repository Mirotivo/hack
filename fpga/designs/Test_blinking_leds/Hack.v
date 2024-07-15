`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
`include "../../modules/CLK_Divider.v"
/** 
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk,rst,rom)
 *
 */

`default_nettype none

module Hack(                        // top level module
    input wire clk_in,
    output reg [3:0] leds
);

    wire clk_out;
    // Divide the input clock frequency by 100 million to get a count every second
    CLK_Divider divider_inst (
        .clk_in(clk_in),
        .divisor(100000000),
        .clk_out(clk_out)
    );

    // Set the output of the pin to always be high
    always @(*) begin
        leds[0] = clk_out;
        leds[1] = ~clk_out;
        leds[2] = clk_out;
        leds[3] = ~clk_out;
    end
endmodule
