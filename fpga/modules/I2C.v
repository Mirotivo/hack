/**
 * The module I2C is an I2C Controller
 * Supports read and write operations via I2C protocol
 * 
 * READY indicates when controller is idle and ready
 */
`default_nettype none
`timescale 1ns / 1ps
module I2C(
    // Clock and Reset
    input wire CLK_100MHz,
    input wire RST,

    // Control Interface
    input wire ENABLE,
    input wire RW,
    output wire READY,

    // Data Interface
    input wire [6:0] ADDR,
    input wire [7:0] DATA_IN,
    output reg [7:0] DATA_OUT,

    // I2C
    inout wire I2C_SDA,
    inout wire I2C_SCL
);

    // State machine states
    localparam IDLE        = 0;
    localparam START       = 1;
    localparam ADDRESS     = 2;
    localparam READ_ACK    = 3;
    localparam WRITE_DATA  = 4;
    localparam WRITE_ACK   = 5;
    localparam READ_DATA   = 6;
    localparam READ_ACK2   = 7;
    localparam STOP        = 8;

    // Internal signals - State machine
    reg [7:0] state;
    reg [7:0] saved_addr;
    reg [7:0] saved_data;
    reg [7:0] counter;
    reg [15:0] clk_div_counter;
    reg i2c_clk;

    // Internal signals - SDA line control
    wire sda_oe;
    wire sda_out;
    wire sda_in;

    // Internal signals - SCL line control
    wire scl_oe;
    wire scl_out;
    wire scl_in;

    // Module instantiations
    
    // SDA line with tristate logic
    InOut sda_inout (
        .PIN(I2C_SDA),
        .dataW(sda_out),
        .dataR(sda_in),
        .dir(sda_oe)
    );

    // SCL line with tristate logic
    InOut scl_inout (
        .PIN(I2C_SCL),
        .dataW(scl_out),
        .dataR(scl_in),
        .dir(scl_oe)
    );

    // Initial blocks
    
    initial begin
        state = IDLE;
        saved_addr = 0;
        saved_data = 0;
        counter = 0;
        clk_div_counter = 0;
        i2c_clk = 1;
        DATA_OUT = 0;
    end

    // Combinational logic
    
    assign READY = ((RST == 0) && (state == IDLE)) ? 1 : 0;
    assign scl_out = i2c_clk;

    // Sequential logic
    
    // Clock divider for I2C clock generation
    always @(posedge CLK_100MHz) begin
        if (clk_div_counter == 999) begin
            i2c_clk <= ~i2c_clk;
            clk_div_counter <= 0;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end 

    // SCL output enable control
    always @(negedge i2c_clk, posedge RST) begin
        if(RST == 1) begin
            scl_oe <= 0;
        end else begin
            if ((state == IDLE) || (state == START) || (state == STOP)) begin
                scl_oe <= 0;
            end else begin
                scl_oe <= 1;
            end
        end
    end

    // Main state machine
    always @(posedge i2c_clk, posedge RST) begin
        if(RST == 1) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                    if (ENABLE) begin
                        state <= START;
                        saved_addr <= {ADDR, RW};
                        saved_data <= DATA_IN;
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
                    if ((sda_in == 0) && (ENABLE == 1)) state <= IDLE;
                    else state <= STOP;
                end
                READ_DATA: begin
                    DATA_OUT[counter] <= sda_in;
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
    
    // SDA line control
    always @(negedge i2c_clk, posedge RST) begin
        if(RST == 1) begin
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
