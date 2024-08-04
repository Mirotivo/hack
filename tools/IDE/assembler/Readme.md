
# Assembler Grammar for nand2tetris

## Lexical Elements

### Identifiers
- **Identifiers**: Used to name variables, labels, and symbols.
  - **Syntax**: `[a-zA-Z_.$:][a-zA-Z0-9_.$:]*`
  - **Examples**: `LOOP`, `i`, `sum`

### Integer Constants
- **Integer Constants**: Non-negative integers.
  - **Syntax**: `[0-9]+`
  - **Examples**: `0`, `123`, `999`

### Symbols
- **Symbols**: Predefined symbols representing specific memory locations.
  - **Examples**: `SP`, `LCL`, `ARG`, `THIS`, `THAT`, `R0`-`R15`, `SCREEN`, `KBD`

## Program Structure

### Instruction Types
- **Instruction Types**: The assembly language consists of two types of instructions: A-instructions and C-instructions.

### A-Instruction
- **A-Instruction**: Sets the A register to a specific value.
  - **Syntax**: `'@' (identifier | integerConstant)`
  - **Examples**: `@2`, `@LOOP`

### C-Instruction
- **C-Instruction**: Computes a value and stores it in a destination.
  - **Syntax**: `dest '=' comp ';' jump`
  - **Components**:
    - **Destination (`dest`)**: Specifies where to store the computed value.
    - **Computation (`comp`)**: Specifies the computation to perform.
    - **Jump (`jump`)**: Specifies the jump condition.

## Detailed Syntax Definitions

### A-Instruction Syntax
```bnf
<a-instruction> ::= '@' <identifier>
                 | '@' <integer-constant>
```

### C-Instruction Syntax
```bnf
<c-instruction> ::= [<dest> '='] <comp> [';' <jump>]

<dest> ::= 'null'
         | 'M'
         | 'D'
         | 'MD'
         | 'A'
         | 'AM'
         | 'AD'
         | 'AMD'

<comp> ::= '0'
         | '1'
         | '-1'
         | 'D'
         | 'A'
         | '!D'
         | '!A'
         | '-D'
         | '-A'
         | 'D+1'
         | 'A+1'
         | 'D-1'
         | 'A-1'
         | 'D+A'
         | 'D-A'
         | 'A-D'
         | 'D&A'
         | 'D|A'
         | 'M'
         | '!M'
         | '-M'
         | 'M+1'
         | 'M-1'
         | 'D+M'
         | 'D-M'
         | 'M-D'
         | 'D&M'
         | 'D|M'

<jump> ::= 'null'
         | 'JGT'
         | 'JEQ'
         | 'JGE'
         | 'JLT'
         | 'JNE'
         | 'JLE'
         | 'JMP'
```

## Program Flow

### Labels
- **Labels**: Used to define destinations for jumps in the code.
  - **Syntax**: `'(' identifier ')'`
  - **Examples**: `(LOOP)`

### Comments and Whitespace
- **Comments**: Ignored by the assembler; used for annotation.
  - **Syntax**: `'//'` followed by any text.
  - **Examples**: `// This is a comment`
- **Whitespace**: Spaces, tabs, and newlines are ignored.

## Examples

### A-Instruction
- `@2`
- `@LOOP`

### C-Instruction
- `D=A`
- `M=D+1`
- `0;JMP`

### Labels
- `(LOOP)`

### Complete Program Example
```assembly
// This is a simple program
@2
D=A
@3
D=D+A
@0
M=D
(LOOP)
@LOOP
0;JMP
```

This grammar specification outlines the structure and rules for writing assembly code in the nand2tetris course. It covers the various instruction types and provides detailed syntax for each, along with examples for clarity.
