# interfaces.py
from abc import ABC, abstractmethod

class ITokenizer(ABC):
    @abstractmethod
    def tokenize(self):
        pass

class IParser(ABC):
    @abstractmethod
    def parse(self):
        pass

class ITranslator(ABC):
    @abstractmethod
    def translate(self):
        pass

class ICodeEmitter(ABC):
    @abstractmethod
    def emit_code(self):
        pass
