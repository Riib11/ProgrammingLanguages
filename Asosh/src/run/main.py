# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# project modules
#
import src.parse.parser as parser
import src.compile.compiler as compiler
import src.syntax.compiler as syntax_compiler

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# external modules
#
import sys

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
# arguments:
#   [0]  : main.py
#   [1]  : asosh syntax definition
#   [2+] : input text files
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# case: valid arguments
#
if len(sys.argv) > 2:

    file_syntax_name = sys.argv[1]
    file_input_names = sys.argv[2:]

    syntax = None
    with open(file_syntax_name, "r+") as file_syntax:
        print("[#] process syntax:", file_syntax_name)
        string = "".join(map(str, [line for line in file_syntax]))
        syntax = syntax_compiler.compile(string)

    print("[>] compiled syntax:", syntax)

    output = None
    for file_input_name in file_input_names:
        with open(file_input_name, "r+") as file_input:
            print("[#] processing:",file_input_name)
            string = "".join(map(str, [line for line in file_input]))
            print("  | parsing")
            parsed = parser.parse(string)
            print("  [>] parsed input:", parsed)
            print("  | compiling")
            output = compiler.compile(parsed)

    print("[>] compiled output:", output)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# case: not enough arguments
#
else:

    print("[!] please provide at least a [[syntax definition]] and one [[input file]]")