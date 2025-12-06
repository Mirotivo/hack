// Create a stub for SB_IO for simulation
module SB_IO #(
    parameter [5:0] PIN_TYPE = 6'b000000,
    parameter PULLUP = 1'b0
) (
    inout PACKAGE_PIN,
    input OUTPUT_ENABLE,
    input D_OUT_0,
    output D_IN_0
);
    // Simple behavioral model for simulation
    assign PACKAGE_PIN = OUTPUT_ENABLE ? D_OUT_0 : 1'bz;
    assign D_IN_0 = PACKAGE_PIN;
endmodule

`include "../../modules/SRAM_Controller.v"
`timescale 1ns/1ps
`default_nettype none

module Hack_tb();

	// Signals
	reg CLK = 0;
	reg RST = 1;
	reg WE = 0;
	reg [17:0] ADDRESS = 0;
	reg [15:0] DATA_WRITE = 0;
	wire [15:0] DATA_READ;
	wire [15:0] DATA;
	wire CSX;
	wire OEX;
	wire WEX;
	
	// Simulate SRAM - drive DATA bus when not writing
	reg [15:0] sram_memory = 16'h0;
	assign DATA = (!WE) ? sram_memory : 16'bz;

	// Device Under Test
	SRAM_Controller SRAM_D(
		.CLK(CLK),
		.RST(RST),
		.WE(WE),
		.ADDRESS(ADDRESS),
		.DATA(DATA),
		.DATA_WRITE(DATA_WRITE),
		.DATA_READ(DATA_READ),
		.CSX(CSX),
		.OEX(OEX),
		.WEX(WEX)
	);
	
	// Simulate SRAM write behavior
	always @(posedge CLK) begin
		if (WE && !WEX) begin
			// SRAM captures data on rising clock during write
			sram_memory <= DATA;
		end
	end
	
	// Clock generation - 100MHz (10ns period)
	always #5 CLK = ~CLK;
	
	// Test sequence
	integer n;
	reg fail = 0;
	
	initial begin
		$dumpfile("Hack_tb.vcd");
		$dumpvars(0, Hack_tb);
		
		$display("------------------------");
		$display("Testbench: SRAM_Controller");
		$display("Testing write and read operations");
		
		// Reset
		RST = 1;
		#20;
		RST = 0;
		#20;
		
		// Test 1: Write 0xAAAA to address 0x00000
		$display("Test 1: Write 0xAAAA to address 0x00000");
		ADDRESS = 18'h00000;
		DATA_WRITE = 16'hAAAA;
		WE = 1;
		#50;
		
		// Verify control signals during write
		if (CSX != 0) begin
			$display("FAIL: CSX should be 0 (chip selected)");
			fail = 1;
		end
		if (WEX != 0) begin
			$display("FAIL: WEX should be 0 (active low - write enabled)");
			fail = 1;
		end
		if (OEX != 1) begin
			$display("FAIL: OEX should be 1 (active low - output disabled during write)");
			fail = 1;
		end
		
		// Test 2: Read from address 0x00000
		$display("Test 2: Read from address 0x00000 (expect 0xAAAA)");
		WE = 0;
		#50;
		
		// Verify control signals during read
		if (CSX != 0) begin
			$display("FAIL: CSX should be 0 (chip selected)");
			fail = 1;
		end
		if (WEX != 1) begin
			$display("FAIL: WEX should be 1 (active low - write disabled during read)");
			fail = 1;
		end
		if (OEX != 0) begin
			$display("FAIL: OEX should be 0 (active low - output enabled during read)");
			fail = 1;
		end
		
		// Verify data
		if (DATA_READ != 16'hAAAA) begin
			$display("FAIL: Read data mismatch! Expected 0xAAAA, got 0x%h", DATA_READ);
			fail = 1;
		end else begin
			$display("PASS: Read data matches (0xAAAA)");
		end
		
		// Test 3: Write 0x5555 to address 0x11111
		$display("Test 3: Write 0x5555 to address 0x11111");
		ADDRESS = 18'h11111;
		DATA_WRITE = 16'h5555;
		WE = 1;
		#50;
		
		// Test 4: Read from address 0x11111
		$display("Test 4: Read from address 0x11111 (expect 0x5555)");
		WE = 0;
		#50;
		
		// Verify data
		if (DATA_READ != 16'h5555) begin
			$display("FAIL: Read data mismatch! Expected 0x5555, got 0x%h", DATA_READ);
			fail = 1;
		end else begin
			$display("PASS: Read data matches (0x5555)");
		end
		
		#100;
		
		if (fail == 0) 
			$display("PASSED: All tests successful!");
		else
			$display("FAILED: Check errors above");
			
		$display("------------------------");
		$finish;
	end

endmodule
