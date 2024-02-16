# PropositionalLogic.jl

A Julia implementation of Propositional Logic (see [PropositionalLogic.md](https://github.com/aidanjbailey/PropositionalLogic.jl/blob/master/PropositionalLogic.md)).

## Motivation

[Julia](https://julialang.org/) is an open-source, high-performance, dynamically typed, jit-compiled programming language initially introduced by MIT.
While an imperative language at its core, functional techniques are complimented by its 
[multimethods](https://en.wikipedia.org/wiki/Multiple_dispatch) and [pattern matching](https://en.wikipedia.org/wiki/Pattern_matching).
If Julia's inheritance is viewed as a tree, inner-nodes are abstract while leaves are abstract or concrete - functionality is shared through composition rather than inheritance.

[Propositional logic](https://en.wikipedia.org/wiki/Propositional_calculus) is well accomodated by Julia. First we will look at types.

### Types

*Propositional Formula*

The concept of a propositional formula is abstract - it applies to everything from a single atom to a string of atoms, constant symbols and connectives.
Julia allows us to capture this with an `abstract type` declaration, with `formula` now representing the root of our inheritance tree.

(WIP)
