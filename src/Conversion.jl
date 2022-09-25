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
export distributive

"Convert a propositional formula to conjunctive normal form." # This could probably be a bit more efficient
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


"Acquire the disjunctive clauses from a propositional formula in cnf." # This method is not accurate TODO
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
