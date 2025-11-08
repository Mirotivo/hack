`default_nettype none

`include "../../modules/CLK_Divider.v"
`include "../../modules/SPI.v"

/**
 * ============================================================================
 * ILI9341 TFT Display Driver - Simple initialization sequence
 * ============================================================================
 */
module Hack (
    input CLK_100MHz,
    input [1:0] BUT,
    output [1:0] LED,
    
    output TFT_CS,
    output TFT_RESET,
    output TFT_SDI,
    output TFT_SCK,
    output reg TFT_DC
);

    // Clock divider: 100MHz -> 1MHz for SPI communication
    wire clk_spi;
    wire [31:0] clk_count;
    
    CLK_Divider clk_div (
        .clk_in(CLK_100MHz),
        .divisor(32'd49),  // 100MHz / (2 * 50) = 1MHz
        // .divisor(32'd4999999),  // 100MHz / (2 * 5000000) = 10Hz
        .clk_out(clk_spi),
        .clk_count(clk_count)
    );

    // TFT Control - Hardware reset
    reg tft_reset = 0;
    assign TFT_RESET = tft_reset;
    
    // SPI signals
    reg spi_load = 0;
    reg [7:0] spi_data = 0;
    wire spi_busy;
    wire spi_csx;
    
    SPI spi (
        .clk(clk_spi),
        .load(spi_load),
        .in(spi_data),
        .SCK(TFT_SCK),
        .SDI(TFT_SDI),
        .CSX(spi_csx),
        .busy(spi_busy)
    );
    
    assign TFT_CS = spi_csx;
    
    // State machine
    localparam RESET_LOW = 0;
    localparam RESET_HIGH = 1;
    localparam LOAD = 2;
    localparam SEND = 3;
    localparam WAIT = 4;
    localparam NEXT = 5;
    
    reg [2:0] state = RESET_LOW;
    reg [7:0] step = 0;  // Current initialization step
    reg [31:0] delay_counter = 0;  // For delays between commands
    reg init_done = 0;  // Flag to indicate initialization is complete
    reg pixel_byte = 0;  // Track which byte of pixel we're sending (0=high, 1=low)
    
    // Main state machine
    always @(posedge clk_spi) begin
        case (state)
            RESET_LOW: begin
                // Pull RESET low for at least 10ms
                tft_reset <= 0;
                delay_counter <= 10000;  // 10ms at 1MHz
                spi_load <= 0;
                if (delay_counter == 0) begin
                    state <= RESET_HIGH;
                    delay_counter <= 120000;  // 120ms delay after reset
                end else begin
                    delay_counter <= delay_counter - 1;
                end
            end
            
            RESET_HIGH: begin
                // Pull RESET high and wait
                tft_reset <= 1;
                if (delay_counter == 0) begin
                    state <= LOAD;
                end else begin
                    delay_counter <= delay_counter - 1;
                end
            end
            
            LOAD: begin
                // Load command or data based on current step
                delay_counter <= 0;  // Reset delay for next command
                
                case (step)
                    // Software Reset
                    0: begin TFT_DC <= 0; spi_data <= 8'h01; delay_counter <= 150000; end  // CMD: SWRESET (needs 150ms delay)
                    
                    // Power Control A
                    1: begin TFT_DC <= 0; spi_data <= 8'hCB; end  // CMD: Power control A
                    2: begin TFT_DC <= 1; spi_data <= 8'h39; end  // DATA
                    3: begin TFT_DC <= 1; spi_data <= 8'h2C; end  // DATA
                    4: begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA
                    5: begin TFT_DC <= 1; spi_data <= 8'h34; end  // DATA
                    6: begin TFT_DC <= 1; spi_data <= 8'h02; end  // DATA
                    
                    // Power Control B
                    7:  begin TFT_DC <= 0; spi_data <= 8'hCF; end  // CMD: Power control B
                    8:  begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA
                    9:  begin TFT_DC <= 1; spi_data <= 8'hC1; end  // DATA
                    10: begin TFT_DC <= 1; spi_data <= 8'h30; end  // DATA
                    
                    // Driver Timing Control A
                    11: begin TFT_DC <= 0; spi_data <= 8'hE8; end  // CMD
                    12: begin TFT_DC <= 1; spi_data <= 8'h85; end  // DATA
                    13: begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA
                    14: begin TFT_DC <= 1; spi_data <= 8'h78; end  // DATA
                    
                    // Power on Sequence Control
                    15: begin TFT_DC <= 0; spi_data <= 8'hED; end  // CMD
                    16: begin TFT_DC <= 1; spi_data <= 8'h64; end  // DATA
                    17: begin TFT_DC <= 1; spi_data <= 8'h03; end  // DATA
                    18: begin TFT_DC <= 1; spi_data <= 8'h12; end  // DATA
                    19: begin TFT_DC <= 1; spi_data <= 8'h81; end  // DATA
                    
                    // Pump Ratio Control
                    20: begin TFT_DC <= 0; spi_data <= 8'hF7; end  // CMD
                    21: begin TFT_DC <= 1; spi_data <= 8'h20; end  // DATA
                    
                    // Power Control 1
                    22: begin TFT_DC <= 0; spi_data <= 8'hC0; end  // CMD
                    23: begin TFT_DC <= 1; spi_data <= 8'h23; end  // DATA: VRH[5:0]
                    
                    // Power Control 2
                    24: begin TFT_DC <= 0; spi_data <= 8'hC1; end  // CMD
                    25: begin TFT_DC <= 1; spi_data <= 8'h10; end  // DATA: SAP[2:0];BT[3:0]
                    
                    // VCOM Control 1
                    26: begin TFT_DC <= 0; spi_data <= 8'hC5; end  // CMD
                    27: begin TFT_DC <= 1; spi_data <= 8'h3E; end  // DATA
                    28: begin TFT_DC <= 1; spi_data <= 8'h28; end  // DATA
                    
                    // VCOM Control 2
                    29: begin TFT_DC <= 0; spi_data <= 8'hC7; end  // CMD
                    30: begin TFT_DC <= 1; spi_data <= 8'h86; end  // DATA
                    
                    // Memory Access Control
                    31: begin TFT_DC <= 0; spi_data <= 8'h36; end  // CMD: MADCTL
                    32: begin TFT_DC <= 1; spi_data <= 8'h08; end  // DATA: Try standard rotation with BGR
                    
                    // Pixel Format
                    33: begin TFT_DC <= 0; spi_data <= 8'h3A; end  // CMD: COLMOD
                    34: begin TFT_DC <= 1; spi_data <= 8'h55; end  // DATA: 16-bit/pixel
                    
                    // Frame Rate Control
                    35: begin TFT_DC <= 0; spi_data <= 8'hB1; end  // CMD
                    36: begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA
                    37: begin TFT_DC <= 1; spi_data <= 8'h18; end  // DATA
                    
                    // Display Function Control
                    38: begin TFT_DC <= 0; spi_data <= 8'hB6; end  // CMD
                    39: begin TFT_DC <= 1; spi_data <= 8'h08; end  // DATA
                    40: begin TFT_DC <= 1; spi_data <= 8'h82; end  // DATA
                    41: begin TFT_DC <= 1; spi_data <= 8'h27; end  // DATA
                    
                    // Sleep Out
                    42: begin TFT_DC <= 0; spi_data <= 8'h11; delay_counter <= 120000; end  // CMD: Sleep Out (needs 120ms delay)
                    
                    // Display ON
                    43: begin TFT_DC <= 0; spi_data <= 8'h29; delay_counter <= 50000; end  // CMD: Display ON (needs 50ms delay)
                    
                    // Column Address Set (0 to 239)
                    44: begin TFT_DC <= 0; spi_data <= 8'h2A; end  // CMD: CASET
                    45: begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA: Start high
                    46: begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA: Start low
                    47: begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA: End high
                    48: begin TFT_DC <= 1; spi_data <= 8'hEF; end  // DATA: End low (239)
                    
                    // Page Address Set (0 to 319)
                    49: begin TFT_DC <= 0; spi_data <= 8'h2B; end  // CMD: PASET
                    50: begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA: Start high
                    51: begin TFT_DC <= 1; spi_data <= 8'h00; end  // DATA: Start low
                    52: begin TFT_DC <= 1; spi_data <= 8'h01; end  // DATA: End high
                    53: begin TFT_DC <= 1; spi_data <= 8'h3F; end  // DATA: End low (319)
                    
                    // Memory Write
                    54: begin TFT_DC <= 0; spi_data <= 8'h2C; end  // CMD: Memory Write
                    
                    // Now send pixel data - Blue color (0x001F in RGB565)
                    // For 16-bit RGB565: High byte = R[4:0]G[5:3], Low byte = G[2:0]B[4:0]
                    // Blue: R=0, G=0, B=31 -> High=0x00, Low=0x1F
                    default: begin 
                        if (step >= 55) begin
                            // Keep sending blue pixels
                            TFT_DC <= 1; 
                            spi_data <= pixel_byte ? 8'h1F : 8'h00;  // Alternate: high byte 0x00, low byte 0x1F
                        end
                    end
                endcase
                
                spi_load <= 1;
                state <= SEND;
            end
            
            SEND: begin
                // Wait for SPI to accept
                if (spi_busy) begin
                    spi_load <= 0;
                end
                
                // Wait for transmission to complete
                if (!spi_busy && !spi_load) begin
                    if (delay_counter > 0) begin
                        state <= WAIT;
                    end else begin
                        state <= NEXT;
                    end
                end
            end
            
            WAIT: begin
                // Wait for required delay
                if (delay_counter > 0) begin
                    delay_counter <= delay_counter - 1;
                end else begin
                    state <= NEXT;
                end
            end
            
            NEXT: begin
                if (step < 55) begin
                    // Normal initialization sequence
                    step <= step + 1;
                    pixel_byte <= 0;
                end else begin
                    // Pixel data phase - stay at step 55 and toggle pixel_byte
                    if (!init_done) begin
                        init_done <= 1;
                    end
                    step <= 55;
                    pixel_byte <= ~pixel_byte;  // Toggle between high and low byte
                end
                state <= LOAD;
            end
            
            default: state <= RESET_LOW;
        endcase
    end
    
    // LED indicators
    assign LED[0] = spi_busy;
    assign LED[1] = TFT_DC;

endmodule
