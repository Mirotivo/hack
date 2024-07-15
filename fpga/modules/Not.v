module Not(
	input in,
	output out
);

	Nand Nand1(.a(in), .b(in), .out(out));

endmodule
