/**
 * The module FullAdder is a full adder
 * Adds three 1-bit values, produces sum and carry
 * 
 * SUM = A XOR B XOR C
 * CARRY = (A AND B) OR (C AND (A XOR B))
 */
`default_nettype none
module FullAdder(
    // Data Interface
    input A,
    input B,
    input C,
    output SUM,
    output CARRY
);

    // --------------------------
    // Internal signals
    // --------------------------
    wire sum_ab;
    wire carry_ab;
    wire carry_abc;

    // --------------------------
    // Module instantiations
    // --------------------------
    
    HalfAdder half_adder1(.A(A), .B(B), .SUM(sum_ab), .CARRY(carry_ab));
    HalfAdder half_adder2(.A(sum_ab), .B(C), .SUM(SUM), .CARRY(carry_abc));
    Or or_gate(.A(carry_ab), .B(carry_abc), .OUT(CARRY));

endmodule
