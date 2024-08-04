# Lexical Elements

### Identifiers
- **Identifiers**: Used to name classes, subroutines, and variables.
  - **Syntax**: `[a-zA-Z_][a-zA-Z0-9_]*`
  - **Examples**: `className`, `subroutineName`, `varName`

### Integer Constants
- **Integer Constants**: Non-negative integers.
  - **Syntax**: `[0-9]+`
  - **Examples**: `0`, `123`, `999`

### String Constants
- **String Constants**: Sequence of characters enclosed in double quotes.
  - **Syntax**: `'"' ([^"\n])* '"'`
  - **Examples**: `"hello"`, `"Jack and Jill"`

### Keywords
- **Keywords**: Reserved words in the language.
  - **Examples**: `'class'`, `'constructor'`, `'function'`, `'method'`, `'field'`, `'static'`, `'var'`, `'int'`, `'char'`, `'boolean'`, `'void'`, `'true'`, `'false'`, `'null'`, `'this'`, `'let'`, `'do'`, `'if'`, `'else'`, `'while'`, `'return'`

# Program Structure

### Class
- **Class Declaration**: Defines the structure of a class.
  - **Syntax**: `'class' className '{' classVarDec* subroutineDec* '}'`

### Class Variable Declaration
- **Class Variable Declaration**: Declares class-level variables.
  - **Syntax**: `('static' | 'field') type varName (',' varName)* ';'`

### Type
- **Type**: Specifies the data type.
  - **Syntax**: `'int' | 'char' | 'boolean' | className`

### Subroutine Declaration
- **Subroutine Declaration**: Defines constructors, functions, and methods.
  - **Syntax**: `('constructor' | 'function' | 'method') ('void' | type) subroutineName '(' parameterList ')' subroutineBody`

### Parameter List
- **Parameter List**: Lists parameters of a subroutine.
  - **Syntax**: `((type varName) (',' type varName)*)?`

### Subroutine Body
- **Subroutine Body**: Contains variable declarations and statements.
  - **Syntax**: `'{' varDec* statements '}'`

### Variable Declaration
- **Variable Declaration**: Declares local variables.
  - **Syntax**: `'var' type varName (',' varName)* ';'`

# Statements

### Statements
- **Statements**: A sequence of executable instructions.
  - **Syntax**: `statement*`

### Statement
- **Statement**: Different types of executable instructions.
  - **Syntax**: `letStatement | ifStatement | whileStatement | doStatement | returnStatement`

### Let Statement
- **Let Statement**: Assigns values to variables.
  - **Syntax**: `'let' varName ('[' expression ']')? '=' expression ';'`

### If Statement
- **If Statement**: Conditional execution of code blocks.
  - **Syntax**: `'if' '(' expression ')' '{' statements '}' ('else' '{' statements '}')?`

### While Statement
- **While Statement**: Repeats a block of code while a condition is true.
  - **Syntax**: `'while' '(' expression ')' '{' statements '}'`

### Do Statement
- **Do Statement**: Calls a subroutine.
  - **Syntax**: `'do' subroutineCall ';'`

### Return Statement
- **Return Statement**: Returns a value from a subroutine.
  - **Syntax**: `'return' expression? ';'`

# Expressions

### Expression
- **Expression**: A combination of terms and operators.
  - **Syntax**: `term (op term)*`

### Term
- **Term**: The basic building block of expressions.
  - **Syntax**: `integerConstant | stringConstant | keywordConstant | varName | varName '[' expression ']' | subroutineCall | '(' expression ')' | unaryOp term`

### Subroutine Call
- **Subroutine Call**: Invocation of a subroutine.
  - **Syntax**: `subroutineName '(' expressionList ')' | (className | varName) '.' subroutineName '(' expressionList ')'`

### Expression List
- **Expression List**: A list of expressions.
  - **Syntax**: `(expression (',' expression)*)?`

# Operators and Constants

### Operators
- **Operators**: Symbols that perform operations on terms.
  - **Syntax**: `'+' | '-' | '*' | '/' | '&' | '|' | '<' | '>' | '='`

### Unary Operators
- **Unary Operators**: Operators that operate on a single term.
  - **Syntax**: `'-' | '~'`

### Keyword Constants
- **Keyword Constants**: Special predefined constants.
  - **Syntax**: `'true' | 'false' | 'null' | 'this'`
