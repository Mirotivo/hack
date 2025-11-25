/**
 * The module SPI is an SPI Controller with timing divider
 * Transmits 8-bit data via SPI protocol at 1MHz
 * 
 * BUSY indicates transmission in progress
 */
`default_nettype none
module SPI (
    // Clock
    input wire CLK_100MHz,

    // Control Interface
    input wire LOAD,
    output wire BUSY,

    // Data Interface
    input wire [7:0] IN,

    // SPI
    output reg SCK,
    output reg SDI,
    output reg CSX
);

    // Parameters
    parameter CLK_FREQ = 100000000;      // 100 MHz
    parameter SPI_FREQ = 1000000;        // 1 MHz SPI
    localparam SPI_PERIOD = CLK_FREQ / SPI_FREQ;
    localparam SPI_HALF_PERIOD = SPI_PERIOD / 2;  // For SCK toggle
    
    // State machine states
    localparam IDLE     = 1'd0;
    localparam TRANSMIT = 1'd1;
    
    // Internal signals
    reg state;
    reg [31:0] clk_cycles;
    reg [4:0] bit_index;
    reg [7:0] data_reg;
    
    // Initial blocks
    
    initial begin
        SCK = 0;
        SDI = 0;
        CSX = 1;
        state = IDLE;
        clk_cycles = 0;
        bit_index = 0;
        data_reg = 0;
    end

    // Combinational logic
    
    assign BUSY = (state != IDLE);
    
    // Sequential logic
    
    always @(posedge CLK_100MHz) begin
        case (state)
            IDLE: begin
                if (LOAD) begin
                    // Start new transmission
                    data_reg <= IN;
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
                    
                    // Execute once per HALF_PERIOD
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
