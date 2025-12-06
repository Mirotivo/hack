/**
 * The module BitShift9R is a 9-bit right shift register
 * Supports load and shift operations with MSB input
 */
`default_nettype none
module BitShift9R (
    // Clock
    input wire CLK,

    // Control Interface
    input wire LOAD,
    input wire SHIFT,

    // Data Interface
    input wire [8:0] IN,
    input wire IN_MSB,
    output reg [8:0] OUT
);

    // --------------------------
    // Sequential logic
    // --------------------------
    
    initial begin
        OUT = 9'b0;
    end
    
    always @(posedge CLK) begin
        if (LOAD) begin
            OUT <= IN;
        end else if (SHIFT) begin
            OUT <= (OUT >> 1) | (IN_MSB << 8);
        end
    end

endmodule
