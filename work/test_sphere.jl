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
    lon0 = -90 - 2.0(i-1)
    lat0 = -30 + 1.5(i-1)
    gax = GeoAxis(fig[1, 1], dest="+proj=ortho +lon_0=$(lon0) +lat_0=$(lat0)")
    CairoMakie.heatmap!(gax, topo.x, topo.y, topo.elevation', colormap=cmaptopo, colorrange=(-5000, 5000))
    for j = 1:length(amrall.amr[i])
        tile = amrall.amr[i][j]
        x = collect(LinRange(tile.xlow, tile.xlow+(tile.mx-1)*tile.dx, tile.mx))
        y = collect(LinRange(tile.ylow, tile.ylow+(tile.my-1)*tile.dy, tile.my))
        z = tile.eta'
        CairoMakie.heatmap!(gax, x, y, z, colormap=cmapwater, colorrange=(-0.2, 0.2))
    end
    Colorbar(fig[1,2], limits = (-0.2, 0.2), colormap = cmapwater, flipaxis = false)

    save(@sprintf("chile%03d_sphere.png",i), fig)

end

