# assembler/asm_tokenizer.py
import re
from interfaces import ITokenizer

class AsmTokenizer(ITokenizer):
    # Constants and regex patterns
    NUMBER = 1
    SYMBOL = 2
    OPERATION = 3
    ERROR = 4

    _number_re = r'\d+'
    _symbol_start_re = r'\w_.$:'
    _symbol_re = '[' + _symbol_start_re + '][' + _symbol_start_re + r'\d]*'
    _operation_re = r'[=;()@+\-&|!]'
    _word = re.compile(_number_re + '|' + _symbol_re + '|' + _operation_re)
    _comment = re.compile('//.*$')

    def __init__(self, asm_file_name):
        with open(asm_file_name, 'r') as file:
            self._lines = file.read()
        self._tokens = self.tokenize(self._lines.split('\n'))
        self.curr_instr_tokens = []
        self.curr_token = (self.ERROR, 0)
        self.curr_instruction = ''

    def _is_operation(self, word):
        return re.match(self._operation_re, word) is not None

    def _is_number(self, word):
        return re.match(self._number_re, word) is not None

    def _is_symbol(self, word):
        return re.match(self._symbol_re, word) is not None

    def tokenize(self, lines):
        return [t for t in [self._tokenize_line(l) for l in lines] if t]

    def _tokenize_line(self, line):
        return [self._token(word) for word in self._split(self._remove_comment(line))]

    def _remove_comment(self, line):
        return self._comment.sub('', line)

    def _split(self, line):
        return self._word.findall(line)

    def _token(self, word):
        if self._is_number(word):
            return self.NUMBER, word
        elif self._is_symbol(word):
            return self.SYMBOL, word
        elif self._is_operation(word):
            return self.OPERATION, word
        else:
            return self.ERROR, word

    def has_more_instructions(self):
        return bool(self._tokens)

    def next_instruction(self):
        self.curr_instr_tokens = self._tokens.pop(0)
        self.curr_instruction = ' '.join(token[1] for token in self.curr_instr_tokens)
        self.next_token()
        return self.curr_instr_tokens

    def has_next_token(self):
        return bool(self.curr_instr_tokens)

    def next_token(self):
        if self.has_next_token():
            self.curr_token = self.curr_instr_tokens.pop(0)
        else:
            self.curr_token = (self.ERROR, 0)
        return self.curr_token

    def peek_token(self):
        if self.has_next_token():
            return self.curr_instr_tokens[0]
        else:
            return (self.ERROR, 0)
