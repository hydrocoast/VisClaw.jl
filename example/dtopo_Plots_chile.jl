using VisClaw
using Printf

using Plots
gr()

# -----------------------------
# chile 2010
# -----------------------------
## load
simdir = joinpath(VisClaw.CLAW, "geoclaw/examples/tsunami/chile2010/_output")
dtopo = loaddtopo(simdir)

## output test
printdtopo(dtopo)

## plot
plt = plotsdtopo(dtopo; linetype=:contourf, color=:coolwarm, clims=(-3.0,3.0))
savefig(plt, "chile_dtopo.png")
# -----------------------------
