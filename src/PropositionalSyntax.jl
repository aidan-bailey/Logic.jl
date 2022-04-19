module PropositionalSyntax

"Propositional formula supertype."
abstract type Formula end
export Formula

"Propostional constant supertype."
abstract type Constant <: Formula end
export Constant

"Propositional tautology type."
struct Tautology <: Constant end
export Tautology
⊤ = Tautology()
export ⊤
tautology = Tautology()
export tautology
Base.show(io::IO, ::Tautology) = show(io, "⊤")
Base.print(io::IO, ::Tautology) = print(io, "⊤")

"Propositional contradiction type."
struct Contradiction <: Constant end
export Contradiction
⊥ = Contradiction()
export ⊥
contradiction = Contradiction()
export contradiction
Base.show(io::IO, ::Contradiction) = show(io, "⊥")
Base.print(io::IO, ::Contradiction) = print(io, "⊥")

"Propositional atom type."
struct Atom <: Formula
    name::String
end
export Atom
name(α::Atom)::String = α.name
export name
Base.show(io::IO, a::Atom) = show(io, name(a))
Base.print(io::IO, a::Atom) = print(io, name(a))

"Propostional operator supertype."
abstract type Operator end
export Operator

"Propositional operation supertype."
abstract type Operation <: Formula end
export Operation
operator(operation::Operation) = operation.operator
export operator

"Propositional unary operator supertype."
abstract type UnaryOperator <: Operator end
export UnaryOperator

"Propositional unary operation type."
struct UnaryOperation{T <: UnaryOperator} <: Operation
    operator::T
    operand::Formula
end
export UnaryOperation
operand(operation::UnaryOperation) = operation.operand
export operand
function Base.show(io::IO, z::UnaryOperation)
    show(io, operator(z))
    show(io, operand(z))
end
function Base.print(io::IO, z::UnaryOperation)
    print(io, operator(z))
    print(io, operand(z))
end

"Propositional negation unary operator type."
struct Negation <: UnaryOperator end
export Negation
negation = Negation()
export negation
Base.show(io::IO, ::Negation) = show(io, "¬")
Base.print(io::IO, ::Negation) = print(io, "¬")
not(α::Union{Formula,String}) = UnaryOperation(
    Negation(),
    α isa String ? Atom(α) : α
)
export not
¬ = not
export ¬

"Propositional binary operator supertype."
abstract type BinaryOperator <: Operator end
export BinaryOperator

"Propositional binary operation type."
struct BinaryOperation{T <: BinaryOperator} <: Operation
    operator::T
    operand1::Formula
    operand2::Formula
end
export BinaryOperation
operand1(operation::BinaryOperation) = operation.operand1
export operand1
operand2(operation::BinaryOperation) = operation.operand2
export operand2
function Base.show(io::IO, z::BinaryOperation)
    show("(")
    show(io, operand1(z))
    show(io, operator(z))
    show(io, operand2(z))
    show(")")
end
function Base.print(io::IO, z::BinaryOperation)
    print("(")
    print(io, operand1(z))
    print(io, operator(z))
    print(io, operand2(z))
    print(")")
end

"Propositional disjunction operator type."
struct Disjunction <: BinaryOperator end
export Disjunction
disjunction = Disjunction()
export disjunction
Base.show(io::IO, ::Disjunction) = show(io, "∨")
Base.print(io::IO, ::Disjunction) = print(io, "∨")
or(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Disjunction(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
export or
∨ = or
export ∨

"Propositional conjunction operator type."
struct Conjunction <: BinaryOperator end
export Conjunction
conjunction = Conjunction()
export conjunction
Base.show(io::IO, ::Conjunction) = show(io, "∧")
Base.print(io::IO, ::Conjunction) = print(io, "∧")
and(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Conjunction(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
export and
∧ = and
export ∧

"Propositional implication operator type."
struct Implication <: BinaryOperator end
export Implication
implication = Implication()
export implication
Base.show(io::IO, ::Implication) = show(io, "→")
Base.print(io::IO, ::Implication) = print(io, "→")
implies(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Implication(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
export implies
→ = implies
export →

"Propositional biconditional operator type."
struct Biconditional <: BinaryOperator end
export Biconditional
biconditional = Biconditional()
export biconditional
Base.show(io::IO, ::Biconditional) = show(io, "↔")
Base.print(io::IO, ::Biconditional) = print(io, "↔")
equals(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Biconditional(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
export equals
↔ = equals
export ↔

"Propositional interpretation type."
const Interpretation = Dict{Atom, Bool}
export Interpretation

end
