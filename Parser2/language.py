from word import *

# ignore_containerclass default
igccd = ["quote"]

class Language:
    #
    # specification: {
    #   "special" : []
    #   "bracket" : []
    #   "struct"  :
    #
    def __init__(self, specificiation):
        for spec in specificiation["special"]: self.defineSpecial(spec)
        for spec in specificiation["bracket"]: self.defineBracket(spec)
        for spec in specificiation["struct"] : self.defineSpecial(spec)

        print(specials)

    def defineSpecial(self, spec):
        l = len(spec)
        Special(
            spec[0],                        # symbol
            spec[1] if l>1 else True,       # force_sep
            spec[2] if l>2 else igccd)      # ignore_containerclass

    def defineBracket(self, spec):
        l = len(spec)
        Bracket(
            spec[0],                        # symbol_open
            spec[1],                        # symbol_close
            spec[2] if l>2 else "bracket",  # containerclass
            spec[3] if l>3 else True,       # force_sep
            spec[4] if l>4 else igccd)      # ignore_containerclass

    def defineStruct(self, spec):
        l = len(spec)
        Struct(
            spec[0],                        # symbol
            spec[1] if l>1 else "struct",   # containerclass
            spec[2] if l>2 else False,      # force_sep
            spec[3] if l>3 else igccd)      # ignore_containerclass

    def fromString(self, string): # [String]
        return Word.fromString(string)