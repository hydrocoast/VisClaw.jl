using VisClaw
using Printf
using GMT: GMT

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")

# load topo
topo = loadtopo(simdir)

# makecpt
cpt = GMT.makecpt(C=:polar, T="-0.5/0.5", D=true)

# load water surface
amrall = loadsurface(simdir)
coarsegridmask!(amrall)
replaceunit!(amrall, :minute)

# projection and region GMT
region = getR(topo)
proj = getJ("X10d", topo)

# masking
landmask_txt = landmask_asc(topo)
Gland = landmask_grd(landmask_txt, R=region, I=topo.dx, S="$(sqrt(2.0)topo.dx)d")


for i = 1:amrall.nstep
    local time_str = @sprintf("%03d", amrall.timelap[i])*" min"
    local outpng = "chile_etagmt-"*@sprintf("%03d", i)*".png"

    # land-masked surface grids
    local G = tilegrd_mask(amrall, i, landmask_txt; length_unit="d")

    # plot
    GMT.grdimage(Gland, J=proj, R=region, C="white,gray80", Q=true, title=time_str)
    map(g -> GMT.grdimage!(g, J=proj, R=region, C=cpt, Q=true), G)
    GMT.colorbar!(B="xa0.1f0.1 y+l(m)", D="jBR+w10.0/0.3+o-1.5/0.0")
    GMT.coast!(B="a15f15 neSW", D=:i, W=:thinnest, savefig=outpng)
end

rm(landmask_txt, force=true)
# -----------------------------
