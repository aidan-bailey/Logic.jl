module Parsing

using ..Syntax

using ParserCombinator

abstract type Node end
struct Form <: Node val end
struct Atom <: Node val end
struct And <: Node val end
struct Or <: Node val end
struct Neg <: Node val end
struct Impl <: Node val end
struct Equiv <: Node val end
struct Taut <: Node end
struct Contr <: Node end

process(root::Atom) = Syntax.Atom(root.val)

process(root::Neg) = Syntax.UnaryOperation(Syntax.Negation(), process(root.val))

process(::Taut) = Syntax.Tautology()

process(::Contr) = Syntax.Contradiction()

function process(root::Node)

    processedChildren::Vector{Syntax.Formula} = map(process, root.val)

    if length(processedChildren) == 1
        return processedChildren[1]
    end

    precedences = [And, Or, Impl, Equiv]

    for precop in precedences
        i = 2
        while i < length(root.val) + 1
            op = root.val[i]
            if op isa precop
                deleteat!(root.val, i)
                if op isa And
                    processedChildren[i-1] = Syntax.BinaryOperation(Syntax.Conjunction(),processedChildren[i-1], processedChildren[i])
                elseif op isa Or
                    processedChildren[i-1] = Syntax.BinaryOperation(Syntax.Disjunction(), processedChildren[i-1], processedChildren[i])
                elseif op isa Impl
                    processedChildren[i-1] = Syntax.BinaryOperation(Syntax.Implication(), processedChildren[i-1], processedChildren[i])
                elseif op isa Equiv
                    processedChildren[i-1] = Syntax.BinaryOperation(Syntax.Biconditional(), processedChildren[i-1], processedChildren[i])
                end
                deleteat!(processedChildren, i)
            else
                i+=1
            end
        end
    end

    return processedChildren[1]

end

tautnotation = (E"T" | E"⊤")
contrnotation = (E"F" | E"⊥")
ornotation = (E"|" | E"∨")
andnotation = (E"&" | E"∧")
implnotation = (E">" | E"→")
equivnotation = (E"<>" | E"↔")
negnotation = (E"!" | E"¬")

expr = Delayed()
or = Delayed()
and = Delayed()
neg = Delayed()
impl = Delayed()
equiv = Delayed()

atom = (tautnotation > Taut) | (contrnotation > Contr) | ((PInt() | PFloat64() | Word()) > Atom) | (E"(" + expr + E")" |> Form)

neg.matcher = (negnotation + neg > Neg) | atom

and.matcher = (andnotation + and |> And) | neg

or.matcher = (ornotation + or |> Or) | and

impl.matcher = (implnotation + impl |> Impl) | or

equiv.matcher = (equivnotation + neg |> Equiv) | impl

form = equiv

expr.matcher = form[0:end]

start = expr + Eos() |> Form

str2form(str::AbstractString)::Formula = process(parse_one(str, start)[1])
export str2form

end
