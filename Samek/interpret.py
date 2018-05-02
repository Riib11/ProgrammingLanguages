import symbol
import term

names = symbol.primitives

def readsymbol(s):
    for name, symbol in names.items():
        if name == s: return symbol

def interpret(filename):
    # read lines
    print("[*] Reading " + filename + " into terms...")
    terms = []
    with open(filename, 'r') as file:
        i = 0
        for fline in file:
            fline = fline.split()
            j = 0
            syms = []
            for s in fline:
                sym = readsymbol(s)
                if not sym:
                    print("[!] Unrecognized symbol at line " + str(i) + ", symbol " + str(j) + ": '" + s + "'")
                    quit()
                syms.append(sym)
                j += 0
            terms.append(term.Term.read(syms))
            i += 1

    # print("terms: ", terms)

    # interpret terms
    print("[*] Interpreting terms into behavior...")
    print("-----------------" + ("-" * len(filename)) + "-----------------")
    for t in terms:
        t.evaluate()