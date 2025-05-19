include("../src/VisClaw.jl")
using Revise
using Printf

#simdir = "/Users/miyashita/Research/AMR/geoclaw/examples/storm-surge/isaac/_output"
simdir = "/Users/miyashita/Research/AMR/simamr_meteotsunami_jp/owi_jebi/_output"

using CairoMakie
fig = VisClaw.makiecheck(simdir, (-0.5, 0.5))
#fig = VisClaw.makiecheck(simdir, (990, 1020); vartype=:storm)
#fig = VisClaw.makiecheck(simdir, (0.0, 25.0); vartype=:wind)
