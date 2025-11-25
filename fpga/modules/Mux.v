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

    // Internal signals
    wire not_sel;
    wire sel_a;
    wire sel_b;

    // Module instantiations
    
    Not not_gate(.in(SEL), .out(not_sel));
    And and1(.a(not_sel), .b(A), .out(sel_a));
    And and2(.a(SEL), .b(B), .out(sel_b));
    Or or_gate(.a(sel_a), .b(sel_b), .out(OUT));

endmodule
