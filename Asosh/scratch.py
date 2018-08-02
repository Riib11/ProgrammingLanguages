class Term:

    indent = "  "

    def __init__(self, symbol, args):
        self.symbol = symbol
        self.args = args

    def tostring(self,lvl=0):
        s = "(" + self.symbol
        for arg in self.args:
            s += "\n" + Term.indent*(lvl+1) + (arg.tostring(lvl+1) if isinstance(arg, Term) else str(arg))
        s += ")"
        return s

    __str__ = tostring
    __repr__ = tostring

class Plus(Term):
    def __init__(self, args): super().__init__("+", args)

print(

    Plus([
        Plus([
            1,
            2]),
        3])

)

print(

    Plus([1,2,3])

)