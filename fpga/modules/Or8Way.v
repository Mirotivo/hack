module Or8Way(
	input[7:0] in,
	output out
);
	wire out01;
	wire out23;
	wire out45;
	wire out67;
	wire out0123;
	wire out4567;
	Or Or1(.a(in[0]), .b(in[1]), .out(out01));
	Or Or2(.a(in[2]), .b(in[3]), .out(out23));
	Or Or3(.a(in[4]), .b(in[5]), .out(out45));
	Or Or4(.a(in[6]), .b(in[7]), .out(out67));
	Or Or5(.a(out01), .b(out23), .out(out0123));
	Or Or6(.a(out45), .b(out67), .out(out4567));
	Or Or7(.a(out0123), .b(out4567), .out(out));
endmodule
