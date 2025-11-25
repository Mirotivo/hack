/**
 * The module DMux8Way is an 8-way 1-bit demultiplexer
 * Routes input to one of eight outputs based on 3-bit SEL
 * 
 * SEL[2:0]: 000=A, 001=B, 010=C, 011=D, 100=E, 101=F, 110=G, 111=H
 */
`default_nettype none
module DMux8Way(
    // Data Interface
    input IN,
    output A,
    output B,
    output C,
    output D,
    output E,
    output F,
    output G,
    output H,

    // Control Interface
    input [2:0] SEL
);

    // Internal signals
    wire not_sel0;
    wire not_sel1;
    wire not_sel2;
    wire sel_a1, sel_b1, sel_c1, sel_d1, sel_e1, sel_f1, sel_g1, sel_h1;
    wire sel_a, sel_b, sel_c, sel_d, sel_e, sel_f, sel_g, sel_h;

    // Module instantiations
    
    Not not1(.in(SEL[0]), .out(not_sel0));
    Not not2(.in(SEL[1]), .out(not_sel1));
    Not not3(.in(SEL[2]), .out(not_sel2));
    
    And and1(.a(not_sel0), .b(not_sel1), .out(sel_a1));
    And and3(.a(sel_a1), .b(not_sel2), .out(sel_a));
    And and4(.a(sel_a), .b(IN), .out(A));
    
    And and5(.a(SEL[0]), .b(not_sel1), .out(sel_b1));
    And and6(.a(sel_b1), .b(not_sel2), .out(sel_b));
    And and7(.a(sel_b), .b(IN), .out(B));
    
    And and8(.a(not_sel0), .b(SEL[1]), .out(sel_c1));
    And and9(.a(sel_c1), .b(not_sel2), .out(sel_c));
    And and10(.a(sel_c), .b(IN), .out(C));
    
    And and11(.a(SEL[0]), .b(SEL[1]), .out(sel_d1));
    And and12(.a(sel_d1), .b(not_sel2), .out(sel_d));
    And and13(.a(sel_d), .b(IN), .out(D));
    
    And and14(.a(not_sel0), .b(not_sel1), .out(sel_e1));
    And and15(.a(sel_e1), .b(SEL[2]), .out(sel_e));
    And and16(.a(sel_e), .b(IN), .out(E));
    
    And and17(.a(SEL[0]), .b(not_sel1), .out(sel_f1));
    And and18(.a(sel_f1), .b(SEL[2]), .out(sel_f));
    And and19(.a(sel_f), .b(IN), .out(F));
    
    And and20(.a(not_sel0), .b(SEL[1]), .out(sel_g1));
    And and21(.a(sel_g1), .b(SEL[2]), .out(sel_g));
    And and22(.a(sel_g), .b(IN), .out(G));
    
    And and23(.a(SEL[0]), .b(SEL[1]), .out(sel_h1));
    And and24(.a(sel_h1), .b(SEL[2]), .out(sel_h));
    And and25(.a(sel_h), .b(IN), .out(H));

endmodule
