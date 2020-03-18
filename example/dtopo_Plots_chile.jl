using VisClaw
using Printf

### Seafloor deformation (for tsunami simulation)
using Plots
gr()

# -----------------------------
# chile 2010
# -----------------------------
# load
simdir = joinpath(VisClaw.CLAW, "geoclaw/examples/tsunami/chile2010/_output")
#dtopodata = dtopodata(simdir)
if @isdefined(scratchdir)
    dtopo = loaddtopo(joinpath(scratchdir,"dtopo_usgs100227.tt3"))
else
    dtopo = loaddtopo(simdir)
end

# plot
plt = plotstopo(dtopo; linetype=:contourf, color=:coolwarm, clims=(-3.0,3.0))
#savefig(plt, "chile_dtopo.svg")
# -----------------------------
