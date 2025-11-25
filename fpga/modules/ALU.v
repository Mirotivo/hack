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
    Mux16 g1(.a(X), .b(16'b0), .sel(ZX), .out(x1));          // if (ZX == 1) set x = 0
    Not16 g2(.in(x1), .out(not_x1));
    Mux16 g3(.a(x1), .b(not_x1), .sel(NX), .out(x2));        // if (NX == 1) set x = !x

    // Y input processing
    Mux16 g4(.a(Y), .b(16'b0), .sel(ZY), .out(y1));          // if (ZY == 1) set y = 0
    Not16 g5(.in(y1), .out(not_y1));
    Mux16 g6(.a(y1), .b(not_y1), .sel(NY), .out(y2));        // if (NY == 1) set y = !y

    // Function selection
    Add16 g7(.a(x2), .b(y2), .out(add_xy));                  // add_xy = x + y
    And16 g8(.a(x2), .b(y2), .out(and_xy));                  // and_xy = x & y
    Mux16 g9(.a(and_xy), .b(add_xy), .sel(F), .out(o1));     // if (F == 1) set out = x + y else set out = x & y
    
    // Output processing
    Not16 g10(.in(o1), .out(not_o1));
    Mux16 g11(.a(o1), .b(not_o1), .sel(NO), .out(o2));       // if (NO == 1) set out = !out

    // Status flags
    Or8Way g13(.in(o2[7:0]), .out(or_low));                  // or_low = Or(out[0..7])
    Or8Way g14(.in(o2[15:8]), .out(or_high));                // or_high = Or(out[8..15])
    Or g15(.a(or_low), .b(or_high), .out(not_zr));           // not_zr = Or(out[0..15])
    Not g16(.in(not_zr), .out(ZR));                          // ZR = !not_zr
    And g17(.a(o2[15]), .b(o2[15]), .out(NG));               // NG = out[15]

    // Combinational logic
    
    assign OUT = o2;

endmodule
