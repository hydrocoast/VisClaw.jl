using VisClaw
using Printf
using Plots
gr()

# -----------------------------
# ike
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
output_prefix = "ike_eta"
using Dates: Dates
timeorigin = Dates.DateTime(2008, 9, 13, 7)

## load track
track = loadtrack(simdir)
converttodatetime!(track, timeorigin)

## load parameters
surgeparams = surgedata(simdir)
## load water surface
amrall = loadsurface(simdir)
coarsegridmask!(amrall)
converttodatetime!(amrall, timeorigin)

## plot
plts = plotsamr(amrall; c=:darkrainbow, clims=(-0.5,2.0),
                xguide="Longitude", yguide="Latitude",
                xlims=(-99.0,-80.0), ylims=(16.0,32.0),
                guidefont=Plots.font("sans-serif",12),
                tickfont=Plots.font("sans-serif",10),
                )

## time in string
time_str = Dates.format.(amrall.timelap, "yyyy/mm/dd HH:MM")
plts = map((p,s)->plot!(p, title=s), plts, time_str)

## gauge locations (from gauges.data)
gauges = gaugedata(simdir)
## gauge location
plts = map(p -> plotsgaugelocation!(p, gauges; color=:white, offset=(0.25,-0.25), font=Plots.font(10, :white)), plts)

## track
plts = map((p,t) -> plotstrack!(p, track, 1:t; lc=:magenta), plts, 1:amrall.nstep)


## tiles
plts = gridnumber!.(plts, amrall.amr; font=Plots.font(12, :white, :center))
plts = tilebound!.(plts, amrall.amr)

## savefig
plotssavefig(plts, output_prefix*".png")
## gif
plotsgif(plts, output_prefix*".gif", fps=4)
# -----------------------------
