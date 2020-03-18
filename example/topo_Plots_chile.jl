using VisClaw
using Printf

### Topography and bathymetry
using Plots
gr()

# -----------------------------
# chile 2010
# -----------------------------
# load
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
#topodata = topodata(simdir)
if @isdefined(scratchdir)
    topo = loadtopo(joinpath(scratchdir,"etopo10min120W60W60S0S.asc"), 2)
else
    topo = loadtopo(simdir)
end

plt1 = plotscoastline(topo; lc=:black)
plotstoporange!(plt1, topo; lc=:magenta)

# plot
plt = plotstopo(topo; linetype=:heatmap, color=:topo, clims=(-5000,5000))
plt = plotscoastline!(plt, topo; lc=:black)

# save
#savefig(plt, "chile2010_topo.svg")
# -----------------------------
