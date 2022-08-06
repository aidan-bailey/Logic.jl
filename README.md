# PropositionalLogic.jl

(WIP)

A Julia implementation of Propositional Logic.

## Propositional Logic

[Propositional Logic](https://en.wikipedia.org/wiki/Propositional_calculus) is a framework for expressing, using formal notation, 
common logic we use in every day life.
For example, the propositional statement "birds fly" can be represented using the propositional formula 
$\textit{sparrow}\rightarrow\textit{fly}$, or in an abbreviated form, $\textit{s}\rightarrow\textit{f}$.
In this example, $\textit{s}$ and $\textit{f}$ are known as propositional _atoms_ and the $\rightarrow$ is a propositional _implication_ (a binary
type of propositional _connective_).
The language of propositional logic is defined recursively through stringing propositional formulas using propositional connectives.
For example, we can express the statement "sparrows fly and penguins do not fly" with the formula $(\textit{s}\rightarrow\textit{f})\land(\textit{p}\rightarrow\neg\textit{f})$,
where $\neg$ is the single unary type of propositional connective.
Propositional connectives are analogous to the operations found in [Boolean Logic](https://en.wikipedia.org/wiki/Boolean_algebra).

| Name                 | Operator | Notation          | Arity  |
|----------------------|----------|-------------------|--------|
| Negation             | NOT      | $\neg$            | Unary  |
| Conjunction          | AND      | $\land$           | Binary |
| Disjunction          | OR       | $\lor$            | Binary |
| Material Implication | IMPLIES  | $\rightarrow$     | Binary |
| Material Equivalence | IFF      | $\leftrightarrow$ | Binary |

## Motivation

[Julia](https://julialang.org/) is an open-source, high-performance, dynamically typed, jit-compiled programming language developed by MIT.
While at its core Julia an imperative language, functional techniques are rewarded thanks to 
[multimethods](https://en.wikipedia.org/wiki/Multiple_dispatch) and [pattern matching](https://en.wikipedia.org/wiki/Pattern_matching).
If one thinks of Julia inheritance as a tree, inner-nodes can be abstract types while only leaves can be concrete structs.
This design decision promotes composition as a means to sharing functionality, rather than relying heavily on inheritance.
