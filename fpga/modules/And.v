module And(
	input a,
	input b,
	output out
);

	wire aNandb;
	Nand Nand1(.a(a), .b(b), .out(aNandb));
	Not Not1(.in(aNandb), .out(out));

endmodule
