module PropositionalSemantics

using ..PropositionalSyntax

"Get atoms contained in a propositional formula." # Efficient
atoms(α::Formula)::Set{Atom} = error("Atoms does not yet support $(typeof(α)).")
atoms(::Constant)::Set{Atom} = Set()
atoms(α::Atom)::Set{Atom} = Set([α])
atoms(α::UnaryOperation)::Set{Atom} = atoms(operand(α))
atoms(α::BinaryOperation)::Set{Atom} = union(atoms(operand1(α)), atoms(operand2(α)))
export atoms

"Check if an interpretation satisfies a propostional formula." # Efficient
satisfies(_::Interpretation, α::Formula)::Bool = error("Satisfaction does not yet support $(typeof(α)).")
satisfies(::Interpretation, ::Tautology)::Bool = true
satisfies(::Interpretation, ::Contradiction)::Bool = false
satisfies(v::Interpretation, α::Atom)::Bool = assign(v, α)
satisfies(_::Interpretation, α::UnaryOperation)::Bool = error("Satisfaction does not yet support $(typeof(α)).")
satisfies(v::Interpretation, α::UnaryOperation{Negation})::Bool = !satisfies(v, α)
satisfies(_::Interpretation, α::BinaryOperation)::Bool = error("Satisfaction does not yet support $(typeof(α)).")
satisfies(v::Interpretation, α::BinaryOperation{Conjunction})::Bool = satisfies(v, operand1(α)) && satisfies(v, operand2(α))
satisfies(v::Interpretation, α::BinaryOperation{Disjunction})::Bool = satisfies(v, operand1(α)) || satisfies(v, operand2(α))
satisfies(v::Interpretation, α::BinaryOperation{Implication})::Bool = satisfies(v, operand1(α)) <= satisfies(v, operand2(α))
satisfies(v::Interpretation, α::BinaryOperation{Biconditional})::Bool = satisfies(v, operand1(α)) == satisfies(v, operand2(α))
export satisfies

"Convert a propositional formula into negation normal form." # Efficient
nnf(α::Formula) = α
nnf(α::UnaryOperation) = nnf(operator(α), operand(α))
nnf(u::UnaryOperator, α::Formula) = UnaryOperation(u, nnf(α))
nnf(::Negation, α::UnaryOperation{Negation}) = nnf(operand(α))
nnf(::Negation, α::BinaryOperation{Implication}) = nnf(operand1(α) ∧ ¬operand2(α))
nnf(::Negation, α::BinaryOperation{Disjunction}) = nnf(¬operand1(α) ∧ ¬operand2(α))
nnf(::Negation, α::BinaryOperation{Conjunction}) = nnf(¬operand1(α) ∨ ¬operand2(α))
nnf(::Negation, α::BinaryOperation{Biconditional}) = nnf((operand1(α) ∧ ¬operand2(α)) ∨ (¬operand1(α) ∧ operand2(α)))
nnf(α::BinaryOperation) = BinaryOperation(operator(α), nnf(operand1(α)), nnf(operand2(α)))
nnf(α::BinaryOperation{Biconditional}) = nnf((operand1(α) ∧ operand2(α)) ∨ (¬operand1(α) ∧ ¬operand2(α)))
nnf(α::BinaryOperation{Implication}) = nnf(¬operand1(α) ∨ operand2(α))
export nnf

"Apply the distributive law propogation through a propositional formula." # Efficient
distributive(α::Formula) = error("Distributive does not yet support $(typeof(α)).")
distributive(c::Constant) = c
distributive(α::Atom) = α
distributive(α::UnaryOperation) = UnaryOperation(operator(α), distributive(operand(α)))
distributive(α::BinaryOperation) = distributive(operator(α), operand1(α), operand2(α))
distributive(binop::BinaryOperator, α::Formula, β::Formula) = BinaryOperation(binop, distributive(α), distributive(β))
distributive(::Disjunction, α::BinaryOperation{Conjunction}, β::Formula) = distributive((operand1(α) ∨ β) ∧ (operand2(α) ∨ β))
distributive(::Disjunction, α::Formula, β::BinaryOperation{Conjunction}) = distributive((α ∨ operand1(β)) ∧ (α ∨ operand2(β)))
distributive(::Disjunction, α::BinaryOperation{Conjunction}, β::BinaryOperation{Conjunction}) = distributive((operand1(α) ∨ β) ∧ (operand2(α) ∨ β))
distributive(::Disjunction, α::Formula, β::Formula) = distributive(α) ∨ distributive(β)
export distributive

"Convert a propositional formula to conjunctive normal form."
function cnf(α::Formula)
    form=nnf(α)
    while form != distributive(form)
        form = distributive(form)
    end
    return form
end
export cnf

function disjunctiveclauses(α::Formula)

    cnfform = cnf(α)

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

    return disjunctiveclauses(cnfform)

end
export disjunctiveclauses

#function picocnf(α::Formula)
#    dclauses = disjunctiveclauses(α)
#    picoclauses = []
#    namedict = Dict{String, Int}()
#    idcounter = 1
#    for clause in dclauses
#        picoclause = []
#        for literal in clause
#            atomname, sign = literal isa UnaryOperation{Negation} ? (name(operand(literal)), -1)  : (name(literal), 1)
#            id = get(namedict, atomname, idcounter)
#            if idcounter == id
#                idcounter += 1
#                push!(namedict, atomname => id)
#            end
#            push!(picoclause, sign*id)
#        end
#        push!(picoclauses, picoclause)
#    end
#    return picoclauses, namedict
#end

#function satisfiable(α::Formula)
#    picoclauses, _ = picocnf(α)
#    return PicoSAT.solve(picoclauses) != :unsatisfiable
#end

#function models(α::Formula)::Vector{Interpretation}
#    picoclauses, namedict = picocnf(α)
#    rossettadict = Dict(value => key for (key, value) in namedict)
#    picomodels = PicoSAT.itersolve(picoclauses)
#    if isnothing(picomodels)
#        return []
#    end
#    result = []
#    for picomodel in picomodels
#        valuation = Interpretation()
#        for literal in picomodel
#            piconame = abs(literal)
#            atom = Atom(get(rossettadict, piconame, nothing))
#            truthvalue = literal/piconame > 0
#            push!(valuation, atom => truthvalue)
#        end
#        push!(result, valuation)
#    end
#    return result
#end


end
