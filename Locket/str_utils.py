def split_with(splits, s):

    indecies = []
    lengths  = []
    for split in splits:
        orig = s
        p = 0
        while split in orig[p:]:
            i = orig[p:].index(split)
            indecies.append(p+i)
            lengths.append(len(split))
            p += i + len(split)

    result = []
    p = 0
    for i in range(len(indecies)):
        ind = indecies[i]
        result.append(s[p:ind])
        result.append(s[ind:ind+lengths[i]])
        p = ind + lengths[i]
    
    if p < len(s):
        result.append(s[p:])
    if result[0] == "":
        result = result[1:]

    return result