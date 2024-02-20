module Syntax

"ASP term supertype."
abstract type Term end
export Term

"ASP variable type."
struct Variable <: Term
    name::String
end
export Variable

"ASP constant type."
struct Constant <: Term
    value::String
end
export Constant

"ASP function type."
struct Func{N} <: Term
    name::String
    arguments:: NTuple{N, Term}
    Func(name::String, arguments::Term...) = new{length(arguments)}(name, arguments)
    Func(name::String, arguments::Tuple) = new{length(arguments)}(name, arguments)
end
export Func

"ASP atom supertype."
abstract type Atom end
export Atom

"ASP predicate type."
struct Predicate{N} <: Atom
    name::String
    arguments::NTuple{N, Term}
    Predicate(name::String, arguments::Term...) = new{length(arguments)}(name, arguments)
    Predicate(name::String, arguments::Tuple) = new{length(arguments)}(name, arguments)
end
export Predicate

"ASP signature type."
const Signature = Tuple{Set{Type{Predicate}}, Set{Type{Variable}}, Set{Type{Constant}}, Set{Type{Func}}}
export Signature

"ASP rule type."
struct Rule{NHead, NBody, NNegatives}
    head::NTuple{NHead, Atom}
    body::NTuple{NBody, Atom}
    negatives::NTuple{NNegatives, Atom}
end
export Rule

end
