using Revise
include("../src/VisClaw.jl")
using Printf
using CairoMakie

# directory
simdir = joinpath(VisClaw.CLAW, "geoclaw/examples/storm-surge/ike/_output")
track = VisClaw.loadtrack(simdir)

# 
fig, ax = VisClaw.makietrack(track)
CairoMakie.display(fig)
