include("../src/VisClaw.jl")
using Revise
using Printf

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010/_output")

using CairoMakie
fig = VisClaw.makiecheck(simdir, (-0.2, 0.2))
