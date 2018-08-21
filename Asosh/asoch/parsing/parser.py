import asoch.parsing.lexer as lexer
import asoch.utils.tree as tree

#
# Basics
#

class Block:
    def __init__(self, parent):
        self.parent = parent
        if isinstance(parent, Context):
            parent.add_child(self)

class Header(Block): pass

class Term:
    def __init__(self, value, sign):
        self.value = value
        self.sign = sign
    
    def tostring(self):
        return f"{self.value} : {self.sign}"
    __str__ = tostring; __repr__ = tostring

class Value:
    def __init__(self, repr):
        self.repr = repr

    def tostring(self): return str(self.repr)
    __str__ = tostring; __repr__ = tostring

class Signature:
    def __init__(self, term):
        self.term = term

    def tostring(self):
        return f"{self.term}"
    __str__ = tostring; __repr__ = tostring

class SignatureArrow:
    def __init__(self, domain, codomain):
        self.domain   = domain
        self.codomain = codomain

    def tostring(self):
        return f"({self.domain} -> {self.codomain})"
    __str__ = tostring; __repr__ = tostring

#
# Context
#

class Context(Block):
    def __init__(self, parent):
        super().__init__(parent)
        self.children = []

    def add_child(self, x):
        self.children.append(x)

    def tostring(self):
        s = "{\n"
        s += ". ".join(map(str,self.children))
        s += "\n}"
        return s
    __str__ = tostring; __repr__ = tostring

#
# Headers
#

class Define(Header):
    def __init__(self, parent, name, term):
        super().__init__(parent)
        self.name = name # String
        self.term = term # Term

    def tostring(self): return f"Define {self.name} := {self.term}"
    __str__ = tostring; __repr__ = tostring

class Axiom(Header):
    def __init__(self, parent, name, sign):
        super().__init__(parent)
        self.name = name # String
        self.sign = sign # Signature

    def tostring(self):
        s = ""
        return s
    __str__ = tostring; __repr__ = tostring

#
# Constant
#

class Constant:
    def __init__(self, name, term):
        self.name = name # String
        self.term = term # Term

    def tostring(self): return f"{self.name} := {self.term}"
    __str__ = tostring; __repr__ = tostring

class ConstantReference:
    def __init__(self, name):
        self.name = name # String

    def tostring(self): return f"${self.name}"
    __str__ = tostring; __repr__ = tostring

#
# Function
#

class Function:
    def __init__(self, args, value):
        self.args  = args  # [FunctionArgument]
        self.value = value # Value

    def tostring(self):
        args = " ".join(map(str,self.args))
        return f"({args} => {self.value})"
    __str__ = tostring; __repr__ = tostring

class FunctionArgument:
    def __init__(self, name):
        self.name = name # String

    def tostring(self):
        return f"{self.name}"
    __str__ = tostring; __repr__ = tostring

class FunctionApplication:
    def __init__(self, func, terms):
        self.func  = func  # Term
        self.terms = terms # [Term]

    def tostring(self):
        terms = " ".join(map(str,self.terms))
        return f"({self.func} {terms})"
    __str__ = tostring; __repr__ = tostring

#
#
#

def istype(x,c): return x.__class__.__name__ == c.__name__

#
#
#

block = None

def parse(_lexed):

    def parse_helper(lexed):
        global block

        # CONTAINER
        if istype(lexed, lexer.Container):
            block = Context(block)
            for x in lexed.content: parse_helper(x)
            block = block.parent if block.parent else block

        # DEFINE
        elif isinstance(lexed, lexer.Define):
            name  = parse_helper(lexed.get_attr("name"))
            sign  = parse_helper(lexed.get_attr("sign"))
            value = parse_helper(lexed.get_attr("term"))
            # print(name, sign, term)
            Define(block, name, Term(value, sign))

        # AXIOM
        elif isinstance(lexed, lexer.Axiom):
            name = parse_helper(lexed.get_attr("name"))
            sign = parse_helper(lexed.get_attr("sign"))
            Axiom(block, name, sign)

        # NAME
        elif isinstance(lexed, lexer.Name):
            assert len(lexed.content) == 1
            return lexed.content[0]

        # TERMS
        elif isinstance(lexed, lexer.Term):
            return parse_helper(lexed.content)
        # TERMS
        elif isinstance(lexed, list):
            # single term
            if len(lexed) == 1:
                return parse_helper(lexed[0])
            # list of terms
            else:
                # associativity
                T = tree.TreeNode(None)
                for x in lexed:
                    if   "(" == x: T = tree.TreeNode(T)
                    elif ")" == x: T = T.parent
                    else: T.add(x)
                terms = tree.tolist(T)
                while len(terms) == 1 and isinstance(terms[0],list):
                    terms = terms[0]

                # function instanciation
                if "=>" in terms:
                    i = terms.index("=>")
                    args  = [ FunctionArgument(x) for x in terms[:i] ]
                    value = parse_helper(terms[i+1:])
                    return Function(args, value)
                    # def __init__(self, args, term):
                else:
                    # function application
                    func  = parse_helper(terms[0])
                    terms = [ parse_helper(x) for x in terms[1:] ]
                    return FunctionApplication(func, terms)

        # SIGNATURE
        elif isinstance(lexed, lexer.Signature):
            # single term
            terms = lexed.content
            if len(terms) == 0:
                return Signature
            # list of terms
            else:
                # associativity
                T = tree.TreeNode(None)
                for x in terms:
                    if   "(" == x: T = tree.TreeNode(T)
                    elif ")" == x: T = T.parent
                    else: T.add(x)
                terms = tree.tolist(T)
                while len(terms) == 1 and isinstance(terms[0],list):
                    terms = terms[0]

                # signature arrow
                if "->" in terms:
                    # left associativity,
                    # so find the first arrow from right to left
                    terms.reverse() 
                    i = len(terms) - 1 - terms.index("->")
                    terms.reverse()
                    domain           = lexer.Signature(None)
                    domain.content   = terms[:i]
                    domain           = parse_helper(domain)
                    codomain         = lexer.Signature(None)
                    codomain.content = terms[i+1:]
                    codomain         = parse_helper(codomain)
                    return SignatureArrow(domain, codomain)
                else:
                    return Signature(parse_helper(lexed.content))

        # TERM
        elif isinstance(lexed, str):
            return ConstantReference(lexed)


    print("\n"+50*"=")
    parse_helper(_lexed)
    print(50*"="+"\n")
    
    return block