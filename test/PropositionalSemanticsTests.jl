module PropositionalSemanticsTests

include("../src/PropositionalLogic.jl")
using .PropositionalLogic

using Test

@testset "Semantics" begin

    @testset "Models" begin

        @test models(Atom("a")) == Set([I(Atom("a") => true)])
        @test models(¬"a") == Set([I(Atom("a") => false)])

        @test models("a" ∨ "b") == Set([
             I(Atom("a") => true, Atom("b") => false),
             I(Atom("a") => false, Atom("b") => true),
             I(Atom("a") => true, Atom("b") => true),
         ])

        @test models(¬("a" ∨ "b")) == Set([
             I(Atom("a") => false, Atom("b") => false),
         ])

        @test models(¬("a" ∧ "b")) == Set([
             I(Atom("a") => true, Atom("b") => false),
             I(Atom("a") => false, Atom("b") => true),
             I(Atom("a") => false, Atom("b") => false),
         ])

        @test models("a" → "b") == Set([
            I(Atom("a") => false, Atom("b") => false),
            I(Atom("a") => false, Atom("b") => true),
            I(Atom("a") => true, Atom("b") => true),
        ])

        @test models(¬("a" → "b")) == Set([
            I(Atom("a") => true, Atom("b") => false),
        ])

        @test models("a" ↔ "b") == Set([
            I(Atom("a") => false, Atom("b") => false),
            I(Atom("a") => true, Atom("b") => true),
        ])

        @test models(¬("a" ↔ "b")) == Set([
            I(Atom("a") => false, Atom("b") => true),
            I(Atom("a") => true, Atom("b") => false),
        ])

    end

    @testset "Entailment" begin

        @test entails(Atom("a"), Atom("a"))

        @test entails(¬"a", ¬"a")

        @test_broken entails("a" ∧ "b", "a")

    end

end

end
