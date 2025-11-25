/**
 * The module Reset delivers a reset signal at power up
 * which is clocked by CLK_100MHz
 *
 * The timing diagram:
 * -------------------------------------------
 * CLK     0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 ...
 * -------------------------------------------
 * RESET   0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 ...
 * -------------------------------------------
 */
`default_nettype none
module Reset(
    // Clock
    input wire CLK_100MHz,

    // Reset Output
    output wire RESET
);

    // Internal signals
    reg done;
    reg reset_r;

    // Initial blocks
    
    initial begin
        done = 0;
        reset_r = 0;
    end

    // Sequential logic
    
    // Remember that reset has been done
    always @(posedge CLK_100MHz)
        done <= 1;

    // Reset signal generation
    always @(posedge CLK_100MHz) begin
        if (done == 0)
            reset_r <= 1;
        else
            reset_r <= 0;
    end

    // Combinational logic
    
    assign RESET = reset_r;

endmodule
