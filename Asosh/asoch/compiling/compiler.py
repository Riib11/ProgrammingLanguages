import asoch.parsing.parser as parser

def compile(parsed):
    for x in parsed.children:
        if isinstance(x, parser.Define):
            pass

        elif isinstance(x, parser.Axiom):
            pass

        elif isinstance(x, parser.Compute):
            x.compute([])