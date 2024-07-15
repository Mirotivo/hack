module FullAdder(
	input a,
	input b,
	input c,
	output sum,
	output carry
);

	wire sumab;
	wire carryab;
	wire carryabc;
    HalfAdder HalfAdder1(.a(a), .b(b), .sum(sumab), .carry(carryab));
    HalfAdder HalfAdder2(.a(sumab), .b(c), .sum(sum), .carry(carryabc));
	Or Or(.a(carryab), .b(carryabc), .out(carry));

endmodule
