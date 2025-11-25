"""
Jack Compiler Tokenizer
Tokenizes Jack high-level language source code
"""


class Token:
    """Represents a single token in Jack language"""
    
    keyWords = {
        'class': 'class', 'constructor': 'constructor', 'function': 'function',
        'method': 'method', 'field': 'field', 'static': 'static', 'var': 'var',
        'int': 'int', 'char': 'char', 'boolean': 'boolean', 'void': 'void',
        'true': 'true', 'false': 'false', 'null': 'null', 'this': 'this',
        'let': 'let', 'do': 'do', 'if': 'if', 'else': 'else',
        'while': 'while', 'return': 'return'
    }
    
    kinds = {
        'symbol': 'symbol',
        'charConstant': 'charConstant',
        'stringConstant': 'stringConstant',
        'integerConstant': 'integerConstant',
        'keyword': 'keyword',
        'identifier': 'identifier'
    }
    
    def __init__(self, string, kind, keyWord=None):
        """
        Initialize token
        
        Args:
            string: Token string value
            kind: Token kind (from kinds dict)
            keyWord: Keyword type if applicable
        """
        assert kind == None or kind in self.kinds
        assert keyWord == None or keyWord in self.keyWords
        self.string = string
        self.kind = kind
        self.keyWord = keyWord


class JackTokenizer:
    """Tokenizer for Jack language"""
    
    symbols = '{[]}().,;+-*/&!|<>=~'
    keywords = [
        'class', 'constructor', 'function', 'method', 'field', 'static', 'var',
        'int', 'char', 'boolean', 'void', 'true', 'false', 'null', 'this',
        'let', 'do', 'if', 'else', 'while', 'return'
    ]

    def __init__(self, filename):
        """
        Initialize tokenizer with Jack source file
        
        Args:
            filename: Path to Jack source file
        """
        self.insideComment = False
        self.currentToken = None
        self.lastToken = None
        self.file = open(filename, 'r')
        self.line = ''
    
    def hasMoreTokens(self):
        """
        Check if there are more tokens
        
        Returns:
            True if more tokens exist
        """
        return self._getNextToken(False) is not None
    
    def advance(self):
        """
        Advance to next token
        
        Returns:
            Next token
        """
        assert self.hasMoreTokens(), 'no tokens left'
        self.lastToken = self.currentToken
        self.currentToken = self._getNextToken()
        return self.currentToken

    def getToken(self):
        """Get current token"""
        return self.currentToken
    
    def getLastToken(self):
        """Get previous token"""
        return self.lastToken
    
    def peekNextToken(self):
        """
        Peek at next token without advancing
        
        Returns:
            Next token
        """
        return self._getNextToken(False)

    def _getNextToken(self, writeChange=True):
        """
        Get next token from input
        
        Args:
            writeChange: Whether to advance position
            
        Returns:
            Next token or None
        """
        self.line = self._removeMeaningless(self.line)
        while self.line == '':
            line = self.file.readline()
            if line == '':
                return None
            self.line = self._removeMeaningless(line)
        
        token = None
        sCrop = None
        
        if self.line[0] in self.symbols:
            token = Token(self.line[0], Token.kinds['symbol'])
            sCrop = 1
        elif self.line[0] == '"':
            string = self.line.split('"')[1]
            token = Token(string, Token.kinds['stringConstant'])
            sCrop = len(string) + 2
        elif self.line[0] == "'":
            if len(self.line) > 2 and self.line[2] == "'":
                token = Token(self.line[:3], Token.kinds['charConstant'])
                sCrop = 3
            else:
                raise ValueError("Invalid char constant")
        else:
            nextword = self.line.split(' ')[0]
            first_symbol_idx = self._firstSymbolIndex(nextword)
            if first_symbol_idx < len(nextword):
                nextword = nextword[:first_symbol_idx]

            if nextword.isdigit():
                token = Token(nextword, Token.kinds['integerConstant'])
                sCrop = len(nextword)
            elif nextword in self.keywords:
                token = Token(nextword, Token.kinds['keyword'], Token.keyWords[nextword])
                sCrop = len(nextword)
            else:
                token = Token(nextword, Token.kinds['identifier'])
                sCrop = len(nextword)

        if writeChange:
            self.line = self.line[sCrop:]
        return token
    
    def _firstSymbolIndex(self, string):
        """
        Find index of first symbol in string
        
        Args:
            string: String to search
            
        Returns:
            Index of first symbol or length of string
        """
        index = len(string)
        for symbol in self.symbols:
            if symbol in string and string.index(symbol) < index:
                index = string.index(symbol)
        return index
    
    def _removeMeaningless(self, line):
        """
        Remove comments and whitespace from line
        
        Args:
            line: Source line
            
        Returns:
            Cleaned line
        """
        multyLineS = '/*'
        multyLineE = '*/'
        singleLineS = '//'
        line = line.replace('\n', '').replace('\t', '')
        
        if self.insideComment:
            if multyLineE not in line:
                line = ''
            else:
                line = line[line.index(multyLineE) + len(multyLineE):]
                self.insideComment = False
        
        while multyLineS in line:
            if multyLineE in line:
                self.insideComment = False
                line = line[:line.index(multyLineS)] + line[line.index(multyLineE) + len(multyLineE):]
            else:
                self.insideComment = True
                line = line[:line.index(multyLineS)]
        
        if singleLineS in line:
            line = line[:line.index('//')]
        
        while line != '' and line[0] == ' ':
            line = line[1:]
        
        return line
