/**
 * The module Hack is a TFT display test module
 * Uses the LCD module to fill the screen with blue color
 * It connects the external pins of our FPGA (Hack.pcf)
 * to test TFT/LCD functionality with the ILI9341 controller
 */
`default_nettype none

`include "../../modules/SPI.v"
`include "../../modules/LCD.v"

module Hack (
    // Clock
    input CLK_100MHz,

    // GPIO (Buttons and LEDs)
    input [1:0] BUT,
    output [1:0] LED,
    
    // LCD/TFT Display
    output TFT_CS,
    output TFT_RESET,
    output TFT_SDI,
    output TFT_SCK,
    output TFT_DC,
    output TFT_DBG
);

    // Parameters
    parameter CLK_FREQ = 100000000;      // 100 MHz
    parameter STATE_FREQ = 100;          // State machine frequency
    localparam STATE_PERIOD = CLK_FREQ / STATE_FREQ;
    
    // State machine states
    localparam IDLE               = 6'd0;
    localparam WAIT_LCD_READY     = 6'd1;
    localparam SET_COLUMN_ADDR    = 6'd2;
    localparam SET_PAGE_ADDR      = 6'd3;
    localparam START_MEMORY_WRITE = 6'd4;
    localparam STREAM_PIXELS      = 6'd5;
    localparam FILL_COMPLETE      = 6'd6;
    
    localparam TOTAL_PIXELS = 76800;
    localparam COLOR_BLUE_H = 8'h00;
    localparam COLOR_BLUE_L = 8'h1F;

    // Internal signals - State machine
    reg [5:0] state;
    reg [31:0] clk_cycles;
    reg state_tick;
    reg [17:0] pixel_counter;
    reg [4:0] byte_index;

    // Internal signals - LCD interface
    reg lcd_load;
    reg [7:0] lcd_data;
    reg lcd_is_cmd;
    wire lcd_busy;
    wire lcd_ready;

    // Module instantiations
    
    // LCD/TFT Display
    LCD lcd (
        .CLK_100MHz(CLK_100MHz),
        .LOAD(lcd_load),
        .DATA_IN(lcd_data),
        .IS_CMD(lcd_is_cmd),
        .TFT_CS(TFT_CS),
        .TFT_RESET(TFT_RESET),
        .TFT_SDI(TFT_SDI),
        .TFT_SCK(TFT_SCK),
        .TFT_DC(TFT_DC),
        .BUSY(lcd_busy),
        .READY(lcd_ready)
    );

    // Sequential logic
    
    initial begin
        state = IDLE;
        clk_cycles = 0;
        state_tick = 0;
        pixel_counter = 0;
        byte_index = 0;
        lcd_load = 0;
        lcd_data = 0;
        lcd_is_cmd = 0;
    end
    
    // State tick generator
    always @(posedge CLK_100MHz) begin
        if (clk_cycles < STATE_PERIOD - 1) begin
            clk_cycles <= clk_cycles + 1;
            state_tick <= 0;
        end else begin
            clk_cycles <= 0;
            state_tick <= 1;
        end
    end

    // Application state machine
    always @(posedge CLK_100MHz) begin
        // Clear load pulse only after LCD acknowledges by going busy
        if (lcd_busy) begin
            lcd_load <= 0;
        end
        
        if (state_tick) begin
            case (state)
                IDLE: begin
                    byte_index <= 0;
                    pixel_counter <= 0;
                    state <= WAIT_LCD_READY;
                end
                
                WAIT_LCD_READY: begin
                    if (lcd_ready && !lcd_busy) begin
                        state <= SET_COLUMN_ADDR;
                        byte_index <= 0;
                    end
                end
                
                SET_COLUMN_ADDR: begin
                    if (!lcd_busy && !lcd_load) begin
                        case (byte_index)
                            0: begin lcd_is_cmd <= 1; lcd_data <= 8'h2A; lcd_load <= 1; byte_index <= 1; end
                            1: begin lcd_is_cmd <= 0; lcd_data <= 8'h00; lcd_load <= 1; byte_index <= 2; end
                            2: begin lcd_is_cmd <= 0; lcd_data <= 8'h00; lcd_load <= 1; byte_index <= 3; end
                            3: begin lcd_is_cmd <= 0; lcd_data <= 8'h00; lcd_load <= 1; byte_index <= 4; end
                            4: begin lcd_is_cmd <= 0; lcd_data <= 8'hEF; lcd_load <= 1; byte_index <= 5; end
                            5: begin state <= SET_PAGE_ADDR; byte_index <= 0; end
                        endcase
                    end
                end
                
                SET_PAGE_ADDR: begin
                    if (!lcd_busy && !lcd_load) begin
                        case (byte_index)
                            0: begin lcd_is_cmd <= 1; lcd_data <= 8'h2B; lcd_load <= 1; byte_index <= 1; end
                            1: begin lcd_is_cmd <= 0; lcd_data <= 8'h00; lcd_load <= 1; byte_index <= 2; end
                            2: begin lcd_is_cmd <= 0; lcd_data <= 8'h00; lcd_load <= 1; byte_index <= 3; end
                            3: begin lcd_is_cmd <= 0; lcd_data <= 8'h01; lcd_load <= 1; byte_index <= 4; end
                            4: begin lcd_is_cmd <= 0; lcd_data <= 8'h3F; lcd_load <= 1; byte_index <= 5; end
                            5: begin state <= START_MEMORY_WRITE; byte_index <= 0; end
                        endcase
                    end
                end
                
                START_MEMORY_WRITE: begin
                    if (!lcd_busy && !lcd_load) begin
                        lcd_is_cmd <= 1;
                        lcd_data <= 8'h2C;
                        lcd_load <= 1;
                        state <= STREAM_PIXELS;
                        pixel_counter <= 0;
                    end
                end
                
                STREAM_PIXELS: begin
                    if (!lcd_busy && !lcd_load) begin
                        if (pixel_counter < TOTAL_PIXELS * 2) begin
                            lcd_is_cmd <= 0;
                            lcd_data <= pixel_counter[0] ? COLOR_BLUE_L : COLOR_BLUE_H;
                            lcd_load <= 1;
                            pixel_counter <= pixel_counter + 1;
                        end else begin
                            state <= FILL_COMPLETE;
                        end
                    end
                end
                
                FILL_COMPLETE: begin
                    // Stay here
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    // Combinational logic
    
    assign TFT_DBG = lcd_busy;
    assign LED[0] = lcd_ready;
    assign LED[1] = (state == STREAM_PIXELS) || (state == FILL_COMPLETE);

endmodule
