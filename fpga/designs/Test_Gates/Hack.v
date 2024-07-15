`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
/** 
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk,rst,rom)
 *
 */

`default_nettype none
module Hack(                        // top level module 
    input  wire clk,                
    input  wire [1:0] but,          // buttons  (0 if pressed, 1 if released)
    output wire [1:0] led           // leds     (0 off, 1 on)
);

    wire inv_0, inv_1;
    Not Not1(.in(but[0]), .out(inv_0));
    Not Not2(.in(but[1]), .out(inv_1));

    And And1(.a(inv_0), .b(inv_1), .out(led[0]));
    Or Or1(.a(inv_0), .b(inv_1), .out(led[1]));

endmodule
