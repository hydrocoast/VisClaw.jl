using VisClaw
using GMT: GMT

## load
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
topo = loadtopo(simdir)
track = loadtrack(simdir)
gauges = loadgauge(simdir)

## plot
gmttopo(topo)
gmttoporange!(topo; lc=:red, lw=1.0)
GMT.colorbar!(B="xa2000f1000 y+l\"(m)\"", D="jBR+w5.0/0.2+o-1.0/-0.2")
gmttrack!(track; lc=:tomato, lw=1.0)
GMT.coast!(D=:i, W=:thinnest, savefig="ike_topo.pdf")

## projection and region GMT
gmttrack(track; lc=:tomato, lw=1.0, J="M12/16", R=[-96 -84 20 36])
gmtcoastline!(topo, J="M12/16", R=[-96 -84 20 36], savefig="ike_coastline_track.pdf")
