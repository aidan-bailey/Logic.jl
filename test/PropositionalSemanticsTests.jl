module PropositionalSemanticsTests

include("../src/PropositionalLogic.jl")
using .PropositionalLogic

using Test

@testset "Semantics" begin

    @testset "Models" begin

        @test models("a") == Set([I("a")])
        @test models(¬"a") == Set([I()])

        @test models("a" ∨ "b") == Set([
             I("a"),
             I("b"),
             I("a", "b"),
         ])

        @test models(¬("a" ∨ "b")) == Set([
            I(),
        ])

        @test models(¬("a" ∧ "b")) == Set([
             I("a"),
             I("b"),
             I()
         ])

        @test models("a" → "b") == Set([
            I(),
            I("b"),
            I("a", "b"),
        ])

        @test models(¬("a" → "b")) == Set([
            I("a"),
        ])

        @test models("a" ↔ "b") == Set([
            I(),
            I("a", "b"),
        ])

        @test models(¬("a" ↔ "b")) == Set([
            I("b"),
            I("a"),
        ])

    end

    @testset "Entailment" begin

        @test entails("a", "a")
        @test entails(¬"a", ¬"a")
        @test entails("a" ∧ "b", "a")
        @test entails("a" ∧ "b", "a" ∧ "b")
        @test entails("a" → "b", "a")
        @test entails("a" ↔ "b", "a" ∧ "b")
        @test entails("a" ∧ "b", "a" ↔ "b")

    end

end

end
