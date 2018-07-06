from parser import Parser
from language import Language

#
# make language
#
language = Language({
    "special": [
        ["+"]
    ],
    "bracket": [
        ["(",")"],
        ['"','"', "quote"]
    ],
    "struct": [
        ["if"]
    ]
})

#
# make parser
#
parser = Parser(language)

#
# parse text
#
parser.parse("txt/test.txt")