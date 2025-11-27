/**
 * The module Memory provides access to memory RAM
 * In our Minimal-Hack-Project we will use 4Kx16 Bit RAM
 * 
 * Address | Memory
 * --------+-------
 * 0-2047  | RAM
 * 2048    | LED
 * 2049    | Button
 *
 * WRITE:
 * When LOAD_M is set to 1, 16 bit DATA_W are stored to Memory address
 * at next clock cycle. M[address] <= DATA_W
 * READ:
 * DATA_R provides data stored in Memory at address.
 * DATA_R = M[address]
 *
 * 0x6000 keyboard in course
 */
`default_nettype none
module Memory(
    // Clock and Reset
    input wire CLK_100MHz,
    input wire CLK_CPU,
    input wire [31:0] CLK_COUNT,

    // Memory Interface
    input wire [10:0] ADDRESS,      // 11 bits to cover addresses 0 to 2047
    input wire [15:0] DATA_W,
    input wire LOAD_M,
    output reg [15:0] DATA_R
);

    // Parameters
    localparam CLK_COUNT_READ  = 5;     // Read at same time as ROM
    localparam CLK_COUNT_WRITE = 10;    // Write after CPU computation
    
    // Memory storage
    reg [15:0] reg_ram [0:2047];
    
    // Initial blocks
    integer i;
    
    initial begin
        // Initialize RAM to zeros
        for (i = 0; i < 2048; i = i + 1) begin
            reg_ram[i] = 16'b0;
        end
    end

    // Sequential logic
    
    always @(posedge CLK_100MHz) begin
        // Write operation - synchronized with CPU clock
        if (LOAD_M && (CLK_COUNT == CLK_COUNT_WRITE && CLK_CPU == 1'b1)) begin
            reg_ram[ADDRESS] <= DATA_W;
        end
        
        // Read operation - synchronized with CPU clock
        if (CLK_COUNT == CLK_COUNT_READ && CLK_CPU == 1'b1) begin
            DATA_R <= reg_ram[ADDRESS];
        end
    end

endmodule
