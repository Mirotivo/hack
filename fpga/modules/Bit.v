module Bit(
	input wire in,
	input wire clk,
	input wire load,
	output reg out
);

    // Initial block to set the initial value of the output
    initial begin
        out = 1'b0;
    end

	always @(posedge clk) begin
		if (load)
			out <= in;
	end

endmodule
