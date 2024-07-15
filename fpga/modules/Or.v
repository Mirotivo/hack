module Or (
    input a,
    input b,
    output out
);
	wire nota;
	wire notb;
	wire notab;
    Not Not1(.in(a), .out(nota));
	Not Not2(.in(b), .out(notb));
	And And1(.a(nota), .b(notb), .out(notab));
	Not Not3(.in(notab), .out(out));
endmodule