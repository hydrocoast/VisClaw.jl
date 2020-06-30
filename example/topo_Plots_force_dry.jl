using VisClaw
using Plots

simdir = joinpath(CLAW, "geoclaw/examples/tsunami/eta_init_force_dry/_output")
topo = loadtopo(simdir)

force_dry = joinpath(CLAW, "geoclaw/examples/tsunami/eta_init_force_dry/input_files/force_dry_init.tt3")
dry = loadtopo(force_dry, 3)


plt0 = plotscoastline(topo[2], dry)

plt = plotstopo(topo[2]; c=:delta, clims=(-5.0,5.0))
plt = plotscoastline!(plt, topo[2], dry; lw=2.0, lc=:black)
