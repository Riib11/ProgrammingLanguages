def log(*xs, mode="msg"):
    tags = []
    def check(x,t): tags.append(t) if x in mode else None

    check("msg","#")
    check("error","!")
    check("exec","$")
    check("loc","@")
    check("add","+")
    check("pros",">")
    check("q","?")

    if len(tags)==0: tags.append("%") # default

    print("".join(tags)," ".join([str(x) for x in xs]))