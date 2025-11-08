`include "include.v"
`timescale 1ns/1ps
`default_nettype none

module Keypad_tb;

    reg clk = 0;
    wire [3:0] col;
    reg  [3:0] row = 4'b0000;

    wire [3:0] key_index;
    wire key_valid;

    // Instantiate the DUT
    Keypad uut (
        .clk(clk),
        .col(col),
        .row(row),
        .key_index(key_index),
        .key_valid(key_valid)
    );

    // Generate 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("Keypad_tb.vcd");
        $dumpvars(0, Keypad_tb);
        $display("Start keypad simulation");

        // Let the scanner start up
        #100000;

        // Simulate press: key index 5 (row 1, col 1)
        // Wait until col[1] is driven low (col = 4'b0010)
        wait (col == 4'b0010);
        #10 row = 4'b0010; // row 1 (bit 1) pulled high (active-low inverted logic)

        #50000 row = 4'b0000; // release key

        // Wait and simulate key index 14 (row 3, col 2)
        wait (col == 4'b0100);
        #10 row = 4'b1000; // row 3 (bit 3)

        #50000 row = 4'b0000;

        #100000;

        $display("End keypad simulation");
        $finish;
    end

endmodule
