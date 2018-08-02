from src.util.sort import quicksort
from src.parsing.special import seperators, punctuations, ignores

import re

def split_punctuations(program_string): # -> program_array
    s = program_string
    inds = []
    for p in punctuations:
        p_len = len(p)
        _inds = [ (m.start(), p_len) for m in re.finditer( re.escape(p) , s ) ]
        inds += _inds
    quicksort(inds, lambda x:x[0])

    split = []
    first = True
    for i in range(len(inds)):
        ind,l = inds[i]
        if first:
            before = s[ 0 : ind ]
            if len(before)>0: split.append(before)
            first = False
        if i > 0:
            ind_prev, l_prev = inds[i-1]
            sp = s[ ind_prev+l_prev : ind ]
            if len(sp)>0: split.append( sp )
        split.append( s[ ind : ind+l ] )
    return split

def remove_ignores(program_array): # -> program_array
    arr = program_array
    return [ x for x in arr if (not x in ignores) ]

def parse(program_string): # -> program_array
    return  remove_ignores(
            split_punctuations(
            program_string))