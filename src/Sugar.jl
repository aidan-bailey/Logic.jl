module Sugar

using ..Syntax

const ⊤ = Tautology()
export ⊤
const tautology = Tautology()
export tautology

const ⊥ = Contradiction()
export ⊥
const contradiction = Contradiction()
export contradiction

not(α::Union{Formula,String}) = UnaryOperation(Negation(), α isa String ? Atom(α) : α)
export not
const ¬ = not
export ¬
negation = Negation()
export negation

const disjunction = Disjunction()
export disjunction
or(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Disjunction(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
export or
const ∨ = or
export ∨

const conjunction = Conjunction()
export conjunction
and(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Conjunction(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
export and
const ∧ = and
export ∧

const implication = Implication()
export implication
implies(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Implication(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
export implies
const → = implies
export →

equals(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Biconditional(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
export equals
const ↔ = equals
export ↔
const biconditional = Biconditional()
export biconditional

end
