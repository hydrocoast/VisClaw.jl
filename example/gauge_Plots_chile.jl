using VisClaw
using Printf
### Waveform plots from gauges
using Plots
gr()

sec1h = 3.6e3
sec1d = 24sec1h

# -----------------------------
# chile 2010
# -----------------------------
## Load observation ##
using DelimitedFiles: readdlm
#gaugeobs = Vector{VisClaw.Gauge}(undef,1)
# gauge 32412
#obsfile = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/32412_notide.txt")
#obs = readdlm(obsfile)
# Constructor
#gaugeobs[1]=VisClaw.Gauge("Gauge 32412 Obs.", 32412, size(obs,1), [], [], obs[:,1], obs[:,2])
##

## Load simulation result ##
simdir = joinpath(CLAW,"geoclaw/examples/tsunami/chile2010/_output")
# read
params = geodata(simdir)
gauges = loadgauge(simdir, eta0=params.eta0)
##


# plot
plt = plotsgaugewaveform(gauges[1], lw=1.0)
#plt = plotsgaugewaveform!(plt, gaugeobs[1], lc=:black, lw=0.5, linestyle=:dash)
plt = plot!(plt; xlims=(-0.5sec1h, 9.5sec1h), ylims=(-0.15, 0.25),
                 xlabel="Time since earthquake (hour)",
                 ylabel="Amplitude (m)",
                 xticks=(0.0:sec1h:9.0sec1h, [@sprintf("%d",i) for i=0:9]),
                 legendfont=Plots.font("sans-serif",12),
                 guidefont=Plots.font("sans-serif",10),
                 tickfont=Plots.font("sans-serif",10),
                 legend=:topright,
                 )

# save
#savefig(plt, "chile2010_waveform_gauge.svg")
# -----------------------------
