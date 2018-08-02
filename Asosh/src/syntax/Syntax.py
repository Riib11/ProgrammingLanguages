# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# project modules
#

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# external modules
#

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# TODO
#
class Syntax:

    def __init__(self):
        # init properties
        self.term_parens   = {}
        self.string_parens = {}
        # grouped by associativity each entry
        # must be either a String or [String][2]
        # [String] -> [[...[String]]]
        # self.assoc_rules   = None
