using Revise
## check
outdir=ENV["HOME"]*"/Research/AMR/sofugan_bouss/radial_flat/_output"
jld2dir="_jld2"
isdir(outdir) || error("Directory $outdir not found")
isdir(jld2dir) || (mkdir(jld2dir))

## import package
print("import packages ...   ")
using Pkg
Base.find_package("VisClaw") == nothing && (Pkg.add("VisClaw"))
Base.find_package("JLD2") == nothing && (Pkg.add("JLD2"))
using Printf
using VisClaw
using JLD2
print("end\n")


### topo
print("loading topo ...     ")
topo = loadtopo(outdir)
print("end\n")

print("saving topo ...     ")
@save joinpath(jld2dir, "topo.jld2") topo
print("end\n")


## region
print("loading region ...     ")
regions = regiondata(outdir)
print("end\n")

print("saving region ...     ")
@save joinpath(jld2dir, "regions.jld2") regions
print("end\n")


## surface
print("loading eta ...     ")
amrall = loadsurface(outdir)
coarsegridmask!(amrall)
print("end\n")

print("saving eta ...     ")
@save joinpath(jld2dir, "amrall.jld2") amrall
print("end\n")


### gauges
print("loading gauge ...     ")
gauges = loadgauge(outdir)
print("end\n")

print("saving gauge ...     ")
@save joinpath(jld2dir, "gauges.jld2") gauges
print("end\n")


### fgmax
#print("loading fgmax ...     ")
#fg = fgmaxdata(outdir)
#fgmax = loadfgmax.(outdir, fg)
#print("end\n")

#print("saving fgmax ...     ")
#@save joinpath(jld2dir, "fgmax.jld2") fg fgmax
#print("end\n")


## CPU time
#print("loading timing.csv ...     ")
#cputime = CSV.read(joinpath(outdir,"timing.csv"); header=1, datarow=2, delim=',')
#print("end\n")

#print("saving cputime data ...     ")
#@save joinpath(jld2dir, "cputime.jld2") cputime
#print("end\n")
