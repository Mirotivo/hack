module DMux(
	input in,
	input sel,
	output a,
	output b
);

	wire notsel;
	Not Not(.in(sel), .out(notsel));
	And And_1(.a(notsel), .b(in), .out(a));
	And And_2(.a(sel), .b(in), .out(b));
endmodule
