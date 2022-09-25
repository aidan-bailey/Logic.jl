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

    @testset "Distributive" begin

        @test distributive(Atom("α")) == Atom("α")
        @test distributive("α" ∧ "β") == ("α" ∧ "β")
        @test distributive("α" ∨ "β") == ("α" ∨ "β")
        @test distributive("α" → "β") == ("α" → "β")
        @test distributive("α" ↔ "β") == ("α" ↔ "β")

        @test distributive("α" ∧ ("β" ∨ "γ")) == (("α" ∧ "β") ∨ ("α" ∧ "γ"))
        @test distributive("α" ∨ ("β" ∧ "γ")) == (("α" ∨ "β") ∧ ("α" ∨ "γ"))
        @test distributive("α" ∧ ("β" ∧ "γ")) == (("α" ∧ "β") ∧ ("α" ∧ "γ"))
        @test distributive("α" ∨ ("β" ∨ "γ")) == (("α" ∨ "β") ∨ ("α" ∨ "γ"))
        @test distributive("α" → ("β" → "γ")) == (("α" → "β") → ("α" → "γ"))
        @test distributive("α" → ("β" ↔ "γ")) == (("α" → "β") ↔ ("α" → "γ"))
        @test distributive("α" → ("β" ∧ "γ")) == (("α" → "β") ∧ ("α" → "γ"))
        @test distributive("α" → ("β" ↔ "γ")) == (("α" → "β") ↔ ("α" → "γ"))

        @test distributive(("α" ∧ "β") ∨ ("γ" ∧ "δ")) == ((("α" ∨ "γ") ∧ ("α" ∨ "δ")) ∧ (("β" ∨ "γ") ∧ ("β" ∨ "δ")))

    end

end

end
