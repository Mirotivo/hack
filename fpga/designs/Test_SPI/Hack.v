/**
 * The module Hack is an SPI controller test
 * Sends alternating test patterns (0xA5, 0x5A) via SPI
 * These patterns are standard test patterns used in communication protocols
 * It connects the external pins of our FPGA (Hack.pcf)
 * to test SPI functionality with continuous transmission
 */
`default_nettype none

`include "../../modules/CLK_Divider.v"
`include "../../modules/SPI.v"

module Hack (
    // Clock
    input CLK_100MHz,

    // GPIO (Buttons and LEDs)
    input [1:0] BUT,
    output [1:0] LED,
    
    // SPI/TFT Interface
    output TFT_CS,
    output TFT_RESET,
    output TFT_SDI,
    output TFT_SCK,
    output TFT_DC
);

    // Parameters
    localparam BYTE1 = 8'hA5;        // First sequence byte (10100101)
    localparam BYTE2 = 8'h5A;        // Second sequence byte (01011010)
    
    // State machine states
    localparam LOAD_SEQ1 = 2'd0;
    localparam SEND_SEQ1 = 2'd1;
    localparam LOAD_SEQ2 = 2'd2;
    localparam SEND_SEQ2 = 2'd3;

    // Internal signals - Clock divider
    wire clk_divided;
    wire [31:0] clk_count;
    
    // Internal signals - State machine
    reg [1:0] state;
    reg spi_enable;
    reg [7:0] spi_data;
    wire spi_busy;
    wire spi_csx;

    // Module instantiations
    
    // Clock divider: 100MHz / 10M = 10Hz
    CLK_Divider clk_div (
        .CLK_IN(CLK_100MHz),
        .DIVISOR(32'd4999999),       // 100MHz / (2 * 5000000) = 10Hz
        .CLK_OUT(clk_divided),
        .CLK_COUNT(clk_count)
    );
   
    // SPI Controller (using divided 10Hz clock)
    SPI spi (
        .CLK_100MHz(clk_divided),
        .LOAD(spi_enable),
        .IN(spi_data),
        .SCK(TFT_SCK),
        .SDI(TFT_SDI),
        .CSX(spi_csx),
        .BUSY(spi_busy)
    );

    // Sequential logic
    
    initial begin
        state = LOAD_SEQ1;
        spi_enable = 0;
        spi_data = 0;
    end
    
    // Sequence controller - sends alternating test patterns
    always @(posedge clk_divided) begin
        case (state)
            // First Byte Sequence (0xA5)
            LOAD_SEQ1: begin
                // Load data and start transmission
                spi_data <= BYTE1;
                spi_enable <= 1;
                state <= SEND_SEQ1;
            end
            
            SEND_SEQ1: begin
                // Clear enable once SPI controller accepts it
                if (spi_busy) begin
                    spi_enable <= 0;
                end
                
                // Wait for transmission to complete, then move to SEQ2
                if (!spi_busy && !spi_enable) begin
                    state <= LOAD_SEQ2;
                end
            end
            
            // Second Byte Sequence (0x5A)
            LOAD_SEQ2: begin
                // Load data and start transmission
                spi_data <= BYTE2;
                spi_enable <= 1;
                state <= SEND_SEQ2;
            end
            
            SEND_SEQ2: begin
                // Clear enable once SPI controller accepts it
                if (spi_busy) begin
                    spi_enable <= 0;
                end
                
                // Wait for transmission to complete, then restart cycle
                if (!spi_busy && !spi_enable) begin
                    state <= LOAD_SEQ1;
                end
            end
            
            default: begin
                state <= LOAD_SEQ1;
            end
        endcase
    end

    // Combinational logic
    
    // Controlled outputs
    assign TFT_RESET = 1;                                              // Always HIGH
    assign TFT_DC = 0;                                                 // Command mode
    assign TFT_CS = spi_csx;                                          // CS from SPI module
    
    // LED indicators
    assign LED[0] = spi_busy;                                          // Shows when SPI is transmitting
    assign LED[1] = (state == SEND_SEQ1 || state == SEND_SEQ2);      // Shows active sequence state

endmodule
