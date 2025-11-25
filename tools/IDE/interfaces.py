"""
Nand2Tetris IDE - Interface Definitions
Defines abstract interfaces for tokenizer, parser, translator, and code emitter
"""

from abc import ABC, abstractmethod


class ITokenizer(ABC):
    """Abstract interface for tokenizers"""
    
    @abstractmethod
    def tokenize(self):
        """
        Tokenize the input source code
        
        Returns:
            List of tokens
        """
        pass


class IParser(ABC):
    """Abstract interface for parsers"""
    
    @abstractmethod
    def parse(self):
        """
        Parse the tokens into an abstract syntax tree or intermediate representation
        
        Returns:
            Parsed representation
        """
        pass


class ITranslator(ABC):
    """Abstract interface for translators"""
    
    @abstractmethod
    def translate(self):
        """
        Translate from one language/representation to another
        
        Returns:
            Translated output
        """
        pass


class ICodeEmitter(ABC):
    """Abstract interface for code emitters"""
    
    @abstractmethod
    def emit_code(self):
        """
        Emit the final code output
        
        Returns:
            Generated code as string
        """
        pass
