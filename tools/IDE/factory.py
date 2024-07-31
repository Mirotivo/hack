# factory.py
from compiler.jack_translator import JackTranslator
from vm_translator.vm_translator import VMTranslator
from assembler.asm_translator import AsmTranslator

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
