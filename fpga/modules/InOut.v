`default_nettype none
module InOut(
	inout PIN,
	input dataW,
	output dataR,
	input dir
);
	// assign PIN = dir ? dataW: 1'bz;
	// assign dataR = PIN;
	
	// SB_IO instantiation for bi-directional pin
	SB_IO #(
		.PIN_TYPE(6'b1010_01)
	) io_pin (
		.PACKAGE_PIN(PIN),
		.OUTPUT_ENABLE(dir),
		.D_OUT_0(dataW),
		.D_IN_0(dataR)
	);

endmodule

