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
topo = loadtopo(simdir)

plt1 = plotscoastline(topo; lc=:black)
plotstoporange!(plt1, topo; lc=:magenta)
plttmp = plotstoporange(topo; lc=:black)

# plot
plt = plotstopo(topo; linetype=:heatmap, color=:gist_earth, clims=(-5000,5000))
plt = plotscoastline!(plt, topo; lc=:black)

# save
#savefig(plt, "chile2010_topo.svg")
# -----------------------------
