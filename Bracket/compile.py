import os.path

# symbols:
# - line return
# - space

functions = {
    1: lambda x : print(x)
}

def compile(infile, keyfile):

    # check if input exists
    if not os.path.isfile(infile):
        print("[!] input file does not exist")
        return

    # check if key exists
    if not os.path.isfile(keyfile):
        print("[!] key file does not exist")
        return

    # log
    print("[*] compiling " + infile + " with " + keyfile)

    # symbols
    symbols = []
    with open(infile, 'r') as file:
        for s in file:
            syms = []
            for c in s:
                if c == ' ': syms.append('space')
                elif c == '\n': syms.append('lr')
                else: syms = [] # only read spaces and lr's at end of lines
            symbols += syms
    # print(symbols)

    # keys
    keys = {}
    with open(keyfile, 'r') as file:
        i = 1
        for s in file:
            s = s[:-1] # remove line return
            keys[i] = s
            i += 1
    # print(keys)

    print("[*] running " + infile)
    print("------------------------------")

    i = 0
    space_count = 0     # choose function
    lr_count = 0        # choose key
    last_lr = False
    while i < len(symbols):
        sym = symbols[i]
        if sym == 'lr':
            lr_count += 1
            last_lr = True
        elif sym == 'space':
            if last_lr:
                # print("executing function " + str(space_count) + " with key " + str(lr_count) )
                # print(functions[space_count])
                # print(keys[lr_count])
                functions[space_count](keys[lr_count])
                space_count = 0
                lr_count = 0
                last_lr = False
            space_count += 1
        i += 1