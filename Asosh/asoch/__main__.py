import sys

from asoch.compiling.compiler import compile
from asoch.parsing.parser     import parse
from asoch.parsing.lexer      import lex

with open(sys.argv[1],"r+") as file:
    # remove comments
    lines = [ line for line in file if not line.strip().startswith("#") ]
    # remove line returns and formatting whitespace
    string = " ".join([line.strip() for line in lines ])
    # lex
    lexed = lex(string)
    print("lexed:")
    print(lexed)
    # parse
    parsed = parse(lexed)
    print("parsed:")
    print(parsed)
    # compile
    compile(parsed)