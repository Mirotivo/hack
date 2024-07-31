# vm_translator/vm_translator.py
import os
import io
from vm_translator.vm_parser import VMParser
from vm_translator.vm_code_emitter import VMCodeEmitter
from vm_translator.vm_constants import *

class VMTranslator:

    def __init__(self, filepath) -> None:
        self.filepath = filepath

    @staticmethod
    def parse_filename(file):
        filename, ext = os.path.splitext(file)
        return filename, ext.lstrip('.')

    def translate(self) -> str:   
        output = io.StringIO()
        filename, ext = self.parse_filename(self.filepath)
        if not (filename or filename[0].isupper() or ext != 'vm'):
            print(f'Invalid filename format: {filename}.{ext}')
            exit(1)
        parser = VMParser(self.filepath)
        writer = VMCodeEmitter(output)
        writer.set_filename(filename)
        while parser.advance():
            cmd_type = parser.command_type()
            if cmd_type == C_ARITHMETIC:
                writer.write_arithmetic(parser.current_command)
            elif cmd_type == C_PUSH or cmd_type == C_POP:
                writer.write_push_pop(cmd_type, parser.arg1(), parser.arg2())
            elif cmd_type == C_LABEL:
                writer.write_label(parser.arg1())
            elif cmd_type == C_GOTO:
                writer.write_goto(parser.arg1())
            elif cmd_type == C_IF:
                writer.write_if(parser.arg1())
            elif cmd_type == C_FUNCTION:
                writer.write_function(parser.arg1(), parser.arg2())
            elif cmd_type == C_CALL:
                writer.write_call(parser.arg1(), parser.arg2())
            elif cmd_type == C_RETURN:
                writer.write_return()
        asm_code = output.getvalue()
        output.close()
        return asm_code
