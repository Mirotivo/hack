/**
 * The module CLK_Divider divides the input clock frequency
 * Generates a slower clock signal and provides clock count
 */
`default_nettype none
module CLK_Divider (
    // Clock
    input wire CLK_IN,

    // Configuration
    input wire [31:0] DIVISOR,

    // Outputs
    output reg CLK_OUT,
    output reg [31:0] CLK_COUNT
);

    // --------------------------
    // Sequential logic
    // --------------------------
    
    initial begin
        CLK_OUT = 1;
        CLK_COUNT = 0;
    end
    
    always @(posedge CLK_IN) begin
        CLK_COUNT <= CLK_COUNT + 1;
        if (CLK_COUNT == DIVISOR) begin
            CLK_COUNT <= 0;
            CLK_OUT <= ~CLK_OUT;
        end
    end

endmodule
