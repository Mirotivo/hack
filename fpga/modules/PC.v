module PC(
    input wire clk,
    input wire [15:0] in,
    input wire load,
    input wire inc,
    input wire reset,
    output reg [15:0] out
);

    // Initial block to set the initial value of the program counter
    initial begin
        out = 16'b0;
    end

    always @(posedge clk) begin
        if (reset)
            out <= 16'b0;
        else if (load)
            out <= in;
        else if (inc)
            out <= out + 1;
    end

endmodule

