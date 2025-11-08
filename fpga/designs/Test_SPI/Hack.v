`default_nettype none

`include "../../modules/CLK_Divider.v"
`include "../../modules/SPI.v"

/**
 * ============================================================================
 * Main Module - Test the SPI controller
 * ============================================================================
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

    // Clock divider: 100MHz / 10M = 10Hz
    wire clk_divided;
    wire [31:0] clk_count;
    
    CLK_Divider clk_div (
        .clk_in(CLK_100MHz),
        .divisor(32'd4999999),  // 100MHz / (2 * 5000000) = 10Hz
        .clk_out(clk_divided),
        .clk_count(clk_count)
    );
   
    // Sequence control - Using unambiguous patterns
    // 0xA5 and 0x5A are standard test patterns used in disk formatting
    // and communication protocols because they're unambiguous when bit-shifted
    localparam BYTE1 = 8'hA5;   // First sequence byte (10100101)
    localparam BYTE2 = 8'h5A;   // Second sequence byte (01011010)
    
    // State machine states - simplified with proper CS timing
    localparam LOAD_SEQ1  = 2'd0;
    localparam SEND_SEQ1  = 2'd1;
    localparam LOAD_SEQ2  = 2'd2;
    localparam SEND_SEQ2  = 2'd3;
    
    reg [1:0] state = LOAD_SEQ1;
    reg spi_enable = 0;
    reg [7:0] spi_data = 0;
    wire spi_busy;
    
    // Simplified sequence controller - CS is now handled by SPI module
    always @(posedge clk_divided) begin
        
        case (state)
            //═══════════════════════════════════════════════════════
            // First Byte Sequence (0xA5)
            //═══════════════════════════════════════════════════════
            
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
            
            //═══════════════════════════════════════════════════════
            // Second Byte Sequence (0x5A)
            //═══════════════════════════════════════════════════════
            
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
    
    // SPI Controller instance
    // Running at 10Hz (100MHz / 10M)
    wire spi_csx;
    SPI spi (
        .clk(clk_divided),   // Using divided 10Hz clock
        .load(spi_enable),
        .in(spi_data),
        .SCK(TFT_SCK),
        .SDI(TFT_SDI),
        .CSX(spi_csx),
        .busy(spi_busy)
    );
    
    // Controlled outputs
    assign TFT_RESET = 1;       // Always HIGH
    assign TFT_DC = 0;          // Command mode

    // Use CS directly from SPI module
    assign TFT_CS = spi_csx;
    
    // LED indicators
    assign LED[0] = spi_busy;      // LED0: Shows when SPI is transmitting
    assign LED[1] = (state == SEND_SEQ1 || state == SEND_SEQ2);  // LED1: Shows active sequence state

endmodule
