/**
 * The module Hack is a 7-segment display test
 * Displays a counter from 0-9 on a 7-segment display
 * Updates every second using clock divider
 */
`default_nettype none

`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"

// ============================================================================
// Clock Divider Module (local to this design)
// ============================================================================
module CLK_Divider (
    input wire clk_in,
    input wire [31:0] divisor,
    output reg clk_out
);
    // Internal signals
    reg [31:0] counter;

    // Initial blocks
    initial begin
        clk_out = 1;
        counter = 0;
    end

    // Sequential logic
    always @(posedge clk_in) begin
        counter <= counter + 1;
        if (counter == divisor) begin
            counter <= 0;
            if (clk_out == 0)
                clk_out <= 1;
            else
                clk_out <= 0;
        end
    end
endmodule

// ============================================================================
// Counter Module (local to this design)
// ============================================================================
module counter (
    input wire clk,
    input wire rst,
    output reg [3:0] count
);
    // Initial blocks
    initial begin
        count = 0;
    end

    // Sequential logic
    always @(posedge clk) begin
        if (rst)
            count <= 0;
        else
            count <= count + 1;
    end
endmodule

// ============================================================================
// Segment Decoder Module (local to this design)
// ============================================================================
module segment_decoder (
    input wire [3:0] count,
    output wire [6:0] segment
);
    // Internal signals
    reg [6:0] segment_data [0:9];

    // Initial blocks
    initial begin
        segment_data[0] = 7'b0111111;
        segment_data[1] = 7'b0000110;
        segment_data[2] = 7'b1011011;
        segment_data[3] = 7'b1001111;
        segment_data[4] = 7'b1100110;
        segment_data[5] = 7'b1101101;
        segment_data[6] = 7'b1111101;
        segment_data[7] = 7'b0000111;
        segment_data[8] = 7'b1111111;
        segment_data[9] = 7'b1101111;
    end

    // Combinational logic
    assign segment = segment_data[count];
endmodule

// ============================================================================
// Top Level Module
// ============================================================================
module Hack (
    // Clock
    input wire clk_in,

    // 7-Segment Display
    output wire [6:0] seg
);

    // Internal signals
    wire clk_out;
    wire [3:0] count;

    // Module instantiations
    
    // Divide the input clock frequency by 100 million to get a count every second
    CLK_Divider divider_inst (
        .clk_in(clk_in),
        .divisor(100000000),
        .clk_out(clk_out)
    );

    // Counter module
    counter counter_inst (
        .clk(clk_out),
        .rst(1'b0),
        .count(count)
    );

    // Segment decoder
    segment_decoder decoder_inst (
        .count(count),
        .segment(seg)
    );

endmodule
