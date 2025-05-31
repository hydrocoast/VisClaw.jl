include("../src/VisClaw.jl")
using Revise
using Printf

#simdir = "/Users/miyashita/Research/AMR/clawpack/geoclaw/examples/storm-surge/isaac/_output"
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/storm-surge/ike/_output")
#simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010/_output")
#simdir = "/Users/miyashita/Research/AMR/simamr_meteotsunami_jp/owi_jebi/_output"

using CairoMakie
#fig = VisClaw.makiecheck(simdir)
#fig = VisClaw.makiecheck(simdir; vartype=:current)
#fig = VisClaw.makiecheck(simdir; vartype=:storm)
fig = VisClaw.makiecheck(simdir; vartype=:wind)
