/**
 * The module Not is a 1-bit NOT gate
 * Implements: OUT = NOT IN
 */
`default_nettype none
module Not(
    // Data Interface
    input IN,
    output OUT
);

    // Module instantiations
    
    Nand nand1(.A(IN), .B(IN), .OUT(OUT));

endmodule
