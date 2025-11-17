# Hack Computer on FPGA Project

## Introduction
In this project, we will implement the HACK computer from the Nand2Tetris course on real hardware using the iCE40HX1K-EVB FPGA board from Olimex. An FPGA, or Field Programmable Gate Array, is a versatile chip that can be programmed to perform various logical operations. The iCE40HX1K FPGA contains 1280 logic cells (LC), which are basic building blocks capable of performing simple logic operations like AND, OR, and NOT.

The FPGA also includes 64Kbits of block RAM (BRAM) for temporary storage during computations. To configure the FPGA, we use a bitstream, a binary file stored in Serial Flash Memory (SFM), a non-volatile storage medium that retains data even when the power is off. For larger applications, we use additional SRAM (Static RAM), a type of volatile memory that provides fast access storage beyond the FPGA's internal BRAM.

To transfer the bitstream from your computer to the FPGA's serial flash memory, and to facilitate communication between the FPGA and your computer during development, we use a Programmer Board.

The instruction memory ROM of the HACK computer is limited to 256 words. To run larger programs written in JACK (e.g., Tetris), we will store the program in SRAM and use the SRAM memory chip as instruction memory. To achieve this, we need:

1. Bootloader Program: A bootloader program written in assembler, stored in the 256 words of ROM. This bootloader reads a larger HACK binary program previously stored on the SPI memory chip, starting at address 0x010000, and stores it in SRAM.
2. Multiplexer: A multiplexer that switches instruction memory from ROM to SRAM.

By implementing these components, we can expand the capabilities of the HACK computer and run more complex programs on the FPGA. After implementing the HACK computer architecture, the JackOS will be installed on the computer, enabling it to execute high-level applications written in JACK.


## Components and Setup

1. **FPGA Board: iCE40HX1K-EVB**
   - **FPGA Chip (iCE40HX1K):** This chip contains 1280 logic cells ("LC") and 64Kbits of block RAM ("BRAM"). The logic cells perform simple operations, while the block RAM provides temporary storage for data during computations.
   - **Serial Flash Memory (W25Q16BV):** This non-volatile memory stores the bitstream. At startup, the FPGA loads this bitstream to set up its logic cells.
   - **SRAM (256k x 16 bit):** This additional volatile memory is used for running larger applications that require more space than the FPGA's internal BRAM.
   - **LEDs and Buttons:** These are user-programmable components used for input and debugging, allowing you to interact with and test the FPGA configuration.
   - **GPIO Connector:** This connector allows the FPGA to interface with external devices, such as an LCD screen.

2. **LCD Screen: MOD-LCD2.8RTP**
   - **Display Output:** This screen allows you to see the results of your computations and interactions with the FPGA.

3. **Programmer Board: Olimexino-32u4**
   - **Bitstream Upload:** This board is used to transfer the bitstream from your computer to the FPGA's serial flash memory, configuring the FPGA for operation.
   - **UART Communication:** The programmer board also enables UART communication, facilitating runtime interaction between the FPGA and your computer.

   By integrating these components, we can create a functional HACK computer on an FPGA, capable of running larger and more complex programs beyond the limitations of its internal ROM. This setup will allow us to implement and run JackOS on the computer, enabling the execution of high-level applications written in JACK.





## Programming the FPGA

The chips of our HACK computer (ALU, CPU, Register, Memory, IO-Devices) are implemented in Verilog, a hardware description language.

1. **Write Verilog Code:** Create your FPGA design in Verilog. Verilog is a language used to describe hardware circuits. This will result in a `.v` file, such as `Hack.v`, which contains the code for your design.
2. **Synthesize with YoSYS:** Convert the Verilog code into an intermediate format called `Hack.blif` (Berkeley Logic Interchange Format). This process translates the high-level hardware descriptions into a network of logic gates (logic cells).
   ```sh
   yosys -p "synth_ice40 -top Hack -blif Hack.blif" Hack.v
   ```
   Synthesis is essential because it turns the abstract Verilog code into a concrete representation of the logic that will be implemented on the FPGA.
3. **Place and Route with nextpnr:**  Use the BLIF file (`Hack.blif`) and the pin configuration file (`Hack.pcf`) to map the synthesized logic cells onto the FPGA and determine the routing between them. This step generates an ASCII configuration file (`Hack.asc`).
   ```sh
   arachne-pnr -d 1k -P vq100 -o Hack.asc -p Hack.pcf Hack.blif
   nextpnr-ice40 --hx1k --pcf Hack.pcf --asc Hack.asc --blif Hack.blif
   ```
   Placement and routing involve assigning specific physical locations on the FPGA for each logic cell and creating the necessary connections between them.
4. **Generate Bitstream with icepack:** Convert the ASCII configuration file (`Hack.asc`) into a bitstream file (`Hack.bin`). The bitstream is a binary file that contains all the configuration data needed to program the FPGA.
   ```sh
    icepack Hack.asc Hack.bin
   ```
    The bitstream is a binary representation of the FPGA configuration, detailing how the logic cells are connected and what operations they perform.
5. **Upload Bitstream with iceprogduino:** Upload the bitstream (`Hack.bin`) to the FPGA’s serial flash memory. This step programs the FPGA with your design, configuring it to perform the specified operations.
   ```sh
    iceprogduino Hack.bin
   ```
    Uploading the bitstream configures the FPGA to operate according to your design, enabling it to carry out the functions described in your Verilog code.

## Setting Up the Platform IDE in VS Code

1. **Install the WSL**.
2. **Install Required Tools in WSL**:
   ```sh
   wsl
   sudo apt-get update                          # Update package list
   sudo apt-get install make                    # Build automation tool
   sudo apt-get install build-essential         # Essential build tools
   sudo apt-get install python3-pip             # Python package installer
   sudo apt-get install iverilog                # Verilog simulation tool
   sudo apt-get install gtkwave                 # Waveform viewer
   sudo apt-get install yosys                   # Verilog RTL synthesis tool
   sudo apt-get install arachne-pnr             # FPGA place-and-route tool
   ```
   ```sh
   git clone https://github.com/cliffordwolf/icestorm.git

   cd icestorm
   make -j$(nproc)
   sudo make install
   ```
   ```
   git clone https://github.com/OLIMEX/iCE40HX1K-EVB.git

   cd iCE40HX1K-EVB/programmer/iceprogduino
   make
   sudo make install
   ```

3. **Install PlatformIO**:
   ```sh
   platformio run
   platformio run --target upload
   ```
   http://docs.platformio.org/en/stable/installation.html



# ASM
A-Instruction @...| C-Instruction dest=comp;jump|
---|---|
0vvv vvvv vvvv vvvv| 111a cccc ccdd djjj

M=D ... //Write to memory
D=M ... //Read from memory

| a=0 | c5  | c4  | c3  | c2  | c1  | c0  | a=1 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0   | 1   | 0   | 1   | 0   | 1   | 0   |     |
| 1   | 1   | 1   | 1   | 1   | 1   | 1   |     |
| -1  | 1   | 1   | 1   | 0   | 1   | 0   |     |
| D   | 0   | 0   | 1   | 1   | 0   | 0   |     |
| A   | 1   | 1   | 0   | 0   | 0   | 0   | M   |
| !D  | 0   | 0   | 1   | 1   | 0   | 1   |     |
| !A  | 1   | 1   | 0   | 0   | 0   | 1   | !M  |
| -D  | 0   | 0   | 1   | 1   | 1   | 1   |     |
| -A  | 1   | 1   | 0   | 0   | 1   | 1   | -M  |
| D+1 | 0   | 1   | 1   | 1   | 1   | 1   |     |
| A+1 | 1   | 1   | 0   | 1   | 1   | 1   | M+1 |
| D-1 | 0   | 0   | 1   | 1   | 1   | 0   |     |
| A-1 | 1   | 1   | 0   | 0   | 1   | 0   | M-1 |
| D+A | 0   | 0   | 0   | 0   | 1   | 0   | D+M |
| D-A | 0   | 1   | 0   | 0   | 1   | 1   | D-M |
| A-D | 0   | 0   | 0   | 1   | 1   | 1   | M-D |
| D&A | 0   | 0   | 0   | 0   | 0   | 0   | D&M |
| D|A | 0   | 1   | 0   | 1   | 0   | 1   | D|M |

| d2  | d1  | d0  | destination |
| --- | --- | --- | ----------- |
| 0   | 0   | 0   | null        |
| 0   | 0   | 1   | M           |
| 0   | 1   | 0   | D           |
| 0   | 1   | 1   | MD          |
| 1   | 0   | 0   | A           |
| 1   | 0   | 1   | AM          |
| 1   | 1   | 0   | AD          |
| 1   | 1   | 1   | AMD         |

|d-bit|location|
|---|---|
d1|A-register|
d2|D-register|
d3|Memory|

| j2  | j1  | j0  | effect           |
| --- | --- | --- | ---------------- |
| 0   | 0   | 0   | no jump          |
| 0   | 0   | 1   | jump if out > 0  |
| 0   | 1   | 0   | jump if out = 0  |
| 0   | 1   | 1   | jump if out >= 0 |
| 1   | 0   | 0   | jump if out < 0  |
| 1   | 0   | 1   | jump if out != 0 |
| 1   | 1   | 0   | jump if out <= 0 |
| 1   | 1   | 1   | jump             |

j3|j2|j1|Mnemonic
---|---|---|---
0|0|0|null
0|0|1|JGT
0|1|0|JEQ
0|1|1|JGE
1|0|0|JLT
1|0|1|JNE
1|1|0|JLE
1|1|1|JMP

move data between register, add or subtract, and move data from memory to registers or the other way around.
