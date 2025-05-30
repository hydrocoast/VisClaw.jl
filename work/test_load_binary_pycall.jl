using PyCall
using Revise
include("../src/VisClaw.jl")
using Printf


# -----------------------------
# chile 2010 fgmax fgout
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/tsunami/chile2010_fgmax-fgout/_output")

fg = VisClaw.fgoutdata(simdir)
fg = fg[1]  # just take the first one
x = LinRange(fg.xlims[1], fg.xlims[2], fg.nx)
y = LinRange(fg.ylims[1], fg.ylims[2], fg.ny)


using CairoMakie

np = pyimport("numpy")

fileb = joinpath(simdir, "fgout0001.b0003")
dat = np.fromfile(file=fileb, dtype=np.float32)

dat = reshape(dat, (fg.nval, fg.nx, fg.ny))

D = dat[1, :, :]  # just take the first variable
eta = dat[4, :, :]  # just take the second variable
dry = D .< 1e-3
eta[dry] .= NaN  # set dry cells to NaN

cmap = :balance # or :viridis, :plasma, :inferno, :magma, :cividis
clims = (-0.25,0.25)

fig = CairoMakie.Figure()
ax = CairoMakie.Axis(fig[1, 1])
CairoMakie.heatmap!(ax, x, y, eta, colormap=cmap, colorrange=clims)
CairoMakie.Colorbar(fig[1,2], colormap=cmap, limits=clims, flipaxis=true)


fig

#fgout = VisClaw.load_binary_fgout(simdir, "fgout", np)



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

