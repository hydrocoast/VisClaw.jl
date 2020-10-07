using VisClaw
using Printf
using Plots
gr()
#plotlyjs()

# easy checker
# -----------------------------
# ike
# -----------------------------
simdir = joinpath(CLAW, "geoclaw/examples/storm-surge/ike/_output")

## sea surface height
#plt = plotscheck(simdir; color=:darkrainbow, clims=(-0.5,2.0))

## pressure
plt = plotscheck(simdir; vartype=:storm, color=cgrad(:darkrainbow, rev=true), clims=(960,1010))
# -----------------------------
