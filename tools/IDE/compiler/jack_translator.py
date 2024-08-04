# compiler/jack_translator.py
import io
from compiler.jack_tokenizer import JackTokenizer
from compiler.jack_code_emitter import JackCodeEmitter
from compiler.jack_parser import Class
import os

class JackTranslator:
    def __init__(self, filepath) -> None:
        self.filepath = filepath

    def compile(self) -> str:
        output = io.StringIO()
        tokenizer = JackTokenizer(self.filepath)
        writer = JackCodeEmitter(output)

        # # Tokenizer
        # while tokenizer.hasMoreTokens():
        #     tokenizer.advance()
        #     print(tokenizer.getToken().string, tokenizer.getToken().kind, tokenizer.getToken().keyWord)

        while tokenizer.hasMoreTokens():
            if tokenizer.peekNextToken().string != 'class':
                return print('ERROR!!!!! non-class root token [' + tokenizer.getToken().string + '->' + tokenizer.peekNextToken().string + ']')
            Class(writer, tokenizer)

        vm_code = output.getvalue()
        output.close()
        return vm_code
