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

"ASP function header type."
struct FunctionSignature{N}
    name::String
    arityVal::Val{N}
    FunctionSignature(name::String, arity::Int) = new{arity}(name, Val(arity))
end
export FunctionSignature

"ASP value type."
struct Func{N} <: Term
    signature::FunctionSignature{N}
    arguments:: NTuple{N, Term}
    Func(name::String, arguments::Term...) = new{length(arguments)}(FunctionSignature(name, length(arguments)), arguments)
    Func(name::String, arguments::Tuple) = new{length(arguments)}(FunctionSignature(name, length(arguments)), arguments)
end
export Func

"ASP atom supertype."
abstract type Atom end
export Atom

"ASP predicate signature type."
struct PredicateSignature{N}
    name::String
    arityVal::Val{N}
    PredicateSignature(name::String, arity::Int) = new{arity}(name, Val(arity))
end
export PredicateSignature

"ASP predicate type."
struct Predicate{N} <: Atom
    signature::PredicateSignature{N}
    arguments:: NTuple{N, Term}
    Predicate(name::String, arguments::Term...) = new{length(arguments)}(PredicateSignature(name, length(arguments)), arguments)
    Predicate(name::String, arguments::Tuple) = new{length(arguments)}(PredicateSignature(name, length(arguments)), arguments)
end
export Predicate

"ASP signature type."
const Signature = Tuple{Set{PredicateSignature}, Set{Variable}, Set{Constant}, Set{FunctionSignature}}
export Signature

"ASP rule type."
struct Rule{NHead, NBody, NNegatives}
    head::NTuple{NHead, Atom}
    body::NTuple{NBody, Atom}
    negatives::NTuple{NNegatives, Atom}
end
export Rule

"ASP program type."
const Program = Set{Rule}
export Program

end
