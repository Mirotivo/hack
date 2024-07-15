`include "../designs/Test_Computer/Hack.v"
`timescale 1ns / 1ps

module Hack_tb;
    // Inputs
    reg CLK_100MHz;
    reg [1:0] BUT;
    reg UART_RX;
    reg SPI_SDI;

    // Outputs
    wire [1:0] LED;
    wire UART_TX;
    wire SPI_SDO;
    wire SPI_SCK;
    wire SPI_CSX;

    // Internal signals
    wire CLK_CPU;
    wire [15:0] pc;
    wire [15:0] a_out;
    wire loadM;
    wire [15:0] inM;
    wire [15:0] instruction;
    wire [15:0] outM;
    wire [15:0] addressM;


    // Instantiate the Hack module
    Hack uut (
        .CLK_100MHz(CLK_100MHz),
        .BUT(BUT),
        .LED(LED),
        .UART_RX(UART_RX),
        .UART_TX(UART_TX),
        .SPI_SDO(SPI_SDO),
        .SPI_SDI(SPI_SDI),
        .SPI_SCK(SPI_SCK),
        .SPI_CSX(SPI_CSX)
    );

    // Connect internal signals
    assign CLK_CPU = uut.CPU.CLK_CPU;
    assign pc = uut.CPU.pc;
    assign a_out = uut.CPU.a_out;
    assign loadM = uut.CPU.loadM;
    assign inM = uut.CPU.inM;
    assign instruction = uut.CPU.instruction;
    assign outM = uut.CPU.outM;
    assign addressM = uut.CPU.addressM;

    // Clock generation
    initial CLK_100MHz = 0;
    always #5 CLK_100MHz = ~CLK_100MHz; // 100 MHz clock

    initial begin
        // Initialize Inputs
        CLK_100MHz = 0;
        BUT = 2'b10;
        UART_RX = 1;
        SPI_SDI = 0;

        // VCD dump file generation
        $dumpfile("hack_tb.vcd");
        $dumpvars(0, Hack_tb);

        // Wait for one clock cycle
        #10;
        BUT = 2'b11;

        #200000000; // 200,000,000 ns
        
        // End the simulation
        $finish;
    end

    // File descriptor for logging
    integer logfile;
    initial begin
        logfile = $fopen("hack_tb.log", "w");
    end

    // Positive clock cycle counter
    integer pos_clk_count = 0;

    // Variables to store previous states
    reg [1:0] prev_LED;
    reg prev_UART_RX;
    reg prev_UART_TX;
    reg prev_SPI_SDO;
    reg prev_SPI_SDI;
    reg prev_SPI_SCK;
    reg prev_SPI_CSX;

    // Initial values for previous states
    initial begin
        prev_LED = 2'b00;
        prev_UART_RX = 1'b0;
        prev_UART_TX = 1'b0;
        prev_SPI_SDO = 1'b0;
        prev_SPI_SDI = 1'b0;
        prev_SPI_SCK = 1'b0;
        prev_SPI_CSX = 1'b0;
    end

    // Monitor the outputs and log changes
    always @(posedge CLK_100MHz) begin
        $fdisplay(logfile, "Time = %dns: LED[RxReady,TxBusy] = %b, UART[RX,TX] = %b%b, SPI[SDO,SDI,SCK,CSX] = %b%b%b%b", 
            $time, LED, UART_RX, UART_TX, SPI_SDO, SPI_SDI, SPI_SCK, SPI_CSX);
        if (LED !== prev_LED || UART_RX !== prev_UART_RX || UART_TX !== prev_UART_TX || SPI_SDO !== prev_SPI_SDO || SPI_SDI !== prev_SPI_SDI || SPI_SCK !== prev_SPI_SCK || SPI_CSX !== prev_SPI_CSX) begin
            $display("Time = %dns: LED[RxReady,TxBusy] = %b, UART[RX,TX] = %b%b, SPI[SDO,SDI,SCK,CSX] = %b%b%b%b", 
                      $time, LED, UART_RX, UART_TX, SPI_SDO, SPI_SDI, SPI_SCK, SPI_CSX);

            // Update previous states
            prev_LED = LED;
            prev_UART_RX = UART_RX;
            prev_UART_TX = UART_TX;
            prev_SPI_SDO = SPI_SDO;
            prev_SPI_SDI = SPI_SDI;
            prev_SPI_SCK = SPI_SCK;
            prev_SPI_CSX = SPI_CSX;
        end
    end

    reg [3:0] offset = 2;
    always @(posedge CLK_CPU) begin
        case (pc - offset)
            // 0: if (a_out !== 16'h0000 || outM !== 16'h0000 || addressM !== 16'h0000 || inM !== 16'h0000 || instruction !== 16'h0000 || loadM !== 1'b0) begin
            //     $display("Assertion failed at time %dns: Initial state not met", $time);
            // end
            0: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            1: if (uut.CPU.d_out !== 16'h0000) begin
                // D=M
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0000, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            2: if (a_out !== 16'h0001) begin
                // @LCL
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0001, Actual a_out = %h", pc - offset, a_out);
            end
            3: if (outM !== 16'h0000) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x0000, Actual outM = %h", pc - offset, outM);
            end
            4: if (a_out !== 16'h0803) begin
                // @2051
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0803, Actual a_out = %h", pc - offset, a_out);
            end
            5: if (uut.CPU.d_out !== 16'h0803) begin
                // D=A
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0803, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            6: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            7: if (outM !== 16'h0001) begin
                // M=M+1
                $display("Assertion failed at pc = %0d: Expected outM = 0x0001, Actual outM = %h", pc - offset, outM);
            end
            8: if (a_out !== 16'h0000) begin
                // A=M-1
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            9: if (outM !== 16'h0803) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x0803, Actual outM = %h", pc - offset, outM);
            end
            10: if (a_out !== 16'h0048) begin
                // @72
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0048, Actual a_out = %h", pc - offset, a_out);
            end
            11: if (uut.CPU.d_out !== 16'h0048) begin
                // D=A
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0048, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            12: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            13: if (outM !== 16'h0001) begin
                // M=M+1
                $display("Assertion failed at pc = %0d: Expected outM = 0x0001, Actual outM = %h", pc - offset, outM);
            end
            14: if (a_out !== 16'h0000) begin
                // A=M-1
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            15: if (outM !== 16'h0048) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x0048, Actual outM = %h", pc - offset, outM);
            end
            16: if (a_out !== 16'h003A) begin
                // @Mem.poke$ret.0
                $display("Assertion failed at pc = %0d: Expected a_out = 0x003A, Actual a_out = %h", pc - offset, a_out);
            end
            17: if (uut.CPU.d_out !== 16'h003A) begin
                // D=A
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x003A, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            18: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            19: if (outM !== 16'h0001) begin
                // M=M+1
                $display("Assertion failed at pc = %0d: Expected outM = 0x0001, Actual outM = %h", pc - offset, outM);
            end
            20: if (a_out !== 16'h0000) begin
                // A=M-1
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            21: if (outM !== 16'h003A) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x003A, Actual outM = %h", pc - offset, outM);
            end
            22: if (a_out !== 16'h0001) begin
                // @LCL
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0001, Actual a_out = %h", pc - offset, a_out);
            end
            23: if (uut.CPU.d_out !== 16'h0000) begin
                // D=M
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0000, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            24: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            25: if (outM !== 16'h0001) begin
                // M=M+1
                $display("Assertion failed at pc = %0d: Expected outM = 0x0001, Actual outM = %h", pc - offset, outM);
            end
            26: if (a_out !== 16'h0000) begin
                // A=M-1
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            27: if (outM !== 16'h0000) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x0000, Actual outM = %h", pc - offset, outM);
            end
            28: if (a_out !== 16'h0002) begin
                // @ARG
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0002, Actual a_out = %h", pc - offset, a_out);
            end
            29: if (uut.CPU.d_out !== 16'h0000) begin
                // D=M
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0000, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            30: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            31: if (outM !== 16'h0001) begin
                // M=M+1
                $display("Assertion failed at pc = %0d: Expected outM = 0x0001, Actual outM = %h", pc - offset, outM);
            end
            32: if (a_out !== 16'h0000) begin
                // A=M-1
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            33: if (outM !== 16'h0000) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x0000, Actual outM = %h", pc - offset, outM);
            end
            34: if (a_out !== 16'h0003) begin
                // @THIS
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0003, Actual a_out = %h", pc - offset, a_out);
            end
            35: if (uut.CPU.d_out !== 16'h0000) begin
                // D=M
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0000, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            36: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            37: if (outM !== 16'h0001) begin
                // M=M+1
                $display("Assertion failed at pc = %0d: Expected outM = 0x0001, Actual outM = %h", pc - offset, outM);
            end
            38: if (a_out !== 16'h0000) begin
                // A=M-1
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            39: if (outM !== 16'h0000) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x0000, Actual outM = %h", pc - offset, outM);
            end
            40: if (a_out !== 16'h0004) begin
                // @THAT
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0004, Actual a_out = %h", pc - offset, a_out);
            end
            41: if (uut.CPU.d_out !== 16'h0000) begin
                // D=M
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0000, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            42: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            43: if (outM !== 16'h0001) begin
                // M=M+1
                $display("Assertion failed at pc = %0d: Expected outM = 0x0001, Actual outM = %h", pc - offset, outM);
            end
            44: if (a_out !== 16'h0000) begin
                // A=M-1
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            45: if (outM !== 16'h0000) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x0000, Actual outM = %h", pc - offset, outM);
            end
            46: if (a_out !== 16'h0007) begin
                // @7
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0007, Actual a_out = %h", pc - offset, a_out);
            end
            47: if (uut.CPU.d_out !== 16'h0007) begin
                // D=A
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0007, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            48: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            49: if (uut.CPU.d_out !== 16'h0000) begin
                // D=M
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0000, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            50: if (uut.CPU.d_out !== 16'h0002) begin
                // D=M-D
                $display("Assertion failed at pc = %0d: Expected uut.CPU.d_out = 0x0002, Actual uut.CPU.d_out = %h", pc - offset, uut.CPU.d_out);
            end
            51: if (a_out !== 16'h0002) begin
                // @ARG
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0002, Actual a_out = %h", pc - offset, a_out);
            end
            52: if (outM !== 16'h0002) begin
                // M=D
                $display("Assertion failed at pc = %0d: Expected outM = 0x0002, Actual outM = %h", pc - offset, outM);
            end
            53: if (a_out !== 16'h0000) begin
                // @SP
                $display("Assertion failed at pc = %0d: Expected a_out = 0x0000, Actual a_out = %h", pc - offset, a_out);
            end
            default: ; // Do nothing for other values of pc
        endcase
    end

endmodule
