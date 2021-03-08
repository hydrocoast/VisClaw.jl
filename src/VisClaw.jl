"""
## Visualization tool for the clawpack output
VisClaw.jl is a Julia package for plotting simulation results of the clawpack.\n
https://github.com/hydrocoast/VisClaw.jl

### Examples
- $(dirname(dirname(pathof(VisClaw))))/Examples_using_Plots.ipynb
- $(dirname(dirname(pathof(VisClaw))))/Examples_using_GMT.ipynb

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
include("loadfgmaxdata.jl")
include("loadfgmax.jl")
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

## plot (using GMT)
using GMT:GMT
include("gmttools.jl")
include("gmttopo.jl")
include("gmtgauge.jl")
include("gmtsurface.jl")
include("gmtarrows.jl")
include("gmttrack.jl")

## general functions
export geodata, amrdata, surgedata, gaugedata, fgmaxdata, regiondata
export topodata, dtopodata
export loadfgmax
export loadtopo, loaddeform, loaddtopo
export loadgauge
export loadtrack
export loadsurface, loadcurrent, loadstorm
export printtopoESRI, printtopo, printdtopo
export coarsegridmask!
export axesratio
export replaceunit!, converttodatetime!
export gaugemax, gaugeinterp

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


## uniform-grid interpolation
using PyCall: PyCall
include("scipyinterp.jl")

export interpsurface

end
