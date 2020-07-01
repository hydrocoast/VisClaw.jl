using VisClaw

using Printf
using Plots
gr()

# -----------------------------
# ike
# -----------------------------
simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
output_prefix = "ike_pres"
using Dates: Dates
timeorigin = Dates.DateTime(2008, 9, 13, 7)

## load
amrall = loadstorm(simdir)
rmvalue_coarser!.(amrall.amr)

## load topo
topo = loadtopo(simdir)


## plot
plts = plotsamr(amrall; c=cgrad([:red, :yellow, :white]), clims=(960.0, 1010.0),
                xguide="Longitude", yguide="Latitude",
                xlims=(-99.0,-85.0), ylims=(22.0,32.0),
                guidefont=Plots.font("sans-serif",12),
                tickfont=Plots.font("sans-serif",10),
                colorbar_title="hPa",
                )
## coastlines
plts = map(p->plotscoastline!(p, topo; lc=:black), plts)

## time in string
time_dates = timeorigin .+ Dates.Second.(amrall.timelap)
time_str = Dates.format.(time_dates,"yyyy/mm/dd HH:MM")
plts = map((p,s)->plot!(p, title=s), plts, time_str)

plts = gridnumber!.(plts, amrall.amr; font=Plots.font(12, :black, :center))
plts = tilebound!.(plts, amrall.amr)

## save
#plotssavefig(plts, output_prefix*".svg")
## gif
#plotsgif(plts, output_prefix*".gif", fps=4)
# -----------------------------
