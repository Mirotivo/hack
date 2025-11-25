/**
 * The module UartTX transmits data via UART protocol
 * Sends 8-bit data at 115200 baud rate
 * 
 * TX_BUSY indicates when transmission is in progress
 */
`default_nettype none
module UartTX (
    // Clock
    input wire CLK_100MHz,

    // Control Interface
    input wire LOAD,
    output reg TX_BUSY,

    // Data Interface
    input wire [15:0] IN,
    output reg [15:0] OUT,

    // UART
    output reg TX
);

    // Parameters
    parameter CLK_FREQ = 100000000;     // 100 MHz clock
    parameter BAUD_RATE = 115200;       // 115200 baud rate
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;  // Number of clock cycles per bit

    // State machine states
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    // Internal signals
    reg [31:0] clk_cycles;
    reg [8:0] data_tx;
    reg [3:0] bit_index;
    reg [1:0] state;

    // Initial blocks
    
    initial begin
        clk_cycles = 0;
        data_tx = 9'b0;
        bit_index = 0;
        state = IDLE;
        OUT = 16'b0;
        TX = 1;
        TX_BUSY = 0;
    end

    // Sequential logic
    
    always @(posedge CLK_100MHz) begin
        case (state)
            IDLE: begin
                if (LOAD && !TX_BUSY) begin
                    data_tx <= {1'b1, IN[7:0]};  // Start bit + data bits
                    bit_index <= 0;
                    clk_cycles <= 0;
                    TX_BUSY <= 1;                // Set TX_BUSY when transmission starts
                    TX <= 0;                     // Start bit
                    OUT <= IN;                   // Output the input data
                    state <= START;              // Move to START state
                end
            end

            START: begin
                if (clk_cycles < BIT_PERIOD - 1) begin
                    clk_cycles <= clk_cycles + 1;
                end else begin
                    clk_cycles <= 0;
                    bit_index <= bit_index + 1;
                    TX <= data_tx[bit_index];
                    state <= DATA;               // Move to DATA state
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
                        state <= STOP;           // Move to STOP state
                    end
                end
            end

            STOP: begin
                if (clk_cycles < BIT_PERIOD - 1) begin
                    clk_cycles <= clk_cycles + 1;
                end else begin
                    clk_cycles <= 0;
                    TX_BUSY <= 0;                // End of transmission
                    TX <= 1;                     // Idle state
                    state <= IDLE;               // Move back to IDLE state
                end
            end

            default: state <= IDLE;              // Default to IDLE state
        endcase
    end

endmodule
