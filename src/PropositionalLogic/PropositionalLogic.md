# Propositional Logic

[Propositional Logic](https://en.wikipedia.org/wiki/Propositional_calculus) is a framework for expressing, using formal notation, 
common logic we use in every day life.
For example, the propositional statement "sparrows fly" can be represented using the propositional formula 
$\textit{sparrow}\rightarrow\textit{fly}$, or in an abbreviated form, $\textit{s}\rightarrow\textit{f}$.
In this example, $\textit{s}$ and $\textit{f}$ are known as propositional _atoms_ and the $\rightarrow$ is a propositional _implication_ (a binary
type of propositional _connective_).
The language of propositional logic is defined recursively through stringing propositional formulas using propositional connectives.
For example, we can express the statement "sparrows fly and penguins do not fly" with the formula $(\textit{s}\rightarrow\textit{f})\land(\textit{p}\rightarrow\neg\textit{f})$,
where $\neg$ is the single unary type of propositional connective.
The five types of propositional connectives are analogous to the operations found in [Boolean Logic](https://en.wikipedia.org/wiki/Boolean_algebra).

| Name                 | Operator | Notation          | Arity  |
|----------------------|----------|-------------------|--------|
| Negation             | NOT      | $\neg$            | Unary  |
| Conjunction          | AND      | $\land$           | Binary |
| Disjunction          | OR       | $\lor$            | Binary |
| Material Implication | IMPLIES  | $\rightarrow$     | Binary |
| Material Equivalence | IFF      | $\leftrightarrow$ | Binary |

After creating simple propositional formulas using these connectives (i.e. $\neg\alpha$, $\alpha\land\beta$, $\alpha\lor\beta$
, $\alpha\rightarrow\beta$, $\alpha\leftrightarrow\beta$), we assign truth-values to our propositional atoms allowing for truth 
tables to emerge.

| $\alpha$ | $\neg\alpha$ |
|----------|--------------|
| $F$      | $T$          |
| $T$      | $F$          |

| $\alpha$ | $\beta$ | $\alpha\land\beta$ |
|----------|---------|--------------------|
| $F$      | $F$     | $F$                |
| $F$      | $T$     | $F$                |
| $T$      | $F$     | $F$                |
| $T$      | $T$     | $T$                |

| $\alpha$ | $\beta$ | $\alpha\lor\beta$ |
|----------|---------|-------------------|
| $F$      | $F$     | $F$               |
| $F$      | $T$     | $T$               |
| $T$      | $F$     | $T$               |
| $T$      | $T$     | $T$               |

| $\alpha$ | $\beta$ | $\alpha\rightarrow\beta$ |
|----------|---------|--------------------------|
| $F$      | $F$     | $T$                      |
| $F$      | $T$     | $T$                      |
| $T$      | $F$     | $F$                      |
| $T$      | $T$     | $T$                      |

| $\alpha$ | $\beta$ | $\alpha\leftrightarrow\beta$ |
|----------|---------|------------------------------|
| $F$      | $F$     | $T$                          |
| $F$      | $T$     | $F$                          |
| $T$      | $F$     | $F$                          |
| $T$      | $T$     | $T$                          |

(WIP)
