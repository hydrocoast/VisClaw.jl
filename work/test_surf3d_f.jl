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

#record(fig, "chile_3d.gif", 1:amrall.nstep) do i
for i = 1:amrall.nstep
    time_min = amrall.timelap[i]
    
    CairoMakie.empty!(fig)
    ax = CairoMakie.Axis3(fig[1,1], title=@sprintf("%03d min", time_min),azimuth=-0.600pi, elevation=0.20pi)
    CairoMakie.heatmap!(ax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-5000, 5000))
    VisClaw.makiesurface3d!(ax, amrall.amr[i]; colormap=cmapwater, colorrange=(-0.1, 0.1))
    CairoMakie.hidedecorations!(ax)
    CairoMakie.hidespines!(ax) 
    CairoMakie.zlims!(ax, (-0.5, 0.5))
    CairoMakie.Colorbar(fig[1,2], limits = (-0.1, 0.1), colormap = cmapwater, flipaxis = false)

    CairoMakie.save(@sprintf("chile%03d.png",i), fig)
end

