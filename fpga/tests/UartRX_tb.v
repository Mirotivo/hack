`include "include.v"
`timescale 10ns/1ns
`default_nettype none

module UartRX_tb();

	// IN,OUT
	reg clk = 0;
	reg clear = 0;
	wire RX;
	wire [15:0] out;
    integer file;

	// Part
	UartRX UARTRX(
    	.clk(clk),
		.clear(clear),
		.RX(RX),
		.out(out)
	);
	
	// Simulate
	always #2 clk=~clk;
	wire trigger;
	reg load=0;
	assign trigger = (n==1000) || (n==5000) || (n==9000);
	reg [15:0] in=0;
	always @(posedge clk) begin
		in <= trigger?$random:in;	
		load <= trigger;
		clear <= (n==200);
	end

	// Compare
	reg [9:0] uart=10'b1111111111;
	reg [15:0] baudrate = 0;
	reg [15:0] bits = 0;
	always @(posedge clk)
		bits <= (load&~out_tx)?0:((baudrate==216)?bits+1:bits);
	always @(posedge clk)
		baudrate <= (load&~out_tx)?0:((baudrate==216)?0:(out_tx)?baudrate+1:baudrate);
	always @(posedge clk)
		uart <= (load&~out_tx)?((in<<2)|1):((baudrate==216)?{1'b1,uart[9:1]}:uart);
	reg out_tx = 0;
	always @(posedge clk)
		out_tx <= load?1:((bits==10)?0:out_tx);
	assign RX = uart[1];

	reg [15:0] out_cmp 	=0;
	always @(posedge clk)
		out_cmp <= clear?16'b1000000000000000:((baudrate==216)&(bits==9)?in& 16'h00ff:out_cmp);
	reg fail = 0;
	reg [31:0] n = 0;
	task check;
		#4
		if (out_cmp != out) begin
			$display("FAIL: clk=%1b, bits=%d, out_tx=%1b, clear=%1b, baudrate=%d, out=%16b, expected_out=%16b",clk,bits,out_tx,clear,baudrate,out,out_cmp);
			$fdisplay(file, "FAIL: clk=%1b, bits=%d, out_tx=%1b, clear=%1b, baudrate=%d, out=%16b, expected_out=%16b", clk, bits, out_tx, clear, baudrate, out, out_cmp);
			fail=1;
		end else begin
			$display("PASS: clk=%1b, bits=%d, out_tx=%1b, clear=%1b, baudrate=%d, out=%16b", clk,bits,out_tx,clear,baudrate,out);
			$fdisplay(file, "PASS: clk=%1b, bits=%d, out_tx=%1b, clear=%1b, baudrate=%d, out=%16b", clk, bits, out_tx, clear, baudrate, out);
		end
	endtask

	initial begin
		$dumpfile("UartRX_tb.vcd");
  		$dumpvars(0, UartRX_tb);
		
		$display("------------------------");
		$display("Testbench: UartRX");

        file = $fopen("UartRX_tb_output.txt", "w");
        if (file == 0) begin
            $display("Error: could not open file.");
            $finish;
        end

		for (n=0; n<10000;n=n+1) 
				check();
		
		if (fail == 0) $fdisplay(file, "Passed");
        $display("------------------------");
        $fclose(file);

		if (fail==0) $display("passed");
		$display("------------------------");
		$finish;
	end

endmodule
