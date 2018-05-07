from compile import compile
import sys
argv = sys.argv

if len(argv) == 1:
    print("[!] Please supply a program file to compile")

elif len(argv) == 2:
    print("[" + argv[1] + "] returns:",compile(argv[1]))