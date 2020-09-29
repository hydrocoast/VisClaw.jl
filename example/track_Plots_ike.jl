using VisClaw
using Printf
using Plots

simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")

## load topo
topo = loadtopo(simdir)

## load track
track = loadtrack(simdir)
replaceunit!(track, :hour)

## plot
plt = plotstrack(track, lc=:red, lw=1.5, colorbar=false)
plt = plotscoastline!(plt, topo; lw=1.0, lc=:black, xlims=(-100,-80), ylims=(20,35))
