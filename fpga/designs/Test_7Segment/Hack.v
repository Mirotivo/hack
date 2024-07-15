`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
/** 
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk,rst,rom)
 *
 */

`default_nettype none

module CLK_Divider (
    input wire clk_in,
    input wire [31:0] divisor,
    output reg clk_out
);
    initial begin
        clk_out = 1;
    end

    reg [31:0] counter = 0;

    always @(posedge clk_in) begin
        counter <= counter + 1;
        if (counter == divisor) begin
            counter <= 0;
            if (clk_out==0) clk_out <=1;
            else clk_out <= 0;
        end
    end

endmodule

module counter (
    input  wire clk,
    input  wire rst,
    output reg [3:0] count
);
    initial begin
        count = 0;
    end

    always @(posedge clk) begin
        if (rst) count <= 0;
        else count <= count + 1;
    end
endmodule

module segment_decoder (
    input  wire [3:0] count,
    output wire [6:0] segment
);
    reg [6:0] segment_data [0:9];

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

    assign segment = segment_data[count];
endmodule

module Hack(                        // top level module 
    input wire clk_in,
    output wire [6:0] seg
);

    wire clk_out;
    // Divide the input clock frequency by 100 million to get a count every second
    CLK_Divider divider_inst (
        .clk_in(clk_in),
        .divisor(100000000),
        .clk_out(clk_out)
    );


    wire [3:0] count;
    counter counter_inst (
        .clk(clk_out),
        .rst(1'b0),
        .count(count)
    );

    segment_decoder decoder_inst (
        .count(count),
        .segment(seg)
    );
  
//   always @(*) begin
//     always_1 = 1;
//   end

endmodule
