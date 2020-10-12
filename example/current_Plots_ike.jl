using VisClaw
using Printf
using Plots
gr()

# -----------------------------
# ike
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
output_prefix = "ike_velo"
using Dates: Dates
timeorigin = Dates.DateTime(2008, 9, 13, 7)

## for CI ########
pltchk = plotscheck(simdir; vartype=:current, testplot=true)
pltchk = plotscheck(simdir; vartype=:storm, testplot=true)
pltchk = plotscheck(simdir; testplot=true)
##################

## load current
amrall = loadcurrent(simdir)
coarsegridmask!(amrall)

## plot
plts = plotsamr(amrall; c=:isolum, clims=(0.0,2.0),
                xguide="Longitude", yguide="Latitude",
                xlims=(-99.0,-80.0), ylims=(16.0,32.0),
                guidefont=Plots.font("sans-serif",12),
                tickfont=Plots.font("sans-serif",10),
                colorbar_title="m/s"
                )

## time in string
time_dates = timeorigin .+ Dates.Second.(amrall.timelap)
time_str = Dates.format.(time_dates,"yyyy/mm/dd HH:MM")
plts = map((p,s)->plot!(p, title=s), plts, time_str)

## gauge locations (from gauges.data)
gauges = gaugedata(simdir)
## gauge location
plts = map(p->plotsgaugelocation!(p, gauges; color=:orange, offset=(0.25,-0.25), font=Plots.font(10, :white)), plts)

## tiles
plts = gridnumber!.(plts, amrall.amr; font=Plots.font(12, :black, :center))
plts = tilebound!.(plts, amrall.amr)

## save
plotssavefig(plts, output_prefix*".png")
## gif
plotsgif(plts, output_prefix*".gif", fps=4)
# -----------------------------
