module SyntaxTests

include("../../src/PropositionalLogic/PropositionalLogic.jl")
using .PropositionalLogic.Syntax
using .PropositionalLogic.Sugar

using Test

@testset "PL: Syntax" begin

    @testset "Constant" begin
        @test Constant <: Formula
        @testset "Tautology" begin
            @test Tautology <: Constant
            @test Tautology() isa Constant
            @test Tautology() == Tautology()
        end
        @testset "Contradiction" begin
            @test Contradiction <: Constant
            @test Contradiction() isa Constant
            @test Contradiction() == Contradiction()
        end
    end

    @testset "Atom" begin
        @test Atom <: Formula
        @test_throws MethodError Atom()
        @test Atom("Tweety") isa Atom
        @test name(Atom("Tweety")) == "Tweety"
        @test Atom("Tweety") == Atom("Tweety")
        @test Atom("Tweety1") != Atom("Tweety2")
        @test Atom(1) isa Atom
        @test Atom(1) != Atom("1")
    end

    @testset "Operator" begin
        @testset "UnaryOperator" begin
            @test UnaryOperator <: Operator
            @testset "Negation" begin
                @test Negation <: UnaryOperator
                @test Negation() isa Negation
                @test negation isa Negation
            end
        end
        @testset "BinaryOperator" begin
            @test BinaryOperator <: Operator
            @testset "Disjunction" begin
                @test Disjunction <: BinaryOperator
                @test Disjunction() isa Disjunction
            end
            @testset "Conjunction" begin
                @test Conjunction <: BinaryOperator
                @test Conjunction() isa Conjunction
            end
            @testset "Implication" begin
                @test Implication <: BinaryOperator
                @test Implication() isa Implication
            end
            @testset "Biconditional" begin
                @test Biconditional <: BinaryOperator
                @test Biconditional() isa Biconditional
            end
        end
    end

    @testset "Operation" begin
        @test Operation <: Formula
        @testset "UnaryOperation" begin
            @test UnaryOperation <: Operation
            @testset "Negation" begin
                @test UnaryOperation{Negation} <: UnaryOperation
                testFormula = UnaryOperation(Negation(), Atom("α"))
                @test testFormula isa UnaryOperation{Negation, Atom}
                @test operator(testFormula) isa Negation
                @test operand(testFormula) == Atom("α")
            end
        end
        @testset "BinaryOperation" begin
            @test BinaryOperation <: Operation
            @testset "Disjunction" begin
                @test BinaryOperation{Disjunction} <: BinaryOperation
                testFormula = BinaryOperation(Disjunction(), Atom("α"), Atom("β"))
                @test testFormula isa BinaryOperation{Disjunction}
                @test operator(testFormula) isa Disjunction
                @test operand1(testFormula) == Atom("α")
                @test operand2(testFormula) == Atom("β")
            end
            @testset "Conjunction" begin
                @test BinaryOperation{Conjunction} <: BinaryOperation
                testFormula = BinaryOperation(Conjunction(), Atom("α"), Atom("β"))
                @test testFormula isa BinaryOperation{Conjunction}
                @test operator(testFormula) isa Conjunction
                @test operand1(testFormula) == Atom("α")
                @test operand2(testFormula) == Atom("β")
            end
            @testset "Implication" begin
                @test BinaryOperation{Implication} <: BinaryOperation
                testFormula = BinaryOperation(Implication(), Atom("α"), Atom("β"))
                @test testFormula isa BinaryOperation{Implication}
                @test operator(testFormula) isa Implication
                @test operand1(testFormula) == Atom("α")
                @test operand2(testFormula) == Atom("β")
            end
            @testset "Biconditional" begin
                @test BinaryOperation{Biconditional} <: BinaryOperation
                testFormula = BinaryOperation(Biconditional(), Atom("α"), Atom("β"))
                @test testFormula isa BinaryOperation{Biconditional}
                @test operator(testFormula) isa Biconditional
                @test operand1(testFormula) == Atom("α")
                @test operand2(testFormula) == Atom("β")
            end
        end

    end

end

end
