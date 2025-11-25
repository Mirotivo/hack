/**
 * The module UartRX receives data via UART protocol
 * Receives 8-bit data at 115200 baud rate
 * 
 * RX_READY indicates when new data has been received
 */
`default_nettype none
module UartRX (
    // Clock
    input wire CLK_100MHz,

    // Control Interface
    input wire CLEAR,
    output reg RX_READY,

    // Data Interface
    output reg [15:0] OUT,

    // UART
    input wire RX
);

    // Parameters
    parameter CLK_FREQ = 100000000;     // 100 MHz clock
    parameter BAUD_RATE = 115200;       // 115200 baud rate
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;        // Number of clock cycles per bit
    localparam SAMPLE_POINT = (BIT_PERIOD - 1) / 2;      // Middle of the bit period for sampling

    // State machine states
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;

    // Internal signals
    reg [31:0] clk_cycles;
    reg [7:0] data_rx;
    reg [3:0] bit_index;
    reg [2:0] state;

    // Initial blocks
    
    initial begin
        clk_cycles = 0;
        data_rx = 0;
        bit_index = 0;
        state = IDLE;
        OUT = 16'b0;
        RX_READY = 0;
    end

    // Sequential logic
    
    always @(posedge CLK_100MHz) begin
        if (CLEAR) begin
            state <= IDLE;
            clk_cycles <= 0;
            bit_index <= 0;
            data_rx <= 0;
            OUT <= 16'b0;
            RX_READY <= 0;
            OUT[15] <= 1;
        end else begin
            case (state)
                IDLE: begin
                    RX_READY <= 0;
                    if (RX == 0) begin           // Start bit detected
                        state <= START;
                        clk_cycles <= 0;
                    end
                end

                START: begin
                    if (clk_cycles == SAMPLE_POINT) begin
                        if (RX == 0) begin       // Confirm start bit
                            state <= DATA;
                            clk_cycles <= 0;
                            bit_index <= 0;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        clk_cycles <= clk_cycles + 1;
                    end
                end

                DATA: begin
                    if (clk_cycles == BIT_PERIOD) begin
                        clk_cycles <= 0;
                        data_rx[bit_index] <= RX;
                        if (bit_index == 7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_cycles <= clk_cycles + 1;
                    end
                end

                STOP: begin
                    if (clk_cycles == BIT_PERIOD) begin
                        clk_cycles <= 0;
                        if (RX == 1) begin       // Stop bit
                            state <= IDLE;
                            OUT <= {7'b0, data_rx};
                            RX_READY <= 1;
                            OUT[15] <= 0;
                        end else begin
                            state <= IDLE;       // Error, go back to IDLE
                        end
                    end else begin
                        clk_cycles <= clk_cycles + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
