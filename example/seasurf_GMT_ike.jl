using VisClaw
using Printf
using GMT: GMT

# -----------------------------
# ike
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
output_prefix = "ike_eta_GMT"
using Dates: Dates
timeorigin = Dates.DateTime(2008, 9, 13, 7)

# load topo
topo = loadtopo(simdir)

# makecpt
cpt = GMT.makecpt(C=:jet, T="0.0/2.0", D=true, V=true)

# load water surface
amrall = loadsurface(simdir)
rmvalue_coarser!.(amrall.amr)

# projection and region GMT
proj = getJ("X10d", amrall.amr[1])
region = getR(amrall.amr[1])

# masking
landmask_txt = landmask_asc(topo)
#Gland = VisClaw.landmask_grd(landmask_txt, R=region, I=topo.dx, S="$(sqrt(2.0)topo.dx)d")

# time in string
time_dates = timeorigin .+ Dates.Second.(amrall.timelap)
time_str = Dates.format.(time_dates,"yyyy/mm/dd_HH:MM")

for i = 1:amrall.nstep
    outpdf = output_prefix*@sprintf("%03d", i)*".pdf"

    # land-masked surface grids
    #G = tilegrd_mask.(amrall.amr[i], landmask_txt; length_unit="d")
    G = tilegrd_mask(amrall, i, landmask_txt; length_unit="d")

    # plot
    gmtgrdimage_tiles(G, C=cpt, J=proj, R=region, B="+t"*time_str[i], Q=true)
    GMT.colorbar!(B="xa0.5f0.25 y+l(m)", D="jBR+w8.0/0.3+o-1.5/0.0", V=true)
    GMT.coast!(B="a10f10 neSW", D=:i, W=:thinnest, V=true, savefig=outpdf)
end

rm(landmask_txt, force=true)
# -----------------------------
