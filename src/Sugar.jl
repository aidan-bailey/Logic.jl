module Sugar

using ..Syntax
using ..Parsing

Base.convert(::Type{Formula}, x::String) = str2form(x)
Base.convert(::Type{Formula}, x::Char) = str2form(string(x))
Base.convert(::Type{Formula}, x::Int) = Syntax.Atom(x)
Base.convert(::Type{Formula}, x::Formula) = x
function Base.convert(::Type{Formula}, x::KnowledgeBase)
    if isempty(x)
        return Contradiction()
    elseif length(x) == 1
        return pop!(collect(x))
    end
    kCopy = copy(x)
    form = pop!(kCopy)
    while !isempty(kCopy)
        form = and(form, pop!(kCopy))
    end
    return form
end

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

I(atoms::Union{String, Char, Int, Atom}...) = Interpretation(map(a -> a isa Atom ? a : Atom(a), atoms))
export I

K(formulas...) = KnowledgeBase(map(a -> Base.convert(Formula, a), formulas))
export K

clause(α...) = Clause(map(x -> Base.convert(Formula, x), α))
export clause

end
