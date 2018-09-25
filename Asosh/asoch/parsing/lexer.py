import asoch.strings.split as split
import asoch.parsing.syntax as syntax

class Block:
    def __init__(self, parent):
        self.parent = parent
        self.attr = {}
        self.content = []
    def set_attr(self,k,v): self.attr[k] = v
    def get_attr(self,k): return self.attr[k]
    def add(self,x): self.content.append(x)
    def tostring(self):
        s = ("<" + str(self.__class__.__name__) + " " + " ".join([f"{k}={v}" for k,v in self.attr.items()])).strip()
        s += ">"
        if len(self.content) > 0:
            s += "{" + " ".join(map(str,self.content)) + "}"
        return s
    __str__ = tostring; __repr__ = tostring

class Container(Block): pass


headers = ["Define", "Axiom"]

# Define:
# - name: Name
# - type: Signature
# - term: Term 
class Define(Block): pass

# Axiom
# - name: Name
# - type: Signature
class Axiom(Block): pass

# Compute
# - term: Term
class Compute(Block): pass

# Name
# - string: String
class Name(Block): pass

# Term
class Term(Block): pass

# Signature
class Signature(Block): pass

#
#
#

block = Container(None)
ss = ""

def lex(string):
    # split by special syntax symbols
    global ss
    ss = split.split_with(string, syntax.force_separate)

    #
    # block manipulation
    #

    def enterblock(B, attr=None):
        global block
        if attr:
            b = B(block)
            block.set_attr(attr, b)
            block = b
        else:
            b = B(block)
            block.add(b)
            block = b
    
    def exitblock():
        global block
        block = block.parent

    #
    # lexers
    #

    def lex_name():
        global ss
        enterblock(Name, "name")
        block.add(ss[0])
        exitblock()
        ss = ss[1:]
        if ss[0] == ":":
            ss = ss[1:]

    def lex_typesiganture():
        global ss
        enterblock(Signature, "sign")
        for i in range(len(ss)):
            s = ss[i]
            if s in syntax.block_separate:
                exitblock()
                ss = ss[i+1:]
                return
            else:
                block.add(s)

    def lex_term():
        global ss
        enterblock(Term, "term")
        for i in range(len(ss)):
            s = ss[i]
            if s in syntax.block_separate:
                exitblock()
                ss = ss[i+1:]
                return
            else:
                block.add(s)

    def lex_helper():
        global ss
        s = ss[0]
        if "Define" == s:
            enterblock(Define)
            ss = ss[1:]
            lex_name()
            lex_typesiganture()
            lex_term()
            exitblock()
        elif "Axiom" == s:
            enterblock(Axiom)
            ss = ss[1:]
            lex_name()
            lex_typesiganture()
            exitblock()
        elif "Compute" == s:
            enterblock(Compute)
            ss = ss[1:]
            lex_term()
            exitblock()

    while len(ss) > 0: lex_helper()

    return block