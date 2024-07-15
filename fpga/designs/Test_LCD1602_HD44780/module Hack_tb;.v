module Hack_tb;

  // Instantiate the iCE40 I2C module
  i2c_master i2c (
    .clk(clk),
    .sda(sda),
    .scl(scl)
  );

  // Send the byte 10100110 to the I2C slave device
  initial begin
    sda = 1;
    scl = 1;

    // Start condition
    sda = 0;
    #10 scl = 0;

    // Send slave address (in this case, 0x50)
    sda = 0;
    #10 scl = 1;
    sda = 1;
    #10 scl = 0;

    // Send data byte (10100110)
    sda = 0;
    #10 scl = 1;
    sda = 1;
    #10 scl = 0;

    // Stop condition
    sda = 0;
    #10 scl = 1;
    sda = 1;
  end

endmodule