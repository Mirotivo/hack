`default_nettype none

module BitShift9R (
    input wire clk,
    input wire [8:0] in,
    input wire inMSB,
    input wire load,
    input wire shift,
    output reg [8:0] out
);
    // Initial block to set the initial value of the output register
    initial begin
        out = 9'b0;
    end

    always @(posedge clk) begin
        if (load) begin
            out <= in;
        end else if (shift) begin
            out <= (out >> 1) | (inMSB << 8);
        end
    end

endmodule
