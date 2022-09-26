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

    end

end

end
