from parser import *
from special import *

#
# make specials
#

# Specials:

Special.initList([
    '+', '-', '*', '/', '!', '@',
    '#', "'", '"', '%', '^',
    '&', '=', '|', ':', '<',
    '>', '?', '.', ',', '$'
])

# Brackets:

Bracket.initList([
    ['(',')'],
    ['[',']'],
    ['{','}']
])

# Structs

Struct.initList([
    ["if"   ],
    ["then" ],
    ["else" ],
    [";",      None, None, True]
])

#
# make parser
#
parser = Parser(specials)