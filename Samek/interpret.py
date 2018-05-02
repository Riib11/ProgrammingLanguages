from symbol import Symbol, primitives
from term import Term

# get value of outside file
primitives["get"] = Symbol("get", 1, lambda xs: Interpreter(xs[0]+".smk").interpret())

class Interpreter:

    def __init__(self,filename):
        self.names = primitives
        self.filename = filename

    def readsymbol(self,s):
        for name, symbol in self.names.items():
            if name == s: return symbol

    def interpret(self):
        # read lines
        print("[*] Reading " + self.filename + " into symbols...")
        symbols = []
        with open(self.filename, 'r') as file:
            i = 0
            inquotes = False
            for fline in file:
                fline = fline.split()

                j = 0
                for s in fline:
                    sym = None

                    if not inquotes:
                        sym = self.readsymbol(s)
                        if not sym:
                            print("[!] Unrecognized symbol at line " + str(i) + ", symbol " + str(j) + ": '" + s + "'")
                            quit()
                    # string
                    else:
                        sym = Symbol(s, 0, lambda xs: s)

                    j += 1
                    symbols.append(sym)
                    if not inquotes:
                        if sym.symbol == "`":
                            inquotes = True
                    else:
                        inquotes = False
                i += 1

        # compile symbols into term
        print("[*] Combining symbols into term...")
        term = Term.read(symbols)

        print("[$] Resulting term:", term)

        # interpret term
        print("[*] Interpreting term into behavior...")
        print("----------------------------------" + ("-" * len(self.filename)))
        term.evaluate()