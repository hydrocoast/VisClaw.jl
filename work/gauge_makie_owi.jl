include("../src/VisClaw.jl")
using Revise
using Printf
using Dates
using GeoMakie
using CairoMakie

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

fig = CairoMakie.Figure(size=(900, 450))
ax1 = CairoMakie.Axis(fig[1, 1])
VisClaw.makietopo!(ax1, topo; colormap=:topo, colorrange=(-5000,5000))
VisClaw.makiegaugelocation!(ax1, gauges)
CairoMakie.Colorbar(fig[1,2], limits = (-5000, 5000), colormap = :topo, flipaxis = false)

ax2 = CairoMakie.Axis(fig[1,3], xlabel="Time (hour)", ylabel="Water level (m)")
VisClaw.makiegaugewaveform!(ax2, gauges)
#=
for g in gauges
    VisClaw.makiegaugewaveform!(ax2, g)
end
=#

