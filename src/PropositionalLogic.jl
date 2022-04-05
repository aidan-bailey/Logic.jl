module PropositionalLogic

import PicoSAT

include("PropositionalSyntax.jl")
include("SatSolver.jl")
include("PropositionalSemantics.jl")

using .PropositionalSyntax
using .PropositionalSemantics

end # module
