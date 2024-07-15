`define RAMFILE "../designs/Test_Computer/empty_ram.ram"
`define ROMFILE "../designs/Test_Computer/empty_rom.rom"
`include "include.v"

/**
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk,rst,rom)
 *
 */

`default_nettype none
`timescale 1ns / 1ps
module Hack(
    input wire CLK_100MHz,
    input [1:0] BUT,
    inout wire I2C_SDA,
    output wire I2C_SCL
    );


    // Internal signals for SDA line control
    wire sda_oe;    // Output enable for SDA
    wire sda_out;   // Output data for SDA
    wire sda_in;    // Input data from SDA
    // Assign the inout SDA line with tristate logic
    InOut sda_inout (
            .PIN(I2C_SDA),
            .dataW(sda_out),
            .dataR(sda_in),
            .dir(sda_oe)
        );

    // Create a reset signal that is active when either button is pressed
    wire rst_n;
    assign rst_n = BUT[0] | BUT[1];

    reg [21:0] delay_counter = 0;
    reg delay_done = 0;

    // LCD commands for initialization and data
    localparam CMD_LENGTH = 16;
    reg [7:0] init_cmds [0:CMD_LENGTH-1];
    initial begin
        // Initialize the LCD backlight
        init_cmds[0] = 8'h08 & 8'hF0;           // LCD_BACKLIGHT & 0xf0
        init_cmds[1] = (8'h08 & 8'h0F) << 4;    // (LCD_BACKLIGHT & 0x0f) << 4

        // Function set - 8-bit mode
        init_cmds[2] = 8'h30;                   // 0x03 << 4
        // Function set - 4-bit mode
        init_cmds[3] = 8'h20;                   // 0x02 << 4

        // Function set - 4-bit mode, 2-line
        init_cmds[4] = (8'h20 | 8'h08) & 8'hF0; // (LCD_FUNCTIONSET | LCD_2LINE) & 0xf0
        init_cmds[5] = ((8'h20 | 8'h08) & 8'h0F) << 4; // ((LCD_FUNCTIONSET | LCD_2LINE) & 0x0f) << 4

        // Display control - display on
        init_cmds[6] = (8'h08 | 8'h04) & 8'hF0; // (LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0xf0
        init_cmds[7] = ((8'h08 | 8'h04) & 8'h0F) << 4; // ((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0x0f) << 4

        // Clear display
        init_cmds[8] = 8'h01 & 8'hF0;           // LCD_CLEARDISPLAY & 0xf0
        init_cmds[9] = (8'h01 & 8'h0F) << 4;    // (LCD_CLEARDISPLAY & 0x0f) << 4

        // Entry mode set - increment cursor, no shift
        init_cmds[10] = (8'h04 | 8'h02) & 8'hF0; // (LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0xf0
        init_cmds[11] = ((8'h04 | 8'h02) & 8'h0F) << 4; // ((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0x0f) << 4

        // Return home
        init_cmds[12] = 8'h02 & 8'hF0;           // LCD_RETURNHOME & 0xf0
        init_cmds[13] = (8'h02 & 8'h0F) << 4;    // (LCD_RETURNHOME & 0x0f) << 4

        // Padding for array length consistency
        init_cmds[14] = 8'h00;                   // Placeholder for additional commands if needed
        init_cmds[15] = 8'h00;                   // Placeholder for additional commands if needed
    end

    localparam DATA_LENGTH = 26;
    reg [7:0] display_data [0:DATA_LENGTH-1];
    initial begin
        // "Hello World!" at position 2,0
        display_data[0] = (8'h80 | 2) & 8'hF0;  // (LCD_SETDDRAMADDR | addr) & 0xf0
        display_data[1] = ((8'h80 | 2) & 8'h0F) << 4;  // ((LCD_SETDDRAMADDR | addr) & 0x0f) << 4

        // For 'H'
        display_data[2] = ("H" & 8'hF0) | 8'h01;
        display_data[3] = (("H" << 4) & 8'h0F) | 8'h01;

        // For 'e'
        display_data[4] = ("e" & 8'hF0) | 8'h01;
        display_data[5] = (("e" << 4) & 8'h0F) | 8'h01;

        // For 'l'
        display_data[6] = ("l" & 8'hF0) | 8'h01;
        display_data[7] = (("l" << 4) & 8'h0F) | 8'h01;

        // For second 'l'
        display_data[8] = ("l" & 8'hF0) | 8'h01;
        display_data[9] = (("l" << 4) & 8'h0F) | 8'h01;

        // For 'o'
        display_data[10] = ("o" & 8'hF0) | 8'h01;
        display_data[11] = (("o" << 4) & 8'h0F) | 8'h01;

        // For space ' '
        display_data[12] = (" " & 8'hF0) | 8'h01;
        display_data[13] = ((" " << 4) & 8'h0F) | 8'h01;

        // For 'W'
        display_data[14] = ("W" & 8'hF0) | 8'h01;
        display_data[15] = (("W" << 4) & 8'h0F) | 8'h01;

        // For 'o'
        display_data[16] = ("o" & 8'hF0) | 8'h01;
        display_data[17] = (("o" << 4) & 8'h0F) | 8'h01;

        // For 'r'
        display_data[18] = ("r" & 8'hF0) | 8'h01;
        display_data[19] = (("r" << 4) & 8'h0F) | 8'h01;

        // For 'l'
        display_data[20] = ("l" & 8'hF0) | 8'h01;
        display_data[21] = (("l" << 4) & 8'h0F) | 8'h01;

        // For 'd'
        display_data[22] = ("d" & 8'hF0) | 8'h01;
        display_data[23] = (("d" << 4) & 8'h0F) | 8'h01;

        // For '!'
        display_data[24] = ("!" & 8'hF0) | 8'h01;
        display_data[25] = (("!" << 4) & 8'h0F) | 8'h01;
    end


    // LCD I2C address
    localparam LCD_ADDRESS = 7'b0100111;

    reg [7:0] data_in = 0;
    reg enable = 0;
    reg rw = 0;
    wire [7:0] data_out;
    wire ready;
    wire i2c_clk;


    // Instantiate I2C module
    I2C i2c_inst (
        .CLK_100MHz(CLK_100MHz),
        .rst(!rst_n), // Use active low reset signal
        .addr(LCD_ADDRESS),
        .data_in(data_in),
        .enable(enable),
        .rw(rw), // 1 for read, 0 for write
        .data_out(data_out),
        .ready(ready),
        .i2c_clk(i2c_clk),
        .i2c_sda_out(sda_out),  // Driven low by the I2C module when needed
        .i2c_sda_in(sda_in),    // Read from the I2C_SDA line
        .i2c_sda_oe(sda_oe),    // Controls whether the I2C module drives the line
        .I2C_SCL(I2C_SCL)
    );


    reg [10:0] state = 0;
    // State machine logic
    always @(posedge i2c_clk) begin
        if (!rst_n) begin
            // Reset all registers and state
            state <= 0;
            enable <= 0;
            rw <= 0;
            data_in <= 0;
            delay_counter <= 0;
            delay_done <= 0;
            
        end else begin
            case (state)
                0: begin
                    data_in <= init_cmds[0];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 1;
                end
                1: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 2;
                    end
                end
                2: begin
                    data_in <= (init_cmds[0] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 3;
                end
                3: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 4;
                    end
                end
                4: begin
                    data_in <= (init_cmds[0] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 5;
                end
                5: state <= 6;
                6: state <= 7;
                7: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 8;
                    end
                end
                8: begin
                    data_in <= init_cmds[1];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 9;
                end
                9: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 10;
                    end
                end
                10: begin
                    data_in <= (init_cmds[1] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 11;
                end
                11: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 12;
                    end
                end
                12: begin
                    data_in <= (init_cmds[1] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 13;
                end
                13: state <= 14;
                14: state <= 15;
                15: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 16;
                    end
                end
                16: begin
                    data_in <= init_cmds[2];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 17;
                end
                17: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 18;
                    end
                end
                18: begin
                    data_in <= (init_cmds[2] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 19;
                end
                19: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 20;
                    end
                end
                20: begin
                    data_in <= (init_cmds[2] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 21;
                end
                21: state <= 22;
                22: state <= 23;
                23: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 24;
                    end
                end
                24: begin
                    data_in <= init_cmds[3];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 25;
                end
                25: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 26;
                    end
                end
                26: begin
                    data_in <= (init_cmds[3] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 27;
                end
                27: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 28;
                    end
                end
                28: begin
                    data_in <= (init_cmds[3] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 29;
                end
                29: state <= 30;
                30: state <= 31;
                31: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 32;
                    end
                end
                32: begin
                    data_in <= init_cmds[4];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 33;
                end
                33: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 34;
                    end
                end
                34: begin
                    data_in <= (init_cmds[4] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 35;
                end
                35: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 36;
                    end
                end
                36: begin
                    data_in <= (init_cmds[4] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 37;
                end
                37: state <= 38;
                38: state <= 39;
                39: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 40;
                    end
                end
                40: begin
                    data_in <= init_cmds[5];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 41;
                end
                41: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 42;
                    end
                end
                42: begin
                    data_in <= (init_cmds[5] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 43;
                end
                43: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 44;
                    end
                end
                44: begin
                    data_in <= (init_cmds[5] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 45;
                end
                45: state <= 46;
                46: state <= 47;
                47: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 48;
                    end
                end
                48: begin
                    data_in <= init_cmds[6];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 49;
                end
                49: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 50;
                    end
                end
                50: begin
                    data_in <= (init_cmds[6] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 51;
                end
                51: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 52;
                    end
                end
                52: begin
                    data_in <= (init_cmds[6] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 53;
                end
                53: state <= 54;
                54: state <= 55;
                55: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 56;
                    end
                end
                56: begin
                    data_in <= init_cmds[7];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 57;
                end
                57: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 58;
                    end
                end
                58: begin
                    data_in <= (init_cmds[7] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 59;
                end
                59: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 60;
                    end
                end
                60: begin
                    data_in <= (init_cmds[7] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 61;
                end
                61: state <= 62;
                62: state <= 63;
                63: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 64;
                    end
                end
                64: begin
                    data_in <= init_cmds[8];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 65;
                end
                65: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 66;
                    end
                end
                66: begin
                    data_in <= (init_cmds[8] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 67;
                end
                67: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 68;
                    end
                end
                68: begin
                    data_in <= (init_cmds[8] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 69;
                end
                69: state <= 70;
                70: state <= 71;
                71: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 72;
                    end
                end
                72: begin
                    data_in <= init_cmds[9];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 73;
                end
                73: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 74;
                    end
                end
                74: begin
                    data_in <= (init_cmds[9] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 75;
                end
                75: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 76;
                    end
                end
                76: begin
                    data_in <= (init_cmds[9] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 77;
                end


                77: begin
                    // Initialize the delay
                    delay_counter <= 0;
                    delay_done <= 0;
                    state <= 78;
                end
                
                78: begin
                    if (delay_counter < 100000) begin
                        delay_counter <= delay_counter + 1;
                    end else begin
                        delay_done <= 1;
                        state <= 79;
                    end
                end

                
                79: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 80;
                    end
                end
                80: begin
                    data_in <= init_cmds[10];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 81;
                end
                81: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 82;
                    end
                end
                82: begin
                    data_in <= (init_cmds[10] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 83;
                end
                83: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 84;
                    end
                end
                84: begin
                    data_in <= (init_cmds[10] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 85;
                end
                85: state <= 86;
                86: state <= 87;
                87: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 88;
                    end
                end
                88: begin
                    data_in <= init_cmds[11];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 89;
                end
                89: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 90;
                    end
                end
                90: begin
                    data_in <= (init_cmds[11] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 91;
                end
                91: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 92;
                    end
                end
                92: begin
                    data_in <= (init_cmds[11] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 93;
                end
                93: state <= 94;
                94: state <= 95;
                95: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 96;
                    end
                end
                96: begin
                    data_in <= init_cmds[12];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 97;
                end
                97: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 98;
                    end
                end
                98: begin
                    data_in <= (init_cmds[12] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 99;
                end
                99: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 100;
                    end
                end
                100: begin
                    data_in <= (init_cmds[12] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 101;
                end
                101: state <= 102;
                102: state <= 103;
                103: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 104;
                    end
                end
                104: begin
                    data_in <= init_cmds[13];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 105;
                end
                105: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 106;
                    end
                end
                106: begin
                    data_in <= (init_cmds[13] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 107;
                end
                107: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 108;
                    end
                end
                108: begin
                    data_in <= (init_cmds[13] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 109;
                end
                109: state <= 110;
                110: state <= 111;
                111: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 112;
                    end
                end
                112: begin
                    data_in <= init_cmds[14];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 113;
                end
                113: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 114;
                    end
                end
                114: begin
                    data_in <= (init_cmds[14] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 115;
                end
                115: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 116;
                    end
                end
                116: begin
                    data_in <= (init_cmds[14] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 117;
                end
                117: state <= 118;
                118: state <= 119;
                119: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 120;
                    end
                end
                120: begin
                    data_in <= init_cmds[15];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 121;
                end
                121: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 122;
                    end
                end
                122: begin
                    data_in <= (init_cmds[15] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 123;
                end
                123: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 124;
                    end
                end
                124: begin
                    data_in <= (init_cmds[15] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 125;
                end
                125: state <= 126;
                126: state <= 127;
                127: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 128;
                    end
                end
                128: begin
                    data_in <= display_data[0];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 129;
                end
                129: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 130;
                    end
                end
                130: begin
                    data_in <= (display_data[0] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 131;
                end
                131: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 132;
                    end
                end
                132: begin
                    data_in <= (display_data[0] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 133;
                end
                133: state <= 134;
                134: state <= 135;
                135: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 136;
                    end
                end
                136: begin
                    data_in <= display_data[1];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 137;
                end
                137: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 138;
                    end
                end
                138: begin
                    data_in <= (display_data[1] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 139;
                end
                139: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 140;
                    end
                end
                140: begin
                    data_in <= (display_data[1] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 141;
                end
                141: state <= 142;
                142: state <= 143;
                143: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 144;
                    end
                end
                144: begin
                    data_in <= display_data[2];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 145;
                end
                145: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 146;
                    end
                end
                146: begin
                    data_in <= (display_data[2] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 147;
                end
                147: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 148;
                    end
                end
                148: begin
                    data_in <= (display_data[2] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 149;
                end
                149: state <= 150;
                150: state <= 151;
                151: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 152;
                    end
                end
                152: begin
                    data_in <= display_data[3];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 153;
                end
                153: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 154;
                    end
                end
                154: begin
                    data_in <= (display_data[3] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 155;
                end
                155: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 156;
                    end
                end
                156: begin
                    data_in <= (display_data[3] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 157;
                end
                157: state <= 158;
                158: state <= 159;
                159: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 160;
                    end
                end
                160: begin
                    data_in <= display_data[4];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 161;
                end
                161: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 162;
                    end
                end
                162: begin
                    data_in <= (display_data[4] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 163;
                end
                163: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 164;
                    end
                end
                164: begin
                    data_in <= (display_data[4] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 165;
                end
                165: state <= 166;
                166: state <= 167;
                167: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 168;
                    end
                end
                168: begin
                    data_in <= display_data[5];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 169;
                end
                169: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 170;
                    end
                end
                170: begin
                    data_in <= (display_data[5] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 171;
                end
                171: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 172;
                    end
                end
                172: begin
                    data_in <= (display_data[5] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 173;
                end
                173: state <= 174;
                174: state <= 175;
                175: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 176;
                    end
                end
                176: begin
                    data_in <= display_data[6];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 177;
                end
                177: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 178;
                    end
                end
                178: begin
                    data_in <= (display_data[6] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 179;
                end
                179: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 180;
                    end
                end
                180: begin
                    data_in <= (display_data[6] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 181;
                end
                181: state <= 182;
                182: state <= 183;
                183: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 184;
                    end
                end
                184: begin
                    data_in <= display_data[7];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 185;
                end
                185: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 186;
                    end
                end
                186: begin
                    data_in <= (display_data[7] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 187;
                end
                187: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 188;
                    end
                end
                188: begin
                    data_in <= (display_data[7] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 189;
                end
                189: state <= 190;
                190: state <= 191;
                191: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 192;
                    end
                end
                192: begin
                    data_in <= display_data[8];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 193;
                end
                193: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 194;
                    end
                end
                194: begin
                    data_in <= (display_data[8] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 195;
                end
                195: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 196;
                    end
                end
                196: begin
                    data_in <= (display_data[8] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 197;
                end
                197: state <= 198;
                198: state <= 199;
                199: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 200;
                    end
                end
                200: begin
                    data_in <= display_data[9];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 201;
                end
                201: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 202;
                    end
                end
                202: begin
                    data_in <= (display_data[9] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 203;
                end
                203: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 204;
                    end
                end
                204: begin
                    data_in <= (display_data[9] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 205;
                end
                205: state <= 206;
                206: state <= 207;
                207: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 208;
                    end
                end
                208: begin
                    data_in <= display_data[10];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 209;
                end
                209: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 210;
                    end
                end
                210: begin
                    data_in <= (display_data[10] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 211;
                end
                211: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 212;
                    end
                end
                212: begin
                    data_in <= (display_data[10] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 213;
                end
                213: state <= 214;
                214: state <= 215;
                215: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 216;
                    end
                end
                216: begin
                    data_in <= display_data[11];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 217;
                end
                217: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 218;
                    end
                end
                218: begin
                    data_in <= (display_data[11] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 219;
                end
                219: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 220;
                    end
                end
                220: begin
                    data_in <= (display_data[11] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 221;
                end
                221: state <= 222;
                222: state <= 223;
                223: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 224;
                    end
                end
                224: begin
                    data_in <= display_data[12];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 225;
                end
                225: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 226;
                    end
                end
                226: begin
                    data_in <= (display_data[12] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 227;
                end
                227: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 228;
                    end
                end
                228: begin
                    data_in <= (display_data[12] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 229;
                end
                229: state <= 230;
                230: state <= 231;
                231: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 232;
                    end
                end
                232: begin
                    data_in <= display_data[13];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 233;
                end
                233: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 234;
                    end
                end
                234: begin
                    data_in <= (display_data[13] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 235;
                end
                235: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 236;
                    end
                end
                236: begin
                    data_in <= (display_data[13] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 237;
                end
                237: state <= 238;
                238: state <= 239;
                239: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 240;
                    end
                end
                240: begin
                    data_in <= display_data[14];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 241;
                end
                241: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 242;
                    end
                end
                242: begin
                    data_in <= (display_data[14] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 243;
                end
                243: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 244;
                    end
                end
                244: begin
                    data_in <= (display_data[14] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 245;
                end
                245: state <= 246;
                246: state <= 247;
                247: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 248;
                    end
                end
                248: begin
                    data_in <= display_data[15];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 249;
                end
                249: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 250;
                    end
                end
                250: begin
                    data_in <= (display_data[15] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 251;
                end
                251: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 252;
                    end
                end
                252: begin
                    data_in <= (display_data[15] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 253;
                end
                253: state <= 254;
                254: state <= 255;
                255: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 256;
                    end
                end
                256: begin
                    data_in <= display_data[16];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 257;
                end
                257: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 258;
                    end
                end
                258: begin
                    data_in <= (display_data[16] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 259;
                end
                259: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 260;
                    end
                end
                260: begin
                    data_in <= (display_data[16] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 261;
                end
                261: state <= 262;
                262: state <= 263;
                263: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 264;
                    end
                end
                264: begin
                    data_in <= display_data[17];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 265;
                end
                265: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 266;
                    end
                end
                266: begin
                    data_in <= (display_data[17] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 267;
                end
                267: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 268;
                    end
                end
                268: begin
                    data_in <= (display_data[17] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 269;
                end
                269: state <= 270;
                270: state <= 271;
                271: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 272;
                    end
                end
                272: begin
                    data_in <= display_data[18];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 273;
                end
                273: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 274;
                    end
                end
                274: begin
                    data_in <= (display_data[18] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 275;
                end
                275: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 276;
                    end
                end
                276: begin
                    data_in <= (display_data[18] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 277;
                end
                277: state <= 278;
                278: state <= 279;
                279: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 280;
                    end
                end
                280: begin
                    data_in <= display_data[19];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 281;
                end
                281: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 282;
                    end
                end
                282: begin
                    data_in <= (display_data[19] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 283;
                end
                283: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 284;
                    end
                end
                284: begin
                    data_in <= (display_data[19] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 285;
                end
                285: state <= 286;
                286: state <= 287;
                287: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 288;
                    end
                end
                288: begin
                    data_in <= display_data[20];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 289;
                end
                289: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 290;
                    end
                end
                290: begin
                    data_in <= (display_data[20] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 291;
                end
                291: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 292;
                    end
                end
                292: begin
                    data_in <= (display_data[20] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 293;
                end
                293: state <= 294;
                294: state <= 295;
                295: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 296;
                    end
                end
                296: begin
                    data_in <= display_data[21];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 297;
                end
                297: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 298;
                    end
                end
                298: begin
                    data_in <= (display_data[21] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 299;
                end
                299: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 300;
                    end
                end
                300: begin
                    data_in <= (display_data[21] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 301;
                end
                301: state <= 302;
                302: state <= 303;
                303: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 304;
                    end
                end
                304: begin
                    data_in <= display_data[22];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 305;
                end
                305: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 306;
                    end
                end
                306: begin
                    data_in <= (display_data[22] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 307;
                end
                307: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 308;
                    end
                end
                308: begin
                    data_in <= (display_data[22] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 309;
                end
                309: state <= 310;
                310: state <= 311;
                311: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 312;
                    end
                end
                312: begin
                    data_in <= display_data[23];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 313;
                end
                313: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 314;
                    end
                end
                314: begin
                    data_in <= (display_data[23] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 315;
                end
                315: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 316;
                    end
                end
                316: begin
                    data_in <= (display_data[23] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 317;
                end
                317: state <= 318;
                318: state <= 319;
                319: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 320;
                    end
                end
                320: begin
                    data_in <= display_data[24];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 321;
                end
                321: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 322;
                    end
                end
                322: begin
                    data_in <= (display_data[24] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 323;
                end
                323: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 324;
                    end
                end
                324: begin
                    data_in <= (display_data[24] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 325;
                end
                325: state <= 326;
                326: state <= 327;
                327: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 328;
                    end
                end
                328: begin
                    data_in <= display_data[25];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 329;
                end
                329: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 330;
                    end
                end
                330: begin
                    data_in <= (display_data[25] | 8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 331;
                end
                331: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 332;
                    end
                end
                332: begin
                    data_in <= (display_data[25] & ~8'd4) | 8'h80;
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    

                    state <= 333;
                end
                333: state <= 334;
                334: state <= 335;
                335: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        

                        state <= 336;
                    end
                end
                336: state <= 336; // Final state or a loop to restart display if needed

                default: begin
                    state <= 0; // Default case to reset state machine
                end
            endcase
        end
    end


endmodule


