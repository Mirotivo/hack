/**
 * The module HalfAdder is a half adder
 * Adds two 1-bit values, produces sum and carry
 * 
 * SUM = A XOR B
 * CARRY = A AND B
 */
`default_nettype none
module HalfAdder(
    // Data Interface
    input A,
    input B,
    output SUM,
    output CARRY
);

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Xor xor_gate(.A(A), .B(B), .OUT(SUM));
    And and_gate(.A(A), .B(B), .OUT(CARRY));

endmodule
