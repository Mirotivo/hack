module Not16(
	input[15:0] in,
	output[15:0] out
);

	Nand16 Nand16(.a(in), .b(in), .out(out));

endmodule
