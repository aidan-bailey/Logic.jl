module Sugar

using ..Syntax
using ..Parsing

Base.convert(::Type{Formula}, x::String) = parseform(x)
Base.convert(::Type{Formula}, x::Char) = parseform(string(x))
Base.convert(::Type{Formula}, x::Int) = Syntax.Atom(x)
Base.convert(::Type{Formula}, x::Formula) = x

const tautology = Tautology()
const ⊤ = Tautology()
export tautology, ⊤

const contradiction = Contradiction()
const ⊥ = Contradiction()
export contradiction, ⊥

const negation = Negation()
not(α) = UnaryOperation(negation, convert(Formula, α))
const ¬ = not
export negation, not, ¬

const disjunction = Disjunction()
or(α, β) = BinaryOperation(
    disjunction, convert(Formula, α), convert(Formula, β)
)
const ∨ = or
export disjunction, or, ∨

const conjunction = Conjunction()
and(α, β) = BinaryOperation(
    conjunction, convert(Formula, α), convert(Formula, β)
)
const ∧ = and
export conjunction, and, ∧

const implication = Implication()
implies(α, β) = BinaryOperation(
    implication, convert(Formula, α), convert(Formula, β)
)
const → = implies
export implication, implies, →

const biconditional = Biconditional()
equals(α, β) = BinaryOperation(
    biconditional, convert(Formula, α), convert(Formula, β)
)
const ↔ = equals
export biconditional, equals, ↔

end
