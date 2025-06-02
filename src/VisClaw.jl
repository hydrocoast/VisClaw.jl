"""
## Visualization tool for the clawpack output
VisClaw.jl is a Julia package for plotting simulation results of the clawpack.\n
https://github.com/hydrocoast/VisClaw.jl

### Examples
- pathof(VisClaw)/Examples_using_Plots.ipynb
- pathof(VisClaw)/Examples_using_GMT.ipynb

### Author
Takuya Miyashita (miyashita@hydrocoast.jp)\n
Doctoral student, Kyoto University, 2018\n
"""
module VisClaw

using Statistics: mean
using DelimitedFiles: readdlm
using Interpolations: Interpolations
using Printf
using Dates
using NetCDF: NetCDF
using Requires

using GeometricalPredicates: GeometricalPredicates
using Plots: Plots

## define CLAW path from shell
include("clawpath.jl")
export CLAW

## define structs and basic functions
const KWARG = Dict{Symbol,Any}
const emptyF = Array{Float64}(undef, 0, 0)
const timedict = Dict(:second => 1.0, :minute => 60.0, :hour => 3600.0, :day => 24*3600.0)
const varnameset(D,k,v) = haskey(D,k) ? k : v

include("structclaw.jl")
include("amrutils.jl")
include("replaceunit.jl")
include("converttodatetime.jl")
include("getvarname_nctopo.jl")

## load
include("loaddata.jl")
include("loadtrack.jl")
include("loadtopo.jl")
include("loadfgoutdata.jl")
include("loadfgmaxdata.jl")
include("loadfgmax.jl")
include("loadfgout.jl")
include("loadfort.jl")
include("loadgauge.jl")

## print
include("printtopo.jl")

## convert data
include("gaugemax.jl")
include("gaugeinterp.jl")
include("coarsegridmask.jl")

## setup
include("plotsargs.jl")
include("plotstools.jl")

## plot (using Plots)
include("plots2d.jl")
include("plotscheck.jl")
include("plotstopo.jl")
include("plotsgaugewaveform.jl")
include("plotsgaugevelocity.jl")
include("plotsgaugelocation.jl")
include("plotsfgmax.jl")
include("plotstrack.jl")

## plot (using Makie)
using CairoMakie: CairoMakie
include("makiesurface3d.jl")
include("makieheatmap.jl")
include("makietopo.jl")
include("makiewindarrows.jl")
include("makiegauge.jl")
include("quickview.jl")


## general functions
export geodata, amrdata, surgedata, gaugedata, fgmaxdata, fgoutdata, regiondata
export topodata, dtopodata
export loadfgmax, loadfgout
export loadtopo, loaddeform, loaddtopo
export loadgauge
export loadtrack
export loadsurface, loadcurrent, loadstorm
export printtopoESRI, printtopo, printdtopo
export coarsegridmask!
export axesratio
export replaceunit!, converttodatetime!
export gaugemax, gaugeinterp

## functions with Makie.jl
export makiesurface3d!
export makieheatmap!
export quickview, quickviewfgout
export makiewindarrows!
export makietopo!, makietopo, makiedtopo!, makiedtopo
export makiegaugewaveform!, makiegaugewaveform
export makiegaugevelocity!, makiegaugevelocity
export makiegaugelocation!, makiegaugelocation

## functions with Plots.jl
export plotsamr
export plotscheck
export gridnumber!, tilebound!
export plotscoastline, plotscoastline!
export plotsfgmax, plotsfgmax!
export plotstopo, plotstopo!
export plotsdtopo, plotsdtopo!
export plotstoporange, plotstoporange!
export plotsgaugelocation, plotsgaugelocation!
export plotsgaugewaveform, plotsgaugewaveform!
export plotsgaugevelocity, plotsgaugevelocity!
export plotstrack, plotstrack!
export plotsgif, plotssavefig

@require GMT="5752ebe1-31b9-557e-87aa-f909b540aa54" begin
    using .GMT: GMT
    ## plot (using GMT)
    using GMT:GMT
    include("gmttools.jl")
    include("gmttopo.jl")
    include("gmtgauge.jl")
    include("gmtsurface.jl")
    include("gmtarrows.jl")
    include("gmttrack.jl")
    ## functions with GMT.jl
    export getR, getR_tile, getJ, geogrd
    export landmask_asc, landmask_grd
    export tilegrd_xyz, tilegrd, tilegrd_mask
    export arrowgrd, arrowscalegrd
    export gmttopo
    export gmtgaugewaveform, gmtgaugewaveform!
    export gmtgaugevelocity, gmtgaugevelocity!
    export gmtgaugelocation, gmtgaugelocation!
    export gmtgaugeannotation!
    export gmttoporange!
    export gmtcoastline, gmtcoastline!
    export gmttrack, gmttrack!
end

end
