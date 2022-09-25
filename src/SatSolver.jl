module SatSolver

import PicoSAT
using ..PropositionalSyntax
using ..Conversion

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
            truthvalue = literal / piconame > 0
            push!(valuation, atom => truthvalue)
        end
        push!(result, valuation)
    end
    return Set(result)
end

end
