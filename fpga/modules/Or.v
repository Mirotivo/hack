/**
 * The module Or is a 1-bit OR gate
 * Implements: OUT = A OR B
 */
`default_nettype none
module Or (
    // Data Interface
    input A,
    input B,
    output OUT
);

    // --------------------------
    // Internal signals
    // --------------------------
    wire not_a;
    wire not_b;
    wire not_ab;

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Not not1(.IN(A), .OUT(not_a));
    Not not2(.IN(B), .OUT(not_b));
    And and1(.A(not_a), .B(not_b), .OUT(not_ab));
    Not not3(.IN(not_ab), .OUT(OUT));

endmodule
