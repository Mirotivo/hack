`include "../../modules/CLK_Divider.v"
`include "../../modules/SRAM_Controller.v"

/**
 * The module Hack is an SRAM controller test
 * Tests SRAM write and read operations with simple patterns
 * Pattern: Write 0xAAAA to address 0x00000, then read it back
 *          Write 0x5555 to address 0x11111, then read it back
 * LEDs show operation status and data validation
 * Buttons control test start/reset
 * Use Logic Analyzer to monitor: CSX, WEX, OEX, ADDR[0], DATA[0]
 */
`default_nettype none
module Hack (
    // Clock
    input CLK_100MHz,

    // GPIO (Buttons and LEDs)
    input [1:0] BUT,
    output [1:0] LED,

    // UART (unused but needed for PCF)
    input UART_RX,
    output UART_TX,

    // SPI (unused but needed for PCF)
    output SPI_SDO,
    input SPI_SDI,
    output SPI_SCK,
    output SPI_CSX,

    // SRAM
    output [17:0] SRAM_ADDR,
    inout [15:0] SRAM_DATA,
    output SRAM_WEX,
    output SRAM_OEX,
    output SRAM_CSX,

    // LCD (unused but needed for PCF)
    output LCD_DCX,
    output LCD_SDO,
    output LCD_SCK,
    output LCD_CSX,

    // RTP (unused but needed for PCF)
    input RTP_SDI,
    output RTP_SDO,
    output RTP_SCK
);

    // Test patterns
    localparam PATTERN1 = 16'hAAAA;      // 1010101010101010
    localparam PATTERN2 = 16'h5555;      // 0101010101010101
    localparam ADDR1 = 18'h00000;        // First address
    localparam ADDR2 = 18'h11111;        // Second address

    // State machine states
    localparam IDLE          = 4'd0;
    localparam WRITE_ADDR1   = 4'd1;
    localparam WAIT_WRITE1   = 4'd2;
    localparam READ_ADDR1    = 4'd3;
    localparam WAIT_READ1    = 4'd4;
    localparam VERIFY1       = 4'd5;
    localparam WRITE_ADDR2   = 4'd6;
    localparam WAIT_WRITE2   = 4'd7;
    localparam READ_ADDR2    = 4'd8;
    localparam WAIT_READ2    = 4'd9;
    localparam VERIFY2       = 4'd10;
    localparam TEST_PASS     = 4'd11;
    localparam TEST_FAIL     = 4'd12;

    // Internal signals - Clock
    wire clk_slow;
    wire [31:0] clk_count;

    // Internal signals - SRAM Controller
    reg rst;
    reg we;
    reg [17:0] address;
    reg [15:0] data_write;
    wire [15:0] data_read;

    // Internal signals - State machine
    reg [3:0] state;
    reg [3:0] wait_counter;
    reg [15:0] data_captured;
    reg test1_pass;
    reg test2_pass;

    // Internal signals - Button processing
    wire button_start;
    wire button_reset;

    // Initial blocks
    
    initial begin
        state = IDLE;
        rst = 1;
        we = 0;
        address = 0;
        data_write = 0;
        data_captured = 0;
        wait_counter = 0;
        test1_pass = 0;
        test2_pass = 0;
    end

    // Module instantiations
    
    // Clock divider: Make it slow enough to see on LEDs
    // 100MHz / 10M = 10Hz (0.1 second per cycle)
    // This means ~1 second total test time (visible on LEDs)
    CLK_Divider clk_divider_inst (
        .CLK_IN(CLK_100MHz),
        .DIVISOR(32'd5000000),         // 100MHz / (2 * 5M) = 10Hz
        .CLK_OUT(clk_slow),
        .CLK_COUNT(clk_count)
    );

    // SRAM Controller (SB_IO primitives inside)
    // DATA port connects directly to top-level SRAM_DATA inout port
    SRAM_Controller sram_ctrl_inst (
        .CLK(clk_slow),
        .RST(rst),
        .WE(we),
        .ADDRESS(address),
        .DATA(SRAM_DATA),              // Direct connection to physical pins
        .DATA_WRITE(data_write),       // Data to write
        .DATA_READ(data_read),         // Data read back
        .CSX(SRAM_CSX),
        .OEX(SRAM_OEX),
        .WEX(SRAM_WEX)
    );

    // Sequential logic
    
    // Main test state machine
    always @(posedge clk_slow) begin
        if (button_reset) begin
            // Reset everything
            state <= IDLE;
            rst <= 1;
            we <= 0;
            address <= 0;
            data_write <= 0;
            test1_pass <= 0;
            test2_pass <= 0;
            wait_counter <= 0;
        end else begin
            rst <= 0;  // Release reset
            
            case (state)
                IDLE: begin
                    // Wait for button press to start test
                    we <= 0;
                    if (button_start) begin
                        state <= WRITE_ADDR1;
                    end
                end

                // Test 1: Write PATTERN1 to ADDR1
                WRITE_ADDR1: begin
                    address <= ADDR1;
                    data_write <= PATTERN1;
                    we <= 1;                    // Enable write
                    wait_counter <= 0;
                    state <= WAIT_WRITE1;
                end

                WAIT_WRITE1: begin
                    // Wait a few cycles for write to complete
                    if (wait_counter >= 4'd3) begin
                        we <= 0;                // Disable write
                        state <= READ_ADDR1;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end

                // Test 1: Read back from ADDR1
                READ_ADDR1: begin
                    address <= ADDR1;
                    we <= 0;                    // Enable read
                    wait_counter <= 0;
                    state <= WAIT_READ1;
                end

                WAIT_READ1: begin
                    // Wait a few cycles for read to complete
                    if (wait_counter >= 4'd3) begin
                        data_captured <= data_read;
                        state <= VERIFY1;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end

                VERIFY1: begin
                    // Check if data matches
                    if (data_captured == PATTERN1) begin
                        test1_pass <= 1;
                        state <= WRITE_ADDR2;
                    end else begin
                        test1_pass <= 0;
                        state <= TEST_FAIL;
                    end
                end

                // Test 2: Write PATTERN2 to ADDR2
                WRITE_ADDR2: begin
                    address <= ADDR2;
                    data_write <= PATTERN2;
                    we <= 1;                    // Enable write
                    wait_counter <= 0;
                    state <= WAIT_WRITE2;
                end

                WAIT_WRITE2: begin
                    // Wait a few cycles for write to complete
                    if (wait_counter >= 4'd3) begin
                        we <= 0;                // Disable write
                        state <= READ_ADDR2;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end

                // Test 2: Read back from ADDR2
                READ_ADDR2: begin
                    address <= ADDR2;
                    we <= 0;                    // Enable read
                    wait_counter <= 0;
                    state <= WAIT_READ2;
                end

                WAIT_READ2: begin
                    // Wait a few cycles for read to complete
                    if (wait_counter >= 4'd3) begin
                        data_captured <= data_read;
                        state <= VERIFY2;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end

                VERIFY2: begin
                    // Check if data matches
                    if (data_captured == PATTERN2) begin
                        test2_pass <= 1;
                        state <= TEST_PASS;
                    end else begin
                        test2_pass <= 0;
                        state <= TEST_FAIL;
                    end
                end

                TEST_PASS: begin
                    // Both tests passed - stay here
                    // LEDs will show success pattern
                    state <= TEST_PASS;
                end

                TEST_FAIL: begin
                    // At least one test failed - stay here
                    // LEDs will show failure pattern
                    state <= TEST_FAIL;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    // Combinational logic
    
    // Address bus
    assign SRAM_ADDR = address;

    // Button processing (buttons are active low)
    assign button_start = !BUT[0];      // BUT1 = Start test
    assign button_reset = !BUT[1];      // BUT2 = Reset

    // LED indicators
    // LED[0] = Test in progress (blinks during test)
    // LED[1] = Test result (ON = PASS, OFF = FAIL, Blink = Running)
    assign LED[0] = (state == TEST_PASS) ? 1'b1 :         // Both pass = ON
                    (state == TEST_FAIL) ? 1'b0 :         // Any fail = OFF
                    (state == IDLE) ? 1'b0 :              // Idle = OFF
                    clk_count[20];                         // Running = Blink

    assign LED[1] = (state == TEST_PASS) ? 1'b1 :         // Pass = ON
                    (state == TEST_FAIL) ? 1'b0 :         // Fail = OFF
                    (state == IDLE) ? clk_count[22] :     // Idle = Slow blink
                    clk_count[20];                         // Running = Fast blink

    // Unused outputs
    assign UART_TX = 1;
    assign SPI_SDO = 0;
    assign SPI_SCK = 0;
    assign SPI_CSX = 1;
    assign LCD_DCX = 0;
    assign LCD_SDO = 0;
    assign LCD_SCK = 0;
    assign LCD_CSX = 1;
    assign RTP_SDO = 0;
    assign RTP_SCK = 0;

endmodule
