# assembler/asm_parser.py
from interfaces import IParser
from assembler.asm_tokenizer import AsmTokenizer

class AsmParser(IParser):
    A_INSTRUCTION = 0
    C_INSTRUCTION = 1
    L_INSTRUCTION = 2

    def __init__(self, file):
        self.tokenizer = AsmTokenizer(file)
        self._init_instruction_info()

    def _init_instruction_info(self):
        self._instruction_type = -1
        self._symbol = ''
        self._dest = ''
        self._comp = ''
        self._jmp = ''

    def _a_instruction(self):
        self._instruction_type = self.A_INSTRUCTION
        _, self._symbol = self.tokenizer.next_token()

    def _l_instruction(self):
        self._instruction_type = self.L_INSTRUCTION
        _, self._symbol = self.tokenizer.next_token()

    def _c_instruction(self, token, value):
        self._instruction_type = self.C_INSTRUCTION
        comp_tok, comp_val = self._get_dest(token, value)
        self._get_comp(comp_tok, comp_val)
        self._get_jump()

    def _get_dest(self, token, value):
        tok2, val2 = self.tokenizer.peek_token()
        if tok2 == AsmTokenizer.OPERATION and val2 == '=':
            self.tokenizer.next_token()
            self._dest = value
            comp_tok, comp_val = self.tokenizer.next_token()
        else:
            comp_tok, comp_val = token, value
        return comp_tok, comp_val

    def _get_comp(self, token, value):
        if token == AsmTokenizer.OPERATION and (value == '-' or value == '!'):
            _, val2 = self.tokenizer.next_token()
            self._comp = value + val2
        elif token in (AsmTokenizer.NUMBER, AsmTokenizer.SYMBOL):
            self._comp = value
            tok2, val2 = self.tokenizer.peek_token()
            if tok2 == AsmTokenizer.OPERATION and val2 != ';':
                self.tokenizer.next_token()
                _, val3 = self.tokenizer.next_token()
                self._comp += val2 + val3

    def _get_jump(self):
        token, value = self.tokenizer.next_token()
        if token == AsmTokenizer.OPERATION and value == ';':
            _, self._jmp = self.tokenizer.next_token()

    @property
    def instruction_type(self):
        return self._instruction_type

    @property
    def symbol(self):
        return self._symbol

    @property
    def dest(self):
        return self._dest

    @property
    def comp(self):
        return self._comp

    @property
    def jmp(self):
        return self._jmp

    def has_more_instructions(self):
        return self.tokenizer.has_more_instructions()

    def advance(self):
        self._init_instruction_info()
        self.tokenizer.next_instruction()
        token, val = self.tokenizer.curr_token
        if token == AsmTokenizer.OPERATION and val == '@':
            self._a_instruction()
        elif token == AsmTokenizer.OPERATION and val == '(':
            self._l_instruction()
        else:
            self._c_instruction(token, val)

    def parse(self):
        while self.has_more_instructions():
            self.advance()
