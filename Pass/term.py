class Term:

    def __init__(self, evaluation, signature):
        self.evaluation = evaluation # () -> value
        self.signature  = signature  # () -> [term]