using Printf
using Revise
include("../src/VisClaw.jl")

using CairoMakie

simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/storm-surge/ike/_output")
topo = VisClaw.loadtopo(simdir)


fig = Figure()
ax = Axis(fig[1, 1])
VisClaw.makietopo!(ax, topo; colormap=:topo, colorrange=(-7000, 7000))
fig
