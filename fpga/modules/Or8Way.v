/**
 * The module Or8Way is an 8-way OR gate
 * Implements: OUT = IN[0] OR IN[1] OR ... OR IN[7]
 */
`default_nettype none
module Or8Way(
    // Data Interface
    input [7:0] IN,
    output OUT
);

    // Internal signals
    wire out_01;
    wire out_23;
    wire out_45;
    wire out_67;
    wire out_0123;
    wire out_4567;

    // Module instantiations
    
    Or or1(.A(IN[0]), .B(IN[1]), .OUT(out_01));
    Or or2(.A(IN[2]), .B(IN[3]), .OUT(out_23));
    Or or3(.A(IN[4]), .B(IN[5]), .OUT(out_45));
    Or or4(.A(IN[6]), .B(IN[7]), .OUT(out_67));
    Or or5(.A(out_01), .B(out_23), .OUT(out_0123));
    Or or6(.A(out_45), .B(out_67), .OUT(out_4567));
    Or or7(.A(out_0123), .B(out_4567), .OUT(OUT));

endmodule
