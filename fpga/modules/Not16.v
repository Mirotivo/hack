/**
 * The module Not16 is a 16-bit NOT gate
 * Implements: OUT = NOT IN (bitwise)
 */
`default_nettype none
module Not16(
    // Data Interface
    input [15:0] IN,
    output [15:0] OUT
);

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Nand16 nand16(.A(IN), .B(IN), .OUT(OUT));

endmodule
