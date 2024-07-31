# vm_translator/vm_parser.py
from vm_translator.vm_constants import *

class VMParser:
    def __init__(self, filename):
        self.file = open(filename, 'r')
        self.current_command = ''

    def __del__(self):
        self.file.close()

    def advance(self):
        self.current_command = ''
        while char := self.file.read(1):
            if char == ' ':
                if not self.current_command:
                    continue
            elif char == '/':
                if self.current_command:
                    self._format_cmd()
                    return True
                self.file.readline()
                continue
            elif char == '\n':
                if self.current_command:
                    self._format_cmd()
                    return True
                continue
            self.current_command += char
        return False

    def _format_cmd(self):
        for i in range(len(self.current_command) - 1, 0, -1):
            if self.current_command[i] != ' ':
                return
            self.current_command = self.current_command[:i]

    def command_type(self):
        arithmetic_cmds = ['add', 'sub', 'neg', 'eq', 'gt', 'lt', 'and', 'or', 'not']
        if self.current_command in arithmetic_cmds:
            return C_ARITHMETIC
        if self.current_command.startswith('push'):
            return C_PUSH
        if self.current_command.startswith('pop'):
            return C_POP
        if self.current_command.startswith('label'):
            return C_LABEL
        if self.current_command.startswith('goto'):
            return C_GOTO
        if self.current_command.startswith('if-goto'):
            return C_IF
        if self.current_command.startswith('function'):
            return C_FUNCTION
        if self.current_command.startswith('call'):
            return C_CALL
        if self.current_command.startswith('return'):
            return C_RETURN

    def arg1(self):
        if self.command_type() == C_ARITHMETIC:
            return self.current_command
        return self._get_cmd_field(2)

    def arg2(self):
        return int(self._get_cmd_field(3))

    def _get_cmd_field(self, field_num):
        field_str = ''
        current_field = 0
        inside_field = False
        for char in self.current_command:
            if not inside_field and char != ' ':
                current_field += 1
                inside_field = True
            elif inside_field and char == ' ':
                inside_field = False
            if inside_field and current_field == field_num:
                field_str += char
        return field_str
