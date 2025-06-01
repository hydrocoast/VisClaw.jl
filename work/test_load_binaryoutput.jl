using PyCall
using Revise
include("../src/VisClaw.jl")
using Printf


# -----------------------------
# chile 2010 fgmax fgout
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010_fgmax-fgout/_output")
fig_prefix = "chile2010_fgmax-fgout"

## load topo
topo = VisClaw.loadtopo(simdir)

## load amr data
amrall = VisClaw.loadsurface(simdir); VisClaw.replaceunit!(amrall, :minute)
amrvel = VisClaw.loadcurrent(simdir); VisClaw.replaceunit!(amrvel, :minute)

cmaptopo = :topo # or :gist_earth, :bukavu
cmapwater = :balance
colorrange = (-0.25,0.25)


fig = CairoMakie.Figure()
figdir = "tmp_fig"
isdir(figdir) || (mkdir(figdir))
for i = 1:amrall.nstep
    time_min = amrall.timelap[i]
    
    CairoMakie.empty!(fig)
    ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%03d min", time_min))
    VisClaw.makietopo!(ax, topo; colormap=cmaptopo, colorrange=(-4000, 4000))
    VisClaw.makieheatmap!(ax, amrall.amr[i]; colormap=cmapwater, colorrange=colorrange)
    CairoMakie.Colorbar(fig[1,2], limits = colorrange, colormap = cmapwater, flipaxis = true)
    ## save
    figname = fig_prefix*@sprintf("_%03d_2d.png",i)
    CairoMakie.save(joinpath(figdir,figname), fig)
end


fig = CairoMakie.Figure()
figdir = "tmp_fig_current"
isdir(figdir) || (mkdir(figdir))
for i = 1:amrall.nstep
    time_min = amrall.timelap[i]
    
    CairoMakie.empty!(fig)
    ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%03d min", time_min))
    VisClaw.makietopo!(ax, topo; colormap=cmaptopo, colorrange=(-4000, 4000))
    VisClaw.makieheatmap!(ax, amrvel.amr[i]; colormap=:turbo, colorrange = (0.0, 0.1))
    CairoMakie.Colorbar(fig[1,2], colormap=:turbo, limits = (0.0, 0.1), flipaxis = true)
    ## save
    figname = fig_prefix*@sprintf("_%03d_2d.png",i)
    CairoMakie.save(joinpath(figdir,figname), fig)
end


#=
fg = VisClaw.fgoutdata(simdir)
fg = fg[1]  # just take the first one
x = LinRange(fg.xlims[1], fg.xlims[2], fg.nx)
y = LinRange(fg.ylims[1], fg.ylims[2], fg.ny)

nall = fg.nval*fg.nx*fg.ny

fileb = joinpath(simdir, "fgout0001.b0003")
dat = Vector{Float32}(undef, nall)
# Read the data into arrays
open(fileb, "r") do io
    for k in 1:nall
        dat[k] = read(io, Float32)
    end
end
=#

#=
np = pyimport("numpy")
dat = np.fromfile(file=fileb, dtype=np.float32)
=#

#=
dat = reshape(dat, (fg.nval, fg.nx, fg.ny))
D = dat[1, :, :]  # just take the first variable
eta = dat[4, :, :]  # just take the second variable
dry = D .< 1e-3
eta[dry] .= NaN  # set dry cells to NaN
=#

#=
using CairoMakie
cmap = :balance # or :viridis, :plasma, :inferno, :magma, :cividis
clims = (-0.25,0.25)

fig = CairoMakie.Figure()
ax = CairoMakie.Axis(fig[1, 1])
CairoMakie.heatmap!(ax, x, y, eta, colormap=cmap, colorrange=clims)
CairoMakie.Colorbar(fig[1,2], colormap=cmap, limits=clims, flipaxis=true)

fig
=#


#=
    with open(b_fname,'rb') as b_file:
        if file_format in ['binary', 'binary64']:
            qdata = np.fromfile(file=b_file, dtype=np.float64)
        elif file_format == 'binary32':
            qdata = np.fromfile(file=b_file, dtype=np.float32)
        else:
            msg = "Unrecognized file_format: %s" % file_format
            logger.critical(msg)
            raise Exception(msg)
=#

