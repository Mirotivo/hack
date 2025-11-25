"""
Nand2Tetris IDE - Command Pattern Implementation
Defines abstract Command interface and concrete command implementations
for compile, translate, and assemble operations
"""

from abc import ABC, abstractmethod
from compiler.jack_translator import JackTranslator
from vm_translator.vm_translator import VMTranslator
from assembler.asm_translator import AsmTranslator


class Command(ABC):
    """Abstract base class for command pattern"""
    
    @abstractmethod
    def execute(self, input_data):
        """
        Execute the command with given input data
        
        Args:
            input_data: Input file or data to process
            
        Returns:
            Processed output
        """
        pass


class ToolFactory:
    """Factory class for creating translator/compiler/assembler instances"""
    
    @staticmethod
    def create_tool(tool_type, input_file):
        """
        Create appropriate tool instance based on type
        
        Args:
            tool_type: Type of tool ("compile", "translate", "assemble")
            input_file: Input file path
            
        Returns:
            Tool instance
            
        Raises:
            ValueError: If tool_type is unknown
        """
        if tool_type == "compile":
            return JackTranslator(input_file)
        elif tool_type == "translate":
            return VMTranslator(input_file)
        elif tool_type == "assemble":
            return AsmTranslator(input_file)
        else:
            raise ValueError("Unknown tool type")


class CompileCommand(Command):
    """Command for compiling Jack to VM code"""
    
    def execute(self, input_data):
        """Execute compilation"""
        compiler = ToolFactory.create_tool("compile", input_data)
        return compiler.compile()


class TranslateCommand(Command):
    """Command for translating VM code to assembly"""
    
    def execute(self, input_data):
        """Execute translation"""
        translator = ToolFactory.create_tool("translate", input_data)
        return translator.translate()


class AssembleCommand(Command):
    """Command for assembling assembly code to machine code"""
    
    def execute(self, input_data):
        """Execute assembly"""
        assembler = ToolFactory.create_tool("assemble", input_data)
        return assembler.assemble()
