using VisClaw
using Printf
using GMT: GMT

# -----------------------------
# chile2010
# -----------------------------
# load
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
if @isdefined(scratchdir)
    topo = loadtopo(joinpath(scratchdir,"etopo10min120W60W60S0S.asc"), 2)
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
GMT.grdimage(G, C=cpt, J=proj, R=region, B="a15f15 neSW", Q=true, V=true)
GMT.colorbar!(J=proj, R=region, B="xa1000f1000 y+l\"(m)\"", D="jBR+w10.0/0.3+o-1.2/-0.1", V=true)
GMT.coast!(J=proj, R=region, D=:i, W=:thinnest, V=true, savefig="chile2010_topo.pdf")
# -----------------------------
