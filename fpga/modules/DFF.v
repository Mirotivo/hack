module DFF(
	input wire in,
	input wire clk,
	output reg out
);

    // Initial block to set the initial value of the output register
    initial begin
        out = 1'b0;
    end

    always @(posedge clk) begin
        out <= in;
    end

endmodule
