class Term:

    def __init__(self, symbols):
        self.symbols = symbols

    @classmethod
    def read(cls, symbols):
        term = Term(symbols)
        return term

    # TODO
    def evaluate(self):
        if len(self.symbols) == 0: return
        s = self.symbols[0]
        arity = s.arity
        xs = []
        i = 1
        while i < len(self.symbols):
            sym = self.symbols[i]
            rest = Term(self.symbols[i:i+sym.arity+1])
            xs.append(rest.evaluate())
            i += sym.arity + 1

        return s.evaluate(xs)

    def tostring(self):
        return str(self.symbols)
    __str__ = tostring
    __repr__ = tostring