`timescale 1ns / 1ps

module I2C(
    input wire CLK_100MHz,
    input wire rst,
    input wire [6:0] addr,
    input wire [7:0] data_in,
    input wire enable,
    input wire rw,

    output reg [7:0] data_out,
    output wire ready,

    inout wire i2c_sda,
    inout wire i2c_scl
    );

    localparam IDLE = 0;
    localparam START = 1;
    localparam ADDRESS = 2;
    localparam READ_ACK = 3;
    localparam WRITE_DATA = 4;
    localparam WRITE_ACK = 5;
    localparam READ_DATA = 6;
    localparam READ_ACK2 = 7;
    localparam STOP = 8;

    reg [7:0] state;
    reg [7:0] saved_addr;
    reg [7:0] saved_data;
    reg [7:0] counter;
    reg [15:0] clk_div_counter = 0;
    reg i2c_clk = 1;

    // Internal signals for SDA line control
    wire sda_oe;    // Output enable for SDA
    wire sda_out;   // Output data for SDA
    wire sda_in;    // Input data from SDA

    // Internal signals for SCL line control
    wire scl_oe;    // Output enable for SCL
    wire scl_out;   // Output data for SCL
    wire scl_in;    // Input data from SCL

    // Assign the inout SDA line with tristate logic
    InOut sda_inout (
        .PIN(i2c_sda),
        .dataW(sda_out),
        .dataR(sda_in),
        .dir(sda_oe)
    );

    // Assign the inout SCL line with tristate logic
    InOut scl_inout (
        .PIN(i2c_scl),
        .dataW(scl_out),
        .dataR(scl_in),
        .dir(scl_oe)
    );

    assign ready = ((rst == 0) && (state == IDLE)) ? 1 : 0;
    assign scl_out = i2c_clk;  // Drive the SCL line with the internal clock

    always @(posedge CLK_100MHz) begin
        if (clk_div_counter == 999) begin
            i2c_clk <= ~i2c_clk;
            clk_div_counter <= 0;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end 

    always @(negedge i2c_clk, posedge rst) begin
        if(rst == 1) begin
            scl_oe <= 0;
        end else begin
            if ((state == IDLE) || (state == START) || (state == STOP)) begin
                scl_oe <= 0;
            end else begin
                scl_oe <= 1;
            end
        end
    end

    always @(posedge i2c_clk, posedge rst) begin
        if(rst == 1) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                    if (enable) begin
                        state <= START;
                        saved_addr <= {addr, rw};
                        saved_data <= data_in;
                    end else state <= IDLE;
                end
                START: begin
                    counter <= 7;
                    state <= ADDRESS;
                end
                ADDRESS: begin
                    if (counter == 0) begin 
                        state <= READ_ACK;
                    end else counter <= counter - 1;
                end
                READ_ACK: begin
                    if (sda_in == 0) begin
                        counter <= 7;
                        if(saved_addr[0] == 0) state <= WRITE_DATA;
                        else state <= READ_DATA;
                    end else state <= STOP;
                end
                WRITE_DATA: begin
                    if(counter == 0) begin
                        state <= READ_ACK2;
                    end else counter <= counter - 1;
                end
                READ_ACK2: begin
                    if ((sda_in == 0) && (enable == 1)) state <= IDLE;
                    else state <= STOP;
                end
                READ_DATA: begin
                    data_out[counter] <= sda_in;
                    if (counter == 0) state <= WRITE_ACK;
                    else counter <= counter - 1;
                end
                WRITE_ACK: begin
                    state <= STOP;
                end
                STOP: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
    always @(negedge i2c_clk, posedge rst) begin
        if(rst == 1) begin
            sda_oe <= 1;
            sda_out <= 1;
        end else begin
            case(state)
                START: begin
                    sda_oe <= 1;
                    sda_out <= 0;
                end
                ADDRESS: begin
                    sda_out <= saved_addr[counter];
                end
                READ_ACK: begin
                    sda_oe <= 0;
                end
                WRITE_DATA: begin 
                    sda_oe <= 1;
                    sda_out <= saved_data[counter];
                end
                WRITE_ACK: begin
                    sda_oe <= 1;
                    sda_out <= 0;
                end
                READ_DATA: begin
                    sda_oe <= 0;                
                end
                STOP: begin
                    sda_oe <= 1;
                    sda_out <= 1;
                end
            endcase
        end
    end

endmodule