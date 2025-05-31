using Revise
using Printf
using DelimitedFiles

#using VisClaw
include("../src/VisClaw.jl")

# -----------------------------
# chile 2010
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010_fgmax-fgout/_output")


## load fgmax
fg = VisClaw.fgmaxdata(simdir)
fgmax = VisClaw.loadfgmax.(simdir, fg)

fgo = VisClaw.fgoutdata(simdir)
fgout = VisClaw.loadfgout.(simdir, fgo)

using CairoMakie

clims = (-0.25, 0.25)
cmap = :viridis
fig = CairoMakie.Figure()
VisClaw.makieheatmap!(CairoMakie.Axis(fig[1,1]), fgo[1], fgout[1], 1; colorrange=clims, colormap=cmap)
VisClaw.makieheatmap!(CairoMakie.Axis(fig[1,2]), fgo[1], fgout[1], 2; colorrange=clims, colormap=cmap)
VisClaw.makieheatmap!(CairoMakie.Axis(fig[1,3]), fgo[1], fgout[1], 3; colorrange=clims, colormap=cmap)
VisClaw.makieheatmap!(CairoMakie.Axis(fig[2,1]), fgo[1], fgout[1], 4; colorrange=clims, colormap=cmap)
VisClaw.makieheatmap!(CairoMakie.Axis(fig[2,2]), fgo[1], fgout[1], 5; colorrange=clims, colormap=cmap)
VisClaw.makieheatmap!(CairoMakie.Axis(fig[2,3]), fgo[1], fgout[1], 6; colorrange=clims, colormap=cmap)
VisClaw.makieheatmap!(CairoMakie.Axis(fig[3,1]), fgo[1], fgout[1], 7; colorrange=clims, colormap=cmap)
VisClaw.makieheatmap!(CairoMakie.Axis(fig[3,2]), fgo[1], fgout[1], 8; colorrange=clims, colormap=cmap)
VisClaw.makieheatmap!(CairoMakie.Axis(fig[3,3]), fgo[1], fgout[1], 9; colorrange=clims, colormap=cmap)
CairoMakie.Colorbar(fig[3,4], limits=clims, colormap=cmap, flipaxis=true)
fig


figm = CairoMakie.Figure()
ax = CairoMakie.Axis(figm[1,1])
VisClaw.makieheatmap!(ax, fg[1], fgmax[1]; colorrange=(0.0, 1.0), colormap=:viridis)
CairoMakie.Colorbar(figm[1,2], limits=(0.0, 0.5), colormap=:viridis, flipaxis=true)
figm

#=
fig = CairoMakie.Figure()
ax = CairoMakie.Axis(fig[1,1])
VisClaw.makieheatmap!(ax, fgo[1], fgout[1], 5; colorrange=(0.0, 1.0), colormap=:viridis)
CairoMakie.Colorbar(fig[1,2], limits=(0.0, 0.5), colormap=:viridis, flipaxis=true)
fig
=#

