(START)
    D=0
    @ADDR_UART_RX
    M=1
    M=0

(RECEIVE)
    @ADDR_UART_RX
    D=M
    @RECEIVE
    D;JEQ

(STORECACHE)
    @200
    M=D

(TRANSMIT_BUSY)
    D=0
    @ADDR_UART_TX
    D=M
    @TRANSMIT_BUSY
    D;JNE

(LOADCACHE)
    @200
    D=M

(TRANSMIT)
    @ADDR_UART_TX
    M=D

(END)
	@RECEIVE
	0;JMP