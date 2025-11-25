/**
 * The module Nand is a 1-bit NAND gate (primitive)
 * Implements: OUT = NOT (A AND B)
 */
`default_nettype none
module Nand(
    // Data Interface
    input A,
    input B,
    output OUT
);

    // Combinational logic
    
    nand(OUT, A, B);

endmodule
