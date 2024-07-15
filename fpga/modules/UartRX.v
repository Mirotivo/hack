module UartRX (
    input wire CLK_100MHz,           // System clock
    input wire clear,         // clear signal
    input wire RX,       // UART receive pin
    output reg [15:0] out, // Received byte
    output reg rx_ready       // Data ready signal
);

    parameter CLK_FREQ = 100000000;  // 100 MHz clock
    // parameter CLK_FREQ = 25000000; // 25 MHz clock
    parameter BAUD_RATE = 115200;   // 115200 baud rate
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;  // Number of clock cycles per bit
    localparam SAMPLE_POINT = (BIT_PERIOD - 1) / 2;  // Middle of the bit period for sampling

    reg [31:0] clk_cycles = 0;     // Clock cycles count
    reg [7:0] data_rx = 0;   // Shift register for received data
    reg [3:0] bit_index = 0;      // Bit index for data bits

    // State declaration
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;
    reg [2:0] state = IDLE;       // Current state

    initial begin
        rx_ready <= 0;
    end

    always @(posedge CLK_100MHz) begin
        if (clear) begin
            state <= IDLE;
            clk_cycles <= 0;
            bit_index <= 0;
            data_rx <= 0;
            out <= 16'b0;
            rx_ready <= 0;
            out[15] <= 1;
        end else begin
            case (state)
                IDLE: begin
                    rx_ready <= 0;
                    if (RX == 0) begin  // Start bit detected
                        state <= START;
                        clk_cycles <= 0;
                    end
                end

                START: begin
                    if (clk_cycles == SAMPLE_POINT) begin
                        if (RX == 0) begin  // Confirm start bit
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
                        if (RX == 1) begin  // Stop bit
                            state <= IDLE;
                            out <= {7'b0, data_rx};
                            rx_ready <= 1;
                            out[15] <= 0;
                        end else begin
                            state <= IDLE;  // Error, go back to IDLE
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
