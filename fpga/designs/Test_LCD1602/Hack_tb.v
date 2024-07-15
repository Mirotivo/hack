`include "Hack.v"
`timescale 1ns / 1ps

`timescale 1ns / 1ps

module Hack_tb;
    reg CLK_100MHz;
    reg rst_n;
    wire I2C_SCL;
    reg I2C_SDA_int;
    wire I2C_SDA;

    // Tri-state buffer for I2C_SDA
    assign I2C_SDA = (I2C_SDA_int) ? 1'bz : 0;

    // Instantiate the top-level module
    Hack uut (
        .CLK_100MHz(CLK_100MHz),
        .BUT({rst_n, rst_n}),
        .I2C_SDA(I2C_SDA),
        .I2C_SCL(I2C_SCL)
    );

    // Clock generation
    initial begin
        CLK_100MHz = 0;
        forever #5 CLK_100MHz = ~CLK_100MHz; // 100MHz clock
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0d, hack state: %0d, I2C state: %0d, enable: %0b, rw: %0b, data_in: %0h, ready: %0b, I2C_SDA: %0b",
                 $time, uut.state, uut.i2c_inst.state, uut.i2c_inst.enable, uut.i2c_inst.rw, uut.i2c_inst.data_in, uut.i2c_inst.ready, I2C_SDA);
    end

    // Simulate slave acknowledgment
    always @(posedge CLK_100MHz) begin
        if (uut.i2c_inst.state == 4 || uut.i2c_inst.state == 6) begin
            // Drive SDA low to simulate ACK
            I2C_SDA_int <= 0;
        end else begin
            // Release SDA line
            I2C_SDA_int <= 1;
        end
    end

    // Test sequence
    initial begin
        // Initialize reset
        rst_n = 0;
        #20;
        rst_n = 1;

        // Wait for the first command to be sent
        wait (uut.i2c_inst.state == 1);
        #10; // Add a small delay to stabilize the ready signal
        if (uut.i2c_inst.data_in !== uut.init_cmds[0]) $display("Test failed at state 1: expected %h, got %h", uut.init_cmds[0], uut.i2c_inst.data_in);
        else $display("Test passed at state 1");

        wait (uut.i2c_inst.state == 3);
        #10; // Add a small delay to stabilize the ready signal
        if (uut.i2c_inst.data_in !== uut.init_cmds[1]) $display("Test failed at state 3: expected %h, got %h", uut.init_cmds[1], uut.i2c_inst.data_in);
        else $display("Test passed at state 3");

        wait (uut.i2c_inst.state == 5);
        #10; // Add a small delay to stabilize the ready signal
        if (uut.i2c_inst.data_in !== uut.init_cmds[2]) $display("Test failed at state 5: expected %h, got %h", uut.init_cmds[2], uut.i2c_inst.data_in);
        else $display("Test passed at state 5");

        // Add more checks for other states as needed

        // Stop the simulation after a reasonable time
        #10000;
        $finish;
    end

    // Timeout to prevent infinite loop
    initial begin
        #1000000000; // Adjust this value as needed
        $display("Testbench timed out.");
        $finish;
    end
endmodule
