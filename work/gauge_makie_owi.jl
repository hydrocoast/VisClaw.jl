include("../src/VisClaw.jl")
using Revise
using Printf
using Dates
using GeoMakie
using CairoMakie

# -----------------------------
# ike
# -----------------------------
# OWI jebi
simdir = "/Users/miyashita/Research/AMR/simamr_meteotsunami_jp/owi_jebi/_output"
fig_prefix = "owi_jebi"

## read
params = VisClaw.geodata(simdir)
gauges = VisClaw.loadgauge(simdir, eta0=params.eta0, loadvel=true)
VisClaw.replaceunit!.(gauges, :hour)
#VisClaw.converttodatetime!.(gauges, Dates.DateTime(2018, 9, 1, 0, 0, 0))

## loadtopo
topo = VisClaw.loadtopo(simdir)

fig = CairoMakie.Figure()
ax1 = CairoMakie.Axis(fig[1, 1])
VisClaw.makietopo!(ax1,topo; colormap=:topo, colorrange=(-5000,5000))
VisClaw.makiegaugelocation!(ax1, gauges)

ax2 = CairoMakie.Axis(fig[1, 2])
#VisClaw.makiegaugewaveform!(ax2, gauges[1])
#VisClaw.makiegaugevelocity!(ax2, gauges[1])
VisClaw.makiegaugewaveform!.(ax2, gauges)
VisClaw.makiegaugevelocity!.(ax2, gauges)


#=
pltgl = plotsgaugelocation(gauges)
pltgl = plotscoastline!(pltgl, topo; xlims=(-95.5, -93.5), ylims=(28.5, 30.0), axis_ratio=:equal, lc=:black, colorbar=false)


## plot
plt = plotsgaugewaveform(gauges, lw=1.0)
plt = plot!(plt; ylabel="Surface (m)",
            legendfont=Plots.font("sans-serif",10),
            guidefont=Plots.font("sans-serif",10),
            tickfont=Plots.font("sans-serif",10),
            legend=:topleft,
            )
pltv = plotsgaugevelocity(gauges)

## save
savefig(plt, "ike_waveform_gauge.png")
=#

# -----------------------------
