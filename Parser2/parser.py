from word import *

class Parser:

    def __init__(self, language):
        self.language = language

    def parse(self, filename):
        with open(filename, "r+") as file:
            #
            # compress into minimal string form
            #
            strings = ""
            for line in file:
                strings += line.replace("\n"," ")
            strings = strings.split()
            
            # debug
            # print("strings:")
            # print(strings)
            # print()

            #
            # break into words
            #
            words = []
            for s in strings:
                words += self.language.fromString(s)
            
            # debug
            # print("words:")
            # printWords(words)
            # print()

            #
            # process into expression
            #
            expressions = []
            container = None
            struct_new = False
            for w in words:
                # print(w)
                
                # Bracket
                if isinstance(w,Bracket):
                    
                    # already inside a container
                    if container:
                    
                        # open new child bracket
                        if w.mode == 'open':
                            w.parent = container
                            container.append(w)
                            container = w
                    
                        # close current container
                        elif w.mode == 'close' and type(w)==type(container):
                    
                            # close this child bracket, and step up to parent
                            if container.parent:
                                container = container.parent

                            # append bracket when closed (is at top level)
                            else:
                                expressions.append(container)
                                container = None
                    
                    # open new top-level bracket
                    elif w.mode == 'open':
                        container = w

                # Struct
                elif isinstance(w,Struct):
                    # just added struct, so wait till
                    # next expression is closed to finish!
                    struct_new = True
                    
                    # already inside a container
                    if container:
                        w.parent = container
                        container = w

                    # open new top-level container
                    else:
                        container = w

                # Special or Word
                else:

                    # already inside a container,
                    # so append to that container
                    if container:
                        container.append(w)
                    
                    # append at top level
                    else:
                        expressions.append(w)

                # in the case that the most recent content was added
                # to a struct, which accepts just one child
                # expression, then close that struct now
                if type(container)==Struct and not struct_new:
                    
                    # close this child struct, and step up to parent
                    if container.parent:
                        container = container.parent
                    
                    # append struct when closed (is at top level)
                    else:
                        expressions.append(container)
                        container = None

            print(expressions)

            #
            #
            return expressions