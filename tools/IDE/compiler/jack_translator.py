"""
Jack Compiler Translator
Translates Jack high-level language to VM code
"""

import io
from compiler.jack_tokenizer import JackTokenizer
from compiler.jack_code_emitter import JackCodeEmitter
from compiler.jack_parser import Class
import os


class JackTranslator:
    """Translator for Jack language to VM code"""
    
    def __init__(self, filepath):
        """
        Initialize translator with Jack source file
        
        Args:
            filepath: Path to Jack source file
        """
        self.filepath = filepath

    def compile(self):
        """
        Compile Jack code to VM code
        
        Returns:
            VM code as string
        """
        output = io.StringIO()
        tokenizer = JackTokenizer(self.filepath)
        writer = JackCodeEmitter(output)

        # Parse and compile all classes
        while tokenizer.hasMoreTokens():
            if tokenizer.peekNextToken().string != 'class':
                return print('ERROR!!!!! non-class root token [' + tokenizer.getToken().string + '->' + tokenizer.peekNextToken().string + ']')
            Class(writer, tokenizer)

        vm_code = output.getvalue()
        output.close()
        return vm_code
