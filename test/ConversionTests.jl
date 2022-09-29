module ConversionTests

include("../src/PropositionalLogic.jl")
using .PropositionalLogic.Types
using .PropositionalLogic.Algorithms

using Test

@testset "Conversions" begin

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



        @testset "Disjunctive Clauses" begin

            @test disjunctiveclauses("a") == Set([clause("a")])

            @test disjunctiveclauses(¬"a") == Set([clause(¬"a")])

            @test disjunctiveclauses("a" ∨ "b") == Set([clause("a",  "b")])
            @test disjunctiveclauses("a" ∨ "b" ∨ "c") == Set([clause("a",  "b",  "c")])

            @test disjunctiveclauses("a" ∧ "b") == Set([clause("a"),  clause("b")])
            @test disjunctiveclauses("a" ∧ "b" ∧ "c") == Set([clause("a"),  clause("b"),  clause("c")])
            @test disjunctiveclauses("a" ∧ ("b" ∨ "c")) == Set([clause("a"), clause("b",  "c")])

            @test disjunctiveclauses(¬"a" ∨ "b") == Set([clause(¬"a",  "b")])

        end

end

end
