include("../src/VisClaw.jl")
using Revise
using Printf

simdir = "/Users/miyashita/Research/AMR/simamr_meteotsunami_jp/owi_jebi/_output"
fig_prefix = "owi_jebi"


# load topo
topo = VisClaw.loadtopo(simdir)

# load water surface
amrall = VisClaw.loadstorm(simdir)
VisClaw.replaceunit!(amrall, :hour)

using CairoMakie

colorrange_pres = (970,1020)
cmap_pres = :plasma

fig = CairoMakie.Figure()

for i = 1:amrall.nstep
#for i = 10:10
    time_min = amrall.timelap[i]
    
    CairoMakie.empty!(fig)
    ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%03d hours", time_min))
    CairoMakie.heatmap!(ax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-4000, 4000))
    VisClaw.makieheatmap!(ax, amrall.amr[i]; colorrange=colorrange_pres, colormap=cmap_pres)
    VisClaw.makiewindarrows!(ax, amrall.amr[i],  4; AMRlevel=1:1, lengthscale=0.05, arrowsize=6)
    VisClaw.makiewindarrows!(ax, amrall.amr[i], 10; AMRlevel=2:2, lengthscale=0.05, arrowsize=6)
    CairoMakie.Colorbar(fig[1,2], limits=colorrange_pres, colormap=cmap_pres ,flipaxis=true)

    ## save
    CairoMakie.save(fig_prefix*@sprintf("_storm_%03d.png",i), fig)
end

#fig