using VisClaw
using Printf
using GMT: GMT

# -----------------------------
# chile 2010
# -----------------------------
# load
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
dtopo = loaddtopo(simdir)

# makegrd
G = geogrd(dtopo; V=true)
# makecpt
cpt = GMT.makecpt(; C=:polar, T="-3.0/3.0", D=true)

# plot
region = getR(dtopo)
proj = getJ("X10d", axesratio(dtopo))

GMT.grdimage(G, C=cpt, J=proj, R=region, B="a5f5 neSW", Q=true, V=true)
GMT.colorbar!(J=proj, R=region, B="xa1.0f1.0 y+l\"(m)\"", D="jBR+w10.0/0.3+o-1.5/0.0", V=true)
GMT.coast!(J=proj, R=region, D=:i, W="thinnest,gray20", V=true)
GMT.grdcontour!(G, J=proj, R=region, C=1, A=2, W=:black, savefig="chile2010_dtopo.pdf")
# -----------------------------
