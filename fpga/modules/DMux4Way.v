module DMux4Way(
	input in,
	input[1:0] sel,
	output a,
	output b,
	output c,
	output d
);

	wire notsel0, notsel1;
	wire sela, selb, selc, seld;
	Not Not1(.in(sel[0]), .out(notsel0));
	Not Not2(.in(sel[1]), .out(notsel1));
	And And1(.a(notsel0), .b(notsel1), .out(sela));
	And And2(.a(sela), .b(in), .out(a));
	And And3(.a(sel[0]), .b(notsel1), .out(selb));
	And And4(.a(selb), .b(in), .out(b));
	And And5(.a(notsel0), .b(sel[1]), .out(selc));
	And And6(.a(selc), .b(in), .out(c));
	And And7(.a(sel[0]), .b(sel[1]), .out(seld));
	And And8(.a(seld), .b(in), .out(d));
endmodule
