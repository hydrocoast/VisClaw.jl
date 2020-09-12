using VisClaw
using Printf
using Plots
gr()

# -----------------------------
# chile 2010
# -----------------------------
## Load observation
using DelimitedFiles: readdlm
#gaugeobs = Vector{VisClaw.Gauge}(undef,1)
# gauge 32412
#obsfile = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/32412_notide.txt")
#obs = readdlm(obsfile)
# Constructor
#gaugeobs[1]=VisClaw.Gauge("Gauge 32412 Obs.", 32412, size(obs,1), [], [], obs[:,1], obs[:,2])
##

## Load simulation result
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
# read
params = geodata(simdir)
gauges = loadgauge(simdir, eta0=params.eta0, loadvel=true)
replaceunit!.(gauges, :hour)
gmax = gaugemax(gauges[1])

## plot
plt = plotsgaugewaveform(gauges[1], lw=1.0)
#plotsgaugewaveform!(plt, gaugeobs[1], lc=:black, lw=0.5, linestyle=:dash)
plot!(plt; ylims=(-0.15, 0.25),
           xlabel="Time since earthquake (hour)",
           ylabel="Amplitude (m)",
           legendfont=Plots.font("sans-serif",12),
           guidefont=Plots.font("sans-serif",10),
           tickfont=Plots.font("sans-serif",10),
           legend=:topright,
           )

pltv = plotsgaugevelocity(gauges[1])
pltl = plotsgaugelocation(gauges[1])

## save
savefig(plt, "chile2010_waveform_gauge.png")
# -----------------------------
