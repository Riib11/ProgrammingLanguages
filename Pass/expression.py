from token import Token

# the simplest expression is a single token
# an expression is an array of expressions

class Expression:

    def __init__(self, exps):
        self.head = exps[0]
        self.tail = exps[1:]

    # returns a term
    def evaluation(self):
        # recurse on tail
        tail = [ e.evaluation() for e in self.tail ]

        # is Token (base base)
        if isinstance(self.head, Token):
            return self.head.evaluation(self.tail)

        # is sub-Expression (recurse)
        elif isinstance(self.head, Expression):
            return self.head.evaluation()
