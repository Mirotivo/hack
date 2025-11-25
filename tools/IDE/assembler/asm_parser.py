"""
Assembler Parser
Parses tokenized Hack assembly code and identifies instruction types
"""

from interfaces import IParser
from assembler.asm_tokenizer import AsmTokenizer


class AsmParser(IParser):
    """Parser for Hack assembly language"""
    
    # Instruction type constants
    A_INSTRUCTION = 0
    C_INSTRUCTION = 1
    L_INSTRUCTION = 2

    def __init__(self, file):
        """
        Initialize parser with assembly file
        
        Args:
            file: Path to assembly source file
        """
        self.tokenizer = AsmTokenizer(file)
        self._init_instruction_info()

    def _init_instruction_info(self):
        """Initialize instruction information fields"""
        self._instruction_type = -1
        self._symbol = ''
        self._dest = ''
        self._comp = ''
        self._jmp = ''

    def _a_instruction(self):
        """Parse A-instruction (@value)"""
        self._instruction_type = self.A_INSTRUCTION
        _, self._symbol = self.tokenizer.next_token()

    def _l_instruction(self):
        """Parse L-instruction (label)"""
        self._instruction_type = self.L_INSTRUCTION
        _, self._symbol = self.tokenizer.next_token()

    def _c_instruction(self, token, value):
        """Parse C-instruction (dest=comp;jump)"""
        self._instruction_type = self.C_INSTRUCTION
        comp_tok, comp_val = self._get_dest(token, value)
        self._get_comp(comp_tok, comp_val)
        self._get_jump()

    def _get_dest(self, token, value):
        """Extract destination field"""
        tok2, val2 = self.tokenizer.peek_token()
        if tok2 == AsmTokenizer.OPERATION and val2 == '=':
            self.tokenizer.next_token()
            self._dest = value
            comp_tok, comp_val = self.tokenizer.next_token()
        else:
            comp_tok, comp_val = token, value
        return comp_tok, comp_val

    def _get_comp(self, token, value):
        """Extract computation field"""
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
        """Extract jump field"""
        token, value = self.tokenizer.next_token()
        if token == AsmTokenizer.OPERATION and value == ';':
            _, self._jmp = self.tokenizer.next_token()

    @property
    def instruction_type(self):
        """Get current instruction type"""
        return self._instruction_type

    @property
    def symbol(self):
        """Get symbol from A or L instruction"""
        return self._symbol

    @property
    def dest(self):
        """Get destination field from C instruction"""
        return self._dest

    @property
    def comp(self):
        """Get computation field from C instruction"""
        return self._comp

    @property
    def jmp(self):
        """Get jump field from C instruction"""
        return self._jmp

    def has_more_instructions(self):
        """Check if there are more instructions"""
        return self.tokenizer.has_more_instructions()

    def advance(self):
        """Advance to next instruction and parse it"""
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
        """Parse all instructions"""
        while self.has_more_instructions():
            self.advance()
