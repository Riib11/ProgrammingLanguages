import asoch.strings.split as split
import asoch.parsing.syntax as syntax

class Block:
    def __init__(self, parent):
        self.parent = parent
        self.attr = {}
        self.content = []
    def set_attr(self,k,v): self.attr[k] = v
    def add(self,x): self.content.append(x)
    def tostring(self):
        s = ("<" + str(self.__class__.__name__) + " " + " ".join([f"{k}={v}" for k,v in self.attr.items()])).strip()
        s += ">"
        s += "{" + " ".join(map(str,self.content)) + "}"
        return s
    __str__ = tostring; __repr__ = tostring

headers = ["Define", "Axiom"]

# Define:
# - name: Name
# - type: Type
# - term: Term 
class Define(Block): pass

# Axiom
# - name: Name
# - type: Type
class Axiom(Block): pass

# Name
# - string: String
class Name(Block): pass

# Term
class Term(Block): pass

# Type
class Type(Block): pass

#
#
#

block = Block(None)
ss = ""

def lex(string):
    # split by special syntax symbols
    global ss
    ss = split.split_with(string, syntax.force_separate)

    #
    # block manipulation
    #

    def enterblock(B):
        global block
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
        enterblock(Name)
        block.add(ss[0])
        exitblock()
        ss = ss[1:]
        if ss[0] == ":":
            ss = ss[1:]

    def lex_type():
        global ss
        enterblock(Type)
        for i in range(len(ss)):
            # print("type:",i,ss)
            s = ss[i]
            if s in syntax.block_separate:
                exitblock()
                ss = ss[i+1:]
                return
            else:
                block.add(s)

    def lex_term():
        global ss
        enterblock(Term)
        for i in range(len(ss)):
            # print("term:",i,ss)
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
            lex_type()
            lex_term()
            exitblock()
        elif "Axiom" == s:
            enterblock(Axiom)
            ss = ss[1:]
            lex_name()
            lex_type()
            exitblock()

    while len(ss) > 0: lex_helper()

    return block