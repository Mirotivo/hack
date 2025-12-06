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

    // --------------------------
    // Internal signals
    // --------------------------
    wire not_sel0;
    wire not_sel1;
    wire not_sel2;
    wire sel_a1, sel_b1, sel_c1, sel_d1, sel_e1, sel_f1, sel_g1, sel_h1;
    wire sel_a, sel_b, sel_c, sel_d, sel_e, sel_f, sel_g, sel_h;

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Not not1(.IN(SEL[0]), .OUT(not_sel0));
    Not not2(.IN(SEL[1]), .OUT(not_sel1));
    Not not3(.IN(SEL[2]), .OUT(not_sel2));
    
    And and1(.A(not_sel0), .B(not_sel1), .OUT(sel_a1));
    And and3(.A(sel_a1), .B(not_sel2), .OUT(sel_a));
    And and4(.A(sel_a), .B(IN), .OUT(A));
    
    And and5(.A(SEL[0]), .B(not_sel1), .OUT(sel_b1));
    And and6(.A(sel_b1), .B(not_sel2), .OUT(sel_b));
    And and7(.A(sel_b), .B(IN), .OUT(B));
    
    And and8(.A(not_sel0), .B(SEL[1]), .OUT(sel_c1));
    And and9(.A(sel_c1), .B(not_sel2), .OUT(sel_c));
    And and10(.A(sel_c), .B(IN), .OUT(C));
    
    And and11(.A(SEL[0]), .B(SEL[1]), .OUT(sel_d1));
    And and12(.A(sel_d1), .B(not_sel2), .OUT(sel_d));
    And and13(.A(sel_d), .B(IN), .OUT(D));
    
    And and14(.A(not_sel0), .B(not_sel1), .OUT(sel_e1));
    And and15(.A(sel_e1), .B(SEL[2]), .OUT(sel_e));
    And and16(.A(sel_e), .B(IN), .OUT(E));
    
    And and17(.A(SEL[0]), .B(not_sel1), .OUT(sel_f1));
    And and18(.A(sel_f1), .B(SEL[2]), .OUT(sel_f));
    And and19(.A(sel_f), .B(IN), .OUT(F));
    
    And and20(.A(not_sel0), .B(SEL[1]), .OUT(sel_g1));
    And and21(.A(sel_g1), .B(SEL[2]), .OUT(sel_g));
    And and22(.A(sel_g), .B(IN), .OUT(G));
    
    And and23(.A(SEL[0]), .B(SEL[1]), .OUT(sel_h1));
    And and24(.A(sel_h1), .B(SEL[2]), .OUT(sel_h));
    And and25(.A(sel_h), .B(IN), .OUT(H));

endmodule
