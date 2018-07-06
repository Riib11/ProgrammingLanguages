#
###
#####
#######
#
# imports
#

from copy import deepcopy

#######
#####
###
#
###
#####
#######
#
# statics
#

# total list of `Special` instances
specials = []

#######
#####
###
#
###
#####
#######

class Word:

    def __init__(self, symbol):
        self.symbol = symbol

    def fromString(string): # [String]
        # base case
        if len(string) == 0: return []
        # find specials inside
        found = False
        for spec in specials:
            spec_loc = spec.findInString(string)
            if spec_loc:
                return (
                    Word.fromString( string[:spec_loc[0]] ) +              # before
                    [ spec.makeWord( string[spec_loc[0]:spec_loc[1]] ) ] + # this
                    Word.fromString( string[spec_loc[1]:] )                # after
                )
        # not special
        return [Word(string)]

    def tostring(self):
        return " "+self.symbol+" "
    __str__ = tostring
    __repr__ = tostring

#######
#####
###
#
###
#####
#######

class Special(Word):

    def __init__(self, symbol, force_sep, ignore_containerclass):
        super().__init__(symbol)
        self.force_sep = force_sep
        self.ignore_containerclass = ignore_containerclass
        specials.append(self)

    def findInString(self, string): # (Int,Int) or False
        # is entire string
        if string == self.symbol: return (0,len(string))
        # is contained somewhere in string
        elif self.force_sep and self.symbol in string:
            i = string.index(self.symbol)
            return (i, i+len(self.symbol))
        # not here!
        return False

    def makeWord(self, string):
        return deepcopy(self)

#######
#####
###
#
###
#####
#######

class Container(Special):

    def __init__(self, symbol, containerclass, force_sep, ignore_containerclass):
        super().__init__(symbol, force_sep, ignore_containerclass)
        self.containerclass = containerclass
        self.parent = None
        self.content = []

    def append(self, word):
        self.content.append(word)

    def tostring(self):
        if len(self.content)>0:
            return " "+self.symbol+" ~{ "+wordsToString(self.content)+" }~ "
        else:
            return " "+self.symbol+" "
    __str__ = tostring
    __repr__ = tostring

#######
#####
###
#
###
#####
#######

class Bracket(Container):

    def __init__(self, symbol_open, symbol_close, containerclass, force_sep, ignore_containerclass):
        super().__init__(symbol_open, containerclass, force_sep, ignore_containerclass)
        self.symbol_open = symbol_open
        self.symbol_close = symbol_close
        self.mode = None # can be 'open' or 'close', when in Word form

    def findInString(self, string): # (Int,Int) or False
        for symbol in [self.symbol_open, self.symbol_close]:
            # is entire string
            if string == symbol: return (0,len(string))
            # is contained somewhere in string
            elif self.force_sep and symbol in string:
                i = string.index(symbol)
                return (i, i+len(symbol))
        # not here!
        return False

    def makeWord(self, string):
        word = deepcopy(self)
        is_open = string == self.symbol_open
        word.mode = 'open' if is_open else 'close'
        return word

    def tostring(self):
        if self.mode:
            return " "+self.symbol_open+" "+wordsToString(self.content)+" "+self.symbol_close+" "
        else:
            return super().tostring()
    __str__ = tostring
    __repr__ = tostring

#######
#####
###
#
###
#####
#######

class Struct(Container):
    
    def __init__(self, symbol, containerclass, force_sep, ignore_containerclass):
        super().__init__(symbol, containerclass, force_sep, ignore_containerclass)

#######
#####
###
#
###
#####
#######
#
# utilities
#

def wordsToString(words):
    s = ""
    for w in words: s += str(w)
    return s