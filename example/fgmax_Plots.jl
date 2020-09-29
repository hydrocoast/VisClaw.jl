using VisClaw
using Printf
using Plots

## directory
simdir = joinpath(CLAW, "geoclaw/examples/tsunami/radial-ocean-island-fgmax/_output")

## load fgmax
fg = fgmaxdata(simdir)

fgmax = loadfgmax.(simdir, fg)
replaceunit!.(fgmax, :hour)

pltA = plotsfgmax(fg[1], fgmax[1], :D; c=:amp, clims=(0.0,15.0))
pltA = plotsfgmax!(pltA, fg[3], fgmax[3], :D; c=:amp, clims=(0.0,15.0))

pltM = plotsfgmax(fg[1], fgmax[1], :Dmin; c=:ice, clims=(-10.0, 0.0))
pltM = plotsfgmax!(pltM, fg[3], fgmax[3], :Dmin; c=:ice, clims=(-10.0, 0.0))

plt = plotsfgmax(fg[2], fgmax[2], :D; label="max 2")
plt = plotsfgmax!(plt, fg[4], fgmax[4], :D; label="max 4")
plt = plotsfgmax!(plt, fg[5], fgmax[5], :D; label="max 5")
plt = plotsfgmax!(plt, fg[2], fgmax[2], :topo; lc=:black, label="topo 2")
plt = plotsfgmax!(plt, fg[4], fgmax[4], :topo; lc=:black, label="topo 4")
plt = plotsfgmax!(plt, fg[5], fgmax[5], :topo; lc=:black, label="topo 5")


## convert test
using Dates: Dates
converttodatetime!.(fgmax, Dates.DateTime(2020,1,1))
