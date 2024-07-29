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

    // LCD I2C address
    localparam LCD_CLEARDISPLAY = 8'h01;
    localparam LCD_RETURNHOME = 8'h02;
    localparam LCD_ENTRYMODESET = 8'h04;
    localparam LCD_DISPLAYCONTROL = 8'h08;
    localparam LCD_FUNCTIONSET = 8'h20;
    localparam LCD_SETDDRAMADDR = 8'h80;
    localparam LCD_ENTRYLEFT = 8'h02;
    localparam LCD_DISPLAYON = 8'h04;
    localparam LCD_2LINE = 8'h08;
    localparam LCD_BACKLIGHT = 8'h08;
    localparam En = 8'h04; // Enable bit
    localparam Rs = 8'h01; // Register select bit
    localparam LCD_ADDRESS = 7'h27; // Define LCD address

    // Create a reset signal that is active when either button is pressed
    wire rst_n;
    assign rst_n = BUT[0] | BUT[1];

    reg [21:0] delay_counter = 0;
    reg delay_done = 0;

    // LCD commands for initialization and data
    localparam CMD_LENGTH = 42;
    reg [7:0] init_cmds [0:CMD_LENGTH-1];
    initial begin
        // Initialize the LCD backlight
        init_cmds[0] = ((LCD_BACKLIGHT & 8'hF0) | LCD_BACKLIGHT);                   // LCD_BACKLIGHT & 0xf0
        init_cmds[1] = ((LCD_BACKLIGHT & 8'hF0) | En) | LCD_BACKLIGHT;            // LCD_BACKLIGHT & 0xf0
        init_cmds[2] = ((LCD_BACKLIGHT & 8'hF0) & ~En) | LCD_BACKLIGHT;           // LCD_BACKLIGHT & 0xf0
        init_cmds[3] = ((LCD_BACKLIGHT & 8'h0F) << 4) | LCD_BACKLIGHT;                      // (LCD_BACKLIGHT & 0x0f) << 4
        init_cmds[4] = (((LCD_BACKLIGHT & 8'h0F) << 4) | En) | LCD_BACKLIGHT;     // (LCD_BACKLIGHT & 0x0f) << 4
        init_cmds[5] = (((LCD_BACKLIGHT & 8'h0F) << 4) & ~En) | LCD_BACKLIGHT;    // (LCD_BACKLIGHT & 0x0f) << 4

        // Function set - 8-bit mode
        init_cmds[6] = 8'h30 | LCD_BACKLIGHT;                                       // 0x03 << 4
        init_cmds[7] = (8'h30 | En) | LCD_BACKLIGHT;                      // 0x03 << 4
        init_cmds[8] = (8'h30 & ~En) | LCD_BACKLIGHT;                     // 0x03 << 4
        // Function set - 4-bit mode
        init_cmds[9] = 8'h20 | LCD_BACKLIGHT;                                       // 0x02 << 4
        init_cmds[10] = (8'h20 | En) | LCD_BACKLIGHT;                     // 0x02 << 4
        init_cmds[11] = (8'h20 & ~En) | LCD_BACKLIGHT;                    // 0x02 << 4

        // Function set - 4-bit mode, 2-line
        init_cmds[12] = ((LCD_FUNCTIONSET | LCD_2LINE) & 8'hF0)| LCD_BACKLIGHT;                          // (LCD_FUNCTIONSET | LCD_2LINE) & 0xf0
        init_cmds[13] = (((LCD_FUNCTIONSET | LCD_2LINE) & 8'hF0) | En) | LCD_BACKLIGHT;         // (LCD_FUNCTIONSET | LCD_2LINE) & 0xf0
        init_cmds[14] = (((LCD_FUNCTIONSET | LCD_2LINE) & 8'hF0) & ~En) | LCD_BACKLIGHT;        // (LCD_FUNCTIONSET | LCD_2LINE) & 0xf0
        init_cmds[15] = (((LCD_FUNCTIONSET | LCD_2LINE) & 8'h0F) << 4)| LCD_BACKLIGHT;                   // ((LCD_FUNCTIONSET | LCD_2LINE) & 0x0f) << 4
        init_cmds[16] = ((((LCD_FUNCTIONSET | LCD_2LINE) & 8'h0F) << 4) | En) | LCD_BACKLIGHT;  // ((LCD_FUNCTIONSET | LCD_2LINE) & 0x0f) << 4
        init_cmds[17] = ((((LCD_FUNCTIONSET | LCD_2LINE) & 8'h0F) << 4) & ~En) | LCD_BACKLIGHT; // ((LCD_FUNCTIONSET | LCD_2LINE) & 0x0f) << 4

        // Display control - display on
        init_cmds[18] = ((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 8'hF0)| LCD_BACKLIGHT;                          // (LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0xf0
        init_cmds[19] = (((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 8'hF0) | En) | LCD_BACKLIGHT;         // (LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0xf0
        init_cmds[20] = (((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 8'hF0) & ~En) | LCD_BACKLIGHT;        // (LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0xf0
        init_cmds[21] = (((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 8'h0F) << 4)| LCD_BACKLIGHT;                   // ((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0x0f) << 4
        init_cmds[22] = ((((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 8'h0F) << 4) | En) | LCD_BACKLIGHT;  // ((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0x0f) << 4
        init_cmds[23] = ((((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 8'h0F) << 4) & ~En) | LCD_BACKLIGHT; // ((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0x0f) << 4

        // Clear display
        init_cmds[24] = (LCD_CLEARDISPLAY & 8'hF0)| LCD_BACKLIGHT;                            // LCD_CLEARDISPLAY & 0xf0
        init_cmds[25] = ((LCD_CLEARDISPLAY & 8'hF0) | En) | LCD_BACKLIGHT;           // LCD_CLEARDISPLAY & 0xf0
        init_cmds[26] = ((LCD_CLEARDISPLAY & 8'hF0) & ~En) | LCD_BACKLIGHT;          // LCD_CLEARDISPLAY & 0xf0
        init_cmds[27] = ((LCD_CLEARDISPLAY & 8'h0F) << 4)| LCD_BACKLIGHT;                     // (LCD_CLEARDISPLAY & 0x0f) << 4
        init_cmds[28] = (((LCD_CLEARDISPLAY & 8'h0F) << 4) | En) | LCD_BACKLIGHT;    // (LCD_CLEARDISPLAY & 0x0f) << 4
        init_cmds[29] = (((LCD_CLEARDISPLAY & 8'h0F) << 4) & ~En) | LCD_BACKLIGHT;   // (LCD_CLEARDISPLAY & 0x0f) << 4

        // Entry mode set - increment cursor, no shift
        init_cmds[30] = ((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 8'hF0)| LCD_BACKLIGHT;                          // (LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0xf0
        init_cmds[31] = (((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 8'hF0) | En) | LCD_BACKLIGHT;         // (LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0xf0
        init_cmds[32] = (((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 8'hF0) & ~En) | LCD_BACKLIGHT;        // (LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0xf0
        init_cmds[33] = (((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 8'h0F) << 4)| LCD_BACKLIGHT;                   // ((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0x0f) << 4
        init_cmds[34] = ((((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 8'h0F) << 4) | En) | LCD_BACKLIGHT;  // ((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0x0f) << 4
        init_cmds[35] = ((((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 8'h0F) << 4) & ~En) | LCD_BACKLIGHT; // ((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0x0f) << 4

        // Return home
        init_cmds[36] = (LCD_RETURNHOME & 8'hF0)| LCD_BACKLIGHT;                            // LCD_RETURNHOME & 0xf0
        init_cmds[37] = ((LCD_RETURNHOME & 8'hF0) | En) | LCD_BACKLIGHT;           // LCD_RETURNHOME & 0xf0
        init_cmds[38] = ((LCD_RETURNHOME & 8'hF0) & ~En) | LCD_BACKLIGHT;          // LCD_RETURNHOME & 0xf0
        init_cmds[39] = ((LCD_RETURNHOME & 8'h0F) << 4) | LCD_BACKLIGHT;                     // (LCD_RETURNHOME & 0x0f) << 4
        init_cmds[40] = (((LCD_RETURNHOME & 8'h0F) << 4) | En) | LCD_BACKLIGHT;    // (LCD_RETURNHOME & 0x0f) << 4
        init_cmds[41] = (((LCD_RETURNHOME & 8'h0F) << 4) & ~En) | LCD_BACKLIGHT;   // (LCD_RETURNHOME & 0x0f) << 4
    end

    localparam DATA_LENGTH = 78;
    reg [7:0] display_data [0:DATA_LENGTH-1];
    initial begin
        // "Hello World!" at position 2,0
        display_data[0] = ((LCD_SETDDRAMADDR | 8'h02) & 8'hF0) | LCD_BACKLIGHT;                            // (LCD_SETDDRAMADDR | addr) & 0xf0
        display_data[1] = (((LCD_SETDDRAMADDR | 8'h02) & 8'hF0) | En) | LCD_BACKLIGHT;           // (LCD_SETDDRAMADDR | addr) & 0xf0
        display_data[2] = (((LCD_SETDDRAMADDR | 8'h02) & 8'hF0) & ~En) | LCD_BACKLIGHT;          // (LCD_SETDDRAMADDR | addr) & 0xf0
        display_data[3] = (((LCD_SETDDRAMADDR | 8'h02) & 8'h0F) << 4) | LCD_BACKLIGHT;                     // ((LCD_SETDDRAMADDR | addr) & 0x0f) << 4
        display_data[4] = ((((LCD_SETDDRAMADDR | 8'h02) & 8'h0F) << 4) | En) | LCD_BACKLIGHT;    // ((LCD_SETDDRAMADDR | addr) & 0x0f) << 4
        display_data[5] = ((((LCD_SETDDRAMADDR | 8'h02) & 8'h0F) << 4) & ~En) | LCD_BACKLIGHT;   // ((LCD_SETDDRAMADDR | addr) & 0x0f) << 4

        // For 'H'
        display_data[6] = (("H" & 8'hF0) | 8'h01);
        display_data[7] = ((("H" & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[8] = ((("H" & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[9] = ((("H" << 4) & 8'h0F) | 8'h01);
        display_data[10] = (((("H" << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[11] = (((("H" << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;

        // For 'e'
        display_data[12] = (("e" & 8'hF0) | 8'h01);
        display_data[13] = ((("e" & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[14] = ((("e" & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[15] = ((("e" << 4) & 8'h0F) | 8'h01);
        display_data[16] = (((("e" << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[17] = (((("e" << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;

        // For 'l'
        display_data[18] = (("l" & 8'hF0) | 8'h01);
        display_data[19] = ((("l" & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[20] = ((("l" & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[21] = ((("l" << 4) & 8'h0F) | 8'h01);
        display_data[22] = (((("l" << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[23] = (((("l" << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;

        // For second 'l'
        display_data[24] = display_data[18];
        display_data[25] = display_data[19];
        display_data[26] = display_data[20];
        display_data[27] = display_data[21];
        display_data[28] = display_data[22];
        display_data[29] = display_data[23];

        // For 'o'
        display_data[30] = (("o" & 8'hF0) | 8'h01);
        display_data[31] = ((("o" & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[32] = ((("o" & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[33] = ((("o" << 4) & 8'h0F) | 8'h01);
        display_data[34] = (((("o" << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[35] = (((("o" << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;

        // For ' '
        display_data[36] = ((" " & 8'hF0) | 8'h01);
        display_data[37] = (((" " & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[38] = (((" " & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[39] = (((" " << 4) & 8'h0F) | 8'h01);
        display_data[40] = ((((" " << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[41] = ((((" " << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;

        // For 'W'
        display_data[42] = (("W" & 8'hF0) | 8'h01);
        display_data[43] = ((("W" & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[44] = ((("W" & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[45] = ((("W" << 4) & 8'h0F) | 8'h01);
        display_data[46] = (((("W" << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[47] = (((("W" << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;

        // For 'o'
        display_data[48] = display_data[30];
        display_data[49] = display_data[31];
        display_data[50] = display_data[32];
        display_data[51] = display_data[33];
        display_data[52] = display_data[34];
        display_data[53] = display_data[35];

        // For 'r'
        display_data[54] = (("r" & 8'hF0) | 8'h01);
        display_data[55] = ((("r" & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[56] = ((("r" & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[57] = ((("r" << 4) & 8'h0F) | 8'h01);
        display_data[58] = (((("r" << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[59] = (((("r" << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;

        // For 'l'
        display_data[60] = display_data[18];
        display_data[61] = display_data[19];
        display_data[62] = display_data[20];
        display_data[63] = display_data[21];
        display_data[64] = display_data[22];
        display_data[65] = display_data[23];

        // For 'd'
        display_data[66] = (("d" & 8'hF0) | 8'h01);
        display_data[67] = ((("d" & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[68] = ((("d" & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[69] = ((("d" << 4) & 8'h0F) | 8'h01);
        display_data[70] = (((("d" << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[71] = (((("d" << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;

        // For '!'
        display_data[72] = (("!" & 8'hF0) | 8'h01);
        display_data[73] = ((("!" & 8'hF0) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[74] = ((("!" & 8'hF0) | 8'h01) & ~En) | LCD_BACKLIGHT;
        display_data[75] = ((("!" << 4) & 8'h0F) | 8'h01);
        display_data[76] = (((("!" << 4) & 8'h0F) | 8'h01) | En) | LCD_BACKLIGHT;
        display_data[77] = (((("!" << 4) & 8'h0F) | 8'h01) & ~En) | LCD_BACKLIGHT;
    end


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
        .i2c_sda(I2C_SDA),
        .i2c_scl(I2C_SCL)
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
                    data_in <= init_cmds[1];
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
                    data_in <= init_cmds[2];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 5;
                end
                5: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 6;
                    end
                end
                6: begin
                    data_in <= init_cmds[3];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 7;
                end
                7: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 8;
                    end
                end
                8: begin
                    data_in <= init_cmds[4];
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
                    data_in <= init_cmds[5];
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
                    data_in <= init_cmds[6];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 13;
                end
                13: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 14;
                    end
                end
                14: begin
                    data_in <= init_cmds[7];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 15;
                end
                15: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 16;
                    end
                end
                16: begin
                    data_in <= init_cmds[8];
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
                    data_in <= init_cmds[9];
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
                    data_in <= init_cmds[10];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 21;
                end
                21: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 22;
                    end
                end
                22: begin
                    data_in <= init_cmds[11];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 23;
                end
                23: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 24;
                    end
                end
                24: begin
                    data_in <= init_cmds[12];
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
                    data_in <= init_cmds[13];
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
                    data_in <= init_cmds[14];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 29;
                end
                29: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 30;
                    end
                end
                30: begin
                    data_in <= init_cmds[15];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 31;
                end
                31: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 32;
                    end
                end
                32: begin
                    data_in <= init_cmds[16];
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
                    data_in <= init_cmds[17];
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
                    data_in <= init_cmds[18];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 37;
                end
                37: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 38;
                    end
                end
                38: begin
                    data_in <= init_cmds[19];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 39;
                end
                39: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 40;
                    end
                end
                40: begin
                    data_in <= init_cmds[20];
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
                    data_in <= init_cmds[21];
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
                    data_in <= init_cmds[22];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 45;
                end
                45: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 46;
                    end
                end
                46: begin
                    data_in <= init_cmds[23];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 47;
                end
                47: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 48;
                    end
                end
                48: begin
                    data_in <= init_cmds[24];
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
                    data_in <= init_cmds[25];
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
                    data_in <= init_cmds[26];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 53;
                end
                53: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 54;
                    end
                end
                54: begin
                    data_in <= init_cmds[27];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 55;
                end
                55: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 56;
                    end
                end
                56: begin
                    data_in <= init_cmds[28];
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
                    data_in <= init_cmds[29];
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
                    // Initialize the delay
                    delay_counter <= 0;
                    delay_done <= 0;
                    state <= 61;
                end
                61: begin
                    if (delay_counter < 200000) begin
                        delay_counter <= delay_counter + 1;
                    end else begin
                        delay_done <= 1;
                        state <= 62;
                    end
                end
                62: begin
                    data_in <= init_cmds[30];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 63;
                end
                63: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 64;
                    end
                end
                64: begin
                    data_in <= init_cmds[31];
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
                    data_in <= init_cmds[32];
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
                    data_in <= init_cmds[33];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 69;
                end
                69: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 70;
                    end
                end
                70: begin
                    data_in <= init_cmds[34];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 71;
                end
                71: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 72;
                    end
                end
                72: begin
                    data_in <= init_cmds[35];
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
                    data_in <= init_cmds[36];
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
                    data_in <= init_cmds[37];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 77;
                end
                77: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 78;
                    end
                end
                78: begin
                    data_in <= init_cmds[38];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 79;
                end
                79: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 80;
                    end
                end
                80: begin
                    data_in <= init_cmds[39];
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
                    data_in <= init_cmds[40];
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
                    data_in <= init_cmds[41];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 85;
                end
                85: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 86;
                    end
                end
                86: begin
                    data_in <= display_data[0];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 87;
                end
                87: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 88;
                    end
                end
                                88: begin
                    data_in <= display_data[1];
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
                    data_in <= display_data[2];
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
                    data_in <= display_data[3];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 93;
                end
                93: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 94;
                    end
                end
                94: begin
                    data_in <= display_data[4];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 95;
                end
                95: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 96;
                    end
                end
                96: begin
                    data_in <= display_data[5];
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
                    data_in <= display_data[6];
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
                    data_in <= display_data[7];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 101;
                end
                101: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 102;
                    end
                end
                102: begin
                    data_in <= display_data[8];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 103;
                end
                103: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 104;
                    end
                end
                104: begin
                    data_in <= display_data[9];
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
                    data_in <= display_data[10];
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
                    data_in <= display_data[11];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 109;
                end
                109: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 110;
                    end
                end
                110: begin
                    data_in <= display_data[12];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 111;
                end
                111: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 112;
                    end
                end
                112: begin
                    data_in <= display_data[13];
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
                    data_in <= display_data[14];
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
                    data_in <= display_data[15];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 117;
                end
                117: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 118;
                    end
                end
                118: begin
                    data_in <= display_data[16];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 119;
                end
                119: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 120;
                    end
                end
                120: begin
                    data_in <= display_data[17];
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
                    data_in <= display_data[18];
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
                    data_in <= display_data[19];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 125;
                end
                125: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 126;
                    end
                end
                126: begin
                    data_in <= display_data[20];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 127;
                end
                127: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 128;
                    end
                end
                128: begin
                    data_in <= display_data[21];
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
                    data_in <= display_data[22];
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
                    data_in <= display_data[23];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 133;
                end
                133: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 134;
                    end
                end
                134: begin
                    data_in <= display_data[24];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 135;
                end
                135: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 136;
                    end
                end
                136: begin
                    data_in <= display_data[25];
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
                    data_in <= display_data[26];
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
                    data_in <= display_data[27];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 141;
                end
                141: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 142;
                    end
                end
                142: begin
                    data_in <= display_data[28];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 143;
                end
                143: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 144;
                    end
                end
                144: begin
                    data_in <= display_data[29];
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
                    data_in <= display_data[30];
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
                    data_in <= display_data[31];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 149;
                end
                149: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 150;
                    end
                end
                150: begin
                    data_in <= display_data[32];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 151;
                end
                151: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 152;
                    end
                end
                152: begin
                    data_in <= display_data[33];
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
                    data_in <= display_data[34];
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
                    data_in <= display_data[35];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 157;
                end
                157: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 158;
                    end
                end
                158: begin
                    data_in <= display_data[36];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 159;
                end
                159: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 160;
                    end
                end
                160: begin
                    data_in <= display_data[37];
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
                    data_in <= display_data[38];
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
                    data_in <= display_data[39];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 165;
                end
                165: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 166;
                    end
                end
                166: begin
                    data_in <= display_data[40];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 167;
                end
                167: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 168;
                    end
                end
                168: begin
                    data_in <= display_data[41];
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
                    data_in <= display_data[42];
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
                    data_in <= display_data[43];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 173;
                end
                173: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 174;
                    end
                end
                174: begin
                    data_in <= display_data[44];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 175;
                end
                175: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 176;
                    end
                end
                176: begin
                    data_in <= display_data[45];
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
                    data_in <= display_data[46];
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
                    data_in <= display_data[47];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 181;
                end
                181: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 182;
                    end
                end
                182: begin
                    data_in <= display_data[48];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 183;
                end
                183: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 184;
                    end
                end
                184: begin
                    data_in <= display_data[49];
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
                    data_in <= display_data[50];
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
                    data_in <= display_data[51];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 189;
                end
                189: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 190;
                    end
                end
                190: begin
                    data_in <= display_data[52];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 191;
                end
                191: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 192;
                    end
                end
                192: begin
                    data_in <= display_data[53];
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
                    data_in <= display_data[54];
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
                    data_in <= display_data[55];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 197;
                end
                197: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 198;
                    end
                end
                198: begin
                    data_in <= display_data[56];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 199;
                end
                199: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 200;
                    end
                end
                200: begin
                    data_in <= display_data[57];
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
                    data_in <= display_data[58];
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
                    data_in <= display_data[59];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 205;
                end
                205: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 206;
                    end
                end
                206: begin
                    data_in <= display_data[60];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 207;
                end
                207: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 208;
                    end
                end
                208: begin
                    data_in <= display_data[61];
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
                    data_in <= display_data[62];
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
                    data_in <= display_data[63];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 213;
                end
                213: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 214;
                    end
                end
                214: begin
                    data_in <= display_data[64];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 215;
                end
                215: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 216;
                    end
                end
                216: begin
                    data_in <= display_data[65];
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
                    data_in <= display_data[66];
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
                    data_in <= display_data[67];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 221;
                end
                221: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 222;
                    end
                end
                222: begin
                    data_in <= display_data[68];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 223;
                end
                223: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 224;
                    end
                end
                224: begin
                    data_in <= display_data[69];
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
                    data_in <= display_data[70];
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
                    data_in <= display_data[71];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 229;
                end
                229: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 230;
                    end
                end
                230: begin
                    data_in <= display_data[72];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 231;
                end
                231: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 232;
                    end
                end
                232: begin
                    data_in <= display_data[73];
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
                    data_in <= display_data[74];
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
                    data_in <= display_data[75];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 237;
                end
                237: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 238;
                    end
                end
                238: begin
                    data_in <= display_data[76];
                    enable <= 1'b1;
                    rw <= 1'b0; // Write operation 
                    state <= 239;
                end
                239: begin
                    if (ready) begin
                        enable <= 1'b0; 
                        state <= 240;
                    end
                end
                240: begin
                    data_in <= display_data[77];
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

                end


                default: begin
                    state <= 0; // Default case to reset state machine
                end
            endcase
        end
    end


endmodule


