/**
 * The module Hack is a clock divider test module
 * Tests CLK_Divider by toggling pins at different rates
 * Each pin toggles at a different frequency to verify clock division
 * It connects the external pins of our FPGA (Hack.pcf)
 */
`default_nettype none

`include "../../modules/CLK_Divider.v"

module Hack (
    // Clock
    input CLK_100MHz,

    // GPIO (Buttons and LEDs)
    input [1:0] BUT,
    output [1:0] LED,
    
    // LCD/TFT Display (used as test pins)
    output TFT_CS,
    output TFT_RESET,
    output TFT_SDI,
    output TFT_SCK,
    output TFT_DC
);

    // Internal signals - Clock dividers
    wire clk_10ms;    // Fast - 10ms (50 Hz)
    wire clk_20ms;    // Medium - 20ms (25 Hz)
    wire clk_100ms;   // Slow - 100ms (5 Hz)
    wire clk_200ms;   // Very slow - 200ms (2.5 Hz)
    
    wire [31:0] count_sck;
    wire [31:0] count_sdi;
    wire [31:0] count_cs;
    wire [31:0] count_dc;

    // Module instantiations
    
    // SCK divider - toggles every 10ms (50 Hz)
    CLK_Divider div_sck (
        .CLK_IN(CLK_100MHz),
        .DIVISOR(32'd999999),        // 100MHz / (2 * 50Hz) - 1 = 999,999
        .CLK_OUT(clk_10ms),
        .CLK_COUNT(count_sck)
    );
    
    // SDI divider - toggles every 20ms (25 Hz)
    CLK_Divider div_sdi (
        .CLK_IN(CLK_100MHz),
        .DIVISOR(32'd1999999),       // 100MHz / (2 * 25Hz) - 1 = 1,999,999
        .CLK_OUT(clk_20ms),
        .CLK_COUNT(count_sdi)
    );
    
    // CS divider - toggles every 100ms (5 Hz)
    CLK_Divider div_cs (
        .CLK_IN(CLK_100MHz),
        .DIVISOR(32'd9999999),       // 100MHz / (2 * 5Hz) - 1 = 9,999,999
        .CLK_OUT(clk_100ms),
        .CLK_COUNT(count_cs)
    );
    
    // DC divider - toggles every 200ms (2.5 Hz)
    CLK_Divider div_dc (
        .CLK_IN(CLK_100MHz),
        .DIVISOR(32'd19999999),      // 100MHz / (2 * 2.5Hz) - 1 = 19,999,999
        .CLK_OUT(clk_200ms),
        .CLK_COUNT(count_dc)
    );

    // Combinational logic
    
    // Assign divided clocks directly to outputs
    assign TFT_SCK = clk_10ms;
    assign TFT_SDI = clk_20ms;
    assign TFT_CS = clk_100ms;
    assign TFT_DC = clk_200ms;
    assign TFT_RESET = 1;                // Always HIGH
    
    // LED indicators
    assign LED[0] = TFT_SCK;
    assign LED[1] = TFT_CS;

endmodule
