# Inline

A programming language that demonstrates the advantages (if there are any) of programming inline. 'Inline' in this programming-language context is defined to be a syntax that completely ignores line-returns and pre-line indents.

## Build Process

- __Parse__  : (program_string -> program_array) Break program down into array of words.
- __Compile__: (program_array -> program) Interpret words into program structures.
- __Execute__: (program -> IO) Initiate call chain from main.