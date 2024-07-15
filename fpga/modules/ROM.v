/**
 * The module rom provides access to the instruction memory
 * of hack. The instruction memory is read only (ROM) and
 * preloaded with 4Kx16bit of Hackcode.
 * 
 * The signal instruction (16bit) provides the instruction at memory pc
 * instruction = ROM[pc]
 */

`default_nettype none
module ROM(
    input wire CLK_100MHz,
    input wire CLK_CPU,
    input wire [31:0] CLK_COUNT,
    input  wire [15:0] pc,
    output reg [15:0] instruction
);

    // your implementation comes here:
    reg [15:0] regROM [0:2047]; //2k
    initial begin
        $readmemb(`ROMFILE, regROM);
    end
    always @(posedge CLK_100MHz) begin
        if ((CLK_COUNT == 5 && CLK_CPU == 1'b1))
        begin
            instruction = regROM[pc];
        end
    end

endmodule
