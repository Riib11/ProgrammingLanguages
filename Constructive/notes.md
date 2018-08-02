# Constructive

A dependently-type programming language with rewrite-based syntax designed to be a simple and single.

## Common Terms

- **Axiom**: When you are using `Axiom` to introduce a term, you are just _asserting_ that the (now referencable) term has the specified type and nothing more.

- **Build**: When you are using `Define` to introduce a term, you are _building_ a term of the correct type using other terms.

- **Construct**: When you are building a term of, say, type `X` using one of the constructors specified when you defined `X`, only then are you _constructing_ a term of `X`.

## Special Symbols

syntax
`:`,`=`,`≠`,`|`,

arrows
`→`, `↦`, `↔`

logic
`∧`, `∨`, `∀`, `∃`

special
`#`

## Notes Notation

`#` specifies the rest of a line to be ignored programatically, in a code block.

- `#>` signifies that the following comment is supposed to be the debug output of the code on the left of the `#>`.
    
- `#:` signifies that the following comment is supposed to be the signature of the term on the left.

`###`...`###` specifies a spanning comment section (can be multiline).

## Types

### Type, the Type

    Axiom Type : (Type1 : (Type2 ...))

The type `Type` is a synonym for `Type0`, the base **level type**, as is the type of `Prop` and `Set`.

### Prop Type (Impredicative)

    Axiom Prop : Type

The type `Prop` is impredicative and has proof-irrelevant terms (have `∀ p1 p2:P, p1=p2`). As such, `Prop` constructions are discarded for program execution. There two built-in inhabitants of `Prop`, which are `True` and `False` (they are detailed later on). Props are useful for propositions that don't don't have a computational component.

An example, `Equal : A → A → Prop` is the `Prop` representing equality in `A`, where `A` is a type. The introduction rule for `Equal` is simply `∀ a:A, Equal a a`. So, if you have a term of type `Equal x y`, then you know that `x` equals `y`, and you can ignore, comptuationally, why. `Equal` is defined as so:

    Axiom Equal {A : Type} : A → A → Prop :=
    | reflexive : ∀ (x : A), Equal x x

    Pattern "x = y" := Equal x y

### Negative Types (Functions)

The negative types are characterized having elimination rules. You can *use* a negative type by *applying* it. You can *construct* a negative type by specifying the result of its application.

For example, `id {A : Type} : A → A` is a negative type with the elimination rule `id x ↦ x`. `id` is defined like so:

    Define id {A : Type} : A → A := x ↦ x

### Positive Types

The positive types are characterized by having introduction rules. You can _use_ a positive type by specifying a new term of the positive type using the introduction rule parameters. You can _construct_ a positive type by by **applying** the introduction rule.

For example, `And : Prop → Prop → Prop` is a positive type with the constructor `And.intro : ∀ A B, And A B`. `And` is defined like so:

    Axiom And : Prop → Prop → Prop :=
    | intro : ∀ (A B : Prop), And A B

You know its a positive type because you defined it using the `|` constructor syntax, where each `|` indicates the start of a constructor. Positive types come with a few special features automatically:

##### `*.constuctor`

This axiom is defined along with your type, and you generally never have to use it directly. It's a type sum of the constructors that you defined by name using the `|`s. For example, if you defined a type

    Axiom X : Set :=
    | A : X
    | B : X → X
    | C : X → X → X

then you get

    Axiom X.constructor : (Unit) * (Unit → Unit) * (Unit → Unit → Unit)

`Unit` is a kind of building block for positive types in this way. Also automatically defined with `X` would be the shorthands
    
    Scope Open X
    Define A := fst (fst constructor)
    Define B := snd (fst constructor)
    Define C := snd constructor

as the constructor's type expression associatively expands (left) to
    
    ((Unit) + (Unit → Unit)) + (Unit → Unit → Unit)

##### `*.eqaulity`

Equality for positive types is predicated on constructive nestequality, especially for dependent types. Equality is already built-in independently as

    Axiom Equal {A : Type} : A → A → Prop :=
    | reflexivity : ∀ (x : A), Equal x x

So `*.nestequality` implements a method for constructing equality for positive types. For our example type `X`, we get

    Scope Open X
    Axiom nestequality
        : ∀ (x1 x2 x3 x4 : X)
        , A = A
        ∧ x1 = x2 → B x1 = Bx2
        ∧ x1 = x3 → x2 = x4 → C x1 x2 = C x3 x4

Using the keyword `nestequality` you can build an equality that automatically extracts the right part of the and clause in `*.nestequality` and applies your arguments to it (in order). For example,
    
    Scope Open B
    Define test : C A A = C A A :=
        nestequality r r 
        where r : A = A := nestequality A

This may seem like a roundabout way to construct equality, and it is, sort of, but it can beuseful sometimes. For example, it allows you to explicitly extract the terms you need to provide to construct the higher-level equality that you want.

_Note_: `nestequality` is in an overloaded reference in the third line of the example above. How is it handled? Well, `X.nestequality` has the lengthy type specified slightly higher above doesn't have the type `A = A → A = A → C A A = C A A`, but just plain `nestequality` can, so it is used!

##### `*.match`

To take advantage of `*.constructor` in the most obvious way, you can pattern match with it, and thats exactly what `*.match` implements for each positive type individually. So, for our type `X` from earlier, you get

    Scope Open X
    Axiom match : ∀ (x:X)
        , x = A
        ∨ x = B
        ∨ x = C

In other words, if you have an `x:X`, you know it had to be constructed using one of `X`'s constructors. If you somehow assume via axiom that there's an `x:X` that doesn't follow thing rule, then you've got yourself a contradiction so don't do that! There's a reason its set up this way, trust me. `*.match` is used by the `match` keyword, which is explained in the [Keywords and Special Symbols](#keywords-special-symbols) section.

##### `*.discriminate`

Combining the logic of `*.equality` and `*.match`, you get the extremeley useful constructor discrimination rule. This rule allows you to draw a contradiction from any expression that asserts the `*.equality` of two terms of a positive type when the terms are no constructred with the same constructor. Formally, for our type `X` again,

    Scope Open X
    Axiom discriminate
        : ∀ (x y x1 x2 : X)
        , A ≠ B x1
        ∧ A ≠ C x1 x2
        ∧ B x ≠ A
        ∧ B x ≠ C x1 x2
        ∧ C x y ≠ A
        ∧ C x y ≠ B x1

which may seem like a lot at first, but its actually extremeely structured. It's constructred from the possible combinations of the constructors, that's all. Take a minute to look it over. Using the `discriminate` keyword will search through the relevant `*.discriminate` property and produced the counterexample you're looking for, as described in the [Keywords and Special Symbols](#keywords-special-symbols) section.

### Set Type (Predicative)

    Axiom Set : Type

The `Set` type is a positive type that is predicative and has proof-relevant terms (possible to have `∃ s1 s2:S, s1≠s2`). Sets are useful for computation.

An example `Bool : Set`, is a set of two elements, `true` and `false`. It's very important to keep these distinct for computation! `Bool` is defined like so:

    Axiom Bool : Set :=
    | true  : Bool
    | false : Bool

### Unit Types (Unit, True, and Null)

The unit types are derivable from any context. In other words, they are positive types with a single constructor, `Unit.intro : Unit`.

There are three flavors of unit types built-in, which are `Unit : Type`, `True : Prop`, and `Null : Set`. They are defined like so:

    Axiom Unit : Type := | intro : Unit
    Axiom True : True := | intro : Unit
    Axiom Null : Set  := | intro : Unit

### Void Types (Void and False)

The void types are positive types with exactly zero constructors. In other words, they are underivable from any non-contradictory context.

There are two flavors of void types build-in, which are `Void : Type` and `False : Prop`. They are defined like so:

    Axiom Void  : Type
    Axiom False : Prop

There is no corresponding void type for `Set` because youd should never encounter a void in a computational setting!

### Dependent Type Sums

A dependent type sum has terms of the form

    sum( B x over x:A )

where `A B : Type, B : A → Type`. A way to think about it is the disjoint union of types. Dependent sums are defined like so:

    Axiom Sum : ∀ (A B : Type), Type :=
    | intro1 : A → Sum A B
    | intro2 : B → Sum A B

    Pattern "A + B" := Sum A B

A place where you may have scene this is with `Prop`'s `Or` disjunction. You could say there's a structural equivelance between `A ∨ B` and `A + B`.

Some useful functions for dealing with sums:

### Dependent Type Product

A dependent product is a function `b : ∀ x:A, B(x)` where `B : A → Type`. A way to think about this is the cartesian product of types. Dependent sums are defined like so:

    Axiom Product : ∀ (A B : Type), Type :=
    | intro : A → B → Product A B

    Pattern "A * B"
        (A B : Type)
        := Product A B
    Pattern "a , b"
        (A B : Type) (a : A) (b : B)
        := intro a b

A place where you may have scene this is with `Prop`'s `And` conjunction. You could say there's a structural equivelance between `A ∧ B` and `A * B`.

Some useful functions for dealing with products:

    Define fst : A * B → A :=
        axb ↦ match axb with
              | intro a b ↦ a
    
    Define snd : A * B ↦ B :=
        axb ↦ match axb with
              | intro a b ↦ b

### Inductive Types

The inductive types are positive types that follow a specific format, allowing a special Induction axiom.

    Inductive Nat : Type :=
    | O : Nat
    | S : Nat → Nat

    // automatically created by program
    Axiom Nat.Induction :
        ∀ (P : Nat → Nat) (n : Nat),
            (P Nat.O ∧ P n → P Nat.S n)
        → ∀ n, P n

## Vocabulary

### Headers

Every sentence starts with a header (although it may be implicit). All headers are capitalized. Some example headers are:

#### `Axiom`

The `Axiom` header specifies a new term of an existing type. Note that this term will be considered unique from any other previously-specified terms of the same type. The name "Axiom" reflects that this header signifies a new assumption. For example, if you have previously defined

    Axiom Bool : Set := | true | false

and then state

    Axiom x : Bool

then, from only this information, all other things consistent, you cannot prove that `x = true ∨ x = false`. In fact, this is actually an insight into how `Axiom` expands to simplest form. In this case,

    Axiom Bool : Set := | true | false

expands to
    
    Axiom Bool : Set
    Axiom Bool.constructor : Unit * Unit
    Define Bool.true  := fst Bool.constructor
    Define Bool.false := snd Bool.constructor
    Axiom Bool.match : ∀ (b:Bool)
        , b = Bool.true
        ∨ b = Bool.false

The `match` property is needed for performing `match`s on bools, derived from their only specified constructors. From previously, another example

    Axiom Equal {A : Type} : A → A → Prop :=
    | reflexivity : ∀ (x : A), Equal x x

fully expands to

    Axiom Equal :
        ∀ (A:Type),
        A → A → Prop
    
    Axiom Equal.reflexivity {A:Type} : ∀ (a:A), Equal A x x

#### `Inductive`

The `Inductive` header indicates that the following type structure has the special inductive property. So the definition of `Nat` like this:

    Inductive Nat : Set :=
    | O : Nat
    | S : Nat → Nat

fully expands to

    Axiom Nat : Set
    Axiom Nat.constructor : Unit * (Unit → Unit)
    Define Nat.O := fst Nat.constructor
    Define Nat.S := snd Nat.constructor
    Axiom Nat.match : ∀ (n:Nat)
        , n = Nat.O
        ∨ ∃ (m:Nat), n = Nat.S m
    Axiom Nat.Induction : ∀ (P : Nat → Nat) (n : Nat)
        , P Nat.O ∧ P n
        → P Nat.S n
        → ∀ n, P n

#### `Define`

The `Define` header creates a new name that is binded to a term that is constructed using other terms. Note that, differently from `Axiom`, the binded term is not necessarily unique from any other terms binded by other `Defines`. For example,

    Define x : Nat := 1
    Define y : Nat := 1
    
    Define x_eq_y : x = y
        := Equal.reflexivity 1

If you run the checks you'll get these

    Check x_eq_y #: x = y
    PostCheck x_eq_y #: 1 = 1

`PostCheck` reflects what will actually be scene when the code is run, as only in the type-checking phase that `Check` operates in are names not substituted by their bindings.

#### `Recursive`

The `Recursive` header works in almost the same way as the `Define` header except that it allows recursive definitions, as you may have guessed. Not a lot new here, but take a look at the classic example:

    Recursive fibonacci (n:Nat) : Nat :=
        match n
        | O     ↦ O
        | S O   ↦ S O
        | S S m ↦ fibonacci (S m) + fibonacci (m)

_Note:_ This may end up being merged with `Define` so that you don't have to distinguish them.

#### `Monad`

A monad is a structure that specifies a process for execution rather than a value for binding. In other words, all monads implement an execution process, which can take inputs and return outputs. A classic monad for demonstrating this concept is the monad `IO`:

    Monad IO : 

#### `Pattern`

The `Pattern` header is a super useful and versatile macro-creation device. Don't worry about infixes or spaces any longer! Just a simple pattern can take care of almost any notational specialty you'd like to include. The notation of `Pattern` starts with the raw pattern in `"`s, followed by variables included in the pattern (if any), followed by a `:` and signature (optional), and finally ended with a `:=` and binding. The binding may be either a term, or string (using `"`s). For example, here's a neat way to type playing cards and then reference them.

    Axiom Suite : Set :=
        | Clubs | Spades | Hearts | Diamonds
    
    Axiom Rank  : Set :=
        | Ace   | Two  | Three | Four | Five  | Six  | Seven 
        | Eight | Nine | Ten   | Jack | Queen | King
    
    Axiom Card : Set :=
        | intro : Suite → Rank → Card

    Pattern "rank of suite"
        (rank:Rank) (suite:Suite) : Card
        := Card.intro suite rank

    # Usage:
    Check Two of Spades #> Card

Additionally, with the easy macro-ing with string outputs, you can quickly implement infixes. For example, with a simple `+` operator infix:

    Define + := Nat.add
    Pattern "n + m" (n m : Nat) := "+ n m"

This may be eventually implemented as a vocabulary command (like in coq), in some way like

    Define + := Nat.add
    Infix 1, + # directly tranlates to the Pattern approach above

_Note:_ When you specify that a variable name is present in a `Pattern` string, the parser automatically take into consieration that term names can written in slightly different ways with slightly different decorations. For example, taking the previous pattern example, all the following statements will all work in the parser with the defined `"rank of suite"` pattern:

    Scope Open Suite, Rank # access constructors

    Define suite : Suite := Hearts
    Overload Define Ace : Type := Void

    Define card1 : Card := (Ace:Rank) of suite
    Define card2 : Card := (Ace:Rank) of (suite:Suite)
    Define card3 : Card := Ace of suite

#### `Overload`
#### `Check`
#### `PostCheck`
#### `Compute`
#### `Execute`

### Keywords / Special Symbols

All keywords are uncapitalized, and neither keywords nor special symbols can be overloaded.

#### `match`

To use `match`, write something like

    match a
    | a1 x y ↦ something
    | a2 x   ↦ something else

where `a` is a term of type `A`, and each `|` indicates the start of a function that maps the constructor of `A` referenced (in this example, `a1`, and `a2` are constructors of `A`). This allows the phrase to evaluate to either something or something else based on what constructor of `A` that `a` was built with. In this case, `A` only has two constructors, `a1` and `a2`, but in any match you need to have a function specified to deal with each constructor of the type that you are matching with. The `match` keyword references the `A.match` axiom defined (automatically) alongside types when you create them using the constructor (`|`) syntax.

You may also do some more fancy matching, where you take advantage of nested constructions of terms like so:

    Define bounded_minus3 : Nat → Nat :=
        match n
        | O       ↦ O
        | S O     ↦ O
        | S S O   ↦ O
        | S S S m ↦ m

    Recursive pair_max : (Nat,Nat) → Nat :=
        match n,m
        | O,O      ↦ O
        | S q, O   ↦ S q
        | O, S r   ↦ S r
        | S q, S r ↦ pair_max q r

#### `if`,`then`,`else`

The typical clause you're familiar with. It has a signature and pattern rule like this

    Scope {A:Type} (b:Bool) (a1 a2:A) : A {

        Define IfElse :=
            match b
            | true ↦ a1
            | false ↦ a2
        
        Pattern "if condition then a1 else a2" := IfElse condition a1 a2

    }

#### `discriminate`

To use `disciminate`, write something like
    
    Define true_neq_false
        : false ≠ true
        := discriminate false true

Discriminating creates a proof of inequality between terms of the same type that are constructed with different constructors. In this case, `false` and `true` don't take any arguments so its easy to see. Note that you couldn't write this:

    Define O_neq_S
        : O ≠ S
        := discriminate O S

because although `O` and `S` are constructors of `Nat`, they have different types, `Nat` and `Nat → Nat` respectively. Instead, for this example, you'd want to write

    Define O_neq_S
        : ∀ (n:Nat), O ≠ S n
        := discriminate O S

since discriminating `O` and `S` will need to prefix an `∀ (n:Nat)` for `S`'s argument.

#### `reductio`

Using this keyword is the typical way you will construct proofs by reductio ad absurdum.

    Define reductio {A:Prop}
        : (A → False) → ¬ A
        := ...

The above is a sort of psuedo-definition for term named `reductio`, however the keyword is different. The format of the above `reductio`'s typing here is to reflect the process of first assuming `A`, then showing some contradiction, and thus getting `¬ A` out of the exchange. Contradiction is an extremely common and powerful proof technique for good reason. Instead of using in quite tht way, however, `reductio` the keyword instead introduces a new goal `False` and a new assumption `A` (where `A` is implied by external typing). Here's a round-about but illuminating example:

    Define true_eq_true : true = true :=    
        reductio
            (contradiction (reflexivity true))

In this case, `Define` implies onto

    reductio (contradiction (reflexivity true))

the type `true = true`. Then `reductio` implies onto
    
    (contradiction (reflexivity true))

the type `(true ≠ true → False)`. `contradiction` determines that since `(reflexivity true)` has type `true = true`, it must in total have type `contradiction : true = true → true ≠ true → False`. As it is applied, this yields the term

    (contradiction (reflexivity true))

to have the right type for `reductio` to use, so the term is successfully defined!

_Note:_ `reductio` may not even need to be a keyword I guess I just have to define it properly.

#### `let`,`in`

Starting an expression with `let` indicates that everything between the `let` and following `in` should be treated as locally defined in a scope containing the expressions after the `let` and the final expression after the `in`, and this local scope cannot be accessed from outside (its a temporary scope). For example,

    Define x :=
        let
            a := 1
            b := 2
            c := 3
        in
            a + b + c

    Compute x #> 6

Only `Define` headers may be used inside the `let`,`in` clause, and if they are left out they are implied, as they are in the example above.

#### `where`

`where` clauses work in the same way as `let`,`in` clause, but with a different ordering. Ending an expression with `where` indicates that the clause following the `where` will be a temporary scope in following the same rules as a `let`,`in` that is accessable by the expression preceeding the `where`. Rewriting the example in `let`,`in` section,

    Define x := a + b + c
        where
            a := 1
            b := 2
            c := 3

Deciding between `let`,`in` clauses and `where` clauses is a purely aesthetic desicion.

#### `introduce`

Sometimes when building proof terms, you may have something that looks like

    ... Nat → Nat → Prop

where in building the term you'd like to reference the actual terms by name that are going to be provided when this proof is used. The name `intro` borrows from Coq and works in a very similar way. For example,

    Recursive Nat.add : Nat → Nat → Nat :=
        match n,m
        | O  , _   ↦ n
        | _  , O   ↦ m
        | S q, S r ↦ S S (Nat.add q r)
        where
            introduce n,m

`introduce` will create as many names as you provide that correspond to variables of the parenthetical expressions between outer arrows, from left to right, in the typing of the name `Recursive` is currently defining, and stopping at the last outer arrow. An _outer_ arrow is one that isn't contained by any explicit parentheses that begin after the colon. Remember that `→` associates right, so

    Nat → Nat → Nat

parenthetically expands to

    Nat → (Nat → (Nat))

making the intro sequence as expected from left to right, one `Nat` at a time. However, if you had typed `add` like this

    Recursive Nat.add : (Nat → Nat) → Nat :=
        let
            introduce f #: Nat → Nat
        in
            # don't end up using f at all...
            n m ↦
            match n,m
            | O  , _   ↦ n
            | _  , O   ↦ m
            | S q, S r ↦ S S (Nat.add q r)

things wouldn't be working out as planned probably, since `f` is a single-arity function and not really useful in the example.

Also remember that if you already named the variables on either side of the colon in a way like this

    Recursive Nat.add (n:Nat) : ∀ (m:Nat), Nat :=
        match n,m
        | O  , _   ↦ n
        | _  , O   ↦ m
        | S q, S r ↦ S S (Nat.add q r)
    # n and m were named as variables already

then you don't need to use intro at all! These techniques can be combined as well:

    Recursive Nat.make_adder (n:Nat) : Nat → Nat :=
        match n,m
        | O  , _   ↦ n
        | _  , O   ↦ m
        | S q, S r ↦ S S (Nat.make_adder q r)
        where
            introduce m

    Recursive Nat.make_adder (n:Nat) : Nat → Nat :=
        match n
        | O   ↦ m ↦ n
        | S q ↦ m ↦ S (Nat.make_adder q m)

This may seem like a sort of gimmick, but it actually is a great way to make you code readable when you start to have complicated `let` or `where` clauses in which you either nest clauses or work with subgoals. Note that when you nest `where`s, the outer name's signature will not be avaliable to `introduce`, and only the `where` clause's immediate target will be. For example,

    Define true_eq_true : true = true :=
        let
            r_pf : true ≠ true → False := counter
                where
                    introduce true_neq_true
                    counter := contradiction
                        (reflexivity true)
                        true_neq_true
        in
            reductio r_pf

At the second `where` we are entering name "pf", so the introduction expressions order looks like, from this scope,

    true ≠ true → False

This is important because when `introduce` is used, it takes the `true ≠ true`.

###### `:`
###### `→`
###### `|`
###### `↦`
###### `∀`
###### `∃`

See [Exists Statement](#exists-statement)

## Type Judgements

A type judgement is of the form

    term : type

where the `:` importantly seperates them. A type judgement asserts that the `term` has the type `type`.

### Term

A term is a name that inhabits a type.

### Type

A type is a name the provides structure and rules for its terms.

### Signature

A signature is a construction of types using type names, parameters, and function arrows. For example, if we take

    Axiom A : B → C → Type :=
    | intro b c : A b c
    Axiom b : B
    Axiom c : C

and form

    Define a := A.intro b c

Then we can correctly judge that

    a : A

More simply, we can just

    Check a #> a : A

### Variables in Sigantures

In signatures, you may want to refer to the same value more than once. To do this, there are a few special ways to include variables in signatures. They are detailed in the next two sub-sections, but below is a comprehensive list:
    
    # Explicit parameters come before the colon,
    # and if types are specified, parentheses surround inidividual
    # parameters, or optionally parameters of the same type can
    # be seperated by spaces in the same parenthetic group.

    Axiom f (x : Real) : Real     #: Real → Real
    Axiom g (x y z : Real) : Real #: Real → Real → Real → Real

    # Can also be done like this

    Define add_one : ∀ (x:Nat), Nat := x ↦ S x #: Nat → Nat
    Pattern "x + 1" (x:Nat) : Nat := add_one

    # Implicit parameters come before the colon
    # and also before any explicit parameters.
    # Scopes can have parameters that are inherited
    # by the enscoped names.

    Scope {X : Set} (f : Real → X) (g : X → Real) {
        Define compose  := (x : Real) ↦ g (f x)
        Pattern "g * f" := compose g f
        #: {X : Set} (f : Real → X) (g : X → Real)
    }

    Define h := g * f #: Real → Real

    # Can also do this neat trick

    # Scoped names can inherit types too

    Axiom Bool : Type := | true | false

    Scope Bool (b:Bool) : Bool {
        # the first "Bool" scopes inside the name
        # the "b:Bool" variable indicates that names
        # inside this scope have this first explicit variable
        # the second "Bool" indicates the names inside
        # this scope have signatures that end with Bool
        Define not := match b | false | true #: Bool → Bool
    }

#### Explicits

You may write explicit variables either before or after the colon, but each way has a unique syntax. If the types of the variables are specified, parentheses are required around the variable names and their types.

Before the colon (parameter syntax):

    Define f (a b c : Nat) : Nat := a * b + c * d
    #: Nat → Nat → Nat → Nat

After the colon ("forall" syntax):

    Axiom f : ∀ (a b c d: Nat) : Nat := a b c d ↦ a * b + c * d
    #: Nat → Nat → Nat → Nat

The difference netween these, as you may notice, is that in the "forall" syntax the right side of the `:=` must example have the type specified by the right side of the colon of the type judgement, whereas in the parameter syntax the variables didn't appear on the right side of the colon for judging `f`, so the `a b c d` didn't need to be repeated, and just the resulting `Nat` value of `a * b + c * d` needed to be stated.

Because of this, the parameter syntax is a little more flexible, but the "forall" syntax can be more flavorful and expressive sometimes, as well as allowing outer types to contain variables, such as in

    Axiom liebniz (n m: Nat) : n = m → ∀ (P:Nat→Nat), P n → P m
    Define props_for_one := liebniz 1 1 (Equal.reflexivity 1)
    #: ∀ (P:Nat→Nat), P 1 → P 1

#### Implicits

You may only write implicit variables before the colon, before any expicit variables. Implicit variables are unique in that they are tagged to require inference when they are used. For example,

    Define id {A:Type} (a:A) := a #: A → A

The `{A:Type}` is not included in the signature of the name `id`, since the parameter is not to be given when using the name. There is a little flexibility to this though. You can specifically pass implict parameters like so:

    Compute id {Set} 1 #> 1

This can be useful if there are times when you may be using symbols for multiple things (overloading), which is fine but required explicit typing sometimes.

#### Exists Statement

In signatures, you can say that something has the type `∃ (x:A), Px` where `x` is a variable name, `A` is a type, and the `Px` is a `Prop` about `x`. For example you might say

    Axiom nat_has_no_maximum:
        ∀ (n:Nat), ∃ (m:Nat), n < m

`∃ x, Px` is really just notation for the `InhabitedDomain` type:

    Axiom InhabitedDomain {A:Type} (P:A→Prop) : Prop :=
    | intro {A:Type} {P:A→Prop} (wt : A) (pf : P wt) : InhabitedDomain P

    Pattern "∃ x, Px"
        {A:Type} (x:A) (Px:Prop) : Prop
        := "InhabitedDomain (x ↦ Px)"

Here's some more notation for the lengthy `InhabitedDomain.intro` constructor:

    Pattern "example wt pf"
        {A:Type} {P:A→Prop} (wt:A) (pf:A→Prop) : InhabitedDomain P
        := InhabitedDomain.intro wt pf

So, we can write the original axiom in its expanded form

    Axiom nat_has_no_maximum: ∀ (n:Nat), InhabitedDomain (m ↦ n < m)

To prove this rather than take it as an axiom:

    Define nat_has_no_maximum: ∀ (n:Nat), InhabitedDomain (m ↦ n < m) :=
        let
            wt := Nat.S n        #: Nat
            pf (n:Nat) := Lt.S n #: ∀ (n:Nat), n < S n
        in
            InhabitedDomain.intro wt pf

Or we can do it this way, of course as inspired by Haskell's unforgettable `where` syntax:

    Define nat_has_no_maximum: ∀ (n:Nat), InhabitedDomain (m ↦ n < m) :=
        InhabitedDomain.intro wt pf
        where
            wt := Nat.S n        #: Nat
            pf (n:Nat) := Lt.S n #: ∀ (n:Nat), n < S n

The writing out of `InhabitedDomain` and its slightly counter-intuitive formatting makes using the `∃ x, Px` pattern the most efficient in most cases, like this final proof (in quickest form) demonstrates:

    Define nat_has_no_maximum : ∀ (n:Nat), ∃ (x:Nat), n < m :=
        example wt pf
        where # succ of n is always greater than n, by Lt.S
            wt := Nat.S n
            pf (n:Nat) := Lt.S n

## Names

To use a name, first type the name, then supply as many parameters as you want like so:

    name var1 var2 var3 ...

### Associativity

- **Left Associativity**: A B C -→ (A B) C
- **Right Associativity**: A B C -→ A (B C)

The rules for associativity are outlined here, in order from greatest to least priority:

| Phrase        | Rule  | Example                             |
|---------------|-------|-------------------------------------|
| Vocab         | left  | Scope Open Nat ==> (Scope Open) Nat |
| ∃ x, Px       | right | ∃x, ∃y, ∃z, x=y=z ==> ∃x, (∃y, ∃z, x=y=z) |
| ∀ x, Px       | right | ∀x, ∀y, ∀z, x=y=z ==> ∀x, (∀y, ∀z, x=y=z) |
| ↦             | right | x ↦ y ↦ z ==> x ↦ (y ↦ z) |
| →             | left  | A → B → C ==> (A → B) → C |
| default       | left  | f g h ==> (f g) h |


## Compilation

Compiling a Constructive program is divided into several phases:

1. **Expansion**

The compiler scans through the  program and fully expands all expressions. This means adding in parentheses and seperating variable spaces and all that, as well as shifting everything other than names to the right of the type judgement `:`s. Observe:

    Define f x := x + 1
    Define lemma : ∃ (x y:Bool), x = y ∧ x = false

expands to

    (
        (
            (Define)
            (f)
        )
        (:)
        (
            (∀) (x:?)
        )
        (:=)
        (
            (x) + (1)
        )
    )

    (
        (
            (Define)
            (lemma)
        )
        (:)
        (
            ((∃) (x:Bool)),
            (
                ((∃) (y:Bool)),
                (
                    ( ((x) =) (y) )
                    (∧)
                    ( ((x) =) (false) )
                )
            )
        )
    )

The parentheses all are exactly resulting from associativity rules. The `?`s indicates that a typing was expected, but none was given explicitly. So, the `?`s are to be infered by the type checking process.

2. **Patterns**

The compiler specifically looks for `Pattern` declarations, and ignores everything else. The scope of the `Pattern` declarations are noted.

3. **Parsing**

THe compiler makes sure that syntax rules are followed correctly in all lines of the program. Instances where a pattern _may_ be applied are tagged with the possible patterns that could possibly apply there. In the type checking phase, the correct interpretation (if any) will be determined. Errors that result from this pattern parsing (if no possible interpretation type-checks) will be a type checking error thrown in the next section.

4. **Type Checking**

Next, the type checker checks each module, in a tree leaf-to-root fashion of independence, for correct typings.

5. **Execution**

`Execute`s are run.

## Values

Value are represented differently in three sequencial phases.

1. **Referencing Values**

Lazily-bound value are how your names are initially interpretted by the compiler. When you write something like

    Define x : Nat := 1

The name `x` is bound to the value `1`. This means that, via a beta-reduction application, `x` reduces to `1`. However, this reduction is only guranteed to have been performed by then end of the `Reducing Values` step.

This type of reduction applies to functions as well. For example in,

    Define not (b:Bool) := match b | true↦false | false↦true
    Define not_false := not false

`not_false` is bound to `not false`. Only via a beta-reduction step can we reduce this binding to `true`.

2. **Reducing Values**

Values are 'computed' via applying beta-reduction until terms are completely reduced. For example, if we had

    Define a := 1
    Define b (x:Nat) := a
    Define c := b 2
    Define d := c

the then the steps to find the value of `Compute c` are

    Compute c
    ==> d
    ==> c
    ==> b 2
    ==> a
    ==> 1

3. **Returning Values**

The process of _returning_ is critically different from the process of _computing/reducing_. All terms can reduce, but only _executable_ terms can return. So what's an executable term? Generally, these are referred to as monads. Monads are special in that they do not describe a value but instead describe a process for obtaining a value. A Monad always has specifies its return type as the type of the term that can be expected to be obtained when the monad is executed. To obtain this value, use the header [`Execute`](#execute), as described in the Headers section.



## Scopes
### Named Scopes
#### Unparametrized Scopes
#### Parametrized Scopes
### Anonymous Scopes
### Modules