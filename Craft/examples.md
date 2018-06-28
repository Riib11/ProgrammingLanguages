# Examples

## Special Symbols

syntax
`:`,`=`,`≠`,`|`,

arrows
`→`, `↦`, `↔`

logic
`∧`, `∨`, `∀`, `∃`

special
`#`

## Basic

Booleans:

    Axiom Boolean : Set := | true | false

    Scope Enter Boolean

        Define Relation (A:Type) := A → A → Boolean

        Define eq : Relation Boolean :=
            match a,b | true,true ↦ true | false,false ↦ true | _,_ ↦ false
        Pattern "a = b" (a b:Boolean) := 

    Scope Exit Boolean

Propositions:

    Scope Enter Proposition

        Axiom Conjunction {A B : Prop} : A → B → Prop :=
        | intro : A → B → Cojunction A B

        Axiom Disjunction {A B : Prop} : A → B → Prop :=
        | intro_left  : A → Disjunction A B
        | intro_right : B → Disjunction A B

        Axiom Not : Prop → Type :=
        | intro : ∀ (P:Prop), (P → False) → Not P

    Scope Exit Proposition

Relations:

    Scope Enter Relation

        Define Relation {A : Type} := A → A → Prop
    
        Define Nullary {A:Type} := A
        Define Unary   {A:Type} := A → A
        Define Binary  {A:Type} := A → A → A
        Define Ternary {A:Type} := A → A → A → A

    Scope Exit Relation

Natural Numbers:

    Scope Open Relation

    Scope Enter Natural

        Inductive Nat : Set :=
        | O : Nat
        | S : Nat → Nat
    
        Axiom Lt (n m : Nat) : Relation Nat :=
        | S  : m = S n → Lt n m
        | Sn : Le n m → Lt n (S m)

        Axiom Gt (n m : Nat) : Relation Nat :=
        | S  : n = S m → Gt n m
        | Sn : Gt n m → Gt (S n) m

        Recursive add (n m : Nat) : Binary Nat :=
            match n,m
            | O  , _   ↦ m
            | _  , O   ↦ n
            | S q, S r ↦ S S (add q r)
        Pattern "n + m" (n m : Nat) := add n m

        Recursive multiply (n m : Nat) : Binary Nat :=
            match n,m
            | O  , _  ↦ O
            | S q, _  ↦ q + (multiply q m)
        Pattern "n * m" (n m : Nat) := multiply n m

        Recursive factorial (n : Nat) : Unary Nat :=
            match n
            | O   ↦ 1
            | S m ↦ S m * (factorial m)
        Pattern "n !" (n : Nat) := factorial n

        Define secret : Nat := 5 * 6 * 4! + 3 + 10! * 2

    Scope Exit Natural

## Intermediate

Void type fun:
    
    Define false_implies_anything:
        ∀ (P:Prop), False → P
        := (f:False) ↦ match f 

    Define void_builds_anything:
        ∀ (A:Type), Void → A
        := TODO

## Advanced