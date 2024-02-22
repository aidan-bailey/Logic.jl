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
            @test name(Variable("X")) == "X"

        end

        @testset "Constant" begin

            @test Constant <: Term
            @test Constant("a") isa Constant
            @test Constant("a") == Constant("a")
            @test name(Constant("a")) == "a"

        end

        @testset "Function" begin

            @testset "Function Signature" begin

                @test FunctionSignature("Apple", 1) isa FunctionSignature
                @test FunctionSignature("Apple", 1) == FunctionSignature("Apple", 1)
                @test name(FunctionSignature("Apple", 1)) == "Apple"
                @test arity(FunctionSignature("Apple", 1)) == 1

            end

            @test Func <: Term
            @test Func("Apple", Variable("X")) isa Func
            @test Func("Apple", Variable("X")) == Func("Apple", Variable("X"))
            @test name(Func("Apple", Variable("X"))) == "Apple"
            @test arguments(Func("Apple", Variable("X"))) == (Variable("X"),)
            @test arity(Func("Apple", Variable("X"))) == 1

        end

    end

    @testset "Atom" begin

        @testset "Predicate" begin

            @test Predicate <: Atom
            @test Predicate("p" ,Variable("X"), Constant("a")) isa Predicate
            @test Predicate("p", (Variable("X"))) == Predicate("p", (Variable("X")))
            @test name(Predicate("p", (Variable("X")))) == "p"
            @test arguments(Predicate("p", (Variable("X"), Constant("a")))) == (Variable("X"), Constant("a"))
            @test arity(Predicate("p", (Variable("X"), Constant("a"))) ) == 2
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

    @testset "Program" begin

        @test Program() isa Program
        @test Program() == Program()

    end


end

end
