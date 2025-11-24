// Blue Screen Test - Simplified for 50Hz CPU (20ms per instruction)
// CPU is now slower than LCD (10ms per byte), so NO busy-wait loops needed!
// LCD_DATA = 2053 (0x0805), LCD_CMD = 2054 (0x0806), LCD_STATUS = 2055 (0x0807)
// RGB565 Blue = 0x001F (5 bits blue, full intensity)

// Wait for LCD initialization (only needed at startup)
// This is the ONLY wait loop needed because init takes 150ms
(WAIT_READY)
    @2055               // LCD_STATUS address (0x0807)
    D=M
    @1                  // Mask for bit 0
    D=D&A               // Mask bit 0 (ready flag)
    @WAIT_READY
    D;JEQ               // Loop while not ready

// Send Column Address Set command (CASET = 0x2A)
@42                     // Command 0x2A (Column Address Set)
D=A
@2054                   // LCD_CMD address (0x0806)
M=D                     // CPU waits 20ms automatically (LCD needs 10ms)

// Column start MSB: 0x00
@2053                   // LCD_DATA address (0x0805)
M=0                     // 0x00 (MSB of start column) - auto-waits 20ms

// Column start LSB: 0x00
@2053                   // LCD_DATA address (0x0805)
M=0                     // 0x00 (LSB of start column = 0) - auto-waits 20ms

// Column end MSB: 0x00
@2053                   // LCD_DATA address (0x0805)
M=0                     // 0x00 (MSB of end column) - auto-waits 20ms

// Column end LSB: 0xEF (239 decimal)
@239                    // 0xEF (239 decimal, end column)
D=A
@2053                   // LCD_DATA address (0x0805)
M=D                     // auto-waits 20ms

// Send Page Address Set command (PASET = 0x2B)
@43                     // Command 0x2B (Page Address Set)
D=A
@2054                   // LCD_CMD address (0x0806)
M=D                     // auto-waits 20ms

// Page start MSB: 0x00
@2053                   // LCD_DATA address (0x0805)
M=0                     // 0x00 (MSB of start row) - auto-waits 20ms

// Page start LSB: 0x00
@2053                   // LCD_DATA address (0x0805)
M=0                     // 0x00 (LSB of start row = 0) - auto-waits 20ms

// Page end MSB: 0x01
@2053                   // LCD_DATA address (0x0805)
M=1                     // 0x01 (MSB of end row) - auto-waits 20ms

// Page end LSB: 0x3F (63 decimal)
@63                     // 0x3F (63 decimal, LSB of end row)
D=A
@2053                   // LCD_DATA address (0x0805)
M=D                     // Total rows = 0x013F = 319 - auto-waits 20ms

// Send Memory Write command (RAMWR = 0x2C)
@44                     // Command 0x2C (Memory Write)
D=A
@2054                   // LCD_CMD address (0x0806)
M=D                     // auto-waits 20ms

// Initialize pixel counter: 10000 pixels = 0x2710
@10000                  // 0x2710 (10000 decimal pixels)
D=A
@R0                     // Use R0 as counter
M=D

// Stream pixels - RGB565 blue color (0x001F)
// Each pixel = 2 bytes: high byte 0x00, low byte 0x1F
// NO WAIT LOOPS NEEDED! CPU is slow enough :)
(LOOP)
    // Send blue high byte: 0x00
    @2053               // LCD_DATA address (0x0805)
    M=0                 // 0x00 (high byte) - CPU waits 20ms automatically
    
    // Send blue low byte: 0x1F (31 decimal)
    @31                 // 0x1F (31 decimal, low byte of blue pixel)
    D=A
    @2053               // LCD_DATA address (0x0805)
    M=D                 // CPU waits 20ms automatically
    
    // Decrement counter
    @R0
    M=M-1
    D=M
    @LOOP
    D;JGT               // Continue if counter > 0

// Done - infinite loop
(END)
    @END
    0;JMP
