/**
 * The module Hack is a simple LED test
 * Sets an LED pin to always be HIGH
 * It connects the external pins of our FPGA (Hack.pcf)
 * to test basic output functionality
 */
`default_nettype none

`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"

module Hack (
    // GPIO (LED)
    output reg always_true
);

    // Combinational logic
    
    // Set the output pin to always be HIGH
    always @(*) begin
        always_true = 1;
    end

endmodule
