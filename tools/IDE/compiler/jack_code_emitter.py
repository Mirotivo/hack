"""
Jack Compiler Code Emitter
Generates VM code from parsed Jack language structures
Manages symbol tables for class and subroutine scopes
"""

from interfaces import ICodeEmitter


class SymbolTable:
    """Symbol table for managing variable declarations"""
    
    def __init__(self):
        """Initialize empty symbol table"""
        self.table = []
    
    def define(self, name, type, kind):
        """
        Define a new symbol in the table
        
        Args:
            name: Variable name
            type: Variable type
            kind: Variable kind (static, field, arg, var)
        """
        self.table.append({
            "name": name,
            "type": type,
            "kind": kind,
            "index": self.countByKind(kind),
        })
    
    def countByKind(self, kind):
        """
        Count variables of a specific kind
        
        Args:
            kind: Variable kind
            
        Returns:
            Number of variables of that kind
        """
        count = 0
        for row in self.table:
            if row["kind"] == kind:
                count += 1
        return count
    
    def kindOf(self, name):
        """Get kind of named variable"""
        row = self._getNamedRow(name)
        return row["kind"] if row != None else None
    
    def typeOf(self, name):
        """Get type of named variable"""
        row = self._getNamedRow(name)
        return row["type"] if row != None else None
    
    def indexdOf(self, name):
        """Get index of named variable"""
        row = self._getNamedRow(name)
        return row["index"] if row != None else None
    
    def _getNamedRow(self, name):
        """
        Get symbol table row by name
        
        Args:
            name: Variable name
            
        Returns:
            Symbol table entry or None
        """
        for row in self.table:
            if row["name"] == name:
                return row
        return None


class JackCodeEmitter(ICodeEmitter):
    """Emits VM code for Jack language constructs"""
    
    def __init__(self, file):
        """
        Initialize code emitter
        
        Args:
            file: Output file stream for VM code
        """
        self.file = file
        self.className = ''
        self.classScope = SymbolTable()
        self.subroutineScope = SymbolTable()
        self.uniqueCounter = 0

    def getUnique(self):
        """
        Get unique identifier for labels
        
        Returns:
            Unique integer counter
        """
        self.uniqueCounter += 1
        return self.uniqueCounter

    def getByName(self, name):
        """
        Get symbol by name from either scope
        
        Args:
            name: Variable name
            
        Returns:
            Symbol table entry or None
        """
        row = self.subroutineScope._getNamedRow(name)
        if row is None:
            row = self.classScope._getNamedRow(name)
        return row
    
    def writePush(self, segment, index):
        """Write VM push command"""
        self.file.write(f'push {segment} {index}\n')
    
    def writePop(self, segment, index):
        """Write VM pop command"""
        self.file.write(f'pop {segment} {index}\n')
    
    def writeArithmetic(self, command):
        """Write VM arithmetic/logical command"""
        self.file.write(f'{command}\n')
    
    def writeLabel(self, label):
        """Write VM label"""
        self.file.write(f'label {label}\n')
    
    def writeGoto(self, label):
        """Write VM goto command"""
        self.file.write(f'goto {label}\n')
    
    def writeIfGoto(self, label):
        """Write VM if-goto command"""
        self.file.write(f'if-goto {label}\n')
    
    def writeCall(self, name, argsCount):
        """
        Write VM call command
        
        Args:
            name: Function name
            argsCount: Number of arguments
        """
        self.file.write(f'call {name} {argsCount}\n')
    
    def writeFunction(self, name, localsCount):
        """
        Write VM function declaration
        
        Args:
            name: Function name
            localsCount: Number of local variables
        """
        self.file.write(f'function {name} {localsCount}\n')
    
    def writeReturn(self):
        """Write VM return command"""
        self.file.write('return\n')

    def emit_code(self, code):
        """
        Emit code (implements ICodeEmitter interface)
        
        Args:
            code: Code string to emit
        """
        self.file.write(f'{code}\n')
