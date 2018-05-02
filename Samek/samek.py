from interpret import interpret
import sys
argv = sys.argv

if len(argv) == 1:
    print("[!] Please supply a program file to compile")

elif len(argv) == 2:
    interpret(argv[1])
