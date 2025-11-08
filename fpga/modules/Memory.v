
/*
 * The module mem provides access to memory RAM 
 * and memory mapped IO
 * In our Minimal-Hack-Project we will use 4Kx16 Bit RAM
 * 
 * address | memory
 * ----------------
 * 0-2047  | RAM
 * 2048    | led
 * 2049    | but
 *
 * WRITE:
 * When load is set to 1, 16 bit dataW are stored to Memory address
 * at next clock cycle. M[address] <= dataW
 * READ:
 * dataR provides data stored in Memory at address.
 * dataR = M[address]
 *
 * 0x6000	keyboard in course
 */

`default_nettype none
module Memory(
    input wire CLK_100MHz,
    input wire CLK_CPU,
    input wire [31:0] CLK_COUNT,
    input  wire [10:0] address, // 11 bits to cover addresses 0 to 2047
    input  wire [15:0] dataW,
    input  wire loadM,
    output reg [15:0] dataR
);

    // Memory storage
    reg [15:0] regRAM [0:2047];
    
    // Clock enable timing parameters
    localparam CLK_COUNT_READ = 5;   // Read at same time as ROM
    localparam CLK_COUNT_WRITE = 10; // Write after CPU computation
    
    // Initial memory load
    initial begin
        $readmemb(`RAMFILE, regRAM);
    end

    // Synchronized read and write operations
    always @(posedge CLK_100MHz) begin
        // Write operation - synchronized with CPU clock
        if (loadM && (CLK_COUNT == CLK_COUNT_WRITE && CLK_CPU == 1'b1)) begin
            regRAM[address] <= dataW;
        end
        
        // Read operation - synchronized with CPU clock
        if (CLK_COUNT == CLK_COUNT_READ && CLK_CPU == 1'b1) begin
            dataR <= regRAM[address];
        end
    end

endmodule



// module Memory(
//     input  wire CLK_100MHz,
//     input  wire [10:0] address, // 11 bits to cover addresses 0 to 2047
//     input  wire [15:0] dataW,
//     input  wire load,
//     output wire [15:0] dataR
// );

//     // Memory storage
//     reg [15:0] regRAM [0:2047];
    
//     // Initial memory load
//     initial begin
//         $readmemb(`RAMFILE, regRAM);
//     end

//     // Read operation
//     assign dataR = regRAM[address];

//     // Write operation
//     always @(posedge CLK_100MHz) begin
//         if (load) begin
//             regRAM[address] <= dataW;
//         end
//     end

// endmodule
