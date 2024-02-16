module ParsingTests

include("../../src/PropositionalLogic/PropositionalLogic.jl")
using .PropositionalLogic.Syntax
using .PropositionalLogic.Sugar
using .PropositionalLogic.Parsing

using Test

@testset "PL: Parsing" begin

    @testset "Atom" begin

        @test str2form("a") == Atom("a")

    end

    @testset "Negation" begin

        @test str2form("!a") == not(Atom("a"))
        @test str2form("¬a") == not(Atom("a"))
        @test str2form("!a") == not(Atom("a"))
        @test str2form("¬¬a") == not(not(Atom("a")))
        @test str2form("¬!a") == not(not(Atom("a")))

    end

    @testset "Disjunction" begin

        @test str2form("a|b") == or("a", "b")
        @test str2form("!a|b") == or(not("a"), "b")
        @test str2form("¬(a|b)") == not(or("a", "b"))
        @test str2form("¬(a|!b)") == not(or("a", not("b")))

    end

    @testset "Conjunction" begin

        @test str2form("a&b") == and("a", "b")

    end

    @testset "Implication" begin

        @test str2form("a>b") == implies("a", "b")

    end

    @testset "Biconditional" begin

        @test str2form("a<>b") == equals("a", "b")

    end

end

end
