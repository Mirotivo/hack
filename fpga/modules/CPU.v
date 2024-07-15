/**
 * The Hack CPU (Central Processing unit), consisting of an ALU,
 * two registers named A and D, and a program counter named PC.
 * The CPU is designed to fetch and execute instructions written in 
 * the Hack machine language. In particular, functions as follows:
 * Executes the inputted instruction according to the Hack machine 
 * language specification. The D and A in the language specification
 * refer to CPU-resident registers, while M refers to the external
 * memory location addressed by A, i.e. to Memory[A]. The inM input 
 * holds the value of this location. If the current instruction needs 
 * to write a value to M, the value is placed in outM, the address 
 * of the target location is placed in the addressM output, and the 
 * loadM control bit is asserted. (When loadM==0, any value may 
 * appear in outM). The outM and loadM outputs are combinational: 
 * they are affected instantaneously by the execution of the current 
 * instruction. The addressM and pc outputs are clocked: although they 
 * are affected by the execution of the current instruction, they commit 
 * to their new values only in the next time step. If reset==1 then the 
 * CPU jumps to address 0 (i.e. pc is set to 0 in next time step) rather 
 * than to the address resulting from executing the current instruction. 
 */

`default_nettype none
module CPU(
    input wire CLK_100MHz,
    input wire CLK_CPU,
    input wire [31:0] CLK_COUNT,
    input reset,
    input [15:0] instruction,
    input [15:0] inM,
    output loadM,
    output [15:0] outM,
    output [15:0] addressM,
    output [15:0] pc
);
    // Internal wires and registers
    reg [15:0] a_out, d_out;
    wire [15:0] alu_out, alu_input_y;
    wire zr, ng, loadA, loadD, loadPC;

    // Control signals
    wire isAInstruction, isCInstruction;
    wire a;
    wire [5:0] c; // Array for c-bits
    wire [2:0] d; // Array for d-bits
    wire [2:0] j; // Array for j-bits

    // Decode instruction fields
    assign {isCInstruction, a, c, d, j} = {instruction[15], instruction[12], instruction[11:6], instruction[5:3], instruction[2:0]};
    assign isAInstruction = ~instruction[15];

    // Logic for loading registers
    assign loadA = (isAInstruction) || (isCInstruction && d[2]); // Load A register for A-instructions and C-instructions where A is set
    assign loadD = isCInstruction && d[1]; // Load D register if specified in the instruction
    assign loadM = isCInstruction && d[0]; // Write to memory if C-instruction and write bit is set
    assign loadPC = isCInstruction && (
        (j == 3'b111) || // JMP
        (j == 3'b001 && !zr && !ng) || // JGT
        (j == 3'b010 && zr) || // JEQ
        (j == 3'b011 && (zr || !ng)) || // JGE
        (j == 3'b100 && ng) || // JLT
        (j == 3'b101 && !zr) || // JNE
        (j == 3'b110 && (zr || ng)) // JLE
    );

    // ALU input selection for y
    Mux16 Mux16 (
        .a(a_out),
        .b(inM),
        .sel(a),
        .out(alu_input_y)
    );
 
    // ALU module instantiation
    ALU ALU (
        .x(d_out),
        .y(alu_input_y),
        .zx(c[5]),
        .nx(c[4]),
        .zy(c[3]),
        .ny(c[2]),
        .f(c[1]),
        .no(c[0]),
        .out(alu_out),
        .zr(zr),
        .ng(ng)
    );

    always @(posedge CLK_100MHz) begin
        // A register
        if (loadA && (CLK_COUNT == 10 && CLK_CPU == 1'b1)) begin
            a_out <= (isAInstruction) ? instruction : alu_out;
        end
        // D register
        if (loadD && (CLK_COUNT == 10 && CLK_CPU == 1'b1)) begin
            d_out <= alu_out;
        end
    end

    // Program counter
    PC PC_Register (
        .clk(CLK_CPU),
        .reset(reset),
        .load(loadPC),
        .inc(~loadPC),
        .in(a_out),
        .out(pc)
    );

    // Outputs
    assign outM = alu_out;
    assign addressM = a_out;
endmodule
