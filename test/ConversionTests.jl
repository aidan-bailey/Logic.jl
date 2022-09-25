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

        @testset "Conjunctive Normal Form" begin
                @test cnf(("α" → "β") → "γ") == ("α" ∨ "γ") ∧ ((¬"β") ∨ "γ")
                @test (cnf("α" → ("β" → "γ"))) == ((¬"α") ∨ ((¬"β") ∨ "γ"))
        end


        @testset "Simplify" begin
                @test simplify(Atom("α")) == Atom("α")
                @test simplify((¬"α")) == (¬"α")
                @test simplify((¬⊤)) == ⊥
                @test simplify((¬⊥)) == ⊤
                @test simplify(("α" ∧ "β")) == ("α" ∧ "β")
                @test simplify(¬("α" ∧ "β")) == (¬("α" ∧ "β"))

                @test simplify(("α" ∧ ⊤)) == Atom("α")
                @test simplify((⊤ ∧ "α")) == Atom("α")
                @test simplify(("α" ∧ ⊥)) == ⊥
                @test simplify((⊥ ∧ "α")) == ⊥

                @test simplify((⊤ ∧ ⊤)) == ⊤
                @test simplify((⊤ ∧ ⊥)) == ⊥
                @test simplify((⊥ ∧ ⊥)) == ⊥
                @test simplify((⊥ ∧ ⊤)) == ⊥

                @test simplify(("α" ∨ ⊤)) == ⊤
                @test simplify((⊤ ∨ "α")) == ⊤
                @test simplify(("α" ∨ ⊥)) == Atom("α")
                @test simplify((⊥ ∨ "α")) == Atom("α")

                @test simplify((⊤ ∨ ⊤)) == ⊤
                @test simplify((⊤ ∨ ⊥)) == ⊤
                @test simplify((⊥ ∨ ⊥)) == ⊥
                @test simplify((⊥ ∨ ⊤)) == ⊤

                @test simplify(("α" → ⊤)) == ("α" ∨ ¬("α"))
                @test simplify((⊤ → "α")) == Atom("α")
                @test simplify(("α" → ⊥)) == (¬"α")
                @test simplify((⊥ → "α")) == ("α" ∨ ¬("α"))

                @test simplify((⊤ → ⊤)) == ⊤
                @test simplify((⊤ → ⊥)) == ⊥
                @test simplify((⊥ → ⊥)) == ⊤
                @test simplify((⊥ → ⊤)) == ⊤

                @test simplify(("α" ↔ ⊤)) == Atom("α")
                @test simplify((⊤ ↔ "α")) == Atom("α")
                @test simplify(("α" ↔ ⊥)) == (¬"α")
                @test simplify((⊥ ↔ "α")) == (¬"α")

                @test simplify((⊤ ↔ ⊤)) == ⊤
                @test simplify((⊤ ↔ ⊥)) == ⊥
                @test simplify((⊥ ↔ ⊥)) == ⊤
                @test simplify((⊥ ↔ ⊤)) == ⊥
        end

end

end
