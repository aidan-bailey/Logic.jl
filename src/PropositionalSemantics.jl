module PropositionalSemantics

using ..PropositionalSyntax

atoms(::Constant)::Set{Atom} = Set()
atoms(α::Atom)::Set{Atom} = Set([α])
atoms(α::UnaryOperation)::Set{Atom} = atoms(operand(α))
atoms(α::BinaryOperation)::Set{Atom} = union(atoms(operand1(α)), atoms(operand2(α)))
export atoms

satisfies(::Interpretation, ::Tautology)::Bool = true
satisfies(::Interpretation, ::Contradiction)::Bool = false
satisfies(v::Interpretation, α::Atom)::Bool = haskey(v, α) ? get(v, α, nothing) : error("Interpretation, $v, does not contain assignment for atom $α.")
satisfies(v::Interpretation, ::Negation, α::Formula)::Bool = !satisfies(v, α)
satisfies(v::Interpretation, α::UnaryOperation)::Bool = satisfies(v, operator(α), operand(α))
satisfies(v::Interpretation, ::Conjunction, α::Formula, β::Formula)::Bool = satisfies(v, α) && satisfies(v, β)
satisfies(v::Interpretation, ::Disjunction, α::Formula, β::Formula)::Bool = satisfies(v, α) || satisfies(v, β)
satisfies(v::Interpretation, ::Implication, α::Formula, β::Formula)::Bool = satisfies(v, α) <= satisfies(v, β)
satisfies(v::Interpretation, ::Biconditional, α::Formula, β::Formula)::Bool = satisfies(v, α) == satisfies(v, β)
satisfies(v::Interpretation, α::BinaryOperation)::Bool = satisfies(v, operator(α), operand1(α), operand2(α))
export satisfies

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
export nnf

distributive(c::Constant) = c
distributive(α::Atom) = α
distributive(α::UnaryOperation) = UnaryOperation(operator(α), distributive(operand(α)))
distributive(binop::BinaryOperator, α::Formula, β::Formula) = BinaryOperation(binop, distributive(α), distributive(β))
distributive(::Disjunction, α::BinaryOperation{Conjunction}, β::Formula) = distributive((operand1(α) ∨ β) ∧ (operand2(α) ∨ β))
distributive(::Disjunction, α::Formula, β::BinaryOperation{Conjunction}) = distributive((α ∨ operand1(β)) ∧ (α ∨ operand2(β)))
distributive(::Disjunction, α::BinaryOperation{Conjunction}, β::BinaryOperation{Conjunction}) = distributive((operand1(α) ∨ β) ∧ (operand2(α) ∨ β))
distributive(::Disjunction, α::Formula, β::Formula) = distributive(α) ∨ distributive(β)
distributive(α::BinaryOperation) = distributive(operator(α), operand1(α), operand2(α))
export distributive

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
