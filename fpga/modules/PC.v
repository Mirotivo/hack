/**
 * The module PC is a Program Counter (16-bit register with increment)
 * Supports load, increment, and reset operations
 * 
 * Priority: reset > load > increment
 */
`default_nettype none
module PC(
    // Clock and Reset
    input wire CLK,
    input wire RESET,

    // Control Interface
    input wire LOAD,
    input wire INC,

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
        if (RESET)
            OUT <= 16'b0;
        else if (LOAD)
            OUT <= IN;
        else if (INC)
            OUT <= OUT + 1;
    end

endmodule
