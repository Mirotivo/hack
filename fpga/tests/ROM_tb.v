`include "../modules/ROM.v"
`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module ROM_tb;

    integer file;

	reg[15:0] address = 0;
	wire[15:0] data;
	
	ROM ROM(
	    .address(address),
	    .data(data)
	  );

	task display;
    	#1 $fwrite(file, "| %1b | %1b |\n", address, data);
  	endtask
  	
  	initial begin
  		$dumpfile("ROM_tb.vcd");
  		$dumpvars(0, ROM_tb);
		file = $fopen("ROM.out","w");
    	$fwrite(file, "| address | data |\n");
		
		address=16'b0000000000000000;
		display();
  		
		address=16'b0000000000000001;
		display();
		
		address=16'b0000000000000010;
		display();
		
		address=16'b0000000000000011;
		display();
		$finish();	
	end

endmodule
