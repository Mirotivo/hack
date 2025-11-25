/**
 * The module Mux16 is a 16-bit multiplexer
 * Selects between two 16-bit inputs based on SEL
 * 
 * OUT = SEL ? B : A
 */
`default_nettype none
module Mux16(
    // Data Interface
    input [15:0] A,
    input [15:0] B,
    output [15:0] OUT,

    // Control Interface
    input SEL
);

    // Module instantiations
    
    Mux mux0(.A(A[0]), .B(B[0]), .SEL(SEL), .OUT(OUT[0]));
    Mux mux1(.A(A[1]), .B(B[1]), .SEL(SEL), .OUT(OUT[1]));
    Mux mux2(.A(A[2]), .B(B[2]), .SEL(SEL), .OUT(OUT[2]));
    Mux mux3(.A(A[3]), .B(B[3]), .SEL(SEL), .OUT(OUT[3]));
    Mux mux4(.A(A[4]), .B(B[4]), .SEL(SEL), .OUT(OUT[4]));
    Mux mux5(.A(A[5]), .B(B[5]), .SEL(SEL), .OUT(OUT[5]));
    Mux mux6(.A(A[6]), .B(B[6]), .SEL(SEL), .OUT(OUT[6]));
    Mux mux7(.A(A[7]), .B(B[7]), .SEL(SEL), .OUT(OUT[7]));
    Mux mux8(.A(A[8]), .B(B[8]), .SEL(SEL), .OUT(OUT[8]));
    Mux mux9(.A(A[9]), .B(B[9]), .SEL(SEL), .OUT(OUT[9]));
    Mux mux10(.A(A[10]), .B(B[10]), .SEL(SEL), .OUT(OUT[10]));
    Mux mux11(.A(A[11]), .B(B[11]), .SEL(SEL), .OUT(OUT[11]));
    Mux mux12(.A(A[12]), .B(B[12]), .SEL(SEL), .OUT(OUT[12]));
    Mux mux13(.A(A[13]), .B(B[13]), .SEL(SEL), .OUT(OUT[13]));
    Mux mux14(.A(A[14]), .B(B[14]), .SEL(SEL), .OUT(OUT[14]));
    Mux mux15(.A(A[15]), .B(B[15]), .SEL(SEL), .OUT(OUT[15]));

endmodule
