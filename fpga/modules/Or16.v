module Or16(
	input[15:0] a,
	input[15:0] b,
	output[15:0] out
);

	wire[15:0] nota;
	wire[15:0] notb;
	wire[15:0] notab;
    Not16 Not16(.in(a), .out(nota));
	Not16 Not16_2(.in(b), .out(notb));
	And16 And16(.a(nota), .b(notb), .out(notab));
	Not16 Not16_3(.in(notab), .out(out));

endmodule
