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
fig = CairoMakie.Figure()
ax = CairoMakie.Axis(fig[1,1])
VisClaw.makieheatmap!(ax, fgo[1], fgout[1], 5; colorrange=(0.0, 1.0), colormap=:viridis)
CairoMakie.Colorbar(fig[1,2], limits=(0.0, 0.5), colormap=:viridis, flipaxis=true)

fig



#=
outputdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010_fgmax-fgout/_output")
filename= "fgout0001.q0005"
dat = readdlm(joinpath(outputdir, filename), Float64; skipstart=9)

D = reshape(dat[:,1],(fgout[1].nx, fgout[1].ny))
eta = reshape(dat[:,4],(fgout[1].nx, fgout[1].ny))
dry = D .< 1e-3
eta[dry] .= NaN

heatmap(eta; colormap=:viridis, colorrange=(-0.5, 0.5))
=#

#=
using CairoMakie
fig = CairoMakie.Figure()
ax = CairoMakie.Axis(fig[1,1])
VisClaw.makieheatmap!(ax, fg[1], fgmax[1]; colorrange=(0.0, 1.0), colormap=:viridis)
CairoMakie.Colorbar(fig[1,2], limits=(0.0, 0.5), colormap=:viridis, flipaxis=true)

fig
=#