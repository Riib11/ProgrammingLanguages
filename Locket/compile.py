import str_utils
from symbol import Symbol, read_string, symbols_dict, reserveds

comment_symbol = "~"

def compile(params):

    infile = params["file"]
    symbols = []

    # COMPILE
    with open(infile) as file:
        # remove line return
        for line in file:
            line = line[:-1] if line[-1] == "\n" else line
            line = line.split() # by spaces
            # turn into list of symbols
            splitted = []
            for s in line:
                splitted += str_utils.split_with(reserveds, s)
            comment = False
            for s in splitted:
                if not comment:
                    if s == comment_symbol: comment = True
                    else:
                        # print(s)
                        symbols.append(read_string(s))
    if params["verbosity"]: print("[" + infile + "] symbols:", symbols)

    # EXECUTE

    # variables
    vs = {}

    # define evaluation
    class Evaluation:

        def __init__(self, symbols):
            self.symbols = symbols

        def evaluate(self):
            if self.symbols == []:
                if params["debug"]: print("end")
                return None, []
            sym = self.symbols[0]
            # print("evaluating",sym)
            xs = self.symbols[1:]
            if params["debug"]: print("xs",xs)
            # take the next sym.arity values
            inpts = []
            i = 0
            while i < sym.arity:
                val, xs = Evaluation(xs).evaluate()
                if params["debug"]: print("rest",xs)
                inpts.append(val)
                i += 1
            # xs is the rest of the symbols
            return sym.call(vs,inpts), xs

    # execute symbols
    return Evaluation(symbols).evaluate()[0]

# more symbols
Symbol("get", 1, lambda vs, xs : compile({
    "file": xs[0] + ".lkt",
    "verbosity": False,
    "debug": False
}))


