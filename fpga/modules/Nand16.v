/**
 * The module Nand16 is a 16-bit NAND gate
 * Implements: OUT = NOT (A AND B) (bitwise)
 */
`default_nettype none
module Nand16(
    // Data Interface
    input [15:0] A,
    input [15:0] B,
    output [15:0] OUT
);

    // Parameters
    parameter BITS = 16;

    // Module instantiations (generate loop)
    
    genvar bit;
    generate
        for (bit=0; bit<BITS; bit=bit+1) begin
            Nand nand_inst(.A(A[bit]), .B(B[bit]), .OUT(OUT[bit]));
        end
    endgenerate

endmodule
