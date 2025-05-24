#include("../src/VisClaw.jl")
#using Revise
using Printf

# chile 2010
#simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010/_output")
#fig_prefix = "chile2010"
#lon0, lat0 = -90, -30

# OWI jebi
simdir = "/Users/miyashita/Research/AMR/simamr_meteotsunami_jp/owi_jebi/_output"
fig_prefix = "owi_jebi"
lon0, lat0 = 135, 35

# load topo
topo = VisClaw.loadtopo(simdir)

# load water surface
amrall = VisClaw.loadsurface(simdir)
#VisClaw.replaceunit!(amrall, :minute)
VisClaw.replaceunit!(amrall, :hour)

using GeoMakie, CairoMakie
cmaptopo = :bukavu # or :gist_earth, :bukavu
cmapwater = :bwr # :balance, :bwr

#fig0 = CairoMakie.Figure()
#gax0 = GeoAxis(fig0[1, 1], dest="+proj=ortho +lon_0=-90 +lat_0=-30")
#CairoMakie.heatmap!(gax0, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-5000, 5000))

fig = CairoMakie.Figure()

for i = 1:amrall.nstep
#for i = 2:2
    time_min = amrall.timelap[i]

    CairoMakie.empty!(fig)
    gax = GeoAxis(fig[1, 1], dest="+proj=ortho +lon_0=$(lon0) +lat_0=$(lat0)", title=@sprintf("%03d hours", amrall.timelap[i]))
    CairoMakie.heatmap!(gax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-5000, 5000))
    VisClaw.makieheatmap!(gax, amrall.amr[i]; colormap=cmapwater, colorrange=(-0.2, 0.2))
    Colorbar(fig[1,2], limits = (-0.2, 0.2), colormap = cmapwater, flipaxis = true)

    save(fig_prefix*@sprintf("_ortho_%03d.png",i-1), fig)

end

