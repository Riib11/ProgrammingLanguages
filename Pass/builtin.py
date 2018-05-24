from term import Term

def l(v): lambda: v

def createBuiltins(terms):

    # Unit
    terms["Unit"] = Term(
        l( terms["Unit"] ), l( terms["Unit"] ))

    # Type
    terms["Type"] = Term(
        l( terms["Type"] ), l( terms["Type1"] ))

    # Boolean
    terms["Boolean"] = Term(
        l( terms["Boolean"] ), l( terms["Type"] ))
    terms["true"] = Term(
        l( terms["true"] ), l( terms["Boolean"]))
    terms["false"] = Term(
        l( terms["false"] ), l( terms["Boolean"]))

    B_istrue = lambda x : x.evaluation() == terms["true"]
    B_and    = lambda xs: B_istrue(xs[0]) and B_istrue(xs[1])
    B_or     = lambda xs: B_istrue(xs[0]) or B_istrue(xs[1])
    B_not    = lambda xs: not B_istrue(xs[0])

    # Boolean Logic
    terms["and"] = Term(
        B_and , l( terms["Boolean"], terms["Boolean"], terms["Boolean"] ))
    terms["or"]  = Term(
        B_or  , l( terms["Boolean"], terms["Boolean"], terms["Boolean"] ))
    terms["not"] = Term(
        B_not  , l( terms["Boolean"], terms["Boolean"] ))