`timescale 1ns / 1ps

module I2C(
    input wire CLK_100MHz,
    input wire rst,
    input wire [6:0] addr,
    input wire [7:0] data_in,
    input wire enable,
    input wire rw,

    output reg [7:0] data_out,
    output reg ready,
    output reg i2c_clk,

    output wire i2c_sda_out,
    input wire i2c_sda_in,
    output wire i2c_sda_oe, // 1 for output, 0 for high impedance

    output reg I2C_SCL
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

    localparam DIVIDE_BY = 64; // Adjust this value to achieve desired I2C clock frequency

    reg [7:0] state = IDLE;
    reg [7:0] saved_addr = 8'b0;
    reg [7:0] saved_data = 8'b0;
    reg [7:0] counter = 8'b0;
    reg [15:0] counter2 = 16'b0; // Increased width to accommodate higher values for clock division

    // Tristate buffer control signals
    reg sda_out_reg;
    reg sda_oe_reg;
    assign i2c_sda_out = sda_out_reg;
    assign i2c_sda_oe = sda_oe_reg;

    always @(posedge CLK_100MHz) begin
        if (rst) begin
            i2c_clk <= 1'b0; // Initialize i2c_clk during reset
            counter2 <= 0;
        end else if (counter2 == (DIVIDE_BY/2) - 1) begin
            i2c_clk <= ~i2c_clk;
            counter2 <= 0;
        end else begin
            counter2 <= counter2 + 1;
        end
    end 

    always @(negedge i2c_clk or posedge rst) begin
        if (rst) begin
            I2C_SCL <= 0;
        end else begin
            if ((state == IDLE) || (state == START) || (state == STOP)) begin
                I2C_SCL <= 0;
            end else begin
                I2C_SCL <= 1;
            end
        end
    end

    always @(posedge i2c_clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            saved_addr <= 8'b0;
            saved_data <= 8'b0;
            counter <= 8'b0;
            data_out <= 8'b0;
            ready <= 1'b1; // Set ready during reset
        end else begin
            case(state)
                IDLE: begin
                    ready <= 1'b1; // Ready to accept new transaction
                    if (enable) begin
                        state <= START;
                        saved_addr <= {addr, rw};
                        saved_data <= data_in;
                        ready <= 1'b0; // Not ready during transaction
                    end
                end

                START: begin
                    counter <= 7;
                    state <= ADDRESS;
                end

                ADDRESS: begin
                    if (counter == 0) begin 
                        state <= READ_ACK;
                    end else begin
                        counter <= counter - 1;
                    end
                end

                READ_ACK: begin
                    if (i2c_sda_in == 0) begin
                        counter <= 7;
                        if(saved_addr[0] == 0) state <= WRITE_DATA;
                        else state <= READ_DATA;
                    end else begin
                        state <= STOP;
                    end
                end

                WRITE_DATA: begin
                    if(counter == 0) begin
                        state <= READ_ACK2;
                    end else begin
                        counter <= counter - 1;
                    end
                end
                
                READ_ACK2: begin
                    if ((i2c_sda_in == 0) && (enable == 1)) state <= IDLE;
                    else state <= STOP;
                end

                READ_DATA: begin
                    data_out[counter] <= i2c_sda_in;
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

    always @(negedge i2c_clk or posedge rst) begin
        if (rst) begin
            sda_oe_reg <= 1;
            sda_out_reg <= 1;
        end else begin
            case(state)
                START: begin
                    sda_oe_reg <= 1;
                    sda_out_reg <= 0;
                end
                
                ADDRESS: begin
                    sda_oe_reg <= 1;
                    sda_out_reg <= saved_addr[counter];
                end
                
                READ_ACK: begin
                    sda_oe_reg <= 0;
                end
                
                WRITE_DATA: begin 
                    sda_oe_reg <= 1;
                    sda_out_reg <= saved_data[counter];
                end
                
                WRITE_ACK: begin
                    sda_oe_reg <= 1;
                    sda_out_reg <= 0;
                end
                
                READ_DATA: begin
                    sda_oe_reg <= 0;                
                end
                
                STOP: begin
                    sda_oe_reg <= 1;
                    sda_out_reg <= 1;
                end
            endcase
        end
    end

endmodule
