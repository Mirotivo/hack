/*
 * The module MemoryMappedIO provides access to memory RAM 
 * and memory-mapped IO
 * In our Minimal-Hack-Project we will use 4Kx16 Bit RAM
 * 
 * address | memory
 * ----------------
 * 0-2047  | RAM
 * 2048    | led
 * 2049    | but
 * 2050    | UART_RX
 * 2051    | UART_TX
 * 2052    | SPI
 *
 * WRITE:
 * When load is set to 1, 16 bit dataW are stored to Memory address
 * at next clock cycle. M[address] <= dataW
 * READ:
 * dataR provides data stored in Memory at address.
 * dataR = M[address]
 *
 * 0x6000  keyboard in course
 */

`default_nettype none
module MemoryMappedIO(
    // Clock and Reset
    input wire CLK_100MHz,
    input wire CLK_CPU,
    input wire [31:0] CLK_COUNT,
    // Memory Interface
    input wire [15:0] address,
    output reg [15:0] dataR,
    input wire [15:0] dataW,
    input wire loadM,
    // GPIO
    input wire [1:0] but,
    output reg [1:0] led,
    // UART Interface
    input wire UART_RX,
    output wire UART_TX,
    // SPI Interface
    output wire SPI_SDO,
    input wire SPI_SDI,
    output wire SPI_SCK,
    output wire SPI_CSX
);

    // Address range parameters
    localparam ADDR_RAM_END   = 2047;
    localparam ADDR_LED       = 2048;
    localparam ADDR_BUTTON    = 2049;
    localparam ADDR_UART_RX   = 2050;
    localparam ADDR_UART_TX   = 2051;
    localparam ADDR_SPI       = 2052;

    // Internal data register for memory read
    wire [15:0] memDataR;

    // Additional memory storage for special addresses
    reg [15:0] regLED;
    reg [15:0] regButton;
    reg uartTxLoad;
    reg [15:0] uartTxBuffer;
    reg uartRxClear;
    reg [15:0] uartRxData;
    wire [15:0] uartRxOut;

    // UART status flags
    wire uartTxBusy;
    wire uartRxReady;

    // SPI control and status
    reg spiLoad;
    reg [15:0] spiDataIn;
    wire [15:0] spiDataOut;

    // Instantiate Memory module for addresses 0 to 2047
    Memory Memory (
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(CLK_CPU),
        .CLK_COUNT(CLK_COUNT),
        .address(address[10:0]), // Use lower 11 bits for addressing
        .dataW(dataW),
        .loadM(loadM & (address < 2048)), // Enable loadM only for addresses 0 to 2047
        .dataR(memDataR)
    );

    // Instantiate UART Transmitter
    UartTX UartTX (
        .CLK_100MHz(CLK_100MHz),
        .load(uartTxLoad),
        .in(uartTxBuffer),
        .TX(UART_TX),
        .tx_busy(uartTxBusy)
    );

    // Instantiate UART Receiver
    UartRX UartRX (
        .CLK_100MHz(CLK_100MHz),
        .clear(uartRxClear),
        .RX(UART_RX),
        .out(uartRxOut),
        .rx_ready(uartRxReady)
    );

    // Instantiate SPI module
    SPI SPI (
        .CLK_100MHz(CLK_100MHz),
        .reset(1'b0), // Assume reset is not needed for now
        .load(spiLoad),
        .in(spiDataIn),
        .out(spiDataOut),
        .CSX(SPI_CSX),
        .SDO(SPI_SDO),
        .SDI(SPI_SDI),
        .SCK(SPI_SCK)
    );

    // Initialize registers
    initial begin
        regLED = 16'b0;
        regButton = 16'b0;
        uartTxLoad = 1'b0;
        uartTxBuffer = 16'b0;
        uartRxClear = 1'b0;
        uartRxData = 16'b0;
        spiLoad = 1'b0;
        spiDataIn = 16'b0;
        led = 2'b0;
    end

    always @(posedge CLK_100MHz) begin
        // Default values for control signals
        uartTxLoad <= 1'b0;
        spiLoad <= 1'b0;
        uartRxClear <= 1'b0;
        if (uartRxReady) begin
            uartRxData <= uartRxOut;
            uartRxClear <= 1'b1;
        end

        // Read operation
        dataR <= (address <= ADDR_RAM_END) ? memDataR :
                 (address == ADDR_LED) ? regLED :
                 (address == ADDR_BUTTON) ? regButton :
                 (address == ADDR_UART_RX) ? uartRxData :
                 (address == ADDR_UART_TX) ? (uartTxBusy ? 16'hFFFF : 16'h0000) :
                 (address == ADDR_SPI) ? spiDataOut :
                 16'h0000;

        // Write operation
        if (loadM && (CLK_COUNT == 10 && CLK_CPU == 1'b1)) begin
            if (address <= ADDR_RAM_END) begin
                // Write to Memory module handled internally
            end else begin
                case (address)
                    ADDR_LED: regLED <= dataW;
                    ADDR_BUTTON: regButton <= {14'b0, but};
                    // ADDR_UART_RX: uartRxClear <= 1'b1;
                    ADDR_UART_TX: begin
                        if (!uartTxBusy) begin
                            uartTxLoad <= 1'b1;
                            uartTxBuffer <= dataW;
                        end
                    end
                    ADDR_SPI: begin
                        spiLoad <= 1'b1;
                        spiDataIn <= dataW;
                    end
                    default: ; // Do nothing for default case
                endcase
            end
        end

        // Update LEDs based on UART status flags
        led[0] <= uartTxBusy; // LED0 indicates UART Tx busy status
        led[1] <= uartRxReady; // LED1 indicates UART Rx ready status
    end

endmodule
