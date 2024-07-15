`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
`include "../../modules/CLK_Divider.v"

/** 
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk_in,rst,rom)
 *
 */

`default_nettype none

module Hack(                        // top level module
    input wire clk_in,
    output wire [3:0] keypad_rows,
    input wire [3:0] keypad_cols,
    output reg [3:0] leds
);

    wire clk_out;
    // Divide the input clock frequency by 100 million to get a count every second
    CLK_Divider divider_inst (
        .clk_in(clk_in),
        .divisor(100000000),
        .clk_out(clk_out)
    );

    // assign keypad_rows = 4'b1111;
    // always @ (keypad_cols) begin
    //     // check each bit of keypad_cols and set corresponding LED signal
    //     leds <= keypad_cols;
    // end

    reg [3:0] row_sel = 4'b0001; // start with first row selected
    always @ (posedge clk_out) begin
        // shift the row selection to scan the next row
        row_sel <= {row_sel[2:0], row_sel[3]};
        keypad_rows <= row_sel;

        case ({keypad_rows, keypad_cols})
            8'b00010001: leds <= 4'b0001;
            8'b00010010: leds <= 4'b0010;
            8'b00010100: leds <= 4'b0011;
            8'b00011000: leds <= 4'b0000;
            8'b00100001: leds <= 4'b0100;
            8'b00100010: leds <= 4'b0101;
            8'b00100100: leds <= 4'b0110;
            8'b00101000: leds <= 4'b0000;
            8'b01000001: leds <= 4'b0111;
            8'b01000010: leds <= 4'b1000;
            8'b01000100: leds <= 4'b1001;
            8'b01001000: leds <= 4'b0000;
            8'b10000001: leds <= 4'b0000;
            8'b10000010: leds <= 4'b0000;
            8'b10000100: leds <= 4'b0000;
            8'b10001000: leds <= 4'b0000;
            default: leds <= 4'b0000; // no key pressed
        endcase
    end



endmodule
