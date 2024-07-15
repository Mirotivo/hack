module SPI (
    input wire CLK_100MHz,         // System clock
    input wire reset,              // System reset
    input wire load,               // Load signal to initiate transmission
    input wire [15:0] in,          // Input data and control signal
    output wire busy,              // Busy signal
    output reg [15:0] out,         // Output data and status
    output reg CSX,                // Chip Select (active low)
    output reg SDO,                // Serial Data Out
    input wire SDI,                // Serial Data In
    output reg SCK                 // Serial Clock
);

    reg [7:0] shift_reg_tx;        // Shift register for transmitting data
    reg [7:0] shift_reg_rx;        // Shift register for receiving data
    reg [3:0] bit_count;           // Bit counter
    reg state;                     // State: 0 = ready, 1 = busy

    // Clock divider to generate ~8 MHz SPI clock from 100 MHz system clock
    reg [3:0] clk_div;             // 4-bit clock divider
    wire clk_8MHz = clk_div[3];    // Use the MSB of the divider as the SPI clock

    always @(posedge CLK_100MHz or posedge reset) begin
        if (reset) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div + 1;
        end
    end
    
    // State encoding
    localparam READY = 1'b0, BUSY = 1'b1;

    // Assign busy signal based on state
    assign busy = (state == BUSY);

    // SPI operations and state transitions
    always @(posedge clk_8MHz or posedge reset) begin
        if (reset) begin
            CSX <= 1;               // Deassert Chip Select (active low)
            SCK <= 0;               // Serial Clock low
            SDO <= 0;               // Serial Data Out low
            out <= 16'b0;           // Clear output register
            shift_reg_tx <= 8'b0;   // Clear transmit shift register
            shift_reg_rx <= 8'b0;   // Clear receive shift register
            bit_count <= 4'b0;      // Clear bit counter
            state <= READY;         // Initial state
        end else begin
            case (state)
                READY: begin
                    out[15] <= 1'b0;  // Indicate chip is ready
                    if (load) begin
                        if (in[8] == 1'b0) begin
                            shift_reg_tx <= in[7:0];  // Load input data into transmit shift register
                            bit_count <= 4'd7;        // Set bit counter to 7 (for 8 bits) // it was 8
                            CSX <= 0;                 // Assert Chip Select (active low)
                            out[15] <= 1'b1;          // Indicate chip is busy
                            state <= BUSY;            // Change state to BUSY
                        end else begin
                            CSX <= 1;                 // Pull CSX high without transmission
                        end
                    end
                end
                BUSY: begin
                    if (SCK == 0) begin
                        SDO <= shift_reg_tx[7];       // Output MSB of transmit shift register
                    end
                    SCK <= ~SCK;                      // Toggle clock
                    if (SCK == 1) begin               // Falling edge of SCK
                        shift_reg_tx <= {shift_reg_tx[6:0], 1'b0}; // Shift out MSB
                        shift_reg_rx <= {shift_reg_rx[6:0], SDI};  // Shift in SDI
                        if (bit_count == 0) begin
                            state <= READY;           // Change state to READY after last bit
                            out[7:0] <= shift_reg_rx; // Load receive shift register value into output
                            out[15] <= 1'b0;          // Indicate chip is ready
                            CSX <= 1;                 // Deassert Chip Select (active low)
                        end else begin
                            bit_count <= bit_count - 1; // Decrement bit counter
                        end
                    end
                end
            endcase
        end
    end
endmodule
