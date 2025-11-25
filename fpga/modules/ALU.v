/**
 * The module ALU is an Arithmetic Logic Unit (Hack ALU)
 * Performs arithmetic and logic operations based on control bits
 * 
 * Control bits:
 * ZX, NX - Zero and negate X input
 * ZY, NY - Zero and negate Y input
 * F - Function select (1=add, 0=and)
 * NO - Negate output
 * 
 * Status outputs:
 * ZR - Zero flag (out == 0)
 * NG - Negative flag (out < 0)
 */
`default_nettype none
module ALU(
    // Data Interface
    input [15:0] X,
    input [15:0] Y,
    output [15:0] OUT,

    // Control Interface
    input ZX,
    input NX,
    input ZY,
    input NY,
    input F,
    input NO,

    // Status Outputs
    output ZR,
    output NG
);

    // Internal signals
    wire [15:0] x1;
    wire [15:0] not_x1;
    wire [15:0] x2;
    wire [15:0] y1;
    wire [15:0] not_y1;
    wire [15:0] y2;
    wire [15:0] and_xy;
    wire [15:0] add_xy;
    wire [15:0] o1;
    wire [15:0] not_o1;
    wire [15:0] o2;
    wire or_low;
    wire or_high;
    wire not_zr;

    // Module instantiations
    
    // X input processing
    Mux16 g1(.A(X), .B(16'b0), .SEL(ZX), .OUT(x1));          // if (ZX == 1) set x = 0
    Not16 g2(.IN(x1), .OUT(not_x1));
    Mux16 g3(.A(x1), .B(not_x1), .SEL(NX), .OUT(x2));        // if (NX == 1) set x = !x

    // Y input processing
    Mux16 g4(.A(Y), .B(16'b0), .SEL(ZY), .OUT(y1));          // if (ZY == 1) set y = 0
    Not16 g5(.IN(y1), .OUT(not_y1));
    Mux16 g6(.A(y1), .B(not_y1), .SEL(NY), .OUT(y2));        // if (NY == 1) set y = !y

    // Function selection
    Add16 g7(.A(x2), .B(y2), .OUT(add_xy));                  // add_xy = x + y
    And16 g8(.A(x2), .B(y2), .OUT(and_xy));                  // and_xy = x & y
    Mux16 g9(.A(and_xy), .B(add_xy), .SEL(F), .OUT(o1));     // if (F == 1) set out = x + y else set out = x & y
    
    // Output processing
    Not16 g10(.IN(o1), .OUT(not_o1));
    Mux16 g11(.A(o1), .B(not_o1), .SEL(NO), .OUT(o2));       // if (NO == 1) set out = !out

    // Status flags
    Or8Way g13(.IN(o2[7:0]), .OUT(or_low));                  // or_low = Or(out[0..7])
    Or8Way g14(.IN(o2[15:8]), .OUT(or_high));                // or_high = Or(out[8..15])
    Or g15(.A(or_low), .B(or_high), .OUT(not_zr));           // not_zr = Or(out[0..15])
    Not g16(.IN(not_zr), .OUT(ZR));                          // ZR = !not_zr
    And g17(.A(o2[15]), .B(o2[15]), .OUT(NG));               // NG = out[15]

    // Combinational logic
    
    assign OUT = o2;

endmodule
