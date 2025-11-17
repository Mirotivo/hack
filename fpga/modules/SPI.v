`default_nettype none

/**
 * ============================================================================
 * SPI Controller Module - With Timing Divider
 * ============================================================================
 * Original logic with added timing control via counter
 */
module SPI (
    input wire CLK_100MHz,      // System clock (100MHz)
    input wire load,            // Start sending when HIGH
    input wire [7:0] in,        // Byte to send
    output reg SCK = 0,         // SPI Clock
    output reg SDI = 0,         // SPI Data
    output reg CSX = 1,         // Chip Select (active LOW)
    output wire busy            // HIGH while transmitting
);
    
    // ========================================================================
    // Clock Generation
    // ========================================================================
    parameter CLK_FREQ = 100000000;  // 100 MHz
    parameter SPI_FREQ = 1000;   // 1 MHz SPI (production speed)
    localparam SPI_PERIOD = CLK_FREQ / SPI_FREQ;
    localparam SPI_HALF_PERIOD = SPI_PERIOD / 2;  // For SCK toggle
    
    // ========================================================================
    // State Machine
    // ========================================================================
    localparam IDLE = 1'd0;
    localparam TRANSMIT = 1'd1;
    
    reg state = IDLE;
    reg [31:0] clk_cycles = 0;   // Counter for timing division
    reg [4:0] bit_index = 0;
    reg [7:0] data_reg = 0;
    
    assign busy = (state != IDLE);
    
    // ========================================================================
    // SPI Transmission Logic - Original Logic with Timing Divider
    // ========================================================================
    always @(posedge CLK_100MHz) begin
        case (state)
            IDLE: begin
                if (load) begin
                    // Start new transmission
                    data_reg <= in;
                    bit_index <= 0;
                    clk_cycles <= 0;
                    state <= TRANSMIT;
                    CSX <= 0;  // Assert CS (active LOW)
                end
            end
            
            TRANSMIT: begin
                // Wait for timing period before advancing state machine
                if (clk_cycles < SPI_HALF_PERIOD - 1) begin
                    clk_cycles <= clk_cycles + 1;
                end else begin
                    clk_cycles <= 0;
                    
                    // Original logic - execute once per HALF_PERIOD
                    if (bit_index < 16) begin
                        // Send 8 bits (16 half-clocks)
                        if (bit_index[0] == 0) begin
                            // Even: set data, clock LOW
                            SDI <= data_reg[7 - (bit_index>>1)];
                            SCK <= 0;
                        end else begin
                            // Odd: clock HIGH
                            SCK <= 1;
                        end
                        bit_index <= bit_index + 1;
                    end else begin
                        // Transmission complete
                        SCK <= 0;
                        CSX <= 1;  // Deassert CS (goes HIGH)
                        state <= IDLE;
                    end
                end
            end
            
            default: state <= IDLE;
        endcase
    end
endmodule
