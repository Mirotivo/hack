/**
 * The module ROM provides access to the instruction memory
 * of Hack. The instruction memory is read only (ROM) and
 * preloaded with 4Kx16bit of Hack code.
 * 
 * The signal INSTRUCTION (16bit) provides the instruction at memory PC
 * INSTRUCTION = ROM[PC]
 */
`default_nettype none
module ROM(
    // Clock and Reset
    input wire CLK_100MHz,
    input wire CLK_CPU,
    input wire [31:0] CLK_COUNT,

    // Instruction Interface
    input wire [15:0] PC,
    output reg [15:0] INSTRUCTION
);

    // Parameters
    localparam CLK_COUNT_READ = 5;
    
    // Memory storage
    reg [15:0] reg_rom [0:2047];  // 2K instructions
    
    // Initial blocks
    
    initial begin
        $readmemb(`ROMFILE, reg_rom);
    end

    // Sequential logic
    
    always @(posedge CLK_100MHz) begin
        // Read operation - synchronized with CPU clock
        if (CLK_COUNT == CLK_COUNT_READ && CLK_CPU == 1'b1) begin
            INSTRUCTION <= reg_rom[PC];
        end
    end

endmodule
