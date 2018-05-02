class Symbol:

    # symbol : code representation
    # arity  : number of following symbols inputted
    # eval   : function of inputs
    def __init__(self, symbol, arity, eval):
        self.symbol = symbol
        self.arity = arity
        self.eval = eval

    def evaluate(self, xs):
        return self.eval(xs)

    def tostring(self):
        return self.symbol
    __str__ = tostring
    __repr__ = tostring


primitives = {
    "True"  : Symbol("True",  0, lambda xs: True),
    "False" : Symbol("False", 0, lambda xs: False),
    "&&"   : Symbol("&&",    2, lambda xs : all(xs)),
    "||"    : Symbol("||",    2, lambda xs : any(xs)),
    "print" : Symbol("print", 1, lambda xs: print(xs[0]))
}