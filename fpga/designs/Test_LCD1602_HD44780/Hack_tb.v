`include "Hack.v"
`timescale 1ns/1ps

module Hack_tb;

  // Inputs
  reg clk;
  reg rst;
  reg start_bit;
  reg stop_bit;
  reg [7:0] data_in;
  reg [6:0] addr;

  // Outputs
  wire sda;
  wire scl;
  wire [7:0] data_out;

  // Instantiate the i2c_master module
  i2c_master dut (
    .clk(clk),
    .rst(rst),
    .sda(sda),
    .scl(scl),
    .data_out(data_out),
    .data_in(data_in),
    .addr(addr),
    .start_bit(start_bit),
    .stop_bit(stop_bit)
  );

  // Generate a clock signal with a frequency of 100 MHz
  // Clock generation
  always #5 clk = ~clk;

  // Output waveform data to a .vcd file
  initial begin
    $dumpfile("Hack_tb.vcd");
    $dumpvars(0, Hack_tb);
  end

  // Stimulus process
  initial begin
    // Initialize inputs
    clk = 0;
    rst = 1;
    start_bit = 0;
    stop_bit = 0;
    addr = 7'h50;
    data_in = 0;

    // Deassert reset
    #10 rst = 0;

    // Send a write command to the slave device
    start_bit = 1;
    addr = 7'h50;
    data_in = 8'hAA;
    #100 stop_bit = 1;
    #100 start_bit = 0;

    // Wait for the write command to complete
    #1000;

    // Send a read command to the slave device
    start_bit = 1;
    addr = 7'h51;
    #100 stop_bit = 1;
    #100 start_bit = 0;

    // Wait for the read command to complete
    #1000;

    // Check that the data read from the slave device is correct
    if (data_out == 8'hAA) begin
      $display("Read data is correct: 0x%02x", data_out);
    end else begin
      $error("Read data is incorrect: 0x%02x", data_out);
    end

    // Wait for the simulation to finish
    #1000 $finish;
  end

endmodule
