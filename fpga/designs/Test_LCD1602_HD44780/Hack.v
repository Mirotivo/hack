`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"
/** 
 * The module hack is our top-level module
 * It connects the external pins of our fpga (Hack.pcf)
 * to the internal components (cpu,mem,clk,rst,rom)
 *
 */

`default_nettype none



module i2c_master (
  input clk,         // Input clock signal
  input rst,         // Reset signal
  output reg sda,    // I2C data signal
  output reg scl,    // I2C clock signal
  output reg [7:0] data_out,  // Data to be written to the slave device
  input [7:0] data_in,  // Data read from the slave device
  input [6:0] addr,   // I2C slave address
  input start_bit,    // Start bit
  input stop_bit      // Stop bit
);

  // I2C state machine states
  parameter IDLE = 2'd0;
  parameter START = 2'd1;
  parameter WRITE = 2'd2;
  parameter READ = 2'd3;
  parameter STOP = 2'd4;

  // I2C timing parameters (in ns)
  parameter SCL_HIGH_TIME = 500;
  parameter SCL_LOW_TIME = 500;
  parameter SDA_SETUP_TIME = 100;
  parameter SDA_HOLD_TIME = 0;

  // Internal signals
  reg [7:0] data_out_reg;
  reg [3:0] state;
  reg [3:0] bit_cnt;
  reg start_bit_reg;
  reg stop_bit_reg;
  reg sda_out;
  reg scl_out;

  // Start bit generator
  always @(posedge clk) begin
    if (rst) begin
      start_bit_reg <= 0;
    end else begin
      start_bit_reg <= start_bit;
    end
  end

  // Stop bit generator
  always @(posedge clk) begin
    if (rst) begin
      stop_bit_reg <= 0;
    end else begin
      stop_bit_reg <= stop_bit;
    end
  end

  // SDA output driver
  always @(posedge clk) begin
    if (rst) begin
      sda_out <= 1;
    end else begin
      case (state)
        START, WRITE: sda_out <= data_out_reg[bit_cnt];
        READ: sda_out <= 1;
        default: sda_out <= 1;
      endcase
    end
  end

  // SCL output driver
  always @(posedge clk) begin
    if (rst) begin
      scl_out <= 1;
    end else begin
      case (state)
        START: scl_out <= 0;
        WRITE, READ: scl_out <= ~scl_out;
        STOP: scl_out <= 1;
        default: scl_out <= 1;
      endcase
    end
  end

  // State machine
  always @(posedge clk) begin
      if (rst) begin
        state <= IDLE;
        bit_cnt <= 0;
        data_out_reg <= 0;
      end else begin
        case (state)
          IDLE:
            if (start_bit_reg) begin
              state <= START;
              bit_cnt <= 0;
              data_out_reg <= addr << 1;
            end else begin
              state <= IDLE;
            end
          START:
            if (bit_cnt == 7) begin
              state <= WRITE;
              bit_cnt <= 0;
            end else begin
              bit_cnt <= bit_cnt + 1;
            end
          WRITE:
            if (bit_cnt == 7) begin
              if (stop_bit_reg) begin
                state <= STOP;
              end else begin
                state <= READ;
              end
              bit_cnt <= 0;
            end else begin
              bit_cnt <= bit_cnt + 1;
            end
          READ:
            if (bit_cnt == 7) begin
              state <= WRITE;
              bit_cnt <= 0;
            end else begin
              bit_cnt <= bit_cnt + 1;
            end
          STOP:
            state <= IDLE;
          default: state <= IDLE;
        endcase
      end
    end

  // I2C timing generator
  always @(posedge clk) begin
    if (rst) begin
    sda <= 1;
    scl <= 1;
    end else begin
      case (state)
        IDLE: begin
            sda <= 1;
            scl <= 1;
          end
        START: begin
            sda <= sda_out;
            scl <= 1;
            #SCL_HIGH_TIME;
            scl <= 0;
            #SDA_SETUP_TIME;
          end
        WRITE: begin
            sda <= sda_out;
            scl <= 1;
            #SCL_HIGH_TIME;
            scl <= 0;
            #SDA_SETUP_TIME;
          end
        READ: begin
            sda <= 1;
            scl <= 1;
            #SCL_HIGH_TIME;
            scl <= 0;
            #SDA_SETUP_TIME;
          end
        STOP: begin
            sda <= 0;
            scl <= 1;
            #SCL_LOW_TIME;
            sda <= 1;
            #SDA_SETUP_TIME;
          end
        default: begin
            sda <= 1;
            scl <= 1;
          end
      endcase
      #SDA_HOLD_TIME;
    end
  end

endmodule


module Hack(                        // top level module 
    input wire clk_in,
    output wire [6:0] seg
);

  // Inputs
  reg clk;
  reg rst;
  reg start_bit;
  reg stop_bit;
  reg [7:0] data_in;
  reg [6:0] addr;

  // Outputs
  wire sda;
  wire scl;
  wire [7:0] data_out;

  // Instantiate the i2c_master module
  i2c_master dut (
    .clk(clk),
    .rst(rst),
    .sda(sda),
    .scl(scl),
    .data_out(data_out),
    .data_in(data_in),
    .addr(addr),
    .start_bit(start_bit),
    .stop_bit(stop_bit)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Stimulus process
  initial begin
    clk = 0;
    rst = 1;
    start_bit = 0;
    stop_bit = 0;
    addr = 7'h50;
    data_in = 0;

    #10 rst = 0;

    // Send a write command to the slave device
    start_bit = 1;
    addr = 7'h50;
    data_out = 8'hAA;
    #100 stop_bit = 1;
    #100 start_bit = 0;

    // Send a read command to the slave device
    start_bit = 1;
    addr = 7'h51;
    #100 data_in = 8'hFF;
    #100 stop_bit = 1;
    #100 start_bit = 0;

    // Send an invalid address to the slave device
    start_bit = 1;
    addr = 7'h00;
    data_out = 8'hAA;
    #100 stop_bit = 1;
    #100 start_bit = 0;

    // Wait for the simulation to finish
    #1000 $finish;
  end

endmodule
