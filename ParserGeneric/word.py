class Word:
    #
    # token    : the string the parser recognizes this structural by
    # priority : 
    #
    def __init__(self, token, priority=0):
        self.token = token
        self.priority = priority

    def tostring(self):
        if self.priority == 0: return "{ "+self.token+" }"
        else: return "{ "+self.token+" : "+str(self.priority)+" }"
    __str__ = tostring
    __repr__ = tostring