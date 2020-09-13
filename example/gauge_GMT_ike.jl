using VisClaw
using Printf
using GMT: GMT

## load results
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")

## read
params = geodata(simdir)
gauges = loadgauge(simdir; eta0=params.eta0, loadvel=true)
replaceunit!.(gauges, :hour)

## plot waveforms
gmtgaugewaveform(gauges[1], lw=1.0, lc=:blue, R=[-75 25 -1.0 5.0])
gmtgaugewaveform!(gauges[2], lw=1.0, lc=:green)
gmtgaugewaveform!(gauges[3], lw=1.0, lc=:tomato)
gmtgaugewaveform!(gauges[4], lw=1.0, lc=:chocolate, savefig="gauge_waveform_ike.png")

gmtgaugevelocity(gauges[1], lw=1.0, lc=:blue)
gmtgaugevelocity!(gauges[2], lw=1.0, lc=:green)
gmtgaugevelocity!(gauges[3], lw=1.0, lc=:tomato)
gmtgaugevelocity!(gauges[4], lw=1.0, lc=:chocolate, savefig="gauge_vel_ike.png")

## location
#test
gmtgaugelocation(gauges[1]; marker=:circle, markerfacecolor=:blue)

topo = loadtopo(simdir)
Gtopo = geogrd(topo)
region=[-95.5 -93.5 28.8 29.8]
gmtgaugelocation(gauges[1:2]; R=region, marker=:circle, markerfacecolor=:blue)
gmtgaugelocation!(gauges[3:4]; R=region, marker=:circle, markerfacecolor=:red)
gmtgaugeannotation!(gauges[1]; offset=(0.0,-0.5))
gmtgaugeannotation!.(gauges[2:4], ["2","3","4"]; offset=(0.0,-0.5))
gmtcoastline!(Gtopo; R=region, savefig="gauge_location_ike.png")
