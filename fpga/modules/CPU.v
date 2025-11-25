/**
 * The module CPU is the Hack CPU (Central Processing unit), consisting of an ALU,
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
    // Clock and Reset
    input wire CLK_100MHz,
    input wire CLK_CPU,
    input wire [31:0] CLK_COUNT,
    input RESET,

    // Instruction Interface
    input [15:0] INSTRUCTION,
    output [15:0] PC,

    // Memory Interface
    input [15:0] IN_M,
    output LOAD_M,
    output [15:0] OUT_M,
    output [15:0] ADDRESS_M
);

    // Parameters
    localparam CLK_COUNT_WRITE = 10;

    // Internal registers
    reg [15:0] a_out;
    reg [15:0] d_out;

    // ALU signals
    wire [15:0] alu_out;
    wire [15:0] alu_input_y;
    wire zr;
    wire ng;

    // Control signals
    wire is_a_instruction;
    wire is_c_instruction;
    wire a;
    wire [5:0] c;       // Array for c-bits
    wire [2:0] d;       // Array for d-bits
    wire [2:0] j;       // Array for j-bits
    wire load_a;
    wire load_d;
    wire load_pc;

    // Module instantiations
    
    // ALU input selection for y
    Mux16 mux16_alu_y (
        .a(a_out),
        .b(IN_M),
        .sel(a),
        .out(alu_input_y)
    );
 
    // ALU
    ALU alu_inst (
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

    // Program counter
    PC pc_register (
        .clk(CLK_CPU),
        .reset(RESET),
        .load(load_pc),
        .inc(~load_pc),
        .in(a_out),
        .out(PC)
    );

    // Combinational logic
    
    // Decode instruction fields
    assign {is_c_instruction, a, c, d, j} = {INSTRUCTION[15], INSTRUCTION[12], INSTRUCTION[11:6], INSTRUCTION[5:3], INSTRUCTION[2:0]};
    assign is_a_instruction = ~INSTRUCTION[15];

    // Logic for loading registers
    assign load_a = (is_a_instruction) || (is_c_instruction && d[2]); // Load A register for A-instructions and C-instructions where A is set
    assign load_d = is_c_instruction && d[1];                          // Load D register if specified in the instruction
    assign LOAD_M = is_c_instruction && d[0];                          // Write to memory if C-instruction and write bit is set
    assign load_pc = is_c_instruction && (
        (j == 3'b111) ||                    // JMP
        (j == 3'b001 && !zr && !ng) ||      // JGT
        (j == 3'b010 && zr) ||              // JEQ
        (j == 3'b011 && (zr || !ng)) ||     // JGE
        (j == 3'b100 && ng) ||              // JLT
        (j == 3'b101 && !zr) ||             // JNE
        (j == 3'b110 && (zr || ng))         // JLE
    );

    // Outputs
    assign OUT_M = alu_out;
    assign ADDRESS_M = a_out;

    // Sequential logic
    
    always @(posedge CLK_100MHz) begin
        // A register - write after CPU computation
        if (load_a && (CLK_COUNT == CLK_COUNT_WRITE && CLK_CPU == 1'b1)) begin
            a_out <= (is_a_instruction) ? INSTRUCTION : alu_out;
        end
        
        // D register - write after CPU computation
        if (load_d && (CLK_COUNT == CLK_COUNT_WRITE && CLK_CPU == 1'b1)) begin
            d_out <= alu_out;
        end
    end

endmodule
