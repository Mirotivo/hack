/**
 * The module Or16 is a 16-bit OR gate
 * Implements: OUT = A OR B (bitwise)
 */
`default_nettype none
module Or16(
    // Data Interface
    input [15:0] A,
    input [15:0] B,
    output [15:0] OUT
);

    // Internal signals
    wire [15:0] not_a;
    wire [15:0] not_b;
    wire [15:0] not_ab;

    // Module instantiations
    
    Not16 not16_1(.IN(A), .OUT(not_a));
    Not16 not16_2(.IN(B), .OUT(not_b));
    And16 and16(.A(not_a), .B(not_b), .OUT(not_ab));
    Not16 not16_3(.IN(not_ab), .OUT(OUT));

endmodule
