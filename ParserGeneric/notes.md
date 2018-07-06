# Parser (Generic)

## Terminology

**Program**. Everything that is to be read by the parser.

**Pre-Content**. The part of the program that is flagged to be parsed and interpreted before the _content_ of the program.

**Content**. The main part of the program. Its what you focus on for running the program.

**Post-Content**. The part of program that is flagged to be parsed and interpreted after _content_ of the program.

**Phrase**. A section of code that is parsed from start to finish independently from the rest of the program.

## Types of Symbols

When the parser scans through your code, there are a few different kinds of symbols that it looks for: structurals, specials.

### Specials

Specials are designed with a particular structure that expects a specific kind of structure around them, and saves their context in their object when they are parsed. For example, an `if`,`then`,`else` special combination specifies three structural sections that are saved into the object representing the total parsed section:

    def letter :=
        if (true & true & false)    # section 1
            then "A"                # section 2
            else "B";               # section 3

### Structurals

Structurals are words that indicate structural features of a program. For example, the `;` might indicate the end of a phrase:

    def hello () := {
        print("hello"); # end inner phrase
    };                  # end outer phrase

Structurals might also just be reserved symbols that are recognized to be seperate from words they are attached to even if there are no spaces between them. For example,

    "hello "+"world";

should parse to

    " hello " + " world " ;

with the `"`s,`+` and `;` are seperated.

#### How to define context

The `context` parameter needed to instantiate a new `Structural` is tuple of integers with special meanings. The number in each position of the tuple, representing to the left and right of the special, represents with what priority the special will capture context in that direction. A `0` will capture nothing, and an `n` will capture words in that direction until it runs into a word with a priority of greater than or equal to `n`, in which case it will stop its reach right before tht word.