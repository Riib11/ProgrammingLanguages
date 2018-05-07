from symbol import Symbol, read_string, symbols_dict

def compile(infile):

    symbols = []

    # COMPILE
    with open(infile) as file:
        # remove line return
        for line in file:
            line = line[:-1] if line[-1] == "\n" else line
            line = line.split() # by spaces
            for s in line:
                symbols.append(read_string(s))
    print("[" + infile + "] symbols:",symbols)

    # EXECUTE

    # variables
    vs = {}

    # define evaluation
    class Evaluation:

        def __init__(self, symbols):
            self.symbols = symbols

        def evaluate(self):
            if self.symbols == []: return None, []
            sym = self.symbols[0]
            # print("evaluating",sym)
            xs = self.symbols[1:]
            # print("xs",xs)
            # take the next sym.arity values
            inpts = []
            i = 0
            while i < sym.arity:
                val, xs = Evaluation(xs).evaluate()
                # print("rest",xs)
                inpts.append(val)
                i += 1
            # xs is the rest of the symbols
            return sym.call(vs,inpts), xs

    # execute symbols
    return Evaluation(symbols).evaluate()[0]

# more symbols
Symbol("get", 1, lambda vs, xs : compile(xs[0]+".lkt"))


