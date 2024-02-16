module SugarTests

include("../../src/PropositionalLogic/PropositionalLogic.jl")
using .PropositionalLogic.Syntax
using .PropositionalLogic.Sugar

using Test

@testset "PL: Syntactical Sugar" begin

    @testset "Constant" begin

        @testset "Tautology" begin

            @test ⊤ isa Tautology
            @test tautology isa Tautology

        end

        @testset "Contradiction" begin

            @test ⊥ isa Contradiction
            @test contradiction isa Contradiction

        end

    end


    @testset "Operator" begin

        @testset "UnaryOperator" begin

            @testset "Negation" begin
                @test negation isa Negation
            end

        @testset "BinaryOperator" begin
            @testset "Disjunction" begin
                @test disjunction isa Disjunction
            end
            @testset "Conjunction" begin
                @test conjunction isa Conjunction
            end
            @testset "Implication" begin
                @test implication isa Implication
            end
            @testset "Biconditional" begin
                @test biconditional isa Biconditional
            end
        end

        end

    end

    @testset "Operation" begin
        @test Operation <: Formula
        @testset "UnaryOperation" begin
            @test UnaryOperation <: Operation
            @testset "Negation" begin
                testFormula = UnaryOperation(Negation(), Atom("α"))

                @test not(Atom("α")) == testFormula
                @test not("α") == testFormula

                @test ¬(Atom("α")) == testFormula
                @test (¬"α") == testFormula
            end
        end
        @testset "BinaryOperation" begin
            @testset "Disjunction" begin
                testFormula = BinaryOperation(Disjunction(), Atom("α"), Atom("β"))

                @test or(Atom("α"), Atom("β")) == testFormula
                @test or("α", Atom("β")) == testFormula
                @test or(Atom("α"), "β") == testFormula
                @test or("α", "β") == testFormula

                @test (Atom("α") ∨ Atom("β")) == testFormula
                @test ("α" ∨ Atom("β")) == testFormula
                @test (Atom("α") ∨ "β") == testFormula
                @test ("α" ∨ "β") == testFormula
            end
            @testset "Conjunction" begin
                @test BinaryOperation{Conjunction} <: BinaryOperation
                testFormula = BinaryOperation(Conjunction(), Atom("α"), Atom("β"))

                @test and(Atom("α"), Atom("β")) == testFormula
                @test and("α", Atom("β")) == testFormula
                @test and(Atom("α"), "β") == testFormula
                @test and("α", "β") == testFormula

                @test (Atom("α") ∧ Atom("β")) == testFormula
                @test ("α" ∧ Atom("β")) == testFormula
                @test (Atom("α") ∧ "β") == testFormula
                @test ("α" ∧ "β") == testFormula
            end
            @testset "Implication" begin
                testFormula = BinaryOperation(Implication(), Atom("α"), Atom("β"))

                @test implies(Atom("α"), Atom("β")) == testFormula
                @test implies("α", Atom("β")) == testFormula
                @test implies(Atom("α"), "β") == testFormula
                @test implies("α", "β") == testFormula

                @test (Atom("α") → Atom("β")) == testFormula
                @test ("α" → Atom("β")) == testFormula
                @test (Atom("α") → "β") == testFormula
                @test ("α" → "β") == testFormula
            end
            @testset "Biconditional" begin
                testFormula = BinaryOperation(Biconditional(), Atom("α"), Atom("β"))

                @test equals(Atom("α"), Atom("β")) == testFormula
                @test equals("α", Atom("β")) == testFormula
                @test equals(Atom("α"), "β") == testFormula
                @test equals("α", "β") == testFormula

                @test (Atom("α") ↔ Atom("β")) == testFormula
                @test ("α" ↔ Atom("β")) == testFormula
                @test (Atom("α") ↔ "β") == testFormula
                @test ("α" ↔ "β") == testFormula
            end
        end

    end


end

end
