`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
`include "../../modules/CLK_Divider.v"
`include "../../modules/UartTX.v"
`include "../../modules/Keypad.v"

/** 
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk_in,rst,rom)
 *
 */
`default_nettype none

module Hack(
    input wire CLK_100MHz,
    output reg [3:0] keypad_rows,
    input  wire [3:0] keypad_cols,
    output reg [3:0] leds,
    output wire UART_TX
);

    wire [3:0] key_index;
    wire key_valid;

    reg [15:0] uart_payload = 16'd0;
    reg        uart_start = 1'b0;
    wire       uart_is_busy;

    // Internal delay state
    reg [31:0] hold_counter = 0;
    reg hold_active = 0;

    // UART driver
    UartTX uart_tx (
        .CLK_100MHz(CLK_100MHz),
        .load(uart_start),
        .in(uart_payload),
        .TX(UART_TX),
        .tx_busy(uart_is_busy)
    );

    // Keypad module
    wire [3:0] keypad_col_out;
    Keypad keypad (
        .clk(CLK_100MHz),
        .col(keypad_col_out),
        .row(keypad_cols),
        .key_index(key_index),
        .key_valid(key_valid)
    );

    // Output mapping
    always @(*) begin
        keypad_rows = keypad_col_out;
        leds = key_index;
    end

    // Convert key_index to ASCII
    reg [7:0] ascii_char;
    always @(*) begin
        case (key_index)
            4'd0:  ascii_char = 8'd48;  // '0'
            4'd1:  ascii_char = 8'd49;  // '1'
            4'd2:  ascii_char = 8'd50;  // '2'
            4'd3:  ascii_char = 8'd51;  // '3'
            4'd4:  ascii_char = 8'd52;  // '4'
            4'd5:  ascii_char = 8'd53;  // '5'
            4'd6:  ascii_char = 8'd54;  // '6'
            4'd7:  ascii_char = 8'd55;  // '7'
            4'd8:  ascii_char = 8'd56;  // '8'
            4'd9:  ascii_char = 8'd57;  // '9'
            4'd10: ascii_char = 8'd65;  // 'A'
            4'd11: ascii_char = 8'd66;  // 'B'
            4'd12: ascii_char = 8'd67;  // 'C'
            4'd13: ascii_char = 8'd68;  // 'D'
            4'd14: ascii_char = 8'd42;  // '*'
            4'd15: ascii_char = 8'd35;  // '#'
            default: ascii_char = 8'd63; // '?'
        endcase
    end

    // Debouncing and single-shot detection
    reg [3:0] last_key_index = 4'd0;
    reg last_key_valid = 1'b0;
    reg key_sent = 1'b0;
    
    // UART logic with proper debouncing
    always @(posedge CLK_100MHz) begin
        uart_start <= 0;
        
        // Store previous state
        last_key_valid <= key_valid;
        
        if (hold_active) begin
            hold_counter <= hold_counter + 1;
            if (hold_counter >= 50_000_000) begin  // 0.5 second debounce
                hold_active <= 0;
                hold_counter <= 0;
                key_sent <= 0;
            end
        end else begin
            // Detect rising edge of key_valid (new key press)
            if (key_valid && !last_key_valid && !key_sent && !uart_is_busy) begin
                uart_payload <= {8'd0, ascii_char};  // Send ASCII character
                uart_start <= 1;
                hold_active <= 1;
                hold_counter <= 0;
                key_sent <= 1;
                last_key_index <= key_index;
            end
        end
    end

endmodule
