`default_nettype none

`include "../../modules/CLK_Divider.v"
`include "../../modules/SPI.v"

/**
 * ============================================================================
 * Main Module - ILI9341 TFT Display Initialization and Clear Screen
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
    output TFT_DC
);

    // ========================================================================
    // Clock Dividers - Create clocks for state machine and SPI
    // ========================================================================
    // State machine clock: 1kHz (for timing delays)
    wire clk_state;
    CLK_Divider clk_div_state (
        .clk_in(CLK_100MHz),
        .divisor(32'd49999),  // 100MHz / (2 * 50000) = 1kHz (1ms per tick)
        .clk_out(clk_state),
        .clk_count()
    );
    
    // SPI clock: 10MHz (for fast SPI communication with ILI9341)
    wire clk_spi;
    CLK_Divider clk_div_spi (
        .clk_in(CLK_100MHz),
        .divisor(32'd4),  // 100MHz / (2 * 5) = 10MHz -> SPI SCK = 5MHz
        .clk_out(clk_spi),
        .clk_count()
    );

    // ========================================================================
    // State Machine Definitions
    // ========================================================================
    localparam RESET_LOW         = 8'd0;
    localparam RESET_HIGH        = 8'd1;
    localparam SEND_SWRESET_CMD  = 8'd2;
    localparam WAIT_SWRESET      = 8'd3;
    localparam SEND_DISPOFF_CMD  = 8'd4;
    localparam WAIT_DISPOFF      = 8'd5;
    localparam SEND_PWCTRL1_CMD  = 8'd6;
    localparam SEND_PWCTRL1_DATA = 8'd7;
    localparam WAIT_PWCTRL1      = 8'd8;
    localparam SEND_PWCTRL2_CMD  = 8'd9;
    localparam SEND_PWCTRL2_DATA = 8'd10;
    localparam WAIT_PWCTRL2      = 8'd11;
    localparam SEND_VCCR1_CMD    = 8'd12;
    localparam SEND_VCCR1_DATA1  = 8'd13;
    localparam SEND_VCCR1_DATA2  = 8'd14;
    localparam WAIT_VCCR1        = 8'd15;
    localparam SEND_VCCR2_CMD    = 8'd16;
    localparam SEND_VCCR2_DATA   = 8'd17;
    localparam WAIT_VCCR2        = 8'd18;
    localparam SEND_MADCTL_CMD   = 8'd19;
    localparam SEND_MADCTL_DATA  = 8'd20;
    localparam WAIT_MADCTL       = 8'd21;
    localparam SEND_COLMOD_CMD   = 8'd22;
    localparam SEND_COLMOD_DATA  = 8'd23;
    localparam WAIT_COLMOD       = 8'd24;
    localparam SEND_FRMCRN1_CMD  = 8'd25;
    localparam SEND_FRMCRN1_DATA1= 8'd26;
    localparam SEND_FRMCRN1_DATA2= 8'd27;
    localparam WAIT_FRMCRN1      = 8'd28;
    localparam SEND_ETMOD_CMD    = 8'd29;
    localparam SEND_ETMOD_DATA   = 8'd30;
    localparam WAIT_ETMOD        = 8'd31;
    localparam SEND_SLPOUT_CMD   = 8'd32;
    localparam WAIT_SLPOUT       = 8'd33;
    localparam SEND_CASET_CMD    = 8'd34;
    localparam SEND_CASET_DATA1  = 8'd35;
    localparam SEND_CASET_DATA2  = 8'd36;
    localparam SEND_CASET_DATA3  = 8'd37;
    localparam SEND_CASET_DATA4  = 8'd38;
    localparam WAIT_CASET        = 8'd39;
    localparam SEND_PASET_CMD    = 8'd40;
    localparam SEND_PASET_DATA1  = 8'd41;
    localparam SEND_PASET_DATA2  = 8'd42;
    localparam SEND_PASET_DATA3  = 8'd43;
    localparam SEND_PASET_DATA4  = 8'd44;
    localparam WAIT_PASET        = 8'd45;
    localparam SEND_DISPON_CMD   = 8'd46;
    localparam WAIT_DISPON       = 8'd47;
    localparam SEND_RAMWR_CMD    = 8'd48;
    localparam WAIT_RAMWR        = 8'd49;
    localparam SEND_PIXEL_HIGH   = 8'd50;
    localparam SEND_PIXEL_LOW    = 8'd51;
    localparam WAIT_PIXEL        = 8'd52;
    localparam DONE              = 8'd53;

    // ========================================================================
    // Registers and Wires
    // ========================================================================
    reg [7:0] state = RESET_LOW;
    reg [15:0] delay_counter = 0;  // For timing delays (at 1kHz clock)
    reg [31:0] pixel_counter = 0;
    reg tft_reset_reg = 1;
    reg tft_dc_reg = 0;
    reg spi_enable = 0;
    reg [7:0] spi_data = 0;
    wire spi_busy;
    wire spi_csx;
    
    // Display parameters
    localparam TOTAL_PIXELS = 76800;  // 240 * 320
    localparam COLOR_HIGH = 8'hF8;    // Red color RGB565 high byte
    localparam COLOR_LOW  = 8'h00;    // Red color RGB565 low byte

    // ========================================================================
    // Main State Machine - Running on slow clock for timing control
    // ========================================================================
    always @(posedge clk_state) begin
        case (state)
            // ================================================================
            // HARDWARE RESET SEQUENCE
            // ================================================================
            RESET_LOW: begin
                tft_reset_reg <= 0;
                spi_enable <= 0;
                if (delay_counter >= 16'd10) begin  // 10ms at 1kHz
                    state <= RESET_HIGH;
                    delay_counter <= 0;
                end else begin
                    delay_counter <= delay_counter + 1;
                end
            end
            
            RESET_HIGH: begin
                tft_reset_reg <= 1;
                if (delay_counter >= 16'd200) begin  // 200ms at 1kHz
                    state <= SEND_SWRESET_CMD;
                    delay_counter <= 0;
                end else begin
                    delay_counter <= delay_counter + 1;
                end
            end

            // ================================================================
            // SOFTWARE RESET (0x01)
            // ================================================================
            SEND_SWRESET_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;  // Command mode
                    spi_data <= 8'h01;
                    spi_enable <= 1;
                    state <= WAIT_SWRESET;
                end
            end
            
            WAIT_SWRESET: begin
                if (spi_busy) begin
                    spi_enable <= 0;
                end
                if (!spi_busy && !spi_enable) begin
                    if (delay_counter >= 16'd50) begin  // 50ms delay
                        state <= SEND_DISPOFF_CMD;
                        delay_counter <= 0;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end
            end

            // ================================================================
            // DISPLAY OFF (0x28)
            // ================================================================
            SEND_DISPOFF_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'h28;
                    spi_enable <= 1;
                    state <= WAIT_DISPOFF;
                end
            end
            
            WAIT_DISPOFF: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_PWCTRL1_CMD;
                end
            end

            // ================================================================
            // POWER CONTROL 1 (0xC0, 0x23)
            // ================================================================
            SEND_PWCTRL1_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'hC0;
                    spi_enable <= 1;
                    state <= SEND_PWCTRL1_DATA;
                end
            end
            
            SEND_PWCTRL1_DATA: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;  // Data mode
                    spi_data <= 8'h23;
                    spi_enable <= 1;
                    state <= WAIT_PWCTRL1;
                end
            end
            
            WAIT_PWCTRL1: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_PWCTRL2_CMD;
                end
            end

            // ================================================================
            // POWER CONTROL 2 (0xC1, 0x10)
            // ================================================================
            SEND_PWCTRL2_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'hC1;
                    spi_enable <= 1;
                    state <= SEND_PWCTRL2_DATA;
                end
            end
            
            SEND_PWCTRL2_DATA: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h10;
                    spi_enable <= 1;
                    state <= WAIT_PWCTRL2;
                end
            end
            
            WAIT_PWCTRL2: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_VCCR1_CMD;
                end
            end

            // ================================================================
            // VCOM CONTROL 1 (0xC5, 0x2B, 0x2B)
            // ================================================================
            SEND_VCCR1_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'hC5;
                    spi_enable <= 1;
                    state <= SEND_VCCR1_DATA1;
                end
            end
            
            SEND_VCCR1_DATA1: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h2B;
                    spi_enable <= 1;
                    state <= SEND_VCCR1_DATA2;
                end
            end
            
            SEND_VCCR1_DATA2: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h2B;
                    spi_enable <= 1;
                    state <= WAIT_VCCR1;
                end
            end
            
            WAIT_VCCR1: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_VCCR2_CMD;
                end
            end

            // ================================================================
            // VCOM CONTROL 2 (0xC7, 0xC0)
            // ================================================================
            SEND_VCCR2_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'hC7;
                    spi_enable <= 1;
                    state <= SEND_VCCR2_DATA;
                end
            end
            
            SEND_VCCR2_DATA: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'hC0;
                    spi_enable <= 1;
                    state <= WAIT_VCCR2;
                end
            end
            
            WAIT_VCCR2: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_MADCTL_CMD;
                end
            end

            // ================================================================
            // MEMORY ACCESS CONTROL (0x36, 0x48)
            // ================================================================
            SEND_MADCTL_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'h36;
                    spi_enable <= 1;
                    state <= SEND_MADCTL_DATA;
                end
            end
            
            SEND_MADCTL_DATA: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h48;
                    spi_enable <= 1;
                    state <= WAIT_MADCTL;
                end
            end
            
            WAIT_MADCTL: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_COLMOD_CMD;
                end
            end

            // ================================================================
            // PIXEL FORMAT SET (0x3A, 0x55) - RGB565
            // ================================================================
            SEND_COLMOD_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'h3A;
                    spi_enable <= 1;
                    state <= SEND_COLMOD_DATA;
                end
            end
            
            SEND_COLMOD_DATA: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h55;
                    spi_enable <= 1;
                    state <= WAIT_COLMOD;
                end
            end
            
            WAIT_COLMOD: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_FRMCRN1_CMD;
                end
            end

            // ================================================================
            // FRAME RATE CONTROL (0xB1, 0x00, 0x1B)
            // ================================================================
            SEND_FRMCRN1_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'hB1;
                    spi_enable <= 1;
                    state <= SEND_FRMCRN1_DATA1;
                end
            end
            
            SEND_FRMCRN1_DATA1: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h00;
                    spi_enable <= 1;
                    state <= SEND_FRMCRN1_DATA2;
                end
            end
            
            SEND_FRMCRN1_DATA2: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h1B;
                    spi_enable <= 1;
                    state <= WAIT_FRMCRN1;
                end
            end
            
            WAIT_FRMCRN1: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_ETMOD_CMD;
                end
            end

            // ================================================================
            // ENTRY MODE SET (0xB7, 0x07)
            // ================================================================
            SEND_ETMOD_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'hB7;
                    spi_enable <= 1;
                    state <= SEND_ETMOD_DATA;
                end
            end
            
            SEND_ETMOD_DATA: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h07;
                    spi_enable <= 1;
                    state <= WAIT_ETMOD;
                end
            end
            
            WAIT_ETMOD: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_SLPOUT_CMD;
                end
            end

            // ================================================================
            // SLEEP OUT (0x11)
            // ================================================================
            SEND_SLPOUT_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'h11;
                    spi_enable <= 1;
                    state <= WAIT_SLPOUT;
                end
            end
            
            WAIT_SLPOUT: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    if (delay_counter >= 16'd150) begin  // 150ms delay
                        state <= SEND_CASET_CMD;
                        delay_counter <= 0;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end
            end

            // ================================================================
            // COLUMN ADDRESS SET (0x2A, 0x00, 0x00, 0x00, 0xEF) - 0 to 239
            // ================================================================
            SEND_CASET_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'h2A;
                    spi_enable <= 1;
                    state <= SEND_CASET_DATA1;
                end
            end
            
            SEND_CASET_DATA1: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h00;
                    spi_enable <= 1;
                    state <= SEND_CASET_DATA2;
                end
            end
            
            SEND_CASET_DATA2: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h00;
                    spi_enable <= 1;
                    state <= SEND_CASET_DATA3;
                end
            end
            
            SEND_CASET_DATA3: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h00;
                    spi_enable <= 1;
                    state <= SEND_CASET_DATA4;
                end
            end
            
            SEND_CASET_DATA4: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'hEF;  // 239
                    spi_enable <= 1;
                    state <= WAIT_CASET;
                end
            end
            
            WAIT_CASET: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_PASET_CMD;
                end
            end

            // ================================================================
            // PAGE ADDRESS SET (0x2B, 0x00, 0x00, 0x01, 0x3F) - 0 to 319
            // ================================================================
            SEND_PASET_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'h2B;
                    spi_enable <= 1;
                    state <= SEND_PASET_DATA1;
                end
            end
            
            SEND_PASET_DATA1: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h00;
                    spi_enable <= 1;
                    state <= SEND_PASET_DATA2;
                end
            end
            
            SEND_PASET_DATA2: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h00;
                    spi_enable <= 1;
                    state <= SEND_PASET_DATA3;
                end
            end
            
            SEND_PASET_DATA3: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h01;
                    spi_enable <= 1;
                    state <= SEND_PASET_DATA4;
                end
            end
            
            SEND_PASET_DATA4: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= 8'h3F;  // 319
                    spi_enable <= 1;
                    state <= WAIT_PASET;
                end
            end
            
            WAIT_PASET: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_DISPON_CMD;
                end
            end

            // ================================================================
            // DISPLAY ON (0x29)
            // ================================================================
            SEND_DISPON_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'h29;
                    spi_enable <= 1;
                    state <= WAIT_DISPON;
                end
            end
            
            WAIT_DISPON: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    if (delay_counter >= 16'd200) begin  // 200ms delay
                        state <= SEND_RAMWR_CMD;
                        delay_counter <= 0;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end
            end

            // ================================================================
            // CLEAR SCREEN - MEMORY WRITE (0x2C)
            // ================================================================
            SEND_RAMWR_CMD: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 0;
                    spi_data <= 8'h2C;
                    spi_enable <= 1;
                    state <= WAIT_RAMWR;
                    pixel_counter <= 0;
                end
            end
            
            WAIT_RAMWR: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    state <= SEND_PIXEL_HIGH;
                end
            end

            // ================================================================
            // SEND PIXEL DATA (76,800 pixels in RGB565 format)
            // ================================================================
            SEND_PIXEL_HIGH: begin
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;  // Data mode
                    spi_data <= COLOR_HIGH;
                    spi_enable <= 1;
                    state <= SEND_PIXEL_LOW;
                end
            end
            
            SEND_PIXEL_LOW: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    tft_dc_reg <= 1;
                    spi_data <= COLOR_LOW;
                    spi_enable <= 1;
                    state <= WAIT_PIXEL;
                end
            end
            
            WAIT_PIXEL: begin
                if (spi_busy) spi_enable <= 0;
                if (!spi_busy && !spi_enable) begin
                    pixel_counter <= pixel_counter + 1;
                    if (pixel_counter >= TOTAL_PIXELS - 1) begin
                        state <= DONE;
                    end else begin
                        state <= SEND_PIXEL_HIGH;
                    end
                end
            end

            // ================================================================
            // DONE - Initialization and Clear Screen Complete
            // ================================================================
            DONE: begin
                // Stay here - display should show red screen
                spi_enable <= 0;
            end

            default: begin
                state <= RESET_LOW;
            end
        endcase
    end
    
    // ========================================================================
    // SPI Controller Instance - Running on fast clock for SPI communication
    // ========================================================================
    SPI spi (
        .clk(clk_spi),   // Using 10MHz clock -> SPI SCK = 5MHz
        .load(spi_enable),
        .in(spi_data),
        .SCK(TFT_SCK),
        .SDI(TFT_SDI),
        .CSX(spi_csx),
        .busy(spi_busy)
    );
    
    // ========================================================================
    // Output Assignments
    // ========================================================================
    assign TFT_RESET = tft_reset_reg;
    assign TFT_DC = tft_dc_reg;
    assign TFT_CS = spi_csx;
    
    // LED indicators
    assign LED[0] = (state == DONE);           // LED0: Initialization complete
    assign LED[1] = spi_busy;                  // LED1: SPI transmission active

endmodule
