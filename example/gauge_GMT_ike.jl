using VisClaw
using Printf
using GMT: GMT

## load results
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")

## read
params = geodata(simdir)
gauges = loadgauge(simdir; eta0=params.eta0, loadvel=true)
replaceunit!.(gauges, :hour)

## plot
gmtgaugewaveform(gauges[1], lw=1.0, lc=:blue, R=[-75 25 -1.0 5.0])
gmtgaugewaveform!(gauges[2], lw=1.0, lc=:green)
gmtgaugewaveform!(gauges[3], lw=1.0, lc=:tomato)
gmtgaugewaveform!(gauges[4], lw=1.0, lc=:chocolate, savefig="gauge_waveform_ike.pdf")

gmtgaugevelocity(gauges[1], lw=1.0, lc=:blue)
gmtgaugevelocity!(gauges[2], lw=1.0, lc=:green)
gmtgaugevelocity!(gauges[3], lw=1.0, lc=:tomato)
gmtgaugevelocity!(gauges[4], lw=1.0, lc=:chocolate, savefig="gauge_vel_ike.pdf")
