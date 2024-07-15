`include "../../modules/CLK_Divider.v"
`include "../../modules/SPI.v"
/** 
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk,rst,rom)
 *
 */

`default_nettype none
module Hack (
    input CLK_100MHz,

    // LEDs
    output [1:0] LED,

    // SPI
    output SPI_SDO,
    input SPI_SDI,
    output SPI_SCK,
    output SPI_CSX,

);
    wire clk_div;
    reg load;
    reg [15:0] data_in;
    wire [15:0] data_out;
    reg [3:0] address_counter = 0; // 4-bit counter to cycle through 4 addresses
    reg [3:0] state = 0;

    // Instantiate Clock Divider
    CLK_Divider clk_divider (
        .clk_in(CLK_100MHz),
        .divisor(100000000),
        .clk_out(clk_div)
    );

    // Instantiate SPI
    SPI spi (
        .clk(clk_div),
        .load(load),
        .in(data_in),
        .out(data_out),
        .CSX(SPI_CSX),
        .SDO(SPI_SDO),
        .SDI(SPI_SDI),
        .SCK(SPI_SCK)
    );

    always @(posedge clk_div) begin
        case (state)
            0: begin
                load <= 1;
                data_in <= {8'h01, address_counter}; // Address + data
                state <= 1;
            end
            1: begin
                load <= 0;
                if (SPI_CSX == 1) begin // Wait for SPI transaction to complete
                    state <= 2;
                end
            end
            2: begin
                LED <= data_out[1:0]; // Display received data on LEDs
                address_counter <= address_counter + 1; // Increment address
                if (address_counter >= 4) begin
                    address_counter <= 0; // Wrap around
                end
                state <= 0; // Repeat the process
            end
        endcase
    end

endmodule
