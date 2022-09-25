module Conversion

using ..PropositionalSyntax

"Convert a propositional formula into negation normal form." # Efficient
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

"Convert a propositional formula to conjunctive normal form." # This could probably be a bit more efficient
function cnf(α::Formula)
    form = nnf(α)
    while form != distributive(form)
        form = distributive(form)
    end
    return form
end
export cnf

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
export disjunctiveclauses

"Convert a propositional formula in cnf into pico cnf format." # This method is sound and complete but could be more efficient
function picocnf(α::Formula)
    dclauses = disjunctiveclauses(α)
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
export picocnf

end
