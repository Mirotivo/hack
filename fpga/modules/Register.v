module Register (
    input wire clk,
    input wire load,
    input wire [15:0] in,
    output reg [15:0] out
);
    // Initial block to set the initial value of the output register
    initial begin
        out = 16'b0;
    end

    always @(posedge clk) begin
        if (load)
            out <= in;
    end
endmodule
