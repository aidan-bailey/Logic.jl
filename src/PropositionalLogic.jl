module PropositionalLogic

import PicoSAT
using Combinatorics

##########
# SYNTAX #
##########

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
    name::Union{String, Int}
    Atom(n::Int) = new(n)
    Atom(n::String) = new(n)
    Atom(n::Char) = new(string(n))
end
export Atom
name(α::Atom)::Union{String, Int} = α.name
Base.convert(::Type{Formula}, x::Union{String, Char, Int}) = Atom(x)
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
struct UnaryOperation{T<:UnaryOperator} <: Operation
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
struct BinaryOperation{T<:BinaryOperator} <: Operation
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
const Interpretation = Set{Atom}
export Interpretation
I(atoms::Union{String, Char, Int, Atom}...) = Interpretation(map(a -> a isa Atom ? a : Atom(a), atoms))
export I

const Literal = Union{Atom, UnaryOperation, Constant}
export Literal
const Clause = Set{Literal}
clause(α...) = Clause(map(x -> Base.convert(Formula, x), α))
export clause
export Clause

###############
# CONVERSIONS #
###############

"Convert a propositional formula into negation normal form." # Efficient
nnf(α) = nnf(convert(Formula, α))
nnf(α::Formula) = error("NNF does not yet support $(typeof(α)).")
nnf(α::Atom) = α
nnf(α::UnaryOperation) = nnf(operator(α), operand(α))
nnf(u::UnaryOperator, α::Formula) = UnaryOperation(u, nnf(α))
nnf(::Negation, α::Atom) = ¬α
nnf(::Negation, α::UnaryOperation{Negation}) = nnf(operand(α))
nnf(::Negation, α::BinaryOperation{Implication}) = nnf(operand1(α) ∧ ¬operand2(α))
nnf(::Negation, α::BinaryOperation{Disjunction}) = nnf(¬operand1(α) ∧ ¬operand2(α))
nnf(::Negation, α::BinaryOperation{Conjunction}) = nnf(¬operand1(α) ∨ ¬operand2(α))
nnf(::Negation, α::BinaryOperation{Biconditional}) = nnf(operand1(α) ∨ operand2(α)) ∧ nnf(¬operand1(α) ∨ ¬operand2(α))
nnf(α::BinaryOperation) = BinaryOperation(operator(α), nnf(operand1(α)), nnf(operand2(α)))
nnf(α::BinaryOperation{Biconditional}) = nnf(operand1(α) ∨ ¬operand2(α)) ∧ nnf(¬operand1(α) ∨ operand2(α))
nnf(α::BinaryOperation{Implication}) = nnf(¬operand1(α) ∨ operand2(α))
export nnf

"Apply the distributive law propogation through a propositional formula." # Broken
distributive(α) = distributive(convert(Formula, α))
distributive(α::Formula) = error("Distributive does not yet support $(typeof(α)).")
distributive(c::Constant) = c
distributive(α::Atom) = α
distributive(α::UnaryOperation) = UnaryOperation(operator(α), distributive(operand(α)))
distributive(α::BinaryOperation) = distributive(operator(α), operand1(α), operand2(α))
distributive(binop::BinaryOperator, α::Formula, β::Formula) = BinaryOperation(binop, distributive(α), distributive(β))
# Conjunction over disjunction
distributive(::Conjunction, α::Formula, β::BinaryOperation{Disjunction}) = distributive(α ∧ operand1(β)) ∨ distributive(α ∧ operand2(β))
distributive(::Conjunction, α::BinaryOperation{Disjunction}, β::Formula) = distributive(operand1(α) ∧ β) ∨ distributive(operand2(α) ∧ β)
# Disjunction over conjunction
distributive(::Disjunction, α::Formula, β::BinaryOperation{Conjunction}) = distributive(α ∨ operand1(β)) ∧ distributive(α ∨ operand2(β))
distributive(::Disjunction, α::BinaryOperation{Conjunction}, β::Formula) = distributive(operand1(α) ∨ β) ∧ distributive(operand2(α) ∨ β)
# Conjunction over conjunction
distributive(::Conjunction, α::Formula, β::BinaryOperation{Conjunction}) = distributive(α ∧ operand1(β)) ∧ distributive(α ∧ operand2(β))
distributive(::Conjunction, α::BinaryOperation{Conjunction}, β::Formula) = distributive(operand1(α) ∧ β) ∧ distributive(operand2(α) ∧ β)
# Disjunction over disjunction
distributive(::Disjunction, α::Formula, β::BinaryOperation{Disjunction}) = distributive(α ∨ operand1(β)) ∨ distributive(α ∨ operand2(β))
distributive(::Disjunction, α::BinaryOperation{Disjunction}, β::Formula) = distributive(operand1(α) ∨ β) ∨ distributive(operand2(α) ∨ β)
# Implication over implication
distributive(::Implication, α::Formula, β::BinaryOperation{Implication}) = distributive(α → operand1(β)) → distributive(α → operand2(β))
# Implication over equivalence
distributive(::Implication, α::Formula, β::BinaryOperation{Biconditional}) = distributive(α → operand1(β)) ↔ distributive(α → operand2(β))
# Implication over conjunction
distributive(::Implication, α::Formula, β::BinaryOperation{Conjunction}) = distributive(α → operand1(β)) ∧ distributive(α → operand2(β))
# Disjunction over equivalence
distributive(::Disjunction, α::Formula, β::BinaryOperation{Biconditional}) = distributive(α ∨ operand1(β)) ↔ distributive(α ∨ operand2(β))
distributive(::Disjunction, α::BinaryOperation{Biconditional}, β::Formula) = distributive(operand1(α) ∨ β) ↔ distributive(operand2(α) ∨ β)
# Double Distribution
distributive(::Disjunction, α::BinaryOperation{Conjunction}, β::BinaryOperation{Conjunction}) = (distributive(operand1(α) ∨ operand1(β)) ∧ distributive(operand1(α) ∨ operand2(β))) ∧ (distributive(operand2(α) ∨ operand1(β)) ∧ distributive(operand2(α) ∨ operand2(β)))
distributive(::Conjunction, α::BinaryOperation{Disjunction}, β::BinaryOperation{Disjunction}) = (distributive(operand1(α) ∧ operand1(β)) ∨ distributive(operand1(α) ∧ operand2(β))) ∨ (distributive(operand2(α) ∧ operand1(β)) ∨ distributive(operand2(α) ∧ operand2(β)))
export distributive

"Convert a propositional formula to conjunctive normal form." # This could probably be a bit more efficient
cnf(α) = cnf(convert(Formula, α))
function cnf(α::Formula)
    cnfpass(α::Formula) = α
    cnfpass(c::Constant) = c
    cnfpass(α::Atom) = α
    cnfpass(α::BinaryOperation) = cnfpass(operator(α), operand1(α), operand2(α))
    cnfpass(::Conjunction, α::Formula, β::Formula) = cnfpass(α) ∧ cnfpass(β)
    cnfpass(::Disjunction, α::BinaryOperation{Conjunction}, β::Formula) = cnfpass((operand1(α) ∨ β) ∧ (operand2(α) ∨ β))
    cnfpass(::Disjunction, α::Formula, β::BinaryOperation{Conjunction}) = cnfpass((α ∨ operand1(β)) ∧ (α ∨ operand2(β)))
    cnfpass(::Disjunction, α::BinaryOperation{Conjunction}, β::BinaryOperation{Conjunction}) = cnfpass((operand1(α) ∨ β) ∧ (operand2(α) ∨ β))
    cnfpass(::Disjunction, α::Formula, β::Formula) = cnfpass(α) ∨ cnfpass(β)
    form = cnfpass(nnf(α))
    while (local next = cnfpass(form)) != form
        form = next
    end
    return form
end
export cnf

simplify(α) = simplift(convert(Formula, α))
function simplify(α::Formula)
    simplify(α::Atom) = α
    simplify(c::Constant) = c
    simplify(α::BinaryOperation) = simplify(operator(α), operand1(α), operand2(α))
    simplify(α::UnaryOperation) = simplify(operator(α), operand(α))
    simplify(::Negation, ::Tautology) = ⊥
    simplify(::Negation, ::Contradiction) = ⊤
    simplify(unop::UnaryOperator, α::Formula) = UnaryOperation(unop, simplify(α))
    simplify(binop::BinaryOperator, α::Formula, β::Formula) = BinaryOperation(binop, α, β)

    simplify(::Conjunction, ::Tautology, α::Formula) = simplify(α)
    simplify(::Conjunction, ::Contradiction, α::Formula) = ⊥
    simplify(::Conjunction, α::Formula, ::Tautology) = simplify(α)
    simplify(::Conjunction, α::Formula, ::Contradiction) = ⊥
    simplify(::Conjunction, ::Tautology, ::Tautology) = ⊤
    simplify(::Conjunction, ::Tautology, ::Contradiction) = ⊥
    simplify(::Conjunction, ::Contradiction, ::Contradiction) = ⊥
    simplify(::Conjunction, ::Contradiction, ::Tautology) = ⊥

    simplify(::Disjunction, ::Tautology, α::Formula) = ⊤
    simplify(::Disjunction, ::Contradiction, α::Formula) = simplify(α)
    simplify(::Disjunction, α::Formula, ::Tautology) = ⊤
    simplify(::Disjunction, α::Formula, ::Contradiction) = simplify(α)
    simplify(::Disjunction, ::Tautology, ::Tautology) = ⊤
    simplify(::Disjunction, ::Tautology, ::Contradiction) = ⊤
    simplify(::Disjunction, ::Contradiction, ::Contradiction) = ⊥
    simplify(::Disjunction, ::Contradiction, ::Tautology) = ⊤

    simplify(::Implication, ::Tautology, α::Formula) = simplify(α)
    simplify(::Implication, α::Formula, ::Tautology) = simplify(α ∨ ¬α)
    simplify(::Implication, ::Contradiction, α::Formula) = simplify(α ∨ ¬α)
    simplify(::Implication, α::Formula, ::Contradiction) = simplify(¬α)
    simplify(::Implication, ::Tautology, ::Tautology) = ⊤
    simplify(::Implication, ::Tautology, ::Contradiction) = ⊥
    simplify(::Implication, ::Contradiction, ::Contradiction) = ⊤
    simplify(::Implication, ::Contradiction, ::Tautology) = ⊤

    simplify(::Biconditional, ::Tautology, α::Formula) = simplify(α)
    simplify(::Biconditional, α::Formula, ::Tautology) = simplify(α)
    simplify(::Biconditional, ::Contradiction, α::Formula) = simplify(¬α)
    simplify(::Biconditional, α::Formula, ::Contradiction) = simplify(¬α)
    simplify(::Biconditional, ::Tautology, ::Tautology) = ⊤
    simplify(::Biconditional, ::Tautology, ::Contradiction) = ⊥
    simplify(::Biconditional, ::Contradiction, ::Contradiction) = ⊤
    simplify(::Biconditional, ::Contradiction, ::Tautology) = ⊥

    form = simplify(α)
    while (local next = simplify(form)) != form
        form = next
    end
    return form
end
export simplify

function disjunctiveclauses(α::Formula)::Set{Clause}
    disjunctiveclauses(::Union{BinaryOperation{Implication},BinaryOperation{Biconditional}}) = error("Disjunctive class called for non-cnf formula")
    disjunctiveclauses(α::BinaryOperation{Conjunction}) = [disjunctiveclauses(operand1(α))..., disjunctiveclauses(operand2(α))...]
    disjunctiveclauses(α::BinaryOperation{Disjunction}) = [union(disjunctiveclauses(operand1(α))..., disjunctiveclauses(operand2(α))...)]
    disjunctiveclauses(α::UnaryOperation) = [Clause([α])]
    disjunctiveclauses(α::Atom) = [Clause([α])]
    disjunctiveclauses(c::Constant) = [Clause([c])]
    return Set(disjunctiveclauses(α))
end
disjunctiveclauses(α) = disjunctiveclauses(convert(Formula, α))
export disjunctiveclauses

"Convert a propositional formula in cnf into pico cnf format." # This method is sound and complete but could be more efficient
function picocnf(α::Formula)
    dclauses = collect(disjunctiveclauses(α))
    picoclauses = []
    namedict = Dict{String,Int}()
    idcounter = 1
    for clause in dclauses
        picoclause = []
        for literal in clause
            atomname, sign = literal isa UnaryOperation{Negation} ? (name(operand(literal)), -1) : (name(literal), 1)
            id = get(namedict, atomname, idcounter)
            if idcounter == id
                idcounter += 1
                push!(namedict, atomname => id)
            end
            push!(picoclause, sign * id)
        end
        push!(picoclauses, picoclause)
    end
    return picoclauses, namedict
end
picocnf(α) = picocnf(convert(Formula, α))
export picocnf

#############
# SEMANTICS #
#############

"Get atoms contained in a propositional formula." # Efficient
atoms(α) = atoms(convert(Formula, α))
atoms(α::Formula)::Set{Atom} = error("Atoms does not yet support $(typeof(α)).")
atoms(::Constant)::Set{Atom} = Set()
atoms(α::Atom)::Set{Atom} = Set([α])
atoms(α::UnaryOperation)::Set{Atom} = atoms(operand(α))
atoms(α::BinaryOperation)::Set{Atom} = union(atoms(operand1(α)), atoms(operand2(α)))
export atoms

"Check if an interpretation satisfies a propostional formula." # Efficient
satisfies(v::Interpretation, α) = satisfies(v, convert(Formula, α))
satisfies(::Interpretation, α::Formula)::Bool = error("Satisfaction does not yet support $(typeof(α)).")
satisfies(::Interpretation, ::Tautology)::Bool = true
satisfies(::Interpretation, ::Contradiction)::Bool = false
satisfies(v::Interpretation, α::Atom)::Bool = α ∈ v
satisfies(::Interpretation, α::UnaryOperation)::Bool = error("Satisfaction does not yet support $(typeof(α)).")
satisfies(v::Interpretation, α::UnaryOperation{Negation})::Bool = !satisfies(v, α)
satisfies(::Interpretation, α::BinaryOperation)::Bool = error("Satisfaction does not yet support $(typeof(α)).")
satisfies(v::Interpretation, α::BinaryOperation{Conjunction})::Bool = satisfies(v, operand1(α)) && satisfies(v, operand2(α))
satisfies(v::Interpretation, α::BinaryOperation{Disjunction})::Bool = satisfies(v, operand1(α)) || satisfies(v, operand2(α))
satisfies(v::Interpretation, α::BinaryOperation{Implication})::Bool = satisfies(v, operand1(α)) <= satisfies(v, operand2(α))
satisfies(v::Interpretation, α::BinaryOperation{Biconditional})::Bool = satisfies(v, operand1(α)) == satisfies(v, operand2(α))
export satisfies
⊢ = satisfies
export ⊢

world(α) = world(convert(Formula, α))
world(α::Formula) = union(Interpretation(), Set(map(Interpretation, combinations(atoms(α)))))
export world

"Check if a propositional formula is satisfiable." # Efficient
satisfiable(α) = satisfiable(convert(Formula, α))
function satisfiable(α::Formula)
    form = simplify(cnf(α))
    if form isa Contradiction
        return false
    elseif form isa Tautology
        return true
    end
    picoclauses, _ = picocnf(form)
    return PicoSAT.solve(picoclauses) != :unsatisfiable
end
export satisfiable

"Get the models of a propositional formula."
models(α) = models(convert(Formula, α))
function models(α::Formula)::Set{Interpretation} # This is fine
    form = simplify(cnf(α))

    if form isa Contradiction
        return Set{Interpretation}()
    elseif form isa Tautology
        return world(α)
    end

    picoclauses, namedict = picocnf(form)
    rossettadict = Dict(value => key for (key, value) in namedict)
    picomodels = PicoSAT.itersolve(picoclauses)
    if isnothing(picomodels)
        return []
    end
    result::Vector{Interpretation} = []
    for picomodel in picomodels
        valuation::Interpretation = Interpretation()
        for literal in picomodel
            piconame = abs(literal)
            atom = Atom(get(rossettadict, piconame, nothing))
            truthvalue = literal / piconame > 0
            if truthvalue
                push!(valuation, atom)
            end
        end
        push!(result, valuation)
    end
    return Set{Interpretation}(result)
end
export models

"Check if propositional formula α is a tautology." # Efficient
istautology(α) = istautology(convert(Formula, α))
istautology(::Contradiction)::Bool = false
istautology(::Tautology)::Bool = true
istautology(α::Formula)::Bool = length(models(α)) == 2^length(atoms(α))
export isvalid

"Check if propositional formula α is a contradiction."
iscontradiction(α) = iscontradiction(convert(Formula, α))
iscontradiction(::Contradiction)::Bool = true
iscontradiction(::Tautology)::Bool = false
iscontradiction(α::Formula) = isempty(models(α))

"Check if propositional formula α entails propositional formula β." # Efficient and elegant wow!
entails(α, β) = entails(convert(Formula, α), convert(Formula, β))
entails(α::Formula, β) = entails(α, convert(Formula, β))
entails(α, β::Formula) = entails(α, convert(Formula, β))
function entails(α::Formula, β::Formula)
    prevalentatoms = intersect(atoms(α), atoms(β))
    models1 = collect(map(m -> intersect(m, prevalentatoms), collect(models(α))))
    models2 = collect(models(β))
    all(
        map(m1 -> any(
            map(m2 -> m1 ⊆ m2, models2)),
            models1
            )
    )
end
entails(α::Formula, ::Tautology) = istautology(α)
entails(α::Formula, ::Contradiction) = iscontradiction(α)
entails(::Tautology, ::Tautology) = true            # I think?
entails(::Contradiction, ::Contradiction) = true    # I think?
entails(::Contradiction, ::Tautology) = true
entails(::Tautology, ::Contradiction) = false

export entails
#⊧ = entails #I wish
#export ⊧    #upon a fish

end # module
