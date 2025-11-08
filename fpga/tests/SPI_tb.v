`include "include.v"
`timescale 1ns/1ns
`default_nettype none

module SPI_tb();
    reg CLK_100MHz = 0;
    reg reset = 1;
    reg load = 0;
    reg [15:0] in = 0;
    wire busy;
    wire [15:0] out;
    wire CSX, SDO, SCK;
    reg SDI = 0;

    // Instantiate the SPI module
    SPI uut (
        .CLK_100MHz(CLK_100MHz),
        .reset(reset),
        .load(load),
        .in(in),
        .busy(busy),
        .out(out),
        .CSX(CSX),
        .SDO(SDO),
        .SDI(SDI),
        .SCK(SCK)
    );

    // Clock generation: 100 MHz => 10 ns period
    always #5 CLK_100MHz = ~CLK_100MHz;

    // Simulate SDI response (return 0b10101010)
    reg [7:0] slave_data = 8'b10101010;

    initial begin
        $dumpfile("SPI_tb.vcd");
        $dumpvars(0, SPI_tb);

        // Reset sequence
        #20 reset = 0;

        // Wait a bit
        #100;

        // Start transmission
		in = 16'b0000000010101010; // [8]=0 (write), [7:0]=0xAA
		load = 1;
		#200 load = 0;             // Keep load high long enough for clk_8MHz to catch it

        // Respond on SDI in sync with SCK rising edges
        forever begin
            @(posedge SCK);
            SDI = slave_data[7];
            slave_data = {slave_data[6:0], 1'b0}; // shift left
        end
    end

    // End simulation
    initial begin
        #5000 $finish;
    end

endmodule
