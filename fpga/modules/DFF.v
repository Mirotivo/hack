/**
 * The module DFF is a D Flip-Flop
 * Captures input value on clock edge
 */
`default_nettype none
module DFF(
    // Clock
    input wire CLK,

    // Data Interface
    input wire IN,
    output reg OUT
);

    // --------------------------
    // Sequential logic
    // --------------------------
    
    initial begin
        OUT = 1'b0;
    end
    
    always @(posedge CLK) begin
        OUT <= IN;
    end

endmodule
