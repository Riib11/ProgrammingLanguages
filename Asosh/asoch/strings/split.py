import re

def split_with(s, splits):
    splits_inds = []
    for split in splits:
        inds = [(m.start(0), m.end(0)) for m in re.finditer(re.escape(split), s)]
        splits_inds += inds
    splits_inds = sorted(splits_inds, key=lambda x: x[0])
    
    # make sure that they don't overlap
    splits_inds_new = []
    prev_start, prev_end = -1, -1
    for inds in splits_inds:
        if prev_start < 0:
            prev_start, prev_end = inds
            splits_inds_new.append(inds)
        else:
            start, end = inds
            # overlap, and this one is larger
            if prev_start == start:
                if prev_end < end:
                    splits_inds_new[-1] = inds
                    prev_start, prev_end = inds
            elif prev_end <= start:
                prev_start, prev_end = inds
                splits_inds_new.append(inds)
    splits_inds = splits_inds_new


    arr = []
    def safeappend(x):
        if not any([x==i for i in [""," "]]):
            arr.append(x)

    last_i = 0
    for inds in splits_inds:
        safeappend(s[last_i:inds[0]])
        safeappend(s[inds[0]:inds[1]])
        last_i = inds[1]
    safeappend(s[inds[1]:])

    return arr