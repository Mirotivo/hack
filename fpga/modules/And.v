/**
 * The module And is a 1-bit AND gate
 * Implements: OUT = A AND B
 */
`default_nettype none
module And(
    // Data Interface
    input A,
    input B,
    output OUT
);

    // Internal signals
    wire a_nand_b;

    // Module instantiations
    
    Nand nand1(.A(A), .B(B), .OUT(a_nand_b));
    Not not1(.IN(a_nand_b), .OUT(OUT));

endmodule
