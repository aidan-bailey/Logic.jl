module PropositionalLogic

import PicoSAT

include("PropositionalSyntax.jl")
include("PropositionalSemantics.jl")

using .PropositionalSyntax
using .PropositionalSemantics

end # module
