`default_nettype none

module UartTX (
    input wire CLK_100MHz,
    input wire load,
    input wire [15:0] in,
    output reg TX,
    output reg [15:0] out,
    output reg tx_busy // Signal to indicate transmission status
);

    parameter CLK_FREQ = 100000000; // 100 MHz clock
    parameter BAUD_RATE = 115200; // 115200 baud rate
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE; // Number of clock cycles per bit

    reg [31:0] clk_cycles;
    reg [8:0] data_tx;
    reg [3:0] bit_index;

    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    reg [1:0] state = IDLE;

    initial begin
        clk_cycles <= 0;       // Initialize clk_cycles to 0
        data_tx <= 9'b0;       // Initialize data_tx to 0 (8 data bits + start bit)
        bit_index <= 0;        // Initialize bit_index to 0
        out <= 16'b0;          // Initialize out to 0

        TX <= 1;
        tx_busy <= 0;
    end

    always @(posedge CLK_100MHz) begin
        case (state)
            IDLE: begin
                if (load && !tx_busy) begin
                    data_tx <= {1'b1, in[7:0]}; // Start bit + data bits
                    bit_index <= 0;
                    clk_cycles <= 0;
                    tx_busy <= 1; // Set tx_busy when transmission starts
                    TX <= 0; // Start bit
                    out <= in; // Output the input data
                    state <= START; // Move to START state
                end
            end

            START: begin
                if (clk_cycles < BIT_PERIOD - 1) begin
                    clk_cycles <= clk_cycles + 1;
                end else begin
                    clk_cycles <= 0;
                    bit_index <= bit_index + 1;
                    TX <= data_tx[bit_index];
                    state <= DATA; // Move to DATA state
                end
            end

            DATA: begin
                if (clk_cycles < BIT_PERIOD - 1) begin
                    clk_cycles <= clk_cycles + 1;
                end else begin
                    clk_cycles <= 0;
                    bit_index <= bit_index + 1;
                    if (bit_index < 8) begin
                        TX <= data_tx[bit_index];
                    end else begin
                        state <= STOP; // Move to STOP state
                    end
                end
            end

            STOP: begin
                if (clk_cycles < BIT_PERIOD - 1) begin
                    clk_cycles <= clk_cycles + 1;
                end else begin
                    clk_cycles <= 0;
                    tx_busy <= 0; // End of transmission
                    TX <= 1; // Idle state
                    state <= IDLE; // Move back to IDLE state
                end
            end

            default: state <= IDLE; // Default to IDLE state
        endcase
    end

endmodule
