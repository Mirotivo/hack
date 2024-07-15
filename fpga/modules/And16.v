module And16(
	input[15:0] a,
	input[15:0] b,
	output[15:0] out
);

	wire[15:0] aNandb;
	Nand16 Nand16(.a(a), .b(b), .out(aNandb));
	Not16 Not16(.in(aNandb), .out(out));

endmodule
