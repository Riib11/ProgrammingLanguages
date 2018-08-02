import src.compilation.compiler as compiler
import src.parsing.parser as parser
import src.execution.executor as executor
from src.util.logger import log

import os
import sys

args = sys.argv
argl = len( args )

log( "args:",args )

if 1 == argl:

    log( "please provide a .il program file" , mode="error" )

else:

    # get program_string
    program_filename = args[1]
    program_file = open( program_filename , "r+" )
    program_string = (" ").join([ l for l in program_file ])
    log( "reading..." , mode="msg pros" )
    log( "program string:" , (
        program_string
        if not program_string.endswith("\n")
        else program_string[:-1] ))

    # parse program_string -> program_array
    program_array = parser.parse( program_string )
    log( "parsing..." , mode="msg pros" )
    log( "program array:" , program_array )

    # compile program_array -> program
    log( "compiling..." , mode="msg pros" )
    program = compiler.compile( program_array )

    # execute program -> IO
    log( "executing..." , mode="msg pros" )
    executor.execute( program )