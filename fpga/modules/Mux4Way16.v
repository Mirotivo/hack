module Mux4Way16(
	input[15:0] a,
	input[15:0] b,
	input[15:0] c,
	input[15:0] d,
	input[1:0] sel,
	output[15:0] out
);

	wire[15:0] outab;
	wire[15:0] outcd;
	Mux16 Mux16_1(.a(a), .b(b), .sel(sel[0]), .out(outab));
	Mux16 Mux16_2(.a(c), .b(d), .sel(sel[0]), .out(outcd));
	Mux16 Mux16_3(.a(outab), .b(outcd), .sel(sel[1]), .out(out));

endmodule
