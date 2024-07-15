module Mux8Way16(
	input[15:0] a,
	input[15:0] b,
	input[15:0] c,
	input[15:0] d,
	input[15:0] e,
	input[15:0] f,
	input[15:0] g,
	input[15:0] h,
	input[2:0] sel,
	output[15:0] out
);

	wire[15:0] outabcd;
	wire[15:0] outdefg;
	Mux4Way16 Mux4Way16_1(.a(a), .b(b), .c(c), .d(d), .sel(sel[1:0]), .out(outabcd));
	Mux4Way16 Mux4Way16_2(.a(e), .b(f), .c(g), .d(h), .sel(sel[1:0]), .out(outdefg));
	Mux16 Mux16(.a(outabcd), .b(outdefg), .sel(sel[2]), .out(out));

endmodule
