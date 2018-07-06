from word import Word

structurals = []

class Structural(Word):
    #
    # context : specifies the reletive sections that this keyword captures
    #
    def __init__(self, token, context, priority=1, force_sep=False):
        super().__init__(token, priority)
        self.context = context
        self.content = {'l':[],'r':[]}
        self.force_sep = force_sep
        structurals.append(self)
#
# fill stucturals
#
Structural( "if"   , (0,1) ),
Structural( "then" , (0,1) ),
Structural( "else" , (0,1) ),
Structural( ";"    , (100,0) , 100, True)
Structural( "{"    , (0,200) , 200, True)
Structural( "}"    , (0,0)   , 200, True)