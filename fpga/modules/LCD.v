`default_nettype none

// ============================================================================
// LCD Module - ILI9341 TFT Display Controller
// ============================================================================
// Similar to UartTX: has load, busy, and internal state machine
// Handles initialization automatically, then accepts commands/data
// ============================================================================
module LCD (
    input wire CLK_100MHz,
    input wire load,            // Pulse to send data
    input wire [7:0] data_in,   // Data to send
    input wire is_cmd,          // 1=command, 0=data
    output wire TFT_CS,
    output reg TFT_RESET,
    output wire TFT_SDI,
    output wire TFT_SCK,
    output reg TFT_DC,
    output reg busy,            // 1=busy, 0=ready for next byte
    output reg ready            // 1=initialized and ready
);

    // ========================================================================
    // Timing Configuration (like UartTX BIT_PERIOD)
    // ========================================================================
    parameter CLK_FREQ = 100000000;  // 100 MHz
    parameter STATE_FREQ = 100;      // State machine frequency
    localparam STATE_PERIOD = CLK_FREQ / STATE_FREQ;
    
    reg [31:0] clk_cycles = 0;
    reg state_tick = 0;  // Pulses once per STATE_PERIOD

    // ========================================================================
    // State Machine Definitions
    // ========================================================================
    localparam IDLE              = 6'd0;
    localparam RESET_HIGH_1      = 6'd1;
    localparam RESET_LOW         = 6'd2;
    localparam RESET_HIGH_2      = 6'd3;
    localparam SOFT_RESET        = 6'd4;
    localparam DISPLAY_OFF       = 6'd5;
    localparam POWER_CTRL_B      = 6'd6;
    localparam POWER_CTRL_A      = 6'd7;
    localparam DRIVER_TIMING_A   = 6'd8;
    localparam DRIVER_TIMING_B   = 6'd9;
    localparam POWER_ON_SEQ      = 6'd10;
    localparam PUMP_RATIO        = 6'd11;
    localparam POWER_CTRL_1      = 6'd12;
    localparam POWER_CTRL_2      = 6'd13;
    localparam VCOM_CTRL_1       = 6'd14;
    localparam VCOM_CTRL_2       = 6'd15;
    localparam MEM_ACCESS        = 6'd16;
    localparam PIXEL_FORMAT      = 6'd17;
    localparam FRAME_RATE        = 6'd18;
    localparam DISPLAY_FUNC      = 6'd19;
    localparam GAMMA_DISABLE     = 6'd20;
    localparam GAMMA_SET         = 6'd21;
    localparam POSITIVE_GAMMA    = 6'd22;
    localparam NEGATIVE_GAMMA    = 6'd23;
    localparam SLEEP_OUT         = 6'd24;
    localparam DISPLAY_ON        = 6'd25;
    localparam INIT_COMPLETE     = 6'd26;
    localparam READY_STATE       = 6'd27;
    localparam USER_COMMAND      = 6'd28;

    // ========================================================================
    // State Machine Registers
    // ========================================================================
    reg [5:0] state = IDLE;
    reg [15:0] delay_counter = 0;
    reg [4:0] byte_index = 0;
    
    reg [7:0] user_data = 0;
    reg user_is_cmd = 0;
    reg spi_enable = 0;
    reg [7:0] spi_data = 0;
    wire spi_busy;
    wire spi_csx;

    // ========================================================================
    // Command/Data ROM - Sequential storage
    // ========================================================================
    reg [7:0] init_rom [0:99];
    
    initial begin
        // POWER_CTRL_B: 0xCB + 5 data bytes
        init_rom[0]  = 8'hCB; init_rom[1]  = 8'h39; init_rom[2]  = 8'h2C;
        init_rom[3]  = 8'h00; init_rom[4]  = 8'h34; init_rom[5]  = 8'h02;
        
        // POWER_CTRL_A: 0xCF + 3 data bytes
        init_rom[6]  = 8'hCF; init_rom[7]  = 8'h00; init_rom[8]  = 8'hC1; init_rom[9]  = 8'h30;
        
        // DRIVER_TIMING_A: 0xE8 + 3 data bytes
        init_rom[10] = 8'hE8; init_rom[11] = 8'h85; init_rom[12] = 8'h00; init_rom[13] = 8'h78;
        
        // DRIVER_TIMING_B: 0xEA + 2 data bytes
        init_rom[14] = 8'hEA; init_rom[15] = 8'h00; init_rom[16] = 8'h00;
        
        // POWER_ON_SEQ: 0xED + 4 data bytes
        init_rom[17] = 8'hED; init_rom[18] = 8'h64; init_rom[19] = 8'h03;
        init_rom[20] = 8'h12; init_rom[21] = 8'h81;
        
        // PUMP_RATIO: 0xF7 + 1 data byte
        init_rom[22] = 8'hF7; init_rom[23] = 8'h20;
        
        // POWER_CTRL_1: 0xC0 + 1 data byte
        init_rom[24] = 8'hC0; init_rom[25] = 8'h23;
        
        // POWER_CTRL_2: 0xC1 + 1 data byte
        init_rom[26] = 8'hC1; init_rom[27] = 8'h10;
        
        // VCOM_CTRL_1: 0xC5 + 2 data bytes
        init_rom[28] = 8'hC5; init_rom[29] = 8'h3E; init_rom[30] = 8'h28;
        
        // VCOM_CTRL_2: 0xC7 + 1 data byte
        init_rom[31] = 8'hC7; init_rom[32] = 8'h86;
        
        // MEM_ACCESS: 0x36 + 1 data byte
        init_rom[33] = 8'h36; init_rom[34] = 8'h48;
        
        // PIXEL_FORMAT: 0x3A + 1 data byte
        init_rom[35] = 8'h3A; init_rom[36] = 8'h55;
        
        // FRAME_RATE: 0xB1 + 2 data bytes
        init_rom[37] = 8'hB1; init_rom[38] = 8'h00; init_rom[39] = 8'h18;
        
        // DISPLAY_FUNC: 0xB6 + 3 data bytes
        init_rom[40] = 8'hB6; init_rom[41] = 8'h08; init_rom[42] = 8'h82; init_rom[43] = 8'h27;
        
        // GAMMA_DISABLE: 0xF2 + 1 data byte
        init_rom[44] = 8'hF2; init_rom[45] = 8'h00;
        
        // GAMMA_SET: 0x26 + 1 data byte
        init_rom[46] = 8'h26; init_rom[47] = 8'h01;
        
        // POSITIVE_GAMMA: 0xE0 + 15 data bytes
        init_rom[48] = 8'hE0; init_rom[49] = 8'h0F; init_rom[50] = 8'h31; init_rom[51] = 8'h2B;
        init_rom[52] = 8'h0C; init_rom[53] = 8'h0E; init_rom[54] = 8'h08; init_rom[55] = 8'h4E;
        init_rom[56] = 8'hF1; init_rom[57] = 8'h37; init_rom[58] = 8'h07; init_rom[59] = 8'h10;
        init_rom[60] = 8'h03; init_rom[61] = 8'h0E; init_rom[62] = 8'h09; init_rom[63] = 8'h00;
        
        // NEGATIVE_GAMMA: 0xE1 + 15 data bytes
        init_rom[64] = 8'hE1; init_rom[65] = 8'h00; init_rom[66] = 8'h0E; init_rom[67] = 8'h14;
        init_rom[68] = 8'h03; init_rom[69] = 8'h11; init_rom[70] = 8'h07; init_rom[71] = 8'h31;
        init_rom[72] = 8'hC1; init_rom[73] = 8'h48; init_rom[74] = 8'h08; init_rom[75] = 8'h0F;
        init_rom[76] = 8'h0C; init_rom[77] = 8'h31; init_rom[78] = 8'h36; init_rom[79] = 8'h0F;
    end
    
    // ========================================================================
    // State Configuration Table - ROM start address and byte count
    // ========================================================================
    reg [6:0] rom_start;
    reg [4:0] byte_count;
    reg [8:0] delay_ms;
    reg [5:0] next_state_val;
    
    always @(*) begin
        case (state)
            // Reset states - Hardware reset timing only, no SPI data sent
            RESET_HIGH_1:      begin rom_start = 0; byte_count = 0; delay_ms = 5;   next_state_val = RESET_LOW; end
            RESET_LOW:         begin rom_start = 0; byte_count = 0; delay_ms = 20;  next_state_val = RESET_HIGH_2; end
            RESET_HIGH_2:      begin rom_start = 0; byte_count = 0; delay_ms = 150; next_state_val = SOFT_RESET; end
            
            // Init commands with ROM data
            SOFT_RESET:        begin rom_start = 0; byte_count = 1; delay_ms = 150; next_state_val = DISPLAY_OFF; end     // Sends: 0x01
            DISPLAY_OFF:       begin rom_start = 0; byte_count = 1; delay_ms = 0;   next_state_val = POWER_CTRL_B; end    // Sends: 0x28
            POWER_CTRL_B:      begin rom_start = 0; byte_count = 6; delay_ms = 0;   next_state_val = POWER_CTRL_A; end    // Sends: 0xCB 0x39 0x2C 0x00 0x34 0x02
            POWER_CTRL_A:      begin rom_start = 6; byte_count = 4; delay_ms = 0;   next_state_val = DRIVER_TIMING_A; end // Sends: 0xCF 0x00 0xC1 0x30
            DRIVER_TIMING_A:   begin rom_start = 10; byte_count = 4; delay_ms = 0;  next_state_val = DRIVER_TIMING_B; end // Sends: 0xE8 0x85 0x00 0x78
            DRIVER_TIMING_B:   begin rom_start = 14; byte_count = 3; delay_ms = 0;  next_state_val = POWER_ON_SEQ; end    // Sends: 0xEA 0x00 0x00
            POWER_ON_SEQ:      begin rom_start = 17; byte_count = 5; delay_ms = 0;  next_state_val = PUMP_RATIO; end      // Sends: 0xED 0x64 0x03 0x12 0x81
            PUMP_RATIO:        begin rom_start = 22; byte_count = 2; delay_ms = 0;  next_state_val = POWER_CTRL_1; end    // Sends: 0xF7 0x20
            POWER_CTRL_1:      begin rom_start = 24; byte_count = 2; delay_ms = 0;  next_state_val = POWER_CTRL_2; end    // Sends: 0xC0 0x23
            POWER_CTRL_2:      begin rom_start = 26; byte_count = 2; delay_ms = 0;  next_state_val = VCOM_CTRL_1; end     // Sends: 0xC1 0x10
            VCOM_CTRL_1:       begin rom_start = 28; byte_count = 3; delay_ms = 0;  next_state_val = VCOM_CTRL_2; end     // Sends: 0xC5 0x3E 0x28
            VCOM_CTRL_2:       begin rom_start = 31; byte_count = 2; delay_ms = 0;  next_state_val = MEM_ACCESS; end      // Sends: 0xC7 0x86
            MEM_ACCESS:        begin rom_start = 33; byte_count = 2; delay_ms = 0;  next_state_val = PIXEL_FORMAT; end    // Sends: 0x36 0x48
            PIXEL_FORMAT:      begin rom_start = 35; byte_count = 2; delay_ms = 0;  next_state_val = FRAME_RATE; end      // Sends: 0x3A 0x55
            FRAME_RATE:        begin rom_start = 37; byte_count = 3; delay_ms = 0;  next_state_val = DISPLAY_FUNC; end    // Sends: 0xB1 0x00 0x18
            DISPLAY_FUNC:      begin rom_start = 40; byte_count = 4; delay_ms = 0;  next_state_val = GAMMA_DISABLE; end   // Sends: 0xB6 0x08 0x82 0x27
            GAMMA_DISABLE:     begin rom_start = 44; byte_count = 2; delay_ms = 0;  next_state_val = GAMMA_SET; end       // Sends: 0xF2 0x00
            GAMMA_SET:         begin rom_start = 46; byte_count = 2; delay_ms = 0;  next_state_val = POSITIVE_GAMMA; end  // Sends: 0x26 0x01
            POSITIVE_GAMMA:    begin rom_start = 48; byte_count = 16; delay_ms = 0; next_state_val = NEGATIVE_GAMMA; end  // Sends: 0xE0 0x0F 0x31 0x2B 0x0C 0x0E 0x08 0x4E 0xF1 0x37 0x07 0x10 0x03 0x0E 0x09 0x00
            NEGATIVE_GAMMA:    begin rom_start = 64; byte_count = 16; delay_ms = 0; next_state_val = SLEEP_OUT; end       // Sends: 0xE1 0x00 0x0E 0x14 0x03 0x11 0x07 0x31 0xC1 0x48 0x08 0x0F 0x0C 0x31 0x36 0x0F
            SLEEP_OUT:         begin rom_start = 0; byte_count = 1; delay_ms = 120; next_state_val = DISPLAY_ON; end      // Sends: 0x11
            DISPLAY_ON:        begin rom_start = 0; byte_count = 1; delay_ms = 100; next_state_val = INIT_COMPLETE; end   // Sends: 0x29
            
            default:           begin rom_start = 0; byte_count = 0; delay_ms = 0;   next_state_val = IDLE; end
        endcase
    end

    // ========================================================================
    // State Tick Generator
    // ========================================================================
    always @(posedge CLK_100MHz) begin
        if (clk_cycles < STATE_PERIOD - 1) begin
            clk_cycles <= clk_cycles + 1;
            state_tick <= 0;
        end else begin
            clk_cycles <= 0;
            state_tick <= 1;
        end
    end

    // ========================================================================
    // Main State Machine
    // ========================================================================
    always @(posedge CLK_100MHz) begin
        spi_enable <= 0;
        
        if (state_tick) begin
            case (state)
                IDLE: begin
                    TFT_RESET <= 1;
                    byte_index <= 0;
                    delay_counter <= 0;
                    ready <= 0;
                    busy <= 1;
                    state <= RESET_HIGH_1;
                end
                
                // Reset sequence states
                RESET_HIGH_1, RESET_LOW, RESET_HIGH_2: begin
                    TFT_RESET <= (state == RESET_HIGH_1 || state == RESET_HIGH_2) ? 1 : 0;
                    if (delay_counter >= delay_ms) begin
                        state <= next_state_val;
                        delay_counter <= 0;
                        byte_index <= 0;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end
                
                // Generic command/data sender for ROM-based states
                POWER_CTRL_B, POWER_CTRL_A, DRIVER_TIMING_A, DRIVER_TIMING_B,
                POWER_ON_SEQ, PUMP_RATIO, POWER_CTRL_1, POWER_CTRL_2,
                VCOM_CTRL_1, VCOM_CTRL_2, MEM_ACCESS, PIXEL_FORMAT,
                FRAME_RATE, DISPLAY_FUNC, GAMMA_DISABLE, GAMMA_SET,
                POSITIVE_GAMMA, NEGATIVE_GAMMA: begin
                    if (!spi_busy && !spi_enable) begin
                        if (byte_index < byte_count) begin
                            TFT_DC <= (byte_index == 0) ? 0 : 1;  // CMD=0, DATA=1
                            spi_data <= init_rom[rom_start + byte_index];
                            spi_enable <= 1;
                            byte_index <= byte_index + 1;
                        end else begin
                            state <= next_state_val;
                            byte_index <= 0;
                        end
                    end
                end
                
                // Special commands with delays
                SOFT_RESET: begin
                    if (!spi_busy && !spi_enable) begin
                        if (byte_index == 0) begin
                            TFT_DC <= 0;
                            spi_data <= 8'h01;
                            spi_enable <= 1;
                            byte_index <= 1;
                        end else if (delay_counter >= delay_ms) begin
                            state <= next_state_val;
                            delay_counter <= 0;
                            byte_index <= 0;
                        end else begin
                            delay_counter <= delay_counter + 1;
                        end
                    end
                end
                
                DISPLAY_OFF: begin
                    if (!spi_busy && !spi_enable) begin
                        TFT_DC <= 0;
                        spi_data <= 8'h28;
                        spi_enable <= 1;
                        state <= next_state_val;
                        byte_index <= 0;
                    end
                end
                
                SLEEP_OUT: begin
                    if (!spi_busy && !spi_enable) begin
                        if (byte_index == 0) begin
                            TFT_DC <= 0;
                            spi_data <= 8'h11;
                            spi_enable <= 1;
                            byte_index <= 1;
                        end else if (delay_counter >= delay_ms) begin
                            state <= next_state_val;
                            delay_counter <= 0;
                            byte_index <= 0;
                        end else begin
                            delay_counter <= delay_counter + 1;
                        end
                    end
                end
                
                DISPLAY_ON: begin
                    if (!spi_busy && !spi_enable) begin
                        if (byte_index == 0) begin
                            TFT_DC <= 0;
                            spi_data <= 8'h29;
                            spi_enable <= 1;
                            byte_index <= 1;
                        end else if (delay_counter >= delay_ms) begin
                            state <= next_state_val;
                            delay_counter <= 0;
                            byte_index <= 0;
                        end else begin
                            delay_counter <= delay_counter + 1;
                        end
                    end
                end
                
                INIT_COMPLETE: begin
                    ready <= 1;
                    busy <= 0;
                    state <= READY_STATE;
                end
                
                READY_STATE: begin
                    if (load && !busy) begin
                        user_data <= data_in;
                        user_is_cmd <= is_cmd;
                        busy <= 1;
                        byte_index <= 0;
                        state <= USER_COMMAND;
                    end
                end
                
                USER_COMMAND: begin
                    if (byte_index == 0) begin
                        // Send the byte
                        if (!spi_busy && !spi_enable) begin
                            TFT_DC <= user_is_cmd ? 0 : 1;
                            spi_data <= user_data;
                            spi_enable <= 1;
                            byte_index <= 1;
                        end
                    end else begin
                        // Wait for SPI to complete
                        if (!spi_busy) begin
                            busy <= 0;
                            state <= READY_STATE;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
    // ========================================================================
    // SPI Controller Instance
    // ========================================================================
    SPI spi (
        .CLK_100MHz(CLK_100MHz),
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
    assign TFT_CS = spi_csx;

endmodule
