module Nand16(
	input[15:0] a,
	input[15:0] b,
	output[15:0] out
);

	parameter BITS = 16;
	genvar bit;
	generate
		for (bit=0; bit<BITS; bit=bit+1)
		begin
			Nand Nand(.a(a[bit]), .b(b[bit]), .out(out[bit]));
		end
	endgenerate
endmodule
