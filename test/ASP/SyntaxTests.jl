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

            @test Func <: Term
            @test Func("f", (Variable("X"), Constant("a"))) isa Func
            @test Func("f", ()) == Func("f", ())

        end

    end

    @testset "Atom" begin

        @testset "Predicate" begin

            @test Predicate <: Atom
            @test Predicate("p", (Variable("X"), Constant("a"))) isa Predicate
            @test Predicate("p", ()) == Predicate("p", ())

        end

    end

end

end
