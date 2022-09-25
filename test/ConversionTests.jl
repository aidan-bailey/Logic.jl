module ConversionTests

include("../src/PropositionalLogic.jl")
using .PropositionalLogic.PropositionalSyntax
using .PropositionalLogic.Conversion

using Test

@testset "Conversion" begin

    @testset "Negation Normal Form" begin
        @test nnf(Atom("α")) == Atom("α")
        @test nnf(¬"α") == ¬"α"

        @test nnf("α" ∧ "β") == "α" ∧ "β"
        @test nnf(¬("α" ∧ "β")) == (¬"α") ∨ (¬"β")

        @test nnf("α" ∨ "β") == "α" ∨ "β"
        @test nnf(¬("α" ∨ "β")) == (¬"α") ∧ (¬"β")

        @test nnf("α" → "β") == (¬"α") ∨ "β"
        @test nnf(¬("α" → "β")) == "α" ∧ (¬"β")

        @test nnf("α" ↔ "β") == ("α" ∨ (¬"β")) ∧ ((¬"α") ∨ "β")
        @test nnf(¬("α" ↔ "β")) == ("α" ∨ "β") ∧ ((¬"α") ∨ (¬"β"))
    end

end

end
