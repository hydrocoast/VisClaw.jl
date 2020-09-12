using VisClaw
using Printf
using Plots
gr()

# -----------------------------
# ike
# -----------------------------
## load
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
topo = loadtopo(simdir)

## Plot
plt = plotstopo(topo; linetype=:heatmap, color=:delta, clims=(-6000,6000))
plt = plotscoastline!(plt, topo; lc=:black)

## save
savefig(plt, "ike_topo.png")
# -----------------------------
