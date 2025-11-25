/**
 * The module Add16 is a 16-bit adder
 * Adds two 16-bit values with carry propagation
 * 
 * OUT = A + B
 */
`default_nettype none
module Add16(
    // Data Interface
    input [15:0] A,
    input [15:0] B,
    output [15:0] OUT
);

    // Internal signals
    wire [15:0] carry;

    // Module instantiations
    
    HalfAdder half_adder0(.A(A[0]), .B(B[0]), .SUM(OUT[0]), .CARRY(carry[0]));
    FullAdder full_adder1(.A(A[1]), .B(B[1]), .C(carry[0]), .SUM(OUT[1]), .CARRY(carry[1]));
    FullAdder full_adder2(.A(A[2]), .B(B[2]), .C(carry[1]), .SUM(OUT[2]), .CARRY(carry[2]));
    FullAdder full_adder3(.A(A[3]), .B(B[3]), .C(carry[2]), .SUM(OUT[3]), .CARRY(carry[3]));
    FullAdder full_adder4(.A(A[4]), .B(B[4]), .C(carry[3]), .SUM(OUT[4]), .CARRY(carry[4]));
    FullAdder full_adder5(.A(A[5]), .B(B[5]), .C(carry[4]), .SUM(OUT[5]), .CARRY(carry[5]));
    FullAdder full_adder6(.A(A[6]), .B(B[6]), .C(carry[5]), .SUM(OUT[6]), .CARRY(carry[6]));
    FullAdder full_adder7(.A(A[7]), .B(B[7]), .C(carry[6]), .SUM(OUT[7]), .CARRY(carry[7]));
    FullAdder full_adder8(.A(A[8]), .B(B[8]), .C(carry[7]), .SUM(OUT[8]), .CARRY(carry[8]));
    FullAdder full_adder9(.A(A[9]), .B(B[9]), .C(carry[8]), .SUM(OUT[9]), .CARRY(carry[9]));
    FullAdder full_adder10(.A(A[10]), .B(B[10]), .C(carry[9]), .SUM(OUT[10]), .CARRY(carry[10]));
    FullAdder full_adder11(.A(A[11]), .B(B[11]), .C(carry[10]), .SUM(OUT[11]), .CARRY(carry[11]));
    FullAdder full_adder12(.A(A[12]), .B(B[12]), .C(carry[11]), .SUM(OUT[12]), .CARRY(carry[12]));
    FullAdder full_adder13(.A(A[13]), .B(B[13]), .C(carry[12]), .SUM(OUT[13]), .CARRY(carry[13]));
    FullAdder full_adder14(.A(A[14]), .B(B[14]), .C(carry[13]), .SUM(OUT[14]), .CARRY(carry[14]));
    FullAdder full_adder15(.A(A[15]), .B(B[15]), .C(carry[14]), .SUM(OUT[15]), .CARRY(carry[15]));

endmodule
