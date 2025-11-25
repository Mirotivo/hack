// Blue Screen Test - Full 240x320 display with nested loops
// LCD_DATA=2053 (0x0805), LCD_CMD=2054 (0x0806), LCD_STATUS=2055 (0x0807)

// Wait for LCD ready
(WAIT_READY)
    @2055
    D=M
    @1
    D=D&A
    @WAIT_READY
    D;JEQ

// CMD: CASET (0x2A = 42)
@42
D=A
@2054
M=D

// DATA: Column 0-239 (0x00, 0x00, 0x00, 0xEF)
@2053
M=0
@2053
M=0
@2053
M=0
@239                    // 0xEF
D=A
@2053
M=D

// CMD: PASET (0x2B = 43)
@43
D=A
@2054
M=D

// DATA: Row 0-319 (0x00, 0x00, 0x01, 0x3F)
@2053
M=0
@2053
M=0
@2053
M=1
@63                     // 0x3F (0x013F = 319)
D=A
@2053
M=D

// CMD: RAMWR (0x2C = 44)
@44
D=A
@2054
M=D

// Nested loop: 300×256 = 76800 pixels (within 15-bit limit)
@300                    // Outer counter
D=A
@R1
M=D

(OUTER_LOOP)
    @256                // Inner counter
    D=A
    @R0
    M=D
    
    (INNER_LOOP)
        @2053       // DATA: high byte (0x00)
        M=0
        @31         // DATA: low byte (0x1F) - RGB565 blue
        D=A
        @2053
        M=D
        
        @R0
        M=M-1
        D=M
        @INNER_LOOP
        D;JGT
    
    @R1
    M=M-1
    D=M
    @OUTER_LOOP
    D;JGT

(END)
    @END
    0;JMP
