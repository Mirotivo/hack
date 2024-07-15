module DMux8Way(
	input in,
	input[2:0] sel,
	output a,
	output b,
	output c,
	output d,
	output e,
	output f,
	output g,
	output h
);

	wire notsel0;
	wire notsel1;
	wire notsel2;
	wire sela1;
	wire selb1;
	wire selc1;
	wire seld1;
	wire sele1;
	wire self1;
	wire selg1;
	wire selh1;
	wire sela;
	wire selb;
	wire selc;
	wire seld;
	wire sele;
	wire self;
	wire selg;
	wire selh;
	Not Not1(.in(sel[0]), .out(notsel0));
	Not Not2(.in(sel[1]), .out(notsel1));
	Not Not3(.in(sel[2]), .out(notsel2));
	And And1(.a(notsel0), .b(notsel1), .out(sela1));
	And And3(.a(sela1), .b(notsel2), .out(sela));
	And And4(.a(sela), .b(in), .out(a));
	And And5(.a(sel[0]), .b(notsel1), .out(selb1));
	And And6(.a(selb1), .b(notsel2), .out(selb));
	And And7(.a(selb), .b(in), .out(b));
	And And8(.a(notsel0), .b(sel[1]), .out(selc1));
	And And9(.a(selc1), .b(notsel2), .out(selc));
	And And10(.a(selc), .b(in), .out(c));
	And And11(.a(sel[0]), .b(sel[1]), .out(seld1));
	And And12(.a(seld1), .b(notsel2), .out(seld));
	And And13(.a(seld), .b(in), .out(d));
	And And14(.a(notsel0), .b(notsel1), .out(sele1));
	And And15(.a(sele1), .b(sel[2]), .out(sele));
	And And16(.a(sele), .b(in), .out(e));
	And And17(.a(sel[0]), .b(notsel1), .out(self1));
	And And18(.a(self1), .b(sel[2]), .out(self));
	And And19(.a(self), .b(in), .out(f));
	And And20(.a(notsel0), .b(sel[1]), .out(selg1));
	And And21(.a(selg1), .b(sel[2]), .out(selg));
	And And22(.a(selg), .b(in), .out(g));
	And And23(.a(sel[0]), .b(sel[1]), .out(selh1));
	And And24(.a(selh1), .b(sel[2]), .out(selh));
	And And25(.a(selh), .b(in), .out(h));

endmodule
