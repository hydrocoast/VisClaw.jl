using VisClaw
using GMT: GMT

## load
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
topo = loadtopo(simdir)
gauges = loadgauge(simdir)

## plot
gmttopo(topo)
GMT.colorbar!(B="xa1000f1000 y+l\"(m)\"", D="jBR+w10.0/0.3+o-1.2/-0.1")
gmtcoastline!(topo; savefig="chile2010_topo.pdf")

##
gmtcoastline(topo)
gmtgaugelocation!(gauges[1]; marker=:circle, markerfacecolor=:black, savefig="coastline_gaugelocation_chile.pdf")
