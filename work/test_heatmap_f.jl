include("../src/VisClaw.jl")
using Revise
using Printf

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010/_output")

# load topo
topo = VisClaw.loadtopo(simdir)

# load water surface
amrall = VisClaw.loadsurface(simdir)
VisClaw.replaceunit!(amrall, :minute)

using CairoMakie

fig = CairoMakie.Figure()

cmaptopo = :bukavu # or :gist_earth, :bukavu
cmapwater = :balance


for i = 1:amrall.nstep
    time_min = amrall.timelap[i]
    
    CairoMakie.empty!(fig)
    ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%03d min", time_min))
    CairoMakie.heatmap!(ax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-5000, 5000))
    VisClaw.makieheatmap!(ax, amrall.amr[i]; colormap=cmapwater, colorrange=(-0.1, 0.1))
    CairoMakie.Colorbar(fig[1,2], limits = (-0.1, 0.1), colormap = cmapwater, flipaxis = false)
    ## save
    CairoMakie.save(@sprintf("chile%03d_2d.png",i), fig)
end

