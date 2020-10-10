using VisClaw

using Printf
using Plots
gr()

# -----------------------------
# ike
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
output_prefix = "ike_wind"
using Dates: Dates
timeorigin = Dates.DateTime(2008, 9, 13, 7)

## load
amrall = loadstorm(simdir)
coarsegridmask!(amrall)
converttodatetime!(amrall, timeorigin)

topo = loadtopo(simdir)

## plot amrgrid
plts = plotsamr(amrall;
                c=:darktest, clims=(0.0, 40.0),
                xguide="Longitude", yguide="Latitude",
                xlims=(-99.0,-80.0), ylims=(16.0,32.0),
                guidefont=Plots.font("sans-serif",12),
                tickfont=Plots.font("sans-serif",10),
                colorbar_title="m/s",
                wind=true,
                )
## coastlines
plts = map(p->plotscoastline!(p, topo; lc=:black), plts)

## time in string
time_str = Dates.format.(amrall.timelap, "yyyy/mm/dd HH:MM")
plts = map((p,s)->plot!(p, title=s), plts, time_str)

## tiles
plts = gridnumber!.(plts, amrall.amr; font=Plots.font(12, :white, :center))
plts = tilebound!.(plts, amrall.amr)

## save
plotssavefig(plts, output_prefix*".png")
## gif
plotsgif(plts, output_prefix*".gif", fps=4)
# -----------------------------
