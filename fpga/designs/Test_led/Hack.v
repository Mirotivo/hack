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
    output reg always_true
);
    // Set the output of the pin to always be high
    always @(*) begin
        always_true = 1;
    end
endmodule
