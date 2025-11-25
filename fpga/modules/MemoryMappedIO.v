/**
 * The module MemoryMappedIO provides access to memory RAM 
 * and memory-mapped I/O
 * In our Minimal-Hack-Project we will use 4Kx16 Bit RAM
 * 
 * Address | Memory
 * --------+-------
 * 0-2047  | RAM
 * 2048    | LED
 * 2049    | Button
 * 2050    | UART_RX
 * 2051    | UART_TX
 * 2053    | LCD_DATA - Write 8-bit data byte
 * 2054    | LCD_CMD - Write 8-bit command byte
 * 2055    | LCD_STATUS - Read: bit[0]=ready, bit[1]=busy
 *
 * WRITE:
 * When LOAD_M is set to 1, 16 bit DATA_W are stored to Memory address
 * at next clock cycle. M[address] <= DATA_W
 * READ:
 * DATA_R provides data stored in Memory at address.
 * DATA_R = M[address]
 *
 * 0x6000 keyboard in course
 */
`default_nettype none
module MemoryMappedIO(
    // Clock and Reset
    input wire CLK_100MHz,
    input wire CLK_CPU,
    input wire [31:0] CLK_COUNT,

    // Memory Interface
    input wire [15:0] ADDRESS,
    output reg [15:0] DATA_R,
    input wire [15:0] DATA_W,
    input wire LOAD_M,

    // GPIO
    input wire [1:0] BUT,
    output reg [1:0] LED,

    // UART
    input wire UART_RX,
    output wire UART_TX,

    // LCD/TFT Display
    output wire TFT_CS,
    output wire TFT_RESET,
    output wire TFT_SDI,
    output wire TFT_SCK,
    output wire TFT_DC
);

    // Parameters
    localparam ADDR_RAM_END    = 2047;
    localparam ADDR_LED        = 2048;
    localparam ADDR_BUTTON     = 2049;
    localparam ADDR_UART_RX    = 2050;
    localparam ADDR_UART_TX    = 2051;
    localparam ADDR_LCD_DATA   = 2053;
    localparam ADDR_LCD_CMD    = 2054;
    localparam ADDR_LCD_STATUS = 2055;
    localparam CLK_COUNT_WRITE = 10;

    // Memory
    wire [15:0] mem_data_r;

    // GPIO - Additional registers
    reg [15:0] reg_led;
    reg [15:0] reg_button;

    // UART - Control and data
    reg uart_load;
    reg [15:0] uart_data;
    reg uart_clear;
    reg [15:0] uart_rx_data;
    wire [15:0] uart_rx_out;
    wire uart_busy;
    wire uart_ready;

    // LCD/TFT Display - Control and status
    reg lcd_load;
    reg [7:0] lcd_data;
    reg is_cmd;
    wire lcd_busy;
    wire lcd_ready;
    reg lcd_load_pending;  // Track if we've already sent a load pulse

    // Module instantiations
    
    // Memory module for addresses 0 to 2047
    Memory memory_inst (
        .CLK_100MHz(CLK_100MHz),
        .CLK_CPU(CLK_CPU),
        .CLK_COUNT(CLK_COUNT),
        .ADDRESS(ADDRESS[10:0]),              // Use lower 11 bits for addressing
        .DATA_W(DATA_W),
        .LOAD_M(LOAD_M & (ADDRESS < 2048)),   // Enable LOAD_M only for addresses 0 to 2047
        .DATA_R(mem_data_r)
    );

    // UART - Transmitter
    UartTX uart_tx_inst (
        .CLK_100MHz(CLK_100MHz),
        .load(uart_load),
        .in(uart_data),
        .TX(UART_TX),
        .tx_busy(uart_busy)
    );

    // UART - Receiver
    UartRX uart_rx_inst (
        .CLK_100MHz(CLK_100MHz),
        .clear(uart_clear),
        .RX(UART_RX),
        .out(uart_rx_out),
        .rx_ready(uart_ready)
    );

    // LCD/TFT Display
    LCD lcd_inst (
        .CLK_100MHz(CLK_100MHz),
        .load(lcd_load),
        .data_in(lcd_data),
        .is_cmd(is_cmd),
        .TFT_CS(TFT_CS),
        .TFT_RESET(TFT_RESET),
        .TFT_SDI(TFT_SDI),
        .TFT_SCK(TFT_SCK),
        .TFT_DC(TFT_DC),
        .busy(lcd_busy),
        .ready(lcd_ready)
    );

    // Initial blocks
    
    initial begin
        reg_led = 16'b0;
        reg_button = 16'b0;
        uart_load = 1'b0;
        uart_data = 16'b0;
        uart_clear = 1'b0;
        uart_rx_data = 16'b0;
        lcd_load = 1'b0;
        lcd_data = 8'b0;
        is_cmd = 1'b0;
        lcd_load_pending = 1'b0;
        LED = 2'b0;
    end

    // Sequential logic
    
    always @(posedge CLK_100MHz) begin
        // Default values for control signals
        uart_load <= 1'b0;
        uart_clear <= 1'b0;
        
        // LCD handshake: clear load after LCD acknowledges by setting busy
        if (lcd_busy && lcd_load_pending) begin
            lcd_load <= 1'b0;
            lcd_load_pending <= 1'b0;
        end
        
        // UART - Receiver data capture
        if (uart_ready) begin
            uart_rx_data <= uart_rx_out;
            uart_clear <= 1'b1;
        end

        // Read operation
        DATA_R <= (ADDRESS <= ADDR_RAM_END) ? mem_data_r :
                  (ADDRESS == ADDR_LED) ? reg_led :
                  (ADDRESS == ADDR_BUTTON) ? reg_button :
                  (ADDRESS == ADDR_UART_RX) ? uart_rx_data :
                  (ADDRESS == ADDR_UART_TX) ? (uart_busy ? 16'hFFFF : 16'h0000) :
                  (ADDRESS == ADDR_LCD_STATUS) ? {14'b0, lcd_busy, lcd_ready} :
                  16'h0000;

        // Write operation - synchronized with CPU clock
        if (LOAD_M && (CLK_COUNT == CLK_COUNT_WRITE && CLK_CPU == 1'b1)) begin
            if (ADDRESS <= ADDR_RAM_END) begin
                // Write to Memory module handled internally
            end else begin
                case (ADDRESS)
                    ADDR_LED: reg_led <= DATA_W;
                    ADDR_BUTTON: reg_button <= {14'b0, BUT};
                    ADDR_UART_TX: begin
                        if (!uart_busy) begin
                            uart_load <= 1'b1;
                            uart_data <= DATA_W;
                        end
                    end
                    ADDR_LCD_DATA: begin
                        if (lcd_ready && !lcd_busy && !lcd_load_pending) begin
                            lcd_data <= DATA_W[7:0];
                            is_cmd <= 1'b0;     // Data byte
                            lcd_load <= 1'b1;
                            lcd_load_pending <= 1'b1;
                        end
                    end
                    ADDR_LCD_CMD: begin
                        if (lcd_ready && !lcd_busy && !lcd_load_pending) begin
                            lcd_data <= DATA_W[7:0];
                            is_cmd <= 1'b1;     // Command byte
                            lcd_load <= 1'b1;
                            lcd_load_pending <= 1'b1;
                        end
                    end
                    default: ; // Do nothing for default case
                endcase
            end
        end

        // Update LEDs based on LCD status flags
        LED[0] <= lcd_ready;  // LED0 indicates LCD ready status
        LED[1] <= lcd_busy;   // LED1 indicates LCD busy status
    end

endmodule
