include("../src/VisClaw.jl")
using Revise
using Printf

# -----------------------------
# chile 2010
# -----------------------------
simdir = "/Users/miyashita/Research/AMR/geoclaw/examples/storm-surge/isaac/_output"

using CairoMakie
#fig = VisClaw.makiecheck(simdir, (0.0, 1.0))
fig = VisClaw.makiecheck(simdir, (0.0, 25.0); vartype=:wind)
