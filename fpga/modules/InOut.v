`default_nettype none
module InOut(
	inout PIN,
	input dataW,
	output dataR,
	input dir
);
	assign PIN = dir ? dataW: 1'bz;
	assign dataR = PIN;
	
endmodule

