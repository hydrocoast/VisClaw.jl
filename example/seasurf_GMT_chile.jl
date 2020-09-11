using VisClaw
using Printf
using GMT: GMT

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
output_prefix = "chile2010_eta_GMT"

# load topo
topo = loadtopo(simdir)

# makecpt
cpt = GMT.makecpt(C=:polar, T="-1.0/1.0", D=true, V=true)

# load water surface
amrall = loadsurface(simdir)
coarsegridmask!(amrall)

# projection and region GMT
region = getR(topo)
proj = getJ("X10d", topo)

# masking
landmask_txt = landmask_asc(topo)
Gland = landmask_grd(landmask_txt, R=region, I=topo.dx, S="$(sqrt(2.0)topo.dx)d")


for i = 1:amrall.nstep
    time_str = "+t"*@sprintf("%03d", amrall.timelap[i]/60.0)*"_min"
    outpdf = output_prefix*@sprintf("%03d", i)*".pdf"

    # land-masked surface grids
    G = tilegrd_mask(amrall, i, landmask_txt; length_unit="d")

    # plot
    GMT.grdimage(Gland, J=proj, R=region, C="white,gray80", Q=true)
    gmtgrdimage_tiles!(G, C=cpt, B=time_str, Q=true)
    GMT.colorbar!(B="xa0.5f0.5 y+l(m)", D="jBR+w10.0/0.3+o-1.5/0.0", V=true)
    GMT.coast!(B="a15f15 neSW", D=:i, W=:thinnest, V=true, savefig=outpdf)
end

rm(landmask_txt, force=true)
# -----------------------------
