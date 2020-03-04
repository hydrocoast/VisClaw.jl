using VisClaw
using Printf

### Topography and bathymetry
using Plots
#gr()
plotlyjs()

# -----------------------------
# ike
# -----------------------------
# load
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
if @isdefined(scratchdir)
    topo = loadtopo(joinpath(scratchdir,"gulf_caribbean.tt3"), 3)
else
    topo = loadtopo(simdir)
end

# Plot
plt = plotstopo(topo; linetype=:heatmap, color=:delta, clims=(-6000,6000))
plt = plotscoastline!(plt, topo; lc=:black)

# save
#savefig(plt, "ike_topo.svg")
# -----------------------------
