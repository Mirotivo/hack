/**
 * The module Xor is a 1-bit XOR gate
 * Implements: OUT = A XOR B
 */
`default_nettype none
module Xor(
    // Data Interface
    input A,
    input B,
    output OUT
);

    // Internal signals
    wire a_or_b;
    wire a_nand_b;

    // Module instantiations
    
    Or or1(.A(A), .B(B), .OUT(a_or_b));
    Nand nand1(.A(A), .B(B), .OUT(a_nand_b));
    And and1(.A(a_or_b), .B(a_nand_b), .OUT(OUT));

endmodule
