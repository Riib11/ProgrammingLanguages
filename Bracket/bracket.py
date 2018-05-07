import sys
from compile import compile

args = sys.argv

if len(args) == 3:
    infile = args[1]
    keyfile = args[2]
    compile(infile,keyfile)

else:
    print("please supply a input file and key file - nothing more, nothing less")