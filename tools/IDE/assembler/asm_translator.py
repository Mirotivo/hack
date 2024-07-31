# assembler/asm_translator.py
import os
import io
from assembler.asm_parser import AsmParser
from assembler.asm_code_emitter import AsmSymbolTable, AsmCodeEmitter

class AsmTranslator():
    def __init__(self, filepath):
        self.filepath = filepath
        self.symbol_address = 16
        self.symbols_table = AsmSymbolTable()

    def _get_address(self, symbol):
        if symbol.isdigit():
            return symbol
        else:
            if not self.symbols_table.contains(symbol):
                self.symbols_table.add_entry(symbol, self.symbol_address)
                self.symbol_address += 1
            return self.symbols_table.get_address(symbol)

    def pass_1(self):
        parser = AsmParser(self.filepath)
        curr_address = 0
        while parser.has_more_instructions():
            parser.advance()
            inst_type = parser.instruction_type
            if inst_type in [parser.A_INSTRUCTION, parser.C_INSTRUCTION]:
                curr_address += 1
            elif inst_type == parser.L_INSTRUCTION:
                self.symbols_table.add_entry(parser.symbol, curr_address)

    def pass_2(self):
        hack_output = io.StringIO()
        hex_output = io.StringIO()
        parser = AsmParser(self.filepath)
        writer = AsmCodeEmitter()
        
        while parser.has_more_instructions():
            parser.advance()
            inst_type = parser.instruction_type
            assembly_instruction = parser.tokenizer.curr_instruction.strip().replace(" ", "")
            if inst_type == parser.A_INSTRUCTION:
                binary_code = writer.gen_a_instruction(self._get_address(parser.symbol))
            elif inst_type == parser.C_INSTRUCTION:
                binary_code = writer.gen_c_instruction(parser.dest, parser.comp, parser.jmp)
            elif inst_type == parser.L_INSTRUCTION:
                continue
            else:
                continue
            hack_output.write(binary_code + '\n')
            hex_output.write(f'{binary_code} {int(binary_code, 2):04X} {assembly_instruction}\n')
        
        hack_code = hack_output.getvalue()
        hack_output.close()
        hex_output.close()
        return hack_code

    def assemble(self):
        self.pass_1()
        return self.pass_2()
