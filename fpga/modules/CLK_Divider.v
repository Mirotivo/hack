module CLK_Divider (
    input wire clk_in,
    input wire [31:0] divisor,
    output reg clk_out,
    output reg [31:0] clk_count
);
    initial begin
        clk_out = 1;
        clk_count = 0;
    end

    always @(posedge clk_in) begin
        clk_count <= clk_count + 1;
        if (clk_count == divisor) begin
            clk_count <= 0;
            clk_out <= ~clk_out;
        end
    end

endmodule
