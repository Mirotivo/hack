"""
Jack Compiler Parser
Parses Jack language syntax and generates VM code through recursive descent parsing
Implements Jack language grammar with classes for each syntactic element
"""

from compiler.jack_tokenizer import JackTokenizer, Token
from compiler.jack_code_emitter import SymbolTable


class Class:
    """Parses Jack class declaration"""
    triggers = ['class']
    
    def __init__(self, writer, tokenizer):
        assert type(tokenizer) == JackTokenizer
        writer.classScope = SymbolTable()
        tokenizer.advance()
        writer.className = tokenizer.advance().string
        tokenizer.advance()
        while tokenizer.peekNextToken().string in ClassVarDec.triggers:
            ClassVarDec(writer, tokenizer)
        while tokenizer.peekNextToken().string in SubroutineDec.triggers:
            SubroutineDec(writer, tokenizer)
        tokenizer.advance()


class ClassVarDec:
    """Parses class variable declarations (static/field)"""
    triggers = ['static', 'field']
    vmSegment = ['static', 'this']
    
    def __init__(self, writer, tokenizer):
        kind = self.vmSegment[self.triggers.index(tokenizer.advance().string)]
        type = tokenizer.advance().string
        writer.classScope.define(tokenizer.advance().string, type, kind)
        while tokenizer.peekNextToken().string != ';':
            tokenizer.advance()
            writer.classScope.define(tokenizer.advance().string, type, kind)
        tokenizer.advance()


class SubroutineDec:
    """Parses subroutine declaration (constructor/function/method)"""
    triggers = ['constructor', 'function', 'method']
    
    def __init__(self, writer, tokenizer):
        writer.subroutineScope = SymbolTable()
        keyword = tokenizer.advance().string
        isMethod = keyword == 'method'
        isConstructor = keyword == 'constructor'
        tokenizer.advance().string
        subroutineName = tokenizer.advance().string
        if isMethod:
            writer.subroutineScope.define('this', 'Array', 'argument')
        for type, name in ParameterList(writer, tokenizer).parameters:
            writer.subroutineScope.define(name, type, 'argument')
        tokenizer.advance()
        localsCount = 0
        while tokenizer.peekNextToken().string in VarDec.triggers:
            localsCount += VarDec(writer, tokenizer).varCount
        writer.writeFunction(f'{writer.className}.{subroutineName}', localsCount)
        if isMethod:
            writer.writePush('argument', 0)
            writer.writePop('pointer', 0)
        elif isConstructor:
            writer.writePush('constant', writer.classScope.countByKind('this'))
            writer.writeCall('Memory.alloc', 1)
            writer.writePop('pointer', 0)
        self.statements = Statements(writer, tokenizer)
        tokenizer.advance()


class ParameterList:
    """Parses subroutine parameter list"""
    triggers = ['(']
    
    def __init__(self, writer, tokenizer):
        self.parameters = []
        tokenizer.advance()
        if tokenizer.peekNextToken().string != ')':
            self.parameters.append([tokenizer.advance().string, tokenizer.advance().string])
        while tokenizer.peekNextToken().string != ')':
            tokenizer.advance()
            self.parameters.append([tokenizer.advance().string, tokenizer.advance().string])
        tokenizer.advance()


class VarDec:
    """Parses local variable declarations"""
    triggers = ['var']
    
    def __init__(self, writer, tokenizer):
        tokenizer.advance()
        type = tokenizer.advance().string
        writer.subroutineScope.define(tokenizer.advance().string, type, 'local')
        self.varCount = 1
        while tokenizer.peekNextToken().string != ';':
            tokenizer.advance()
            writer.subroutineScope.define(tokenizer.advance().string, type, 'local')
            self.varCount += 1
        tokenizer.advance()


class Statements:
    """Parses sequence of statements"""
    triggers = ['let', 'if', 'while', 'do', 'return']
    
    def __init__(self, writer, tokenizer):
        options = [LetStatement, IfStatement, WhileStatement, DoStatement, ReturnStatement]
        self.statements = []
        while tokenizer.peekNextToken().string in self.triggers:
            statement = options[self.triggers.index(tokenizer.peekNextToken().string)](writer, tokenizer)
            self.statements.append(statement)


class LetStatement:
    """Parses let statement (assignment)"""
    
    def __init__(self, writer, tokenizer):
        tokenizer.advance()
        var = writer.getByName(tokenizer.advance().string)
        self.arrExpression = None
        if tokenizer.peekNextToken().string == '[':
            writer.writePush(var["kind"], var["index"])
            tokenizer.advance()
            self.arrExpression = Expression(writer, tokenizer)
            tokenizer.advance()
            writer.writeArithmetic('add')
            writer.writePop('temp', 0)
        tokenizer.advance()
        self.expression = Expression(writer, tokenizer)
        if self.arrExpression is None:
            writer.writePop(var["kind"], var["index"])
        else:
            writer.writePush('temp', 0)
            writer.writePop('pointer', 1)
            writer.writePop('that', 0)
        tokenizer.advance()


class IfStatement:
    """Parses if statement with optional else"""
    
    def __init__(self, writer, tokenizer):
        tokenizer.advance()
        tokenizer.advance()
        Expression(writer, tokenizer)
        writer.writeArithmetic('not')
        unique = writer.getUnique()
        elseLabel = f'el{unique}'
        ifLabel = f'if{unique}'
        writer.writeIfGoto(elseLabel)
        tokenizer.advance()
        tokenizer.advance()
        Statements(writer, tokenizer)
        writer.writeGoto(ifLabel)
        tokenizer.advance()
        writer.writeLabel(elseLabel)
        if tokenizer.peekNextToken().string == 'else':
            tokenizer.advance()
            tokenizer.advance()
            Statements(writer, tokenizer)
            tokenizer.advance()
        writer.writeLabel(ifLabel)


class WhileStatement:
    """Parses while loop statement"""
    
    def __init__(self, writer, tokenizer):
        unique = writer.getUnique()
        doLabel = f'do{unique}'
        whLabel = f'wh{unique}'
        writer.writeLabel(doLabel)
        tokenizer.advance()
        tokenizer.advance()
        Expression(writer, tokenizer)
        writer.writeArithmetic('not')
        writer.writeIfGoto(whLabel)
        tokenizer.advance()
        tokenizer.advance()
        Statements(writer, tokenizer)
        tokenizer.advance()
        writer.writeGoto(doLabel)
        writer.writeLabel(whLabel)


class DoStatement:
    """Parses do statement (subroutine call)"""
    
    def __init__(self, writer, tokenizer):
        tokenizer.advance()
        self.subroutineCall = SubroutineCall(writer, tokenizer)
        writer.writePop('temp', 0)
        tokenizer.advance()


class ReturnStatement:
    """Parses return statement"""
    
    def __init__(self, writer, tokenizer):
        tokenizer.advance()
        self.expression = None
        if tokenizer.peekNextToken().string != ';':
            self.expression = Expression(writer, tokenizer)
        else:
            writer.writePush('constant', 0)
        writer.writeReturn()
        tokenizer.advance()


class Expression:
    """Parses expression with operators"""
    
    def __init__(self, writer, tokenizer):
        Term(writer, tokenizer)
        while tokenizer.peekNextToken().string in Op.triggers:
            op = Op(writer, tokenizer)
            Term(writer, tokenizer)
            writer.writeArithmetic(op.vm)


class Term:
    """Parses a term (constants, variables, expressions)"""
    
    def __init__(self, writer, tokenizer):
        token = tokenizer.advance()
        self.mainVal, self.expression, self.subroutineCall, self.unaryOp, self.term = (None,) * 5
        isIntergerConstant = (token.kind == Token.kinds['integerConstant'])
        isCharConstant = (token.kind == Token.kinds['charConstant'])
        isStringConstant = (token.kind == Token.kinds['stringConstant'])
        isKeywordConstant = (token.string in KeywordConstant.triggers)
        isSubroutineCall = (token.kind == Token.kinds['identifier'] and tokenizer.peekNextToken().string in SubroutineCall.nextTriggers)
        isVarName = (token.kind == Token.kinds['identifier'] and not isSubroutineCall)
        isAnotherExpression = (token.string == '(')
        isUnaryOp = (token.string in UnaryOp.triggers)
        
        if isIntergerConstant:
            writer.writePush('constant', token.string)
        elif isCharConstant:
            char = token.string[1]
            writer.writePush('constant', ord(char))
        elif isKeywordConstant:
            if token.string in ['null', 'false']:
                writer.writePush('constant', 0)
            elif token.string == 'true':
                writer.writePush('constant', 1)
                writer.writeArithmetic('neg')
            else:
                writer.writePush('pointer', 0)
        elif isStringConstant:
            string = tokenizer.getToken().string
            writer.writePush('constant', len(string))
            writer.writeCall('String.new', 1)
            for char in string:
                writer.writePush('constant', ord(char))
                writer.writeCall('String.appendChar', 2)
        elif isVarName:
            var = writer.getByName(tokenizer.getToken().string)
            writer.writePush(var["kind"], var["index"])
            if tokenizer.peekNextToken().string == '[':
                tokenizer.advance()
                Expression(writer, tokenizer)
                writer.writeArithmetic('add')
                writer.writePop('pointer', 1)
                writer.writePush('that', 0)
                tokenizer.advance()
        elif isSubroutineCall:
            self.subroutineCall = SubroutineCall(writer, tokenizer, token)
        elif isAnotherExpression:
            tokenizer.getToken()
            Expression(writer, tokenizer)
            tokenizer.advance()
        elif isUnaryOp:
            unaryOp = UnaryOp(writer, tokenizer, token)
            Term(writer, tokenizer)
            writer.writeArithmetic(unaryOp.vm)
        else:
            print("./10/CE.py @Term: no match found")


class SubroutineCall:
    """Parses subroutine call"""
    nextTriggers = ["(", "."]
    
    def __init__(self, writer, tokenizer, currentToken=None):
        if currentToken is None:
            self.mainName = tokenizer.advance().string
        else:
            self.mainName = tokenizer.getToken().string
        isMethodCall = writer.getByName(self.mainName) is not None
        isClassMethod = False
        self.subroutineName = '.'
        if tokenizer.peekNextToken().string == '.':
            tokenizer.advance()
            self.subroutineName += tokenizer.advance().string
        else:
            self.subroutineName = ''
            isClassMethod = True
            writer.writePush('pointer', 0)
        tokenizer.advance()
        if isMethodCall:
            this = writer.getByName(self.mainName)
            writer.writePush(this["kind"], this["index"])
        self.expressionList = ExpressionList(writer, tokenizer)
        if isClassMethod:
            writer.writeCall(f'{writer.className}.{self.mainName}', self.expressionList.argsCount + 1)
        elif not isMethodCall:
            writer.writeCall(f'{self.mainName}{self.subroutineName}', self.expressionList.argsCount)
        else:
            writer.writeCall(f'{writer.getByName(self.mainName)["type"]}{self.subroutineName}', self.expressionList.argsCount + 1)
        tokenizer.advance()


class ExpressionList:
    """Parses expression list (function arguments)"""
    
    def __init__(self, writer, tokenizer):
        self.argsCount = 0
        if tokenizer.peekNextToken().string != ')':
            Expression(writer, tokenizer)
            self.argsCount += 1
        while tokenizer.peekNextToken().string == ',':
            tokenizer.advance()
            Expression(writer, tokenizer)
            self.argsCount += 1


class Op:
    """Parses binary operator"""
    triggers = ['+', '-', '*', '/', '&', '|', '<', '>', '=']
    vmLang = ['add', 'sub', 'call Math.multiply 2', 'call Math.divide 2', 'and', 'or', 'lt', 'gt', 'eq']
    
    def __init__(self, writer, tokenizer):
        self.vm = self.vmLang[self.triggers.index(tokenizer.advance().string)]


class UnaryOp:
    """Parses unary operator"""
    triggers = ['-', '~']
    vmLang = ['neg', 'not']
    
    def __init__(self, writer, tokenizer, currentToken):
        self.vm = self.vmLang[self.triggers.index(currentToken.string)]


class KeywordConstant:
    """Parses keyword constant (true/false/null/this)"""
    triggers = ['true', 'false', 'null', 'this']
    
    def __init__(self, writer, tokenizer, currentToken):
        self.keywordConstant = writer.writeTokenXml(currentToken)
