using VisClaw
using Printf
using Plots
gr()
#plotlyjs()

# easy checker
# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(CLAW, "geoclaw/examples/tsunami/chile2010/_output")

## sea surface height
plt = plotscheck(simdir; color=:balance, clims=(-0.5,0.5))

## velocity
#plt = plotscheck(simdir; vartype=:current, color=:isolum, clims=(0.0,0.1))
# -----------------------------
