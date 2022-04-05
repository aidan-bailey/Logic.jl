module PropositionalLogic

using PicoSAT

abstract type Operator end

abstract type Formula end

abstract type Operation <: Formula end

operator(operation::Operation) = operation.operator

struct Atom <: Formula
    name::String
end

const Valuation = Dict{Atom,Bool}

name(α::Atom)::String = α.name

Base.show(io::IO, a::Atom) = show(io, a.name)
Base.print(io::IO, a::Atom) = print(io, a.name)

abstract type Constant <: Formula end

struct Tautology <: Constant end
⊤ = Tautology()
tautology = Tautology()

Base.show(io::IO, ::Tautology) = show(io, "⊤")
Base.print(io::IO, ::Tautology) = print(io, "⊤")

struct Contradiction <: Constant end
⊥ = Contradiction()
contradiction = Contradiction()

Base.show(io::IO, ::Contradiction) = show(io, "⊥")
Base.print(io::IO, ::Contradiction) = print(io, "⊥")

abstract type UnaryOperator <: Operator end

struct Negation <: UnaryOperator end

struct UnaryOperation{T <: UnaryOperator} <: Operation

    operator::T
    operand::Formula

end

operand(operation::UnaryOperation) = operation.operand

Not(α::Union{Formula,String}) = UnaryOperation(
    Negation(),
    α isa String ? Atom(α) : α
)
¬ = Not

function Base.show(io::IO, z::UnaryOperation)
    show(io, z.operator)
    show(io, z.operand)
end

function Base.print(io::IO, z::UnaryOperation)
    print(io, z.operator)
    print(io, z.operand)
end

Base.show(io::IO, ::Negation) = show(io, "¬")
Base.print(io::IO, ::Negation) = print(io, "¬")

abstract type BinaryOperator <: Operator end

struct BinaryOperation{T <: BinaryOperator} <: Operation

    operator::T
    operand1::Formula
    operand2::Formula

end

operand1(operation::BinaryOperation) = operation.operand1

operand2(operation::BinaryOperation) = operation.operand2

struct Disjunction <: BinaryOperator end

Base.show(io::IO, ::Disjunction) = show(io, "∨")
Base.print(io::IO, ::Disjunction) = print(io, "∨")

Or(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Disjunction(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
∨ = Or

struct Conjunction <: BinaryOperator end

Base.show(io::IO, ::Conjunction) = show(io, "∧")
Base.print(io::IO, ::Conjunction) = print(io, "∧")

And(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Conjunction(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
∧ = And

struct Implication <: BinaryOperator end

Base.show(io::IO, ::Implication) = show(io, "→")
Base.print(io::IO, ::Implication) = print(io, "→")

Implies(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Implication(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
→ = Implies

struct Biconditional <: BinaryOperator end

Base.show(io::IO, ::Biconditional) = show(io, "↔")
Base.print(io::IO, ::Biconditional) = print(io, "↔")

Equals(α::Union{Formula,String}, β::Union{Formula,String}) = BinaryOperation(
    Biconditional(), α isa String ? Atom(α) : α, β isa String ? Atom(β) : β
)
↔ = Equals

function Base.show(io::IO, z::BinaryOperation)
    show("(")
    show(io, z.operand1)
    show(io, z.operator)
    show(io, z.operand2)
    show(")")
end

function Base.print(io::IO, z::BinaryOperation)
    print("(")
    print(io, z.operand1)
    print(io, z.operator)
    print(io, z.operand2)
    print(")")
end

atoms(::Constant)::Set{Atom} = Set()
atoms(α::Atom)::Set{Atom} = Set([α])
atoms(α::UnaryOperation)::Set{Atom} = atoms(operand(α))
atoms(α::BinaryOperation)::Set{Atom} = union(atoms(operand1(α)), atoms(operand2(α)))
atoms(v::Valuation)::Set{Atom} = Set(keys(v))

evaluate(::Valuation, ::Tautology)::Bool = true
evaluate(::Valuation, ::Contradiction)::Bool = false
evaluate(v::Valuation, α::Atom)::Bool = haskey(v, α) ? get(v, α, nothing) : error("Valuation, $v, does not contain assignment for atom $α.")
evaluate(v::Valuation, ::Negation, α::Formula)::Bool = !evaluate(v, α)
evaluate(v::Valuation, α::UnaryOperation)::Bool = evaluate(v, operator(α), operand(α))
evaluate(v::Valuation, ::Conjunction, α::Formula, β::Formula)::Bool = evaluate(v, α) && evaluate(v, β)
evaluate(v::Valuation, ::Disjunction, α::Formula, β::Formula)::Bool = evaluate(v, α) || evaluate(v, β)
evaluate(v::Valuation, ::Implication, α::Formula, β::Formula)::Bool = evaluate(v, α) <= evaluate(v, β)
evaluate(v::Valuation, ::Biconditional, α::Formula, β::Formula)::Bool = evaluate(v, α) == evaluate(v, β)
evaluate(v::Valuation, α::BinaryOperation)::Bool = evaluate(v, operator(α), operand1(α), operand2(α))

nnf(c::Constant) = c
nnf(α::Atom) = α

nnf(::Negation, ::Negation, α::Formula) = nnf(α)
nnf(u::UnaryOperator, α::UnaryOperation) = nnf(u, operator(α), operand(α))

nnf(::Negation, α::Atom) = Not(α)
nnf(::Negation, c::Constant) = Not(c)
nnf(α::UnaryOperation) = nnf(operator(α), operand(α))

nnf(::Negation, ::Implication, α::Formula, β::Formula) = nnf(α ∧ ¬β)
nnf(::Negation, ::Disjunction, α::Formula, β::Formula) = nnf(¬α ∧ ¬β)
nnf(::Negation, ::Conjunction, α::Formula, β::Formula) = nnf(¬α ∨ ¬β)
nnf(::Negation, ::Biconditional, α::Formula, β::Formula) = nnf((α ∧ ¬β) ∨ (¬α ∧ β))
nnf(u::UnaryOperator, α::BinaryOperation) = nnf(u, operator(α), operand1(α), operand2(α))

nnf(::Implication, α::Formula, β::Formula) = nnf(¬α ∨ β)
nnf(::Biconditional, α::Formula, β::Formula) = nnf((α ∧ β) ∨ (¬α ∧ ¬β))
nnf(binop::BinaryOperator, α::Formula, β::Formula) = BinaryOperation(binop, nnf(α), nnf(β))
nnf(α::BinaryOperation) = nnf(operator(α), operand1(α), operand2(α))

distributive(c::Constant) = c
distributive(α::Atom) = α
distributive(α::UnaryOperation) = UnaryOperation(operator(α), distributive(operand(α)))
distributive(binop::BinaryOperator, α::Formula, β::Formula) = BinaryOperation(binop, distributive(α), distributive(β))
distributive(::Disjunction, α::BinaryOperation{Conjunction}, β::Formula) = distributive((operand1(α) ∨ β) ∧ (operand2(α) ∨ β))
distributive(::Disjunction, α::Formula, β::BinaryOperation{Conjunction}) = distributive((α ∨ operand1(β)) ∧ (α ∨ operand2(β)))
distributive(::Disjunction, α::BinaryOperation{Conjunction}, β::BinaryOperation{Conjunction}) = distributive((operand1(α) ∨ β) ∧ (operand2(α) ∨ β))
distributive(::Disjunction, α::Formula, β::Formula) = distributive(α) ∨ distributive(β)
distributive(α::BinaryOperation) = distributive(operator(α), operand1(α), operand2(α))

function cnf(α::Formula)
    form=nnf(α)
    while form != distributive(form)
        form = distributive(form)
    end
    return form
end

function disjunctiveclauses(α::Formula)#::Vector{Vector{Formula, 1}, 1}

    cnfform = cnf(α)

    disjunctiveclauses(::Conjunction, α::Formula, β::Formula) = [disjunctiveclauses(α), disjunctiveclauses(β)]
    disjunctiveclauses(::Disjunction, α::Formula, β::Formula) = [disjunctiveclauses(α)..., disjunctiveclauses(β)...]
    disjunctiveclauses(α::BinaryOperation) = disjunctiveclauses(operator(α), operand1(α), operand2(α))
    disjunctiveclauses(α::UnaryOperation) = [α]
    disjunctiveclauses(α::Atom) = [α]
    disjunctiveclauses(c::Constant) = [c]

    return disjunctiveclauses(cnfform)
end

function satisfiable(α::Formula)
    #cnfform = cnf(α)
end

#val = Valuation(Atom("A") => false, Atom("B") => false)
#form = Not(Or(And("A", "B"), ⊤))
form = (("A"∧"B")∨("C"∧"D"))∨"E"
#println(form)
#println(nnf(form))
#println(cnf(form))
#println(disjunctiveclauses(form))


end # module
