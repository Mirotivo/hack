`include "Hack.v"
`timescale 1ns/1ps

module Hack_tb;

  // Inputs
  reg clk_in;

  // Outputs
  wire [6:0] seg;

  // Instantiate the unit under test (UUT)
  Hack uut (
    .clk_in(clk_in),
    .seg(seg)
  );

  // Generate a clock signal with a frequency of 100 MHz
  initial begin
    clk_in = 0;
    forever #1000 clk_in = ~clk_in;
  end

  // // Monitor the output signals
  // always @(posedge clk_in) begin
  //   $display("count = %d, seg = %b", uut.count, uut.seg);
  // end

  // Output waveform data to a .vcd file
  initial begin
    $dumpfile("Hack_tb.vcd");
    $dumpvars(0, Hack_tb);
  end

  // Stop simulation after 10 seconds
  initial begin
    #10_000_000_000; // 100 ns * 10^8 = 10 s
    $finish;
  end
endmodule
