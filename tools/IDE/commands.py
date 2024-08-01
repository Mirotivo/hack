# commands.py
from abc import ABC, abstractmethod
from compiler.jack_translator import JackTranslator
from vm_translator.vm_translator import VMTranslator
from assembler.asm_translator import AsmTranslator

class Command(ABC):
    @abstractmethod
    def execute(self, input_data):
        pass

class ToolFactory:
    @staticmethod
    def create_tool(tool_type, input_file):
        if tool_type == "compile":
            return JackTranslator(input_file)
        elif tool_type == "translate":
            return VMTranslator(input_file)
        elif tool_type == "assemble":
            return AsmTranslator(input_file)
        else:
            raise ValueError("Unknown tool type")

class CompileCommand(Command):
    def execute(self, input_data):
        compiler = ToolFactory.create_tool("compile", input_data)
        return compiler.compile()

class TranslateCommand(Command):
    def execute(self, input_data):
        translator = ToolFactory.create_tool("translate", input_data)
        return translator.translate()

class AssembleCommand(Command):
    def execute(self, input_data):
        assembler = ToolFactory.create_tool("assemble", input_data)
        return assembler.assemble()
