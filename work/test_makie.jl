#include("../src/VisClaw.jl")
#using VisClaw
using Revise
using Printf

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"../sofugan_bouss/radial_flat/_output")
#simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010/_output")

# load topo
topo = VisClaw.loadtopo(simdir)

# load water surface
amrall = VisClaw.loadsurface(simdir)
#VisClaw.coarsegridmask!(amrall)
VisClaw.replaceunit!(amrall, :minute)



using CairoMakie

amrtest = amrall.amr[10]
time_min = amrall.timelap[10]

ntile = length(amrtest)

cmaptopo = :bukavu # or :gist_earth, :bukavu
cmapwater = :balance

fig = Figure()
ax = Axis3(fig[1,1], title=@sprintf("%03d min", time_min), azimuth=-0.600pi, elevation=0.175pi) 
heatmap!(ax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-5000, 5000))
for i = 1:ntile
#i = 2
    x = collect(LinRange(amrtest[i].xlow, amrtest[i].xlow+(amrtest[i].mx-1)*amrtest[i].dx, amrtest[i].mx))
    y = collect(LinRange(amrtest[i].ylow, amrtest[i].ylow+(amrtest[i].my-1)*amrtest[i].dy, amrtest[i].my))
    z = amrtest[i].eta'
    surface!(ax, x, y, z, colormap=cmapwater, colorrange=(-0.1, 0.1))    
end    


hidedecorations!(ax)
hidespines!(ax) 
zlims!(ax, (-0.5, 0.5))

Colorbar(fig[1,2], limits = (-0.1, 0.1), colormap = cmapwater, flipaxis = false)

fig