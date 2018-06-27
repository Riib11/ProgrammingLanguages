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

        Axiom Lt (n m : Nat) : Relation Nat :=
        | S  : m = S n → Lt n m
        | Sn : Le n m → Lt n (S m)

        Axiom Gt (n m : Nat) : Relation Nat :=
        | S  : n = S m → Gt n m
        | Sn : Gt n m → Gt (S n) m

## Intermediate

Void type fun:
    
    Define false_implies_anything:
        ∀ (P:Prop), False → P
        := (f:False) ↦ match f 

    Define void_builds_anything:
        ∀ (A:Type), Void → A
        := 

## Advanced