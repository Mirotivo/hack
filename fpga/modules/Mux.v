module Mux(
	input a,
	input b,
	input sel,
	output out
);

	wire notsel;
	wire sela;
	wire selb;
	Not Not(.in(sel), .out(notsel));
	And And1(.a(notsel), .b(a), .out(sela));
	And And2(.a(sel), .b(b), .out(selb));
	Or Or(.a(sela), .b(selb), .out(out));

endmodule
