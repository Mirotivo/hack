/**
 * The module Mux8Way16 is an 8-way 16-bit multiplexer
 * Selects one of eight 16-bit inputs based on 3-bit SEL
 * 
 * OUT = SEL[2:0] selects: 000=A, 001=B, 010=C, 011=D, 100=E, 101=F, 110=G, 111=H
 */
`default_nettype none
module Mux8Way16(
    // Data Interface
    input [15:0] A,
    input [15:0] B,
    input [15:0] C,
    input [15:0] D,
    input [15:0] E,
    input [15:0] F,
    input [15:0] G,
    input [15:0] H,
    output [15:0] OUT,

    // Control Interface
    input [2:0] SEL
);

    // Internal signals
    wire [15:0] out_abcd;
    wire [15:0] out_efgh;

    // Module instantiations
    
    Mux4Way16 mux4way16_1(.A(A), .B(B), .C(C), .D(D), .SEL(SEL[1:0]), .OUT(out_abcd));
    Mux4Way16 mux4way16_2(.A(E), .B(F), .C(G), .D(H), .SEL(SEL[1:0]), .OUT(out_efgh));
    Mux16 mux16(.A(out_abcd), .B(out_efgh), .SEL(SEL[2]), .OUT(OUT));

endmodule
