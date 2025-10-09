include("../src/VisClaw.jl")
using Revise
using Printf

# -----------------------------
# chile 2010
# -----------------------------
#simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010/_output")
#simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010_fgmax-fgout/_output")
#simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/storm-surge/ike/_output")
simdir = joinpath(VisClaw.CLAW,"../sofugan_bouss/radial_flat/_output")
#simdir = joinpath(VisClaw.CLAW,"../sofugan_bouss/radial_flat_original_qinit/_output")

using CairoMakie
fig = VisClaw.quickview(simdir)
