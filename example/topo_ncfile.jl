using VisClaw

simdir = joinpath(CLAW, "geoclaw/examples/tsunami/bowl-slosh-netcdf/_output")

topo = loadtopo(simdir)

gmttopo(topo; C=:relief)
gmtcoastline!(topo; savefig="./bowl_netcdf.pdf")
