from special import *

class Parser:

    def __init__(self, specials):
        self.specials = specials

    def parse(self, filename):
        with open(filename, "r+") as file:
            words = []
            for line in file: words += self.expandLine(line)

            # print(words)

            content = []
            block_curr = None
            for word in words:
                if isinstance(word,Struct):
                    if block_curr:
                        block_curr.content.append(word)
                        word.parent = block_curr
                    else:
                        content.append(word)
                    block_curr = word
                elif isinstance(word,Bracket):
                    # close bracket
                    if (word.mode == 'close' and
                        word.bracketMatch(block_curr)):
                        block_curr = block_curr.parent
                    # open bracket
                    elif word.mode == 'open':
                        if block_curr:
                            block_curr.content.append(word)
                            word.parent = block_curr
                        else:
                            content.append(word)
                        block_curr = word 
                else:
                    if block_curr:
                        block_curr.content.append(word)
                    else:
                        content.append(word)

            print(content)

    def expandLine(self, line):
        
        line = line.split()
        words = []

        def expandSection(sec):
            if len(sec)==0: return
            word_found = False
            for word in self.specials:
                sec_l = len(sec)
                token = word.inString(sec)
                if token:
                    word = word.clone()
                    if not word.force_sep: continue
                    else:
                        word_found = True
                        token_l = len(token)
                        # is entire section
                        if token_l == sec_l:
                            words.append(word)
                        else:
                            i = sec.index(token)
                            expandSection(sec[:i])         # before
                            words.append(word)             # this
                            if isinstance(word,Bracket):
                                isopen = token == word.token_open
                                word.mode = 'open' if isopen else 'close'
                            expandSection(sec[i+token_l:]) # after

                        break

            if not word_found: words.append(Word(sec))

        for sec in line: expandSection(sec)
        return words



class Phrase:

    def __init__(self, content):
        self.content = content # [string]

    def tostring(self):
        s = ""
        for c in self.content:
            s += c + " "
        s = s[:-1]
        return s
    __str__ = tostring
    __repr__ = tostring