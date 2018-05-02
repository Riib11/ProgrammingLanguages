from interpret import Interpreter
import sys
argv = sys.argv

if len(argv) == 1:
    print("[!] Please supply a program file to compile")

elif len(argv) == 2:
    interpreter = Interpreter(argv[1])
    interpreter.interpret()
