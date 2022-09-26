module PropositionalSemantics

using ..PropositionalSyntax
using ..Conversion
using Combinatorics
import PicoSAT

"Get atoms contained in a propositional formula." # Efficient
atoms(α::Formula)::Set{Atom} = error("Atoms does not yet support $(typeof(α)).")
atoms(::Constant)::Set{Atom} = Set()
atoms(α::Atom)::Set{Atom} = Set([α])
atoms(α::UnaryOperation)::Set{Atom} = atoms(operand(α))
atoms(α::BinaryOperation)::Set{Atom} = union(atoms(operand1(α)), atoms(operand2(α)))
export atoms

"Check if an interpretation satisfies a propostional formula." # Efficient
satisfies(::Interpretation, α::Formula)::Bool = error("Satisfaction does not yet support $(typeof(α)).")
satisfies(::Interpretation, ::Tautology)::Bool = true
satisfies(::Interpretation, ::Contradiction)::Bool = false
satisfies(v::Interpretation, α::Atom)::Bool = v[α]
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

world(α::Formula) = world(atoms(α))
function world(atoms::Set{Atom})
    atomslist = collect(atoms)
    interpretations::Vector{Interpretation} = [Interpretation(atom => false for atom in atomslist)]
    for truths in combinations(atomslist)
        falses = setdiff(atoms, truths)
        interpretation = Interpretation(union([atom => false for atom in falses], [atom => true for atom in truths]))
        push!(interpretations, interpretation)
    end
    return interpretations
end
export world

"Check if a propositional formula is satisfiable." # Efficient
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
function models(α::Formula)::Set{Interpretation} # This is fine
    form = simplify(cnf(α))

    if form isa Contradiction
        return Set{Interpretation}()
    elseif form isa Tautology
        return world(α)
    end

    picoclauses, namedict = picocnf(α)
    rossettadict = Dict(value => key for (key, value) in namedict)
    picomodels = PicoSAT.itersolve(picoclauses)
    if isnothing(picomodels)
        return []
    end
    result = []
    for picomodel in picomodels
        valuation = Interpretation()
        for literal in picomodel
            piconame = abs(literal)
            atom = Atom(get(rossettadict, piconame, nothing))
            truthvalue = literal / piconame > 0
            push!(valuation, atom => truthvalue)
        end
        push!(result, valuation)
    end
    return Set(result)
end
export models

"Check if propositional formula α is a tautology." # Efficient
istautology(::Contradiction)::Bool = false
istautology(::Tautology)::Bool = true
istautology(α::Formula)::Bool = length(models(α)) == 2^length(atoms(α))
export isvalid

"Check if propositional formula α is a contradiction."
iscontradiction(::Contradiction)::Bool = true
iscontradiction(::Tautology)::Bool = false
iscontradiction(α::Formula) = isempty(models(α))

"Check if propositional formula α entails propositional formula β." # Efficient and elegant wow!
entails(α::Formula, β::Formula) = models(α) ⊆ models(β)
entails(α::Formula, ::Tautology) = istautology(α)
entails(α::Formula, ::Contradiction) = iscontradiction(α)
entails(::Tautology, ::Tautology) = true            # I think?
entails(::Contradiction, ::Contradiction) = true    # I think?
entails(::Contradiction, ::Tautology) = true
entails(::Tautology, ::Contradiction) = false

export entails
#⊧ = entails #I wish
#export ⊧    #upon a fish

end
