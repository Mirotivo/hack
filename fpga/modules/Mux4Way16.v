/**
 * The module Mux4Way16 is a 4-way 16-bit multiplexer
 * Selects one of four 16-bit inputs based on 2-bit SEL
 * 
 * OUT = SEL[1:0] selects: 00=A, 01=B, 10=C, 11=D
 */
`default_nettype none
module Mux4Way16(
    // Data Interface
    input [15:0] A,
    input [15:0] B,
    input [15:0] C,
    input [15:0] D,
    output [15:0] OUT,

    // Control Interface
    input [1:0] SEL
);

    // --------------------------
    // Internal signals
    // --------------------------
    wire [15:0] out_ab;
    wire [15:0] out_cd;

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Mux16 mux16_1(.A(A), .B(B), .SEL(SEL[0]), .OUT(out_ab));
    Mux16 mux16_2(.A(C), .B(D), .SEL(SEL[0]), .OUT(out_cd));
    Mux16 mux16_3(.A(out_ab), .B(out_cd), .SEL(SEL[1]), .OUT(OUT));

endmodule
