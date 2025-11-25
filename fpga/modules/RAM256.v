/**
 * The module RAM256 implements 256 x 16-bit RAM
 * RAM is implemented using BRAM of iCE40
 * 
 * OUT = M[ADDRESS]
 * If (LOAD == 1) M[ADDRESS][t+1] = IN[t]
 */
`default_nettype none
module RAM256(
    // Clock
    input CLK,

    // Control Interface
    input LOAD,

    // Data Interface
    input [7:0] ADDRESS,
    input [15:0] IN,
    output [15:0] OUT
);

    // Internal signals - RAM storage
    reg [15:0] reg_ram [0:255];

    // Sequential logic
    
    always @(posedge CLK)
        if (LOAD) reg_ram[ADDRESS[7:0]] <= IN;

    // Combinational logic
    
    assign OUT = reg_ram[ADDRESS[7:0]];

endmodule
