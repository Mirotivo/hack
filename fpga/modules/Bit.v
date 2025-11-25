/**
 * The module Bit is a 1-bit register with load control
 * Stores and outputs a single bit value
 */
`default_nettype none
module Bit(
    // Clock
    input wire CLK,

    // Control Interface
    input wire LOAD,

    // Data Interface
    input wire IN,
    output reg OUT
);

    // Initial blocks
    
    initial begin
        OUT = 1'b0;
    end

    // Sequential logic
    
    always @(posedge CLK) begin
        if (LOAD)
            OUT <= IN;
    end

endmodule
