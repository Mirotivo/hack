/**
 * The module DMux4Way is a 4-way 1-bit demultiplexer
 * Routes input to one of four outputs based on 2-bit SEL
 * 
 * SEL[1:0]: 00=A, 01=B, 10=C, 11=D
 */
`default_nettype none
module DMux4Way(
    // Data Interface
    input IN,
    output A,
    output B,
    output C,
    output D,

    // Control Interface
    input [1:0] SEL
);

    // Internal signals
    wire not_sel0;
    wire not_sel1;
    wire sel_a;
    wire sel_b;
    wire sel_c;
    wire sel_d;

    // Module instantiations
    
    Not not1(.in(SEL[0]), .out(not_sel0));
    Not not2(.in(SEL[1]), .out(not_sel1));
    And and1(.a(not_sel0), .b(not_sel1), .out(sel_a));
    And and2(.a(sel_a), .b(IN), .out(A));
    And and3(.a(SEL[0]), .b(not_sel1), .out(sel_b));
    And and4(.a(sel_b), .b(IN), .out(B));
    And and5(.a(not_sel0), .b(SEL[1]), .out(sel_c));
    And and6(.a(sel_c), .b(IN), .out(C));
    And and7(.a(SEL[0]), .b(SEL[1]), .out(sel_d));
    And and8(.a(sel_d), .b(IN), .out(D));

endmodule
