module SyntaxTests

include("../../src/ASP/ASP.jl")
using .ASP.Syntax

using Test

@testset "ASP: Syntax" begin

    @testset "Term" begin

        @testset "Variable" begin

            @test Variable <: Term
            @test Variable("X") isa Variable
            @test Variable("X") == Variable("X")

        end

        @testset "Constant" begin

            @test Constant <: Term
            @test Constant("a") isa Constant
            @test Constant("a") == Constant("a")

        end

        @testset "Function" begin

            @testset "Function Signature" begin

                @test FunctionSignature("Apple", 1) isa FunctionSignature
                @test FunctionSignature("Apple", 1) == FunctionSignature("Apple", 1)

            end

            @test Func <: Term
            @test Func("Apple", Variable("X")) isa Func
            @test Func("Apple", Variable("X")) == Func("Apple", Variable("X"))

        end

    end

    @testset "Atom" begin

        @testset "Predicate" begin

            @test Predicate <: Atom
            @test Predicate("p" ,Variable("X"), Constant("a")) isa Predicate
            @test Predicate("p", (Variable("X"))) == Predicate("p", (Variable("X")))
        end

    end

    @testset "Rule" begin

        @test Rule((), (), ()) isa Rule
        @test Rule((), (), ()) == Rule((), (), ())

    end

    @testset "Signature" begin

        @test Signature <: Tuple
        @test Signature((Set{PredicateSignature}(), Set{Variable}(), Set{Constant}(), Set{FunctionSignature}())) isa Signature
        @test Signature((Set{PredicateSignature}(), Set{Variable}(), Set{Constant}(), Set{FunctionSignature}())) == Signature((Set{PredicateSignature}(), Set{Variable}(), Set{Constant}(), Set{FunctionSignature}()))

    end


end

end
