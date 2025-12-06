/**
 * The module Inc16 is a 16-bit incrementer
 * Adds 1 to a 16-bit value
 * 
 * OUT = IN + 1
 */
`default_nettype none
module Inc16(
    // Data Interface
    input [15:0] IN,
    output [15:0] OUT
);

    // --------------------------
    // Module instantiations
    // --------------------------
    
    Add16 add16(.A(IN), .B(16'b0000000000000001), .OUT(OUT));

endmodule
