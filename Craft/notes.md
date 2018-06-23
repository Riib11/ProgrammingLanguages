# Craft

A dependently-type programming language with rewrite-based syntax designed to be a simple and single.

## Special Symbols

syntax
:,=,≠,|,

arrows
→, ↦, ↔

logic
∧, ∨, ∀, ∃

special
#

## Notes Notation

`# ` specifies the rest of a line to be ignored programatically, in a code block. Additionally, `#->` signifies the the following comment is supposed to be the debug output of the code on the left of the `#->`.

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

### Set Type (Predicative)

    Axiom Set  : Type

The `Set` type is predicative and has proof-relevant terms (possible to have `∃ s1 s2:S, s1≠s2`). Sets are useful for computation.

An example `Bool : Set`, is a set of two elements, `true` and `false`. It's very important to keep these distinct for computation! `Bool` is defined like so:

    Axiom Bool : Set :=
    | true  : Bool
    | false : Bool

### Negative Types (Functions)

The negative types are characterized having elimination rules. You can *use* a negative type by *applying* it. You can *construct* a negative type by specifying the result of its application.

For example, `Id {A : Type} : A → A` is a negative type with the elimination rule `Id x ↦ x`. `Id` is defined like so:

    Define Id {A : Type} : A → A := x ↦ x

### Positive Types

The positive types are characterized by having introduction rules. You can _use_ a positive type by specifying a new term of the positive type using the introduction rule parameters. You can _construct_ a positive type by by **applying** the introduction rule.

For example, `And : Prop → Prop → Prop` is a positive type with the constructor `And.intro : ∀ A B, And A B`. `And` is defined like so:

    Axiom And : Prop → Prop → Prop :=
    | intro : ∀ (A B : Prop), And A B

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

TODO

### Dependent Type Product

A dependent product is a function `b : ∀ x:A, B(x)` where `B : A → Type`. A way to think about this is the cartesian product of types. Dependent sums are defined like so:

    Axiom Product : ∀ (A B : Type), Type :=
    | intro : A → B → Product A B

    Pattern "A * B"
        where (A B : Type)
        := Product A B
    Pattern "( a , b )"
        where (A B : Type) (a : A) (b : B)
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

## Syntax

### Headers

Every sentence starts with a header (although it may be implicit). Some example headers are:

###### Axiom

`Axiom` specifies a new term of an existing type. Note that this term will be considered unique from any other previously-specified terms of the same type. The name "Axiom" reflects that this header signifies a new assumption. For example, if you have previously defined

    Axiom Bool : Set := | true | false

and then state

    Axiom x : Bool

then, from only this information, all other things consistent, you cannot prove that `x = true ∨ x = false`. In fact, this is actually an insight into how `Axiom` expands to simplest form. In this case,

    Axiom Bool : Set := | true | false

expands to
    
    Axiom Bool : Set
    Axiom Bool.constructor : Unit + Unit
    Define Bool.true  := fst Bool.constructor
    Define Bool.false := snd Bool.constructor
    Axiom Bool.match : ∀ (b:Bool)
        , b = Bool.true
        ∨ b = Bool.false

The `match` property is needed for performing `match`s on bools, derived from their only specified constructors. From previously, another example

    Axiom Equal {A : Type} : A → A → Prop :=
    | reflexive : ∀ (x : A), Equal x x

fully expands to

    Axiom Equal :
        ∀ (A:Type),
        A → A → Prop
    
    Axiom Equal.reflexive :
        ∀ (A:Type) (x:A),
        Equal A x x

###### Inductive

The `Inductive` header indicates that the following type structure has the special inductive property. So the definition of `Nat` like this:

    Inductive Nat : Set :=
    | O : Nat
    | S : Nat → Nat

fully expands to

    Axiom Nat : Set
    Axiom Nat.constructor : Unit + (Unit → Unit)
    Define Nat.O := fst Nat.constructor
    Define Nat.S := snd Nat.constructor
    Axiom Nat.match : ∀ (n:Nat)
        , n = Nat.O
        ∨ ∃ (n':Nat), n = Nat.S n'
    Axiom Nat.Induction : ∀ (P : Nat → Nat) (n : Nat)
        , P Nat.O ∧ P n
        → P Nat.S n
        → ∀ n, P n

###### Define
###### Pattern
###### Check
###### Execute

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

    Check a #-> a : A

#### Explicits

Signatures

#### Implicits

### Writing Names

To use a name, first type the name, then supply as many parameters as you want like so:

    name param1 param2 param3 ...

## Values
### Evaluation (Beta-Reduction)
### Computation
### Referencing values

## Scopes
### Modules

## Examples

Type conjunctions and disjunctions:

    Axiom Conjunction {A B : Type} : A → B → Type :=
    | intro : A → B → Cojunction A B

    Axiom Disjunction {A B : Type} : A → B → Type :=
    | intro_left  : A → Disjunction A B
    | intro_right : B → Disjunction A B

Proposition negation:

    Axiom Not : Prop → Type :=
    | intro : ∀ (P:Prop), (P → False) → Not P

Relations:

    Define Relation {A : Type} := (A → A → Prop) → Type

Natural Numbers:

    Module Nat

        Inductive Nat : Set :=
        | O : Nat
        | S : Nat → Nat
        
        Scope Nat # adds things named like `Nat.*` to local scope

        Axiom Le (n m : Nat) : Relation Nat :=
        | S  : m = S n → Le n m
        | Sn : Le n m → Le n (S m)

        Axiom Gt (n m : Nat) : Relation Nat :=
        | S  : n = S m → Gt n m
        | Sn : Gt n m → Gt (S n) m

## Unique Ideas