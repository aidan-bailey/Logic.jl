module PropositionalLogic

include("Syntax.jl")
include("Parsing.jl")
include("Sugar.jl")
include("Semantics.jl")

using .Syntax
using .Parsing
using .Sugar
using .Semantics

end # module
