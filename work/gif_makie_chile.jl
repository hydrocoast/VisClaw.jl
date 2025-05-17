include("../src/VisClaw.jl")
using .VisClaw
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
#coarsegridmask!(amrall)
VisClaw.replaceunit!(amrall, :minute)



using CairoMakie

fig = Figure()

cmaptopo = :bukavu # or :gist_earth, :bukavu
cmapwater = :balance

#record(fig, "chile_3d.gif", 1:amrall.nstep) do i
for i = 1:amrall.nstep
    amrtest = amrall.amr[i]
    time_min = amrall.timelap[i]
    
    ntile = length(amrtest)
    
    empty!(fig)
    ax = Axis3(fig[1,1], title=@sprintf("%03d min", time_min),azimuth=-0.600pi, elevation=0.20pi)
    heatmap!(ax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-5000, 5000))
    for j = 1:ntile
        x = collect(LinRange(amrtest[j].xlow, amrtest[j].xlow+(amrtest[j].mx-1)*amrtest[j].dx, amrtest[j].mx))
        y = collect(LinRange(amrtest[j].ylow, amrtest[j].ylow+(amrtest[j].my-1)*amrtest[j].dy, amrtest[j].my))
        z = amrtest[j].eta'
        surface!(ax, x, y, z, colormap=cmapwater, colorrange=(-0.1, 0.1))
    end    
    hidedecorations!(ax)
    hidespines!(ax) 
    zlims!(ax, (-0.5, 0.5))
    Colorbar(fig[1,2], limits = (-0.1, 0.1), colormap = cmapwater, flipaxis = false)

    save(@sprintf("chile%03d.png",i), fig)
end


#=
amrtest = amrall.amr[10]
time_min = amrall.timelap[10]

ntile = length(amrtest)

for i = 1:ntile
    x = collect(LinRange(amrtest[i].xlow, amrtest[i].xlow+(amrtest[i].mx-1)*amrtest[i].dx, amrtest[i].mx))
    y = collect(LinRange(amrtest[i].ylow, amrtest[i].ylow+(amrtest[i].my-1)*amrtest[i].dy, amrtest[i].my))
    z = amrtest[i].eta'
    surface!(ax, x, y, z, colormap=:viridis, colorrange=(-0.1, 0.1))
end    
hidedecorations!(ax)
hidespines!(ax) 
zlims!(ax, (-0.5, 0.5))
Colorbar(fig[1,2], limits = (-0.1, 0.1), colormap = :viridis, flipaxis = false)
=#