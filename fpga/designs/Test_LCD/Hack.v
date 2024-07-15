`define RAMFILE "../designs/Test_Computer/empty_ram.ram"
`define ROMFILE "../designs/Test_Computer/empty_rom.rom"
`include "include.v"

/**
 * The module hack is our top-level module
 * It connects the external pins of our FPGA (Hack.pcf)
 * to the internal components (cpu,mem,clk,rst,rom)
 *
 */

`default_nettype none
module Hack (
    input CLK_100MHz,

    // Buttons and LEDs
    input [1:0] BUT,
    output [1:0] LED,

    // UART
    input UART_RX,
    output UART_TX,

    // SPI
    output SPI_SDO,
    input SPI_SDI,
    output SPI_SCK,
    output SPI_CSX
);
    // SPI initialization command array
    reg [7:0] initcmd [0:88]; // Adjust size based on actual number of bytes in initcmd
    initial begin
        initcmd[0] = 8'hEF;
        initcmd[1] = 8'h03;
        initcmd[2] = 8'h80;
        initcmd[3] = 8'h02;
        
        initcmd[4] = 8'hCF;
        initcmd[5] = 8'h00;
        initcmd[6] = 8'hC1;
        initcmd[7] = 8'h30;
        
        initcmd[8] = 8'hED;
        initcmd[9] = 8'h64;
        initcmd[10] = 8'h03;
        initcmd[11] = 8'h12;
        initcmd[12] = 8'h81;
        
        initcmd[13] = 8'hE8;
        initcmd[14] = 8'h85;
        initcmd[15] = 8'h00;
        initcmd[16] = 8'h78;
        
        initcmd[17] = 8'hCB;
        initcmd[18] = 8'h39;
        initcmd[19] = 8'h2C;
        initcmd[20] = 8'h00;
        initcmd[21] = 8'h34;
        initcmd[22] = 8'h02;
        
        initcmd[23] = 8'hF7;
        initcmd[24] = 8'h20;
        
        initcmd[25] = 8'hEA;
        initcmd[26] = 8'h00;
        initcmd[27] = 8'h00;
        
        initcmd[28] = 8'hC0; // ILI9341_PWCTR1
        initcmd[29] = 8'h23;
        
        initcmd[30] = 8'hC1; // ILI9341_PWCTR2
        initcmd[31] = 8'h10;
        
        initcmd[32] = 8'hC5; // ILI9341_VMCTR1
        initcmd[33] = 8'h3e;
        initcmd[34] = 8'h28;
        
        initcmd[35] = 8'hC7; // ILI9341_VMCTR2
        initcmd[36] = 8'h86;
        
        initcmd[37] = 8'h36; // ILI9341_MADCTL
        initcmd[38] = 8'h48;
        
        initcmd[39] = 8'h37; // ILI9341_VSCRSADD
        initcmd[40] = 8'h00;
        
        initcmd[41] = 8'h3A; // ILI9341_PIXFMT
        initcmd[42] = 8'h55;
        
        initcmd[43] = 8'hB1; // ILI9341_FRMCTR1
        initcmd[44] = 8'h00;
        initcmd[45] = 8'h18;
        
        initcmd[46] = 8'hB6; // ILI9341_DFUNCTR
        initcmd[47] = 8'h08;
        initcmd[48] = 8'h82;
        initcmd[49] = 8'h27;
        
        initcmd[50] = 8'hF2;
        initcmd[51] = 8'h00;
        
        initcmd[52] = 8'h26; // ILI9341_GAMMASET
        initcmd[53] = 8'h01;
        
        initcmd[54] = 8'hE0; // ILI9341_GMCTRP1
        initcmd[55] = 8'h0F;
        initcmd[56] = 8'h31;
        initcmd[57] = 8'h2B;
        initcmd[58] = 8'h0C;
        initcmd[59] = 8'h0E;
        initcmd[60] = 8'h08;
        initcmd[61] = 8'h4E;
        initcmd[62] = 8'hF1;
        initcmd[63] = 8'h37;
        initcmd[64] = 8'h07;
        initcmd[65] = 8'h10;
        initcmd[66] = 8'h03;
        initcmd[67] = 8'h0E;
        initcmd[68] = 8'h09;
        initcmd[69] = 8'h00;
        
        initcmd[70] = 8'hE1; // ILI9341_GMCTRN1
        initcmd[71] = 8'h00;
        initcmd[72] = 8'h0E;
        initcmd[73] = 8'h14;
        initcmd[74] = 8'h03;
        initcmd[75] = 8'h11;
        initcmd[76] = 8'h07;
        initcmd[77] = 8'h31;
        initcmd[78] = 8'hC1;
        initcmd[79] = 8'h48;
        initcmd[80] = 8'h08;
        initcmd[81] = 8'h0F;
        initcmd[82] = 8'h0C;
        initcmd[83] = 8'h31;
        initcmd[84] = 8'h36;
        initcmd[85] = 8'h0F;
        
        initcmd[86] = 8'h11; // ILI9341_SLPOUT
        
        initcmd[87] = 8'h29; // ILI9341_DISPON
        
        initcmd[88] = 8'h00; // End of commands
    end

    // Command to fill screen with black color
    reg [7:0] fillcmd [0:10];
    initial begin
        fillcmd[0] = 8'h2A; // ILI9341_CASET
        fillcmd[1] = 0;
        fillcmd[2] = 0;
        fillcmd[3] = 0;
        fillcmd[4] = 239;
        
        fillcmd[5] = 8'h2B; // ILI9341_PASET
        fillcmd[6] = 0;
        fillcmd[7] = 0;
        fillcmd[8] = 0;
        fillcmd[9] = 319;
        
        fillcmd[10] = 8'h2C; // ILI9341_RAMWR
    end

    SPI spi_inst (
        .CLK_100MHz(CLK_100MHz), 
        .reset(reset), 
        .load(spi_load),
        .in(command), 
        .out(spi_out), 
        .CSX(SPI_CSX), 
        .SDO(SPI_SDO), 
        .SDI(SPI_SDI), 
        .SCK(SPI_SCK),
        .busy(spi_busy)
    );

    reg [3:0] state;
    reg [6:0] cmd_index;
    reg spi_load; // Added this signal
    reg [7:0] command; // Added this signal
    reg [15:0] color; // Added this signal
    reg [15:0] pixel_count; // Added this signal
    reg [31:0] delay_counter; // Added this signal for delay
    // Instantiate the SPI module
    wire spi_out; // Added this signal
    wire spi_busy; // Added this signal
    wire reset;
    assign reset = ~BUT[0] | ~BUT[1];

    always @(posedge CLK_100MHz or posedge reset) begin
        if (reset) begin
            state <= 0;
            spi_load <= 0;
            cmd_index <= 0;
            pixel_count <= 0;
            delay_counter <= 0;
        end else if (!spi_busy) begin
            case (state)
                0: begin
                    if (cmd_index < 88) begin
                        command <= initcmd[cmd_index];
                        spi_load <= 1;
                        cmd_index <= cmd_index + 1;
                        state <= 1;
                    end else begin
                        cmd_index <= 0;
                        state <= 2;
                    end
                end
                1: begin
                    spi_load <= 0;
                    if (cmd_index == 87 || cmd_index == 88) begin // Check for specific commands
                        delay_counter <= 15_000_000; // 150ms delay, assuming 100MHz clock
                        state <= 7; // Enter delay state
                    end else begin
                        state <= 0;
                    end
                end
                2: begin
                    if (cmd_index < 11) begin
                        command <= fillcmd[cmd_index];
                        spi_load <= 1;
                        cmd_index <= cmd_index + 1;
                        state <= 3;
                    end else begin
                        cmd_index <= 0;
                        state <= 4;
                    end
                end
                3: begin
                    spi_load <= 0;
                    state <= 2;
                end
                4: begin
                    if (pixel_count < 76800) begin // ILI9341_TFTWIDTH * ILI9341_TFTHEIGHT
                        command <= color[15:8];
                        spi_load <= 1;
                        state <= 5;
                    end else begin
                        state <= 6;
                    end
                end
                5: begin
                    command <= color[7:0];
                    spi_load <= 1;
                    pixel_count <= pixel_count + 1;
                    state <= 4;
                end
                7: begin // Delay state
                    if (delay_counter > 0) begin
                        delay_counter <= delay_counter - 1;
                    end else begin
                        state <= 0; // Return to normal operation
                    end
                end
                default: state <= state;
            endcase
        end else begin
            spi_load <= 0;
        end
    end

    // LEDs to indicate status
    assign LED[0] = ~spi_busy; // Show ready/busy status
    assign LED[1] = spi_load;  // Indicate when data is being loaded

endmodule
