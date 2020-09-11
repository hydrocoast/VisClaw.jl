using VisClaw

using Printf
using GMT: GMT

# -----------------------------
# bowl-radial
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/bowl-radial/_output")
output_prefix = "bowlradial_eta_GMT"

## load topo
topo = loadtopo(simdir)
Gtopo = geogrd(topo)

## makecpt
cpt = GMT.makecpt(C=:polar, T="-1.0/1.0", D=true, V=true)

## load water surface
amrall = loadsurface(simdir)
coarsegridmask!(amrall)

## projection and region GMT
proj = getJ("X10", topo)
region = getR(topo)

for i = 1:amrall.nstep
    #i = 5
    time_str = "+t"*@sprintf("%0.2f", amrall.timelap[i])
    outpdf = output_prefix*@sprintf("%03d", i)*".pdf"

    # land-masked surface grids
    G = tilegrd_xyz(amrall, i; J=proj, R=region)

    # plot
    gmtcoastline(Gtopo; J=proj, R=region, B=time_str, V=true)
    gmtgrdimage_tiles!(G, C=cpt, Q=true)
    GMT.colorbar!(J=proj, R=region, C=cpt, B="xa0.2f0.2 y+l(m)", D="jBR+w10.0/0.3+o-1.5/0.0", savefig=outpdf)
end

# -----------------------------
