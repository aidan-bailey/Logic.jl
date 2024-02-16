module Syntax

"Propositional formula supertype."
abstract type Formula end
export Formula

"Propostional constant supertype."
abstract type Constant <: Formula end
export Constant

"Propositional tautology type."
struct Tautology <: Constant end
export Tautology
Base.show(io::IO, ::Tautology) = show(io, "⊤")
Base.print(io::IO, ::Tautology) = print(io, "⊤")

"Propositional contradiction type."
struct Contradiction <: Constant end
export Contradiction
Base.show(io::IO, ::Contradiction) = show(io, "⊥")
Base.print(io::IO, ::Contradiction) = print(io, "⊥")

"Propositional atom type."
struct Atom <: Formula
    name::Union{String, Int}
    Atom(n::Int) = new(n)
    Atom(n::SubString) = new(string(n))
    Atom(n::String) = new(n)
    Atom(n::Char) = new(string(n))
end
export Atom
name(α::Atom)::Union{String, Int} = α.name
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
struct UnaryOperation{OpType<:UnaryOperator,
                      FormulaType<:Formula} <: Operation
    operator::OpType
    operand::FormulaType
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
Base.show(io::IO, ::Negation) = show(io, "¬")
Base.print(io::IO, ::Negation) = print(io, "¬")

"Propositional binary operator supertype."
abstract type BinaryOperator <: Operator end
export BinaryOperator

"Propositional binary operation type."
struct BinaryOperation{OpType<:BinaryOperator,
                       LFormulaType<:Formula, RFormulaType<:Formula} <: Operation
    operator::OpType
    operand1::LFormulaType
    operand2::RFormulaType
end
export BinaryOperation
operand1(operation::BinaryOperation) = operation.operand1
export operand1
operand2(operation::BinaryOperation) = operation.operand2
export operand2
function Base.show(io::IO, z::BinaryOperation)
    show(io, "(")
    show(io, operand1(z))
    show(io, operator(z))
    show(io, operand2(z))
    show(io, ")")
end
function Base.print(io::IO, z::BinaryOperation)
    print(io, "(")
    print(io, operand1(z))
    print(io, operator(z))
    print(io, operand2(z))
    print(io, ")")
end

"Propositional disjunction operator type."
struct Disjunction <: BinaryOperator end
export Disjunction
Base.show(io::IO, ::Disjunction) = show(io, "∨")
Base.print(io::IO, ::Disjunction) = print(io, "∨")

"Propositional conjunction operator type."
struct Conjunction <: BinaryOperator end
export Conjunction
Base.show(io::IO, ::Conjunction) = show(io, "∧")
Base.print(io::IO, ::Conjunction) = print(io, "∧")

"Propositional implication operator type."
struct Implication <: BinaryOperator end
export Implication
Base.show(io::IO, ::Implication) = show(io, "→")
Base.print(io::IO, ::Implication) = print(io, "→")

"Propositional biconditional operator type."
struct Biconditional <: BinaryOperator end
export Biconditional
Base.show(io::IO, ::Biconditional) = show(io, "↔")
Base.print(io::IO, ::Biconditional) = print(io, "↔")

"Propositional interpretation type."
const Interpretation = Set{Atom}
export Interpretation

const KnowledgeBase = Set{Formula}
export KnowledgeBase

const Literal = Union{Atom, UnaryOperation{T, Atom}} where (T <: UnaryOperator)
export Literal

const Clause = Set{Literal}
export Clause

end
