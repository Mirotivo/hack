/**
 * The module Mux is a 1-bit multiplexer
 * Selects between two 1-bit inputs based on sel
 * 
 * out = sel ? b : a
 */
`default_nettype none
module Mux(
    // Data Interface
    input A,
    input B,
    output OUT,

    // Control Interface
    input SEL
);

    // --------------------------
    // Internal signals
    // --------------------------
    wire not_sel;
    wire sel_a;
    wire sel_b;

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Not not_gate(.IN(SEL), .OUT(not_sel));
    And and1(.A(not_sel), .B(A), .OUT(sel_a));
    And and2(.A(SEL), .B(B), .OUT(sel_b));
    Or or_gate(.A(sel_a), .B(sel_b), .OUT(OUT));

endmodule
