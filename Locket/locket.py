from compile import compile
import sys
argv = sys.argv

if len(argv) == 1:
    print("[!] Please supply a program file to compile")

elif len(argv) > 1:

    params = {
        "debug"     : False,
        "verbosity" : False
    }

    for a in argv:
        if ".lkt" in a: params["file"] = a
        elif "-v" in a: params["verbosity"] = True
        elif "-d" in a: params["debug"] = True

    print("[" + argv[1] + "] returns:",compile(params))