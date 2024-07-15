module HalfAdder(
	input a,
	input b,
	output sum,
	output carry
);

	Xor Xor(.a(a), .b(b), .out(sum));
	And And(.a(a), .b(b), .out(carry));

endmodule
