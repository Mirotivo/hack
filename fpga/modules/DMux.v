/**
 * The module DMux is a 1-bit demultiplexer
 * Routes input to one of two outputs based on SEL
 * 
 * A = SEL==0 ? IN : 0
 * B = SEL==1 ? IN : 0
 */
`default_nettype none
module DMux(
    // Data Interface
    input IN,
    output A,
    output B,

    // Control Interface
    input SEL
);

    // Internal signals
    wire not_sel;

    // Module instantiations
    
    Not not_gate(.in(SEL), .out(not_sel));
    And and_1(.a(not_sel), .b(IN), .out(A));
    And and_2(.a(SEL), .b(IN), .out(B));

endmodule
