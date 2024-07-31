# commands.py
from abc import ABC, abstractmethod
from factory import ToolFactory

class Command(ABC):
    @abstractmethod
    def execute(self, input_data):
        pass

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
