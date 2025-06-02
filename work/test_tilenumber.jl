using Revise
include("../src/VisClaw.jl")
using Printf
using CairoMakie

#
#simdir = joinpath(VisClaw.CLAW, "geoclaw/examples/tsunami/chile2010_fgmax-fgout/_output")
simdir = joinpath(VisClaw.CLAW, "geoclaw/examples/storm-surge/ike/_output")

amrall = VisClaw.loadsurface(simdir)

fig = Figure()
ax = Axis(fig[1,1])
VisClaw.makieheatmap!(ax, amrall.amr[2]; colorrange=(-0.5,0.5))
VisClaw.tilenumber!(ax, amrall.amr[2])
VisClaw.tilebound!(ax, amrall.amr[2])

fig

