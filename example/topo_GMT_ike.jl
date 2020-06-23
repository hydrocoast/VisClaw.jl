using VisClaw
using Printf
using GMT: GMT

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

# makegrd
G = geogrd(topo; V=true)
# makecpt
cpt = GMT.makecpt(; C=:earth, T="-7000/4500", D=true)

# plot
region = getR(topo)
proj = getJ("X10d", axesratio(topo))
GMT.grdimage(G, C=cpt, J=proj, R=region, B="a10f10 neSW", Q=true, V=true)
GMT.colorbar!(J=proj, R=region, B="xa2000f1000 y+l\"(m)\"", D="jBR+w5.5/0.2+o-1.0/-0.5", V=true)
GMT.coast!(J=proj, R=region, D=:i, W=:thinnest, V=true, savefig="ike_topo.pdf")
# -----------------------------
