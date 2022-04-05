module SatSolver

import PicoSAT
using ..PropositionalSyntax

"Acquire the disjunctive clauses from a propositional formula in cnf." # This method is not accurate TODO
function disjunctiveclauses(α::Formula)

    disjunctiveclauses(::Disjunction, α::BinaryOperation{Disjunction}, β::BinaryOperation{Disjunction}) = [vcat(
        vcat(disjunctiveclauses(operand1(α)), disjunctiveclauses(operand2(α))),
        vcat(disjunctiveclauses(operand1(β)), disjunctiveclauses(operand2(β)))
    )]
    disjunctiveclauses(::Disjunction, α::Formula, β::BinaryOperation{Disjunction}) = [vcat(vcat(disjunctiveclauses(operand1(β)), disjunctiveclauses(operand2(β))), disjunctiveclauses(α))]
    disjunctiveclauses(::Disjunction, α::BinaryOperation{Disjunction}, β::Formula) = [vcat(vcat(disjunctiveclauses(operand1(α)), disjunctiveclauses(operand2(α))), disjunctiveclauses(β))]
    disjunctiveclauses(::Disjunction, α::Formula, β::Formula) = [vcat(disjunctiveclauses(α), disjunctiveclauses(β))]

    disjunctiveclauses(::Conjunction, α::BinaryOperation{Conjunction}, β::BinaryOperation{Conjunction}) = [disjunctiveclauses(α)..., disjunctiveclauses(β)...]
    disjunctiveclauses(::Conjunction, α::Formula, β::BinaryOperation{Conjunction}) = [disjunctiveclauses(α), disjunctiveclauses(β)...]
    disjunctiveclauses(::Conjunction, α::BinaryOperation{Conjunction}, β::Formula) = [disjunctiveclauses(α)..., disjunctiveclauses(β)]
    disjunctiveclauses(::Conjunction, α::Formula, β::Formula) = [disjunctiveclauses(α), disjunctiveclauses(β)]

    disjunctiveclauses(α::BinaryOperation) = disjunctiveclauses(operator(α), operand1(α), operand2(α))
    disjunctiveclauses(α::UnaryOperation) = [α]
    disjunctiveclauses(α::Atom) = [α]
    disjunctiveclauses(c::Constant) = [c]

    return disjunctiveclauses(α)

end

"Convert a propositional formula in cnf into pico cnf format." # This method is sound and complete but could be more efficient
function picocnf(α::Formula)
    dclauses = disjunctiveclauses(α)
    picoclauses = []
    namedict = Dict{String, Int}()
    idcounter = 1
    for clause in dclauses
        picoclause = []
        for literal in clause
            atomname, sign = literal isa UnaryOperation{Negation} ? (name(operand(literal)), -1)  : (name(literal), 1)
            id = get(namedict, atomname, idcounter)
            if idcounter == id
                idcounter += 1
                push!(namedict, atomname => id)
            end
            push!(picoclause, sign*id)
        end
        push!(picoclauses, picoclause)
    end
    return picoclauses, namedict

end

"Check if a propositional formula is satisfiable." # Efficient
function satisfiable(α::Formula)
    picoclauses, _ = picocnf(α)
    return PicoSAT.solve(picoclauses) != :unsatisfiable
end

"Get the models of a propositional formula."
function models(α::Formula)::Set{Interpretation} # This is fine
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
            truthvalue = literal/piconame > 0
            push!(valuation, atom => truthvalue)
        end
        push!(result, valuation)
    end
    return Set(result)
end

end
