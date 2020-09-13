using VisClaw

using Printf
using GMT: GMT

# -----------------------------
# bowl-radial
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/bowl-radial/_output")

## load topo
topo = loadtopo(simdir)
Gtopo = geogrd(topo)

## makecpt
cpt = GMT.makecpt(C=:polar, T="-1.0/1.0", D=true)

## load water surface
amrall = loadsurface(simdir)
coarsegridmask!(amrall)

## projection and region GMT
proj = getJ("X10", topo)
region = getR(topo)

for i = 1:amrall.nstep
    local time_str = @sprintf("%0.2f", amrall.timelap[i])
    local outpng = "bowlradial_eta_GMT"*@sprintf("%03d", i)*".png"

    # land-masked surface grids
    local G = tilegrd_xyz(amrall, i; J=proj, R=region)

    # plot
    gmtcoastline(Gtopo; J=proj, R=region, title=time_str)
    map(g -> GMT.grdimage!(g, J=proj, R=region, C=cpt, Q=true), G)
    GMT.colorbar!(J=proj, R=region, C=cpt, B="xa0.2f0.2 y+l(m)", D="jBR+w10.0/0.3+o-1.5/0.0", savefig=outpng)
end

# -----------------------------
