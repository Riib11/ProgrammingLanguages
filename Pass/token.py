class Token:

    #
    # signature  : () -> [token]
    # evaluation : [token]#arity -> token
    #

    def __init__(self, symbol, signature, evaluation):
        self.symbol     = symbol
        self.signature  = signature
        self.evaluation = evaluation
