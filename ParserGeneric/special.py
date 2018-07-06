from copy import deepcopy

#
# Word
#
#  generic class for atomic words with associated string tokens
#  relevant to the parser.
#
class Word:
    #
    # token    : the string the parser recognizes this word by
    # priority : TODO
    #
    def __init__(self, token, priority=0):
        self.token = token
        self.priority = priority

    def inString(self, sec):
        if self.token in sec: return self.token

    def tostring(self):
        if self.priority == 0: return self.token
        else: return self.token+"\\"+str(self.priority)
    __str__ = tostring
    __repr__ = tostring

    def clone(self): return deepcopy(self)

#
# total list of Special instances
#
specials = []

#
# Special
#
#   abstract class for the types of special words treated
#   with extra, built-in properties by the parser.
#
class Special(Word):
    #
    # force_sep : in the case that this token is a subtoken
    #             (not isolated by spaces in a section), whether
    #             to seperate out the subtoken
    #
    def __init__(self, token, priority, force_sep):
        priority = priority or 0
        force_sep = force_sep or False
        super().__init__(token, priority)
        self.force_sep = force_sep
        specials.append(self)

        self.parent = None
        self.content = []

    @classmethod
    def initList(cls, ls):
        for x in ls:
            if isinstance(x,str): cls(x,None,None)
            elif isinstance(x,list):
                cls(x[0], safeindex(x,1), safeindex(x,2))

    def tostring(self):
        if self.priority == 0: return self.token+" ["+str(self.content)+"]"
        else: return self.token+"\\"+str(self.priority)+" ["+str(self.content)+"]"
    __str__ = tostring
    __repr__ = tostring


class Struct(Special):
    #
    # context : specifies the reletive sections that this keyword captures
    #
    def __init__(self, token, context, priority, force_sep):
        priority = priority or 0
        force_sep = force_sep or False
        self.context = context or [0,0]
        super().__init__(token, priority, force_sep)

    @classmethod
    def initList(cls, ls):
        for x in ls:
            cls(x[0], safeindex(x,1), safeindex(x,2), safeindex(x,3))

class Bracket(Special):
    #
    #
    #
    def __init__(self, token_open, token_close, priority, force_sep):
        priority = priority or 0
        force_sep = force_sep or True
        super().__init__(token_open, priority, force_sep)
        self.token_open = token_open
        self.token_close = token_close

        self.mode = None

    @classmethod
    def initList(cls, ls):
        for x in ls:
            cls(x[0], x[1], safeindex(x,2), safeindex(x,3))

    def inString(self, sec):
        if self.token_open in sec: return self.token_open
        if self.token_close in sec: return self.token_close

    def bracketMatch(self, other):
        return isinstance(other,Bracket) and self.token_open == other.token_open

    def tostring(self):
        if self.mode:
            if self.mode == 'open':
                if self.priority == 0: return self.token+" ["+str(self.content)+"]"
                else: return self.token+"\\"+str(self.priority)+" ["+str(self.content)+"]"
            elif self.mode == 'close':
                if self.priority == 0: return self.token_close
                else: return self.token_close+"\\"+str(self.priority)
        else:
            if self.priority == 0: return self.token+" ["+str(self.content)+"]"
            else: return self.token+"\\"+str(self.priority)+" ["+str(self.content)+"]"
    __str__ = tostring
    __repr__ = tostring


#
# Utilities
#

def safeindex(ls,i): return ls[i] if len(ls)>i else None