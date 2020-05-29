using VisClaw

using Printf
using GMT: GMT

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
output_prefix = "chile2010_eta_GMT"

# load topo
if @isdefined(scratchdir)
    topo = loadtopo(joinpath(scratchdir,"etopo10min120W60W60S0S.asc"), 2)
else
    topo = loadtopo(simdir)
end

# makecpt
cpt = GMT.makecpt(C=:polar, T="-1.0/1.0", D=true, V=true)

# load water surface
amrall = loadsurface(simdir)
rmvalue_coarser!.(amrall.amr)

# projection and region GMT
region = getR(amrall.amr[1])
proj = getJ("X10d", axesratio(amrall.amr[1]))

# masking
landmask_txt = landmask_asc(topo)
Gland = landmask_grd(landmask_txt, R=region, I=topo.dx, S="$(sqrt(2.0)topo.dx)d")


for i = 1:amrall.nstep
    time_str = "+t"*@sprintf("%03d", amrall.timelap[i]/60.0)*"_min"
    outpdf = output_prefix*@sprintf("%03d", i)*".pdf"

    # land-masked surface grids
    G = tilegrd_mask.(amrall.amr[i], landmask_txt; length_unit="d")

    # plot
    GMT.basemap(J=proj, R=region, B=time_str)
    GMT.grdimage!(Gland, R=region, J=proj, C="white,gray80", Q=true)
    GMT.grdimage!.(G, C=cpt, J=proj, R=region, B="", Q=true)
    GMT.colorbar!(J=proj, R=region, B="xa0.5f0.5 y+l(m)", D="jBR+w10.0/0.3+o-1.5/0.0", V=true)
    GMT.coast!(J=proj, R=region, B="a15f15 neSW", D=:i, W=:thinnest, V=true, fmt="PDF", savefig=outpdf)
end

rm(landmask_txt, force=true)
# -----------------------------
