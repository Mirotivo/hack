/**
 * The module And16 is a 16-bit AND gate
 * Implements: OUT = A AND B (bitwise)
 */
`default_nettype none
module And16(
    // Data Interface
    input [15:0] A,
    input [15:0] B,
    output [15:0] OUT
);

    // --------------------------
    // Internal signals
    // --------------------------
    wire [15:0] a_nand_b;

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Nand16 nand16(.A(A), .B(B), .OUT(a_nand_b));
    Not16 not16(.IN(a_nand_b), .OUT(OUT));

endmodule
