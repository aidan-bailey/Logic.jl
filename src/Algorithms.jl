module Algorithms

import PicoSAT
using Combinatorics
using ..Types

"Convert a propositional formula into negation normal form." # Efficient
function nnf(α::Formula)::Formula
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
    return nnf(α)
end
nnf(α) = nnf(convert(Formula, α))
export nnf

"Apply the distributive law propogation through a propositional formula." # Broken
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
distributive(α) = distributive(convert(Formula, α))
export distributive

"Convert a propositional formula to conjunctive normal form."
function cnf(α::Formula)::Formula
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
cnf(α) = cnf(convert(Formula, α))
export cnf

function simplify(α::Formula)::Formula
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
simplify(α) = simplify(convert(Formula, α))
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
function picocnf(α::Formula)::Tuple{Vector{Vector{Int}}, Dict{String, Int}}
    dclauses = collect(disjunctiveclauses(α))
    picoclauses::Vector{Vector{Int}} = []
    namedict = Dict{String,Int}()
    idcounter = 1
    for clause in dclauses
        picoclause::Vector{Int} = []
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

"Get atoms contained in a propositional formula." # Efficient
atoms(α::Formula)::Set{Atom} = error("Atoms does not yet support $(typeof(α)).")
atoms(::Constant)::Set{Atom} = Set()
atoms(α::Atom)::Set{Atom} = Set([α])
atoms(α::UnaryOperation)::Set{Atom} = atoms(operand(α))
atoms(α::BinaryOperation)::Set{Atom} = union(atoms(operand1(α)), atoms(operand2(α)))
atoms(α) = atoms(convert(Formula, α))
export atoms

"Check if an interpretation satisfies a propostional formula." # Efficient
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
satisfies(v::Interpretation, α) = satisfies(v, convert(Formula, α))
export satisfies
⊢ = satisfies
export ⊢

world(α::Formula)::Set{Interpretation} = union(Interpretation(), Set(map(Interpretation, combinations(atoms(α)))))
world(α) = world(convert(Formula, α))
export world

"Check if a propositional formula is satisfiable."
function satisfiable(α::Formula)::Bool
    form = simplify(cnf(α))
    if form isa Contradiction
        return false
    elseif form isa Tautology
        return true
    end
    picoclauses, _ = picocnf(form)
    return PicoSAT.solve(picoclauses) != :unsatisfiable
end
satisfiable(α) = satisfiable(convert(Formula, α))
export satisfiable

"Get the models of a propositional formula."
function models(α::Formula)::Set{Interpretation}
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
models(α) = models(convert(Formula, α))
export models

"Check if propositional formula α is a tautology."
istautology(α::Formula)::Bool = length(models(α)) == 2^length(atoms(α))
istautology(::Contradiction)::Bool = false
istautology(::Tautology)::Bool = true
istautology(α) = istautology(convert(Formula, α))
export isvalid

"Check if propositional formula α is a contradiction."
iscontradiction(α::Formula)::Bool = isempty(models(α))
iscontradiction(::Contradiction)::Bool = true
iscontradiction(::Tautology)::Bool = false
iscontradiction(α) = iscontradiction(convert(Formula, α))

"Check if propositional formula α entails propositional formula β."
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
entails(α, β) = entails(convert(Formula, α), convert(Formula, β))
entails(α::Formula, β) = entails(α, convert(Formula, β))
entails(α, β::Formula) = entails(α, convert(Formula, β))
entails(α::Formula, ::Tautology) = istautology(α)
entails(α::Formula, ::Contradiction) = iscontradiction(α)
entails(::Tautology, ::Tautology) = true
entails(::Contradiction, ::Contradiction) = true
entails(::Contradiction, ::Tautology) = true
entails(::Tautology, ::Contradiction) = false

export entails
#⊧ = entails #I wish
#export ⊧    #upon a fish

end
