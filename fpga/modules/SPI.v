`default_nettype none

/**
 * ============================================================================
 * SPI Controller Module - With integrated CS control
 * ============================================================================
 */
module SPI (
    input wire clk,             // System clock
    input wire load,            // Start sending when HIGH
    input wire [7:0] in,        // Byte to send
    output reg SCK = 0,         // SPI Clock
    output reg SDI = 0,         // SPI Data
    output reg CSX = 1,         // Chip Select (active LOW)
    output wire busy            // HIGH while transmitting
);
    
    // State machine
    localparam IDLE = 1'd0;
    localparam TRANSMIT = 1'd1;
    
    reg state = IDLE;
    reg [4:0] bit_index = 0;
    reg [7:0] data_reg = 0;
    
    assign busy = (state != IDLE);
    
    // SPI transmission logic
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                if (load) begin
                    // Start new transmission
                    data_reg <= in;
                    bit_index <= 0;
                    state <= TRANSMIT;
                    CSX <= 0;  // Assert CS (active LOW)
                end
            end
            
            TRANSMIT: begin
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
            
            default: state <= IDLE;
        endcase
    end
endmodule
