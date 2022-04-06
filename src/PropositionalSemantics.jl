module PropositionalSemantics

using ..PropositionalSyntax
import ..SatSolver

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

"Check if a propositional formula is satisfiable." # Efficient
issatisfiable(α::Formula)::Bool = SatSolver.satisfiable(α)
export issatisfiable

"Get the models of a propositional formula." # Efficient
models(α::Formula)::Set{Interpretation} = SatSolver.models(α)
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
