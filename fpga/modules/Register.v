/**
 * The module Register is a 16-bit register with load control
 * Stores and outputs 16-bit values
 */
`default_nettype none
module Register (
    // Clock
    input wire CLK,

    // Control Interface
    input wire LOAD,

    // Data Interface
    input wire [15:0] IN,
    output reg [15:0] OUT
);

    // Initial blocks
    
    initial begin
        OUT = 16'b0;
    end

    // Sequential logic
    
    always @(posedge CLK) begin
        if (LOAD)
            OUT <= IN;
    end

endmodule
