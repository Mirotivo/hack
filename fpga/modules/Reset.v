/**
 * The module rst delivers a reset signal at power up which
 * is clocked by clk.
 *
 * The timing diagram should be:
 * -------------------------------------------
 * clk     0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 ...
 * -------------------------------------------
 * reset   0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 ...
 * -------------------------------------------
 */

module Reset(
    input  wire CLK_100MHz,
    output wire reset
);

    // your implementation comes here:

    // remember that you did it
    reg done = 0;
    always @(posedge CLK_100MHz)
        done <= 1;

    // reset it on start
    reg reset_r = 0;
    always @(posedge CLK_100MHz) begin
        if (done==0) reset_r <=1;
        else reset_r <= 0;
	end

    assign reset = reset_r;

endmodule
