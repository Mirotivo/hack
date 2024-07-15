module ALU(
	input[15:0] x,
	input[15:0] y,
	input zx,
	input nx,
	input zy,
	input ny,
	input f,
	input no,
    output[15:0] out,
	output zr,
	output ng
);

	wire[15:0] x1, notx1, x2, y1, noty1, y2, andxy, addxy, o1, noto1, o2;
	wire orLow, orHigh, notzr;

	Mux16 g1(x,  16'b0, zx, x1);		// if (zx == 1) set x = 0  
	Not16 g2(x1, notx1);
	Mux16 g3(x1, notx1, nx, x2);		// if (nx == 1) set x = !x

	Mux16 g4(y,  16'b0, zy, y1);		// if (zy == 1) set y = 0
	Not16 g5(y1, noty1);
	Mux16 g6(y1, noty1, ny, y2);		// if (ny == 1) set y = !y

	Add16 g7(x2, y2, addxy);			// addxy = x + y
	And16 g8(x2, y2, andxy);			// andxy = x & y

	Mux16 g9(andxy, addxy, f, o1);		// if (f == 1)  set out = x + y else set out = x & y
	Not16 g10(o1, noto1);

	Mux16 g11(o1, noto1, no, o2);		// if (no == 1) set out = !out

	And16 g12(o2, o2, out); 
	Or8Way g13(out[7:0],  orLow);		// orLow = Or(out[0..7]);
	Or8Way g14(out[15:8], orHigh);		// orHigh = Or(out[8..15]);
	Or    g15(orLow, orHigh, notzr);	// nzr = Or(out[0..15]);
	Not   g16(notzr, zr);				// zr = !nzr
	And   g17(o2[15], o2[15], ng);		// ng = out[15]
	And16 g18(o2, o2, out);
endmodule
