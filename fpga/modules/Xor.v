module Xor(
	input a,
	input b,
	output out
);

	wire aOrb;
	wire aAndb;
	Or Or1(.a(a), .b(b), .out(aOrb));
	Nand Nand1(.a(a), .b(b), .out(aAndb));
	And And1(.a(aOrb), .b(aAndb), .out(out));

endmodule
