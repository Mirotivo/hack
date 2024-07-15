module Add16(
	input[15:0] a,
	input[15:0] b,
	output[15:0] out
);

	wire[15:0] carry;
	HalfAdder HalfAdder0(.a(a[0]), .b(b[0]), .sum(out[0]), .carry(carry[0]));
	FullAdder FullAdder1(.a(a[1]), .b(b[1]), .c(carry[0]), .sum(out[1]), .carry(carry[1]));
	FullAdder FullAdder2(.a(a[2]), .b(b[2]), .c(carry[1]), .sum(out[2]), .carry(carry[2]));
	FullAdder FullAdder3(.a(a[3]), .b(b[3]), .c(carry[2]), .sum(out[3]), .carry(carry[3]));
	FullAdder FullAdder4(.a(a[4]), .b(b[4]), .c(carry[3]), .sum(out[4]), .carry(carry[4]));
	FullAdder FullAdder5(.a(a[5]), .b(b[5]), .c(carry[4]), .sum(out[5]), .carry(carry[5]));
	FullAdder FullAdder6(.a(a[6]), .b(b[6]), .c(carry[5]), .sum(out[6]), .carry(carry[6]));
	FullAdder FullAdder7(.a(a[7]), .b(b[7]), .c(carry[6]), .sum(out[7]), .carry(carry[7]));
	FullAdder FullAdder8(.a(a[8]), .b(b[8]), .c(carry[7]), .sum(out[8]), .carry(carry[8]));
	FullAdder FullAdder9(.a(a[9]), .b(b[9]), .c(carry[8]), .sum(out[9]), .carry(carry[9]));
	FullAdder FullAdder10(.a(a[10]), .b(b[10]), .c(carry[9]), .sum(out[10]), .carry(carry[10]));
	FullAdder FullAdder11(.a(a[11]), .b(b[11]), .c(carry[10]), .sum(out[11]), .carry(carry[11]));
	FullAdder FullAdder12(.a(a[12]), .b(b[12]), .c(carry[11]), .sum(out[12]), .carry(carry[12]));
	FullAdder FullAdder13(.a(a[13]), .b(b[13]), .c(carry[12]), .sum(out[13]), .carry(carry[13]));
	FullAdder FullAdder14(.a(a[14]), .b(b[14]), .c(carry[13]), .sum(out[14]), .carry(carry[14]));
	FullAdder FullAdder15(.a(a[15]), .b(b[15]), .c(carry[14]), .sum(out[15]), .carry(carry[15]));

endmodule
