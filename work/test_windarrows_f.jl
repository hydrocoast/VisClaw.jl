include("../src/VisClaw.jl")
using Revise
using Printf

simdir = "/Users/miyashita/Research/AMR/geoclaw/examples/storm-surge/isaac/_output"
# load topo
topo = VisClaw.loadtopo(simdir)

# load water surface
amrall = VisClaw.loadstorm(simdir)
VisClaw.replaceunit!(amrall, :minute)

using CairoMakie

colorrange = (0,20)

fig = CairoMakie.Figure()

for i = 1:amrall.nstep
#for i = 10:10
    time_min = amrall.timelap[i]
    
    CairoMakie.empty!(fig)
    ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%03d min", time_min))
    #CairoMakie.heatmap!(ax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-5000, 5000))
    VisClaw.makieheatmap!(ax, amrall.amr[i]; wind=true, colorrange=colorrange)
    VisClaw.makiewindarrows!(ax, amrall.amr[i], 5; AMRlevel=1:1, lengthscale=0.05, arrowsize=6)
    CairoMakie.Colorbar(fig[1,2], limits=colorrange, flipaxis=true)

    ## save
    CairoMakie.save(@sprintf("wind_isaactest_%03d.png",i), fig)
end

#fig