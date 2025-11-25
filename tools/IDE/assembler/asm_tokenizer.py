"""
Assembler Tokenizer
Tokenizes Hack assembly language source code into tokens for parsing
"""

import re
from interfaces import ITokenizer


class AsmTokenizer(ITokenizer):
    """Tokenizer for Hack assembly language"""
    
    # Token type constants
    NUMBER = 1
    SYMBOL = 2
    OPERATION = 3
    ERROR = 4

    # Regex patterns
    _number_re = r'\d+'
    _symbol_start_re = r'\w_.$:'
    _symbol_re = '[' + _symbol_start_re + '][' + _symbol_start_re + r'\d]*'
    _operation_re = r'[=;()@+\-&|!]'
    _word = re.compile(_number_re + '|' + _symbol_re + '|' + _operation_re)
    _comment = re.compile('//.*$')

    def __init__(self, asm_file_name):
        """
        Initialize tokenizer with assembly file
        
        Args:
            asm_file_name: Path to assembly source file
        """
        with open(asm_file_name, 'r') as file:
            self._lines = file.read()
        self._tokens = self.tokenize(self._lines.split('\n'))
        self.curr_instr_tokens = []
        self.curr_token = (self.ERROR, 0)
        self.curr_instruction = ''

    def _is_operation(self, word):
        """Check if word is an operation symbol"""
        return re.match(self._operation_re, word) is not None

    def _is_number(self, word):
        """Check if word is a number"""
        return re.match(self._number_re, word) is not None

    def _is_symbol(self, word):
        """Check if word is a symbol"""
        return re.match(self._symbol_re, word) is not None

    def tokenize(self, lines):
        """
        Tokenize all lines
        
        Args:
            lines: List of source code lines
            
        Returns:
            List of tokenized instructions
        """
        return [t for t in [self._tokenize_line(l) for l in lines] if t]

    def _tokenize_line(self, line):
        """Tokenize a single line"""
        return [self._token(word) for word in self._split(self._remove_comment(line))]

    def _remove_comment(self, line):
        """Remove comments from line"""
        return self._comment.sub('', line)

    def _split(self, line):
        """Split line into words"""
        return self._word.findall(line)

    def _token(self, word):
        """
        Create token from word
        
        Args:
            word: Word to tokenize
            
        Returns:
            Tuple of (token_type, word)
        """
        if self._is_number(word):
            return self.NUMBER, word
        elif self._is_symbol(word):
            return self.SYMBOL, word
        elif self._is_operation(word):
            return self.OPERATION, word
        else:
            return self.ERROR, word

    def has_more_instructions(self):
        """Check if there are more instructions to process"""
        return bool(self._tokens)

    def next_instruction(self):
        """
        Advance to next instruction
        
        Returns:
            List of tokens for the instruction
        """
        self.curr_instr_tokens = self._tokens.pop(0)
        self.curr_instruction = ' '.join(token[1] for token in self.curr_instr_tokens)
        self.next_token()
        return self.curr_instr_tokens

    def has_next_token(self):
        """Check if there are more tokens in current instruction"""
        return bool(self.curr_instr_tokens)

    def next_token(self):
        """
        Advance to next token
        
        Returns:
            Current token tuple (type, value)
        """
        if self.has_next_token():
            self.curr_token = self.curr_instr_tokens.pop(0)
        else:
            self.curr_token = (self.ERROR, 0)
        return self.curr_token

    def peek_token(self):
        """
        Peek at next token without advancing
        
        Returns:
            Next token tuple (type, value)
        """
        if self.has_next_token():
            return self.curr_instr_tokens[0]
        else:
            return (self.ERROR, 0)
