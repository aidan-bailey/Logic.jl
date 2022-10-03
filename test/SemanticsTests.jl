module SemanticsTests

include("../src/PropositionalLogic.jl")
using .PropositionalLogic.Syntax
using .PropositionalLogic.Parsing
using .PropositionalLogic.Sugar
using .PropositionalLogic.Semantics

using Test

@testset "Semantics" begin

    @testset "Aliases" begin

        @testset "KnowledgeBase" begin
            @test KnowledgeBase <: Set{Formula}
            @test KnowledgeBase() isa KnowledgeBase
            @test K() isa KnowledgeBase
            @test K("a") == KnowledgeBase([Atom("a")])
            @test K(Atom("b")) == KnowledgeBase([Atom("a")])
            @test K("a", Atom("b")) == KnowledgeBase([Atom("a"), Atom("b")])
            @test K("a∧b") == KnowledgeBase([and("a", "b")])
        end

        @testset "Literal" begin
            @test Atom <: Literal
            @test UnaryOperation{UnaryOperator,Atom} <: Literal
        end

        @testset "Interpretation" begin
            @test Interpretation <: Set{Atom}
            @test I() isa Interpretation
            @test I(Atom("a")) == Interpretation([Atom("a")])
            @test I("a") == Interpretation([Atom("a")])
            @test I("a", Atom("b")) == Interpretation([Atom("a"), Atom("b")])
        end

        @testset "Clause" begin
            @test Clause <: Set{Literal}
            @test clause() isa Clause
        end

    end

    @testset "Conversions" begin

        @testset "Negation Normal Form" begin
            @test nnf('α') == Atom('α')
            @test nnf("¬α") == str2form("¬α")

            @test nnf("α∧β") == str2form("α∧β")
            @test nnf("¬(α∧β)") == str2form("¬α∨¬β")

            @test nnf("α∨β") == str2form("α∨β")
            @test nnf("¬(α∨β)") == str2form("¬α∧¬β")

            @test nnf("α→β") == str2form("¬α∨β")
            @test nnf("¬(α→β)") == str2form("α∧¬β")

            @test nnf("α↔β") == str2form("(α∨¬β)∧(¬α∨β)")
            @test nnf("¬(α↔β)") == str2form("(α∨β)∧(¬α∨¬β)")
        end

        @testset "Distributive" begin

            @test distributive('α') == Atom('α')
            @test distributive('α' ∧ 'β') == ('α' ∧ 'β')
            @test distributive('α' ∨ 'β') == ('α' ∨ 'β')
            @test distributive('α' → 'β') == ('α' → 'β')
            @test distributive('α' ↔ 'β') == ('α' ↔ 'β')

            @test distributive('α' ∧ ('β' ∨ 'γ')) == (('α' ∧ 'β') ∨ ('α' ∧ 'γ'))
            @test distributive('α' ∨ ('β' ∧ 'γ')) == (('α' ∨ 'β') ∧ ('α' ∨ 'γ'))
            @test distributive('α' ∧ ('β' ∧ 'γ')) == (('α' ∧ 'β') ∧ ('α' ∧ 'γ'))
            @test distributive('α' ∨ ('β' ∨ 'γ')) == (('α' ∨ 'β') ∨ ('α' ∨ 'γ'))
            @test distributive('α' → ('β' → 'γ')) == (('α' → 'β') → ('α' → 'γ'))
            @test distributive('α' → ('β' ↔ 'γ')) == (('α' → 'β') ↔ ('α' → 'γ'))
            @test distributive('α' → ('β' ∧ 'γ')) == (('α' → 'β') ∧ ('α' → 'γ'))
            @test distributive('α' → ('β' ↔ 'γ')) == (('α' → 'β') ↔ ('α' → 'γ'))

            @test distributive(('α' ∧ 'β') ∨ ('γ' ∧ 'δ')) == ((('α' ∨ 'γ') ∧ ('α' ∨ 'δ')) ∧ (('β' ∨ 'γ') ∧ ('β' ∨ 'δ')))

        end

        @testset "Conjunctive Normal Form" begin
            @test cnf(('α' → 'β') → 'γ') == ('α' ∨ 'γ') ∧ (¬'β' ∨ 'γ')
            @test (cnf('α' → ('β' → 'γ'))) == (¬'α' ∨ (¬'β' ∨ 'γ'))
        end


        @testset "Simplify" begin

            @test simplify('α') == Atom('α')
            @test simplify(¬'α') == (¬'α')
            @test simplify(¬⊤) == ⊥
            @test simplify(¬⊥) == ⊤
            @test simplify('α' ∧ 'β') == ('α' ∧ 'β')
            @test simplify(¬('α' ∧ 'β')) == ¬('α' ∧ 'β')

            @test simplify('α' ∧ ⊤) == Atom('α')
            @test simplify(⊤ ∧ 'α') == Atom('α')
            @test simplify('α' ∧ ⊥) == ⊥
            @test simplify(⊥ ∧ 'α') == ⊥

            @test simplify(⊤ ∧ ⊤) == ⊤
            @test simplify(⊤ ∧ ⊥) == ⊥
            @test simplify(⊥ ∧ ⊥) == ⊥
            @test simplify(⊥ ∧ ⊤) == ⊥

            @test simplify('α' ∨ ⊤) == ⊤
            @test simplify(⊤ ∨ 'α') == ⊤
            @test simplify('α' ∨ ⊥) == Atom('α')
            @test simplify(⊥ ∨ 'α') == Atom('α')

            @test simplify(⊤ ∨ ⊤) == ⊤
            @test simplify(⊤ ∨ ⊥) == ⊤
            @test simplify(⊥ ∨ ⊥) == ⊥
            @test simplify(⊥ ∨ ⊤) == ⊤

            @test simplify('α' → ⊤) == ('α' ∨ ¬'α')
            @test simplify(⊤ → 'α') == Atom('α')
            @test simplify('α' → ⊥) == (¬'α')
            @test simplify(⊥ → 'α') == ('α' ∨ ¬'α')

            @test simplify(⊤ → ⊤) == ⊤
            @test simplify(⊤ → ⊥) == ⊥
            @test simplify(⊥ → ⊥) == ⊤
            @test simplify(⊥ → ⊤) == ⊤

            @test simplify('α' ↔ ⊤) == Atom('α')
            @test simplify(⊤ ↔ 'α') == Atom('α')
            @test simplify('α' ↔ ⊥) == (¬'α')
            @test simplify(⊥ ↔ 'α') == (¬'α')

            @test simplify(⊤ ↔ ⊤) == ⊤
            @test simplify(⊤ ↔ ⊥) == ⊥
            @test simplify(⊥ ↔ ⊥) == ⊤
            @test simplify(⊥ ↔ ⊤) == ⊥
        end



        @testset "Disjunctive Clauses" begin

            @test disjunctiveclauses('a') == Set([clause('a')])

            @test disjunctiveclauses(¬'a') == Set([clause(¬'a')])

            @test disjunctiveclauses('a' ∨ 'b') == Set([clause('a', 'b')])
            @test disjunctiveclauses('a' ∨ 'b' ∨ 'c') == Set([clause('a', 'b', 'c')])

            @test disjunctiveclauses('a' ∧ 'b') == Set([clause('a'), clause('b')])
            @test disjunctiveclauses('a' ∧ 'b' ∧ 'c') == Set([clause('a'), clause('b'), clause('c')])
            @test disjunctiveclauses('a' ∧ ('b' ∨ 'c')) == Set([clause('a'), clause('b', 'c')])

            @test disjunctiveclauses(¬'a' ∨ 'b') == Set([clause(¬'a', 'b')])

        end


    end


    @testset "Models" begin

        @test models('a') == Set([I('a')])
        @test models(¬'a') == Set([I()])

        @test models('a' ∨ 'b') == Set([
            I('a'),
            I('b'),
            I('a', 'b'),
        ])

        @test models(¬('a' ∨ 'b')) == Set([
            I(),
        ])

        @test models(¬('a' ∧ 'b')) == Set([
            I('a'),
            I('b'),
            I()
        ])

        @test models('a' → 'b') == Set([
            I(),
            I('b'),
            I('a', 'b'),
        ])

        @test models(¬('a' → 'b')) == Set([
            I('a'),
        ])

        @test models('a' ↔ 'b') == Set([
            I(),
            I('a', 'b'),
        ])

        @test models(¬('a' ↔ 'b')) == Set([
            I('b'),
            I('a'),
        ])

    end

    @testset "Entailment" begin

        @test entails('a', 'a')
        @test entails(¬'a', ¬'a')
        @test entails('a' ∧ 'b', 'a')
        @test entails('a' ∧ 'b', 'a' ∧ 'b')
        @test entails('a' → 'b', 'a')
        @test entails('a' ↔ 'b', 'a' ∧ 'b')
        @test entails('a' ∧ 'b', 'a' ↔ 'b')

    end

end

end
