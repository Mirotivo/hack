	//System Init: Initialize VM, set SP=256
	@256
	D=A
	@SP
	M=D
	// //Function Call: Function Call Sys.init 0 Setup
	@Sys.init$ret.0
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@5
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@Sys.init	//Jump to function Sys.init
	0;JMP
(Sys.init$ret.0)
	// function Sys.init 1
(Sys.init)
	@SP
	D=M
	@LCL
	M=D
	@0
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	// //Function Call: Function Call UART.new 0 Setup
	@UART.new$ret.0
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@5
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.new	//Jump to function UART.new
	0;JMP
(UART.new$ret.0)
	// pop local[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@LCL	
	D=D+M	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[72]
	@72
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.0
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.0)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[101]
	@101
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.1
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.1)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[108]
	@108
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.2
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.2)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[108]
	@108
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.3
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.3)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[111]
	@111
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.4
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.4)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[32]
	@32
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.5
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.5)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[87]
	@87
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.6
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.6)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[111]
	@111
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.7
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.7)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[114]
	@114
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.8
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.8)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[108]
	@108
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.9
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.9)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[100]
	@100
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.10
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.10)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push local[0]
	@0	
	D=A	
	@LCL	
	A=D+M	
	D=M
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// push constant[33]
	@33
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// //Function Call: Function Call UART.writeChar 2 Setup
	@UART.writeChar$ret.11
	D=A
	@SP
	M=M+1
	A=M-1
	M=D
	//Function Call: Save Caller State
	@LCL
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push LCL
	@ARG
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push ARG
	@THIS
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THIS
	@THAT
	D=M
	@SP
	M=M+1	// Increment SP
	A=M-1
	M=D		// Push THAT
	//Function Call: Reposition ARG and LCL, then call function
	@7
	D=A
	@SP
	D=M-D	// ARG = SP - 5 - n_args
	@ARG
	M=D		// Reposition ARG
	@SP
	D=M
	@LCL
	M=D		// Reposition LCL
	@UART.writeChar	//Jump to function UART.writeChar
	0;JMP
(UART.writeChar$ret.11)
	// pop temp[0]
	@SP	
	M=M-1	
	A=M	
	D=M
	@R13	
	M=D	
	@0	
	D=A	
	@5	
	D=D+A	
	@R14	
	M=D	
	@R13	
	D=M	
	@R14	
	A=M	
	M=D
	// push constant[0]
	@0
	D=A
	@SP	
	M=M+1	
	A=M-1	
	M=D
	// return
	@LCL
	D=M
	@R13
	M=D
	@5
	A=D-A
	D=M
	@R14
	M=D
	@SP
	A=M-1
	D=M
	@ARG
	A=M
	M=D
	D=A+1
	@SP
	M=D
	@R13
	AM=M-1
	D=M
	@THAT
	M=D
	@R13
	AM=M-1
	D=M
	@THIS
	M=D
	@R13
	AM=M-1
	D=M
	@ARG
	M=D
	@R13
	AM=M-1
	D=M
	@LCL
	M=D
	@R14
	A=M
	0;JMP
