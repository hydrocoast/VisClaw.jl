using VisClaw
using GMT: GMT

## load
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
if @isdefined(scratchdir)
    topo = loadtopo(joinpath(scratchdir,"etopo10min120W60W60S0S.asc"), 2)
else
    topo = loadtopo(simdir)
end

## plot
gmttopo(topo)
GMT.colorbar!(B="xa1000f1000 y+l\"(m)\"", D="jBR+w10.0/0.3+o-1.2/-0.1")
gmtcoastline!(topo; savefig="chile2010_topo.pdf")
