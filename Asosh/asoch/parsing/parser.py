import asoch.parsing.lexer as lexer

#
# Basics
#

class Block:
    def __init__(self, parent):
        self.parent = parent

class Header(Block): pass

class Term(Block): pass

class Type(Block): pass

#
# Context
#

class Context(Block):
    def __init__(self, parent):
        super().__init__(parent)
        self.children = []

    def add_child(self, x):
        self.children.append(x)

#
# Headers
#

class Define(Header):
    def __init__(self, name, type, term, parent):
        super().__init__(parent)
        self.name = name # String
        self.type = type # Type
        self.term = term # Term

class Axiom(Header):
    def __init__(self, name, type):
        super().__init__(parent)
        self.name = name # String
        self.type = type # Type

#
# Constant
#

class Constant(Term):
    def __init__(self, name, type, term):
        self.name = name # String
        self.type = type # Type
        self.term = term # Term

class ConstantReference(Term):
    def __init__(self, name):
        self.name = name # String

#
# Function
#

class Function(Term):
    def __init__(self, type, args, term):
        self.type = type # Type
        self.args = args # [FunctionArgument]
        self.term = term # Term

class FunctionArgument:
    def __init__(self, name, type):
        self.name = name # String
        self.type = type # Type

class FunctionApplication(Term):
    def __init__(self, name, args):
        self.name = name # String
        self.args = args # [Term]

#
#
#

block = None

def parse(lexed):
    global block
    block = lexed

    def parse_helper():
        global block
        if type(block) == lexer.Block:
            block = block.content
            parse_helper()
        
        if isinstance(block, list):
            ls = block
            for 
    
