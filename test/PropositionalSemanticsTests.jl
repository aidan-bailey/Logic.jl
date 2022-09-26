module PropositionalSemanticsTests

include("../src/PropositionalLogic.jl")
using .PropositionalLogic

using Test

@testset "Semantics" begin

    @testset "Models" begin

        @test_broken models(Atom("a")) == Set(Interpretation(Atom("a") => true))

    end

end

end
