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

    // --------------------------
    // Internal signals
    // --------------------------
    wire not_sel0;
    wire not_sel1;
    wire sel_a;
    wire sel_b;
    wire sel_c;
    wire sel_d;

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Not not1(.IN(SEL[0]), .OUT(not_sel0));
    Not not2(.IN(SEL[1]), .OUT(not_sel1));
    And and1(.A(not_sel0), .B(not_sel1), .OUT(sel_a));
    And and2(.A(sel_a), .B(IN), .OUT(A));
    And and3(.A(SEL[0]), .B(not_sel1), .OUT(sel_b));
    And and4(.A(sel_b), .B(IN), .OUT(B));
    And and5(.A(not_sel0), .B(SEL[1]), .OUT(sel_c));
    And and6(.A(sel_c), .B(IN), .OUT(C));
    And and7(.A(SEL[0]), .B(SEL[1]), .OUT(sel_d));
    And and8(.A(sel_d), .B(IN), .OUT(D));

endmodule
