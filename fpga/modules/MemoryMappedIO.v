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
 * 2053    | LCD_DATA - Write 8-bit data byte
 * 2054    | LCD_CMD - Write 8-bit command byte
 * 2055    | LCD_STATUS - Read: bit[0]=ready, bit[1]=busy
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
    // LCD Interface
    output wire TFT_CS,
    output wire TFT_RESET,
    output wire TFT_SDI,
    output wire TFT_SCK,
    output wire TFT_DC
);

    // Address range parameters
    localparam ADDR_RAM_END   = 2047;
    localparam ADDR_LED       = 2048;
    localparam ADDR_BUTTON    = 2049;
    localparam ADDR_UART_RX   = 2050;
    localparam ADDR_UART_TX   = 2051;
    localparam ADDR_LCD_DATA  = 2053;
    localparam ADDR_LCD_CMD   = 2054;
    localparam ADDR_LCD_STATUS = 2055;
    
    // Clock enable timing parameter
    localparam CLK_COUNT_WRITE = 10;

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

    // LCD control and status
    reg lcdLoad;
    reg [7:0] lcdData;
    reg lcdIsCmd;
    wire lcdBusy;
    wire lcdReady;
    reg lcdLoadPending;  // Track if we've already sent a load pulse

    // Instantiate Memory module for addresses 0 to 2047
    Memory memory_inst (
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(CLK_CPU),
        .CLK_COUNT(CLK_COUNT),
        .address(address[10:0]), // Use lower 11 bits for addressing
        .dataW(dataW),
        .loadM(loadM & (address < 2048)), // Enable loadM only for addresses 0 to 2047
        .dataR(memDataR)
    );

    // Instantiate UART Transmitter
    UartTX uart_tx_inst (
        .CLK_100MHz(CLK_100MHz),
        .load(uartTxLoad),
        .in(uartTxBuffer),
        .TX(UART_TX),
        .tx_busy(uartTxBusy)
    );

    // Instantiate UART Receiver
    UartRX uart_rx_inst (
        .CLK_100MHz(CLK_100MHz),
        .clear(uartRxClear),
        .RX(UART_RX),
        .out(uartRxOut),
        .rx_ready(uartRxReady)
    );

    // Instantiate LCD module
    LCD lcd_inst (
        .CLK_100MHz(CLK_100MHz),
        .load(lcdLoad),
        .data_in(lcdData),
        .is_cmd(lcdIsCmd),
        .TFT_CS(TFT_CS),
        .TFT_RESET(TFT_RESET),
        .TFT_SDI(TFT_SDI),
        .TFT_SCK(TFT_SCK),
        .TFT_DC(TFT_DC),
        .busy(lcdBusy),
        .ready(lcdReady)
    );

    // Initialize registers
    initial begin
        regLED = 16'b0;
        regButton = 16'b0;
        uartTxLoad = 1'b0;
        uartTxBuffer = 16'b0;
        uartRxClear = 1'b0;
        uartRxData = 16'b0;
        lcdLoad = 1'b0;
        lcdData = 8'b0;
        lcdIsCmd = 1'b0;
        lcdLoadPending = 1'b0;
        led = 2'b0;
    end

    always @(posedge CLK_100MHz) begin
        // Default values for control signals
        uartTxLoad <= 1'b0;
        uartRxClear <= 1'b0;
        
        // LCD handshake: clear load after LCD acknowledges by setting busy
        if (lcdBusy && lcdLoadPending) begin
            lcdLoad <= 1'b0;
            lcdLoadPending <= 1'b0;
        end
        
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
                 (address == ADDR_LCD_STATUS) ? {14'b0, lcdBusy, lcdReady} :
                 16'h0000;

        // Write operation - synchronized with CPU clock
        if (loadM && (CLK_COUNT == CLK_COUNT_WRITE && CLK_CPU == 1'b1)) begin
            if (address <= ADDR_RAM_END) begin
                // Write to Memory module handled internally
            end else begin
                case (address)
                    ADDR_LED: regLED <= dataW;
                    ADDR_BUTTON: regButton <= {14'b0, but};
                    ADDR_UART_TX: begin
                        if (!uartTxBusy) begin
                            uartTxLoad <= 1'b1;
                            uartTxBuffer <= dataW;
                        end
                    end
                    ADDR_LCD_DATA: begin
                        if (lcdReady && !lcdBusy && !lcdLoadPending) begin
                            lcdData <= dataW[7:0];
                            lcdIsCmd <= 1'b0;  // Data byte
                            lcdLoad <= 1'b1;
                            lcdLoadPending <= 1'b1;
                        end
                    end
                    ADDR_LCD_CMD: begin
                        if (lcdReady && !lcdBusy && !lcdLoadPending) begin
                            lcdData <= dataW[7:0];
                            lcdIsCmd <= 1'b1;  // Command byte
                            lcdLoad <= 1'b1;
                            lcdLoadPending <= 1'b1;
                        end
                    end
                    default: ; // Do nothing for default case
                endcase
            end
        end

        // Update LEDs based on LCD status flags
        led[0] <= lcdReady;  // LED0 indicates LCD ready status
        led[1] <= lcdBusy;   // LED1 indicates LCD busy status
    end

endmodule
