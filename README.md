# VisClaw

[![Build Status](https://travis-ci.com/hydrocoast/VisClaw.jl.svg?branch=master)](https://travis-ci.com/hydrocoast/VisClaw.jl)
[![Codecov](https://codecov.io/gh/hydrocoast/VisClaw.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/hydrocoast/VisClaw.jl)
[![Coveralls](https://coveralls.io/repos/github/hydrocoast/VisClaw.jl/badge.svg?branch=master)](https://coveralls.io/github/hydrocoast/VisClaw.jl?branch=master)

VisClaw.jl is a Julia package of the Clawpack visualization tools (see http://www.clawpack.org).   
This allows to draw figures and animations using the Julia language.   
Please note that this package is unofficial and the author is not engaged in the Clawpack Development Team.   

# Requirements
- [Julia](https://github.com/JuliaLang/julia) v1.3.0 or later
- [GMT](https://github.com/GenericMappingTools/gmt) (Generic Mapping Tools)  

# Installation  
- If you want to plot using [GMT.jl](https://github.com/GenericMappingTools/GMT.jl), 
install the [GMT](https://github.com/GenericMappingTools/gmt) in advance.
Note that GMT.jl does NOT install the GMT program.

- You can install the latest VisClaw.jl using the built-in package manager (accessed by pressing `]` in the Julia REPL) to add the package.
```julia
pkg> add VisClaw
```

# Usage  
- In preparation, run some of the Clawpack numerical simulations  
(e.g., chile2010 `$CLAW/geoclaw/examples/tsunami/chile2010` and  
ike `$CLAW/geoclaw/examples/storm-surge/ike`).  

- This package uses either GMT.jl or Plots.jl to plot results of the numerical simulation.
Plots.jl is more suitable for a quick check.
For example, the following codes generate a spatial distribution of the sea surface height:
```julia
julia> using VisClaw
julia> simdir = joinpath(CLAW, "geoclaw/examples/tsunami/chile2010/_output");
julia> plt = plotscheck(simdir; color=:balance, clims=(-0.5,0.5))
input a number (1 to 19) =         # specify a checkpoint time
```
Topography data also can be easily plotted:
```julia
julia> topo = loadtopo(simdir)
julia> plt = plotstopo(topo)
```
See [Examples_using_Plots.ipynb](https://github.com/hydrocoast/VisClaw.jl/blob/master/Examples_using_Plots.ipynb)
and [Examples_using_GMT.ipynb](https://github.com/hydrocoast/VisClaw.jl/blob/master/Examples_using_GMT.ipynb) for more information.

# Plot gallery
The following figures are generated with the Julia scripts in `example/` .  

## using GMT.jl

### sea surface elevation
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/chile2010_eta_GMT.gif", width="375">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/ike_eta_GMT.gif", width="425">
</p>  


### topography and bathymetry
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/chile2010_topo.png", width="350">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/ike_topo.png", width="450">
</p>  

### seafloor deformation (dtopo)
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/chile2010_dtopo.png", width="400">
</p>  

### wind and pressure fields
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/ike_storm_GMT.gif", width="400">
</p>  


## using Plots.jl

### sea surface elevation
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/chile2010_eta.gif", width="400">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/ike_eta.gif", width="400">
</p>  

### flow velocity
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/chile2010_velo.gif", width="400">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/ike_velo.gif", width="400">
</p>  

### topography and bathymetry
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/chile2010_topo.svg", width="400">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/ike_topo.svg", width="400">
</p>  

### wave gauge
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/chile2010_waveform_gauge.svg", width="400">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/ike_waveform_gauge.svg", width="400">
</p>  

### fixed grid monitoring (fgmax)
<p align="center">
<img src="https://github.com/hydrocoast/VisClaw.jl/blob/master/example/figure/fgmax4vars.svg", width="700">
</p>  


# License
BSD 3-Clause  

# Author
[Takuya Miyashita](https://hydrocoast.jp) <miyashita(at)hydrocoast.jp>   
Disaster Prevention Research Institute, Kyoto University  