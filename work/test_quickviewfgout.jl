using Revise
include("../src/VisClaw.jl")
using Printf

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010_fgmax-fgout/_output")
#fg = VisClaw.fgoutdata(simdir)

using CairoMakie
fig = VisClaw.quickviewfgout(simdir)
