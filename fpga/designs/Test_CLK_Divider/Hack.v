`default_nettype none

`include "../../modules/CLK_Divider.v"

/**
 * ============================================================================
 * SIMPLE PIN TEST - Minimal resource usage
 * ============================================================================
 * Each pin toggles at a different rate using CLK_Divider modules
 */

module Hack (
    input CLK_100MHz,
    input [1:0] BUT,
    output [1:0] LED,
    
    output TFT_CS,
    output TFT_RESET,
    output TFT_SDI,
    output TFT_SCK,
    output TFT_DC
);

    // Clock dividers for different toggle rates
    wire clk_10ms;   // Fast  - 10ms (50 Hz)
    wire clk_20ms;   // Medium - 20ms (25 Hz)
    wire clk_100ms;  // Slow - 100ms (5 Hz)
    wire clk_200ms;  // Very slow - 200ms (2.5 Hz)
    
    wire [31:0] count_sck, count_sdi, count_cs, count_dc;
    
    // SCK divider - toggles every 10ms
    CLK_Divider div_sck (
        .clk_in(CLK_100MHz),
        .divisor(32'd999999),    // 100MHz / (2 * 50Hz) - 1 = 999,999
        .clk_out(clk_10ms),
        .clk_count(count_sck)
    );
    
    // SDI divider - toggles every 20ms
    CLK_Divider div_sdi (
        .clk_in(CLK_100MHz),
        .divisor(32'd1999999),   // 100MHz / (2 * 25Hz) - 1 = 1,999,999
        .clk_out(clk_20ms),
        .clk_count(count_sdi)
    );
    
    // CS divider - toggles every 100ms
    CLK_Divider div_cs (
        .clk_in(CLK_100MHz),
        .divisor(32'd9999999),   // 100MHz / (2 * 5Hz) - 1 = 9,999,999
        .clk_out(clk_100ms),
        .clk_count(count_cs)
    );
    
    // DC divider - toggles every 200ms
    CLK_Divider div_dc (
        .clk_in(CLK_100MHz),
        .divisor(32'd19999999),  // 100MHz / (2 * 2.5Hz) - 1 = 19,999,999
        .clk_out(clk_200ms),
        .clk_count(count_dc)
    );
    
    // Assign divided clocks directly to outputs
    assign TFT_SCK = clk_10ms;
    assign TFT_SDI = clk_20ms;
    assign TFT_CS = clk_100ms;
    assign TFT_DC = clk_200ms;
    assign TFT_RESET = 1;  // Always HIGH
    
    // LED indicators
    assign LED[0] = TFT_SCK;
    assign LED[1] = TFT_CS;

endmodule
