symbols_dict = {}

class Symbol:
    def __init__(self, s, arity, call):
        self.s = s
        self.arity = arity
        self.call = call # inputs -> output
        symbols_dict[self.s] = self

    def tostring(self):
        return self.s
    __str__ = tostring
    __repr__ = tostring

def print(v):
    print(v)
    return False

def eval(vs,k):
    return vs[k]

def set(vs,k,v):
    vs[k] = v
    return False

# symbols
# print
Symbol("put", 1, lambda vs, xs : print(xs[0]))
# booleans
Symbol("True",  0, lambda vs, xs : True)
Symbol("False", 0, lambda vs, xs : False)
# boolean logic
Symbol("&&",    2, lambda vs, xs : xs[0] and xs[1])
Symbol("||",    2, lambda vs, xs : xs[0] or xs[1])
Symbol("!!",    2, lambda vs, xs : not xs[0])
# variables
Symbol("eva",  1, lambda vs, xs : eval(vs,xs[0]))
Symbol("set",   2, lambda vs, xs : set(vs,xs[0],xs[1]))

def read_string(s):
    if s in symbols_dict:
        return symbols_dict[s]
    elif s[0] == "\"" and s[-1] == "\"": # is a string
        return Symbol(s[1:-1], 0, lambda vs, xs : s[1:-1])
    else:
        return Symbol(s, 0, lambda vs, xs : s)