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
if @isdefined(scratchdir)
    dtopofile, dtopotype, ndtopo = dtopodata(joinpath(simdir, "dtopo.data"))
    dtopo = loaddtopo(joinpath(scratchdir,"dtopo_usgs100227.tt3"))
else
    dtopo = loaddtopo(simdir)
end

# plot
plt = plotsdtopo(dtopo; linetype=:contourf, color=:coolwarm, clims=(-3.0,3.0))
#savefig(plt, "chile_dtopo.svg")
# -----------------------------
