using VisClaw
using GMT: GMT

## load
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
if @isdefined(scratchdir)
    topo = loadtopo(joinpath(scratchdir,"gulf_caribbean.tt3"), 3)
else
    topo = loadtopo(simdir)
end

track = loadtrack(simdir)

## plot
gmttopo(topo)
gmttoporange!(topo; lc=:red, lw=1.0)
GMT.colorbar!(B="xa2000f1000 y+l\"(m)\"", D="jBR+w5.0/0.2+o-1.0/-0.2")
gmttrack!(track; lc=:tomato, lw=1.0)
GMT.coast!(D=:i, W=:thinnest, savefig="ike_topo.pdf")


# projection and region GMT
gmttrack(track; lc=:tomato, lw=1.0, J="M12/16", R=[-96 -84 20 36])
gmtcoastline!(topo, J="M12/16", R=[-96 -84 20 36], savefig="ike_coastline_track.pdf")
