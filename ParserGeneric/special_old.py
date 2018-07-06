from word import Word

specials = []

class Special(Word):
    #
    # force_sep : in the case that this token is a subtoken
    #             (not isolated by spaces in a section), whether
    #             to seperate out the subtoken
    #
    def __init__(self, token, priority=0, force_sep=True):
        super().__init__(token, priority)
        self.force_sep = force_sep
        specials.append(self)

#
# define specials
#

for token in ['+', '-', '*', '/', '!', '(', ')', '[', ']', '@', '#', "'", '"', '%', '^', '&', '=', '|', ':', '<', '>', '?', '.', ',', '$']:
    Special(token)

# Special('(')
# Special(')')
# Special('[')
# Special(']')
# Special('{')
# Special('}')
# Special("'")
# Special('"')

print([ w.token for w in specials ])