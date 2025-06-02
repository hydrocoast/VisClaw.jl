using Revise
include("../src/VisClaw.jl")
using Printf
using CairoMakie

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010_fgmax-fgout/_output")


dtopo = VisClaw.loaddtopo(simdir)
VisClaw.makiedtopo(dtopo; colorrange=(-1.0, 1.0), colormap=:balance)
