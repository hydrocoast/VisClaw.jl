using VisClaw
using Printf
using Plots
gr()

# -----------------------------
# ike
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")

## read
params = geodata(simdir)
gauges = loadgauge(simdir, eta0=params.eta0, loadvel=true)
replaceunit!.(gauges, :hour)
converttodatetime!.(gauges, Dates.DateTime(2008, 9, 13, 7))

## test
gtest = loadgauge(simdir, 3; loadeta=false)

## loadtopo
topo = loadtopo(simdir)

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

# -----------------------------
