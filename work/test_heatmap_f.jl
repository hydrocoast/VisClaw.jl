include("../src/VisClaw.jl")
using Revise
using Printf

# chile 2010
#simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010/_output")
#fig_prefix = "chile2010"

# OWI Jebi
simdir = "/Users/miyashita/Research/AMR/simamr_meteotsunami_jp/owi_jebi/_output"
fig_prefix = "owi_jebi"

# load topo
topo = VisClaw.loadtopo(simdir)

# load water surface
amrall = VisClaw.loadsurface(simdir)
VisClaw.replaceunit!(amrall, :hour)

using CairoMakie

fig = CairoMakie.Figure()

cmaptopo = :bukavu # or :gist_earth, :bukavu
cmapwater = :balance
colorrange = (-0.5,0.5)

for i = 1:amrall.nstep
    time_min = amrall.timelap[i]
    
    CairoMakie.empty!(fig)
    #ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%03d min", time_min))
    ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%03d hours", time_min))
    CairoMakie.heatmap!(ax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-4000, 4000))
    VisClaw.makieheatmap!(ax, amrall.amr[i]; colormap=cmapwater, colorrange=colorrange)
    CairoMakie.Colorbar(fig[1,2], limits = colorrange, colormap = cmapwater, flipaxis = true)
    ## save
    #CairoMakie.save(fig_prefix*@sprintf("_%03d_2d.png",i), fig)
    CairoMakie.save(fig_prefix*@sprintf("_%03d_2d.png",i), fig)
end

