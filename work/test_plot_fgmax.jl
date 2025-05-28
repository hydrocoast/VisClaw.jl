#include("../src/VisClaw.jl")
using VisClaw
using Revise
using Printf

# OWI Jebi
simdir = "/Users/miyashita/Research/AMR/simamr_meteotsunami_jp/owi_jebi/_output"
fig_prefix = "owi_jebi"

## load fgmax
fg = VisClaw.fgmaxdata(simdir)

fgmax = VisClaw.loadfgmax.(simdir, fg)
#replaceunit!.(fgmax, :hour)


using CairoMakie
fig = CairoMakie.Figure()
#CairoMakie.empty!(fig)
ax = CairoMakie.Axis(fig[1,1])
VisClaw.makieheatmap!(ax, fg[1], fgmax[1]; colorrange=(0.0, 1.0), colormap=:viridis)
CairoMakie.Colorbar(fig[1,2], limits=(0.0, 0.5), colormap=:viridis, flipaxis=true)


fig