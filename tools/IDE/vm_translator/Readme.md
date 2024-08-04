# VM Translator Grammar for nand2tetris

## Lexical Elements

### Identifiers
- **Identifiers**: Used to name variables, functions, and labels.
  - **Syntax**: `[a-zA-Z_][a-zA-Z0-9_]*`
  - **Examples**: `local`, `functionName`, `LOOP_START`

### Integer Constants
- **Integer Constants**: Non-negative integers.
  - **Syntax**: `[0-9]+`
  - **Examples**: `0`, `123`, `999`

## Program Structure

### Command Types
- **Command Types**: The VM language consists of three types of commands: arithmetic, memory access, and program flow.

### Arithmetic Commands
- **Arithmetic Commands**: Perform arithmetic and logical operations.
  - **Syntax**: `'add' | 'sub' | 'neg' | 'eq' | 'gt' | 'lt' | 'and' | 'or' | 'not'`
  - **Examples**: `add`, `sub`, `neg`

### Memory Access Commands
- **Memory Access Commands**: Manipulate the memory segments.
  - **Syntax**: `('push' | 'pop') segment index`
  - **Segment**: `argument | local | static | constant | this | that | pointer | temp`
  - **Index**: Integer constant
  - **Examples**: `push local 0`, `pop argument 2`

### Program Flow Commands
- **Program Flow Commands**: Control the flow of the program.
  - **Label Command**: Defines a label.
    - **Syntax**: `label labelName`
    - **Example**: `label LOOP_START`
  - **Goto Command**: Jumps to a label.
    - **Syntax**: `goto labelName`
    - **Example**: `goto LOOP_START`
  - **If-Goto Command**: Jumps to a label if the top of the stack is not zero.
    - **Syntax**: `if-goto labelName`
    - **Example**: `if-goto LOOP_END`

### Function Commands
- **Function Commands**: Define and call functions, and handle function return.
  - **Function Definition Command**: Defines a function.
    - **Syntax**: `function functionName nVars`
    - **Example**: `function SimpleFunction 2`
  - **Function Call Command**: Calls a function.
    - **Syntax**: `call functionName nArgs`
    - **Example**: `call Main.fibonacci 1`
  - **Function Return Command**: Returns from a function.
    - **Syntax**: `return`
    - **Example**: `return`
