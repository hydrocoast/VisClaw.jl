using VisClaw
using Printf

using Plots
gr() # this code is optimized for the GR backend
clibrary(:colorcet)

# directory
#simdir = "your_simulation_path/_output"
simdir = joinpath(CLAW,"geoclaw/tests/chile2010_fgmax/_output")
# load
fg = fgmaxdata(simdir)
if @isdefined(fgmaxtestdir)
    fg[1] = VisClaw.FGmaxGrid(fg[1].FGid, joinpath(fgmaxtestdir, "def_fgmax1.txt"), fg[1].nval)
    fg[2] = VisClaw.FGmaxGrid(fg[2].FGid, joinpath(fgmaxtestdir, "def_fgmax2.txt"), fg[2].nval)
    fg[3] = VisClaw.FGmaxGrid(fg[3].FGid, joinpath(fgmaxtestdir, "def_fgmax3.txt"), fg[3].nval)
    #fg = Vector{VisClaw.FGmaxGrid}(undef, 3)
    #fg[1] = VisClaw.FGmaxGrid(1, joinpath(fgmaxtestdir, "def_fgmax1.txt"), 5)
    #fg[1] = VisClaw.FGmaxGrid(2, joinpath(fgmaxtestdir, "def_fgmax2.txt"), 5)
    #fg[1] = VisClaw.FGmaxGrid(3, joinpath(fgmaxtestdir, "def_fgmax3.txt"), 5)
end
#fg = fgmaxdata(simdir)

fg = loadfgmaxgrid.(fg)
fgmax = loadfgmax.(simdir, fg, nval_save=5)
replaceunit!.(fgmax, :hour)

# plot
plt_h = plotsfgmax(fg[1], fgmax[1], :h; linetype=:contourf, color=:heat, clims=(0.0, 2.0), colorbar_title="(m)", title="h")
plt_v = plotsfgmax(fg[1], fgmax[1], :v; linetype=:contourf, color=:rainbow, clims=(0.0, 0.2), colorbar_title="(m/s)", title="v")
plt_th = plotsfgmax(fg[1], fgmax[1], :th; linetype=:contourf, color=:darktest_r, colorbar_title=string(fgmax[1].unittime), title="th")
plt_tv = plotsfgmax(fg[1], fgmax[1], :tv; linetype=:contourf, color=:darktest_r, colorbar_title=string(fgmax[1].unittime), title="tv")

plotsfgmaxsurf(fg[1], fgmax[1])

# subplot layout
plts = plot(plt_h, plt_v, plt_th, plt_tv, layout=(2,2), size=(800,600))

plt_hmin = plotsfgmax(fg[1], fgmax[1], :hmin; linetype=:contourf, color=:dense_r, clims=(-4.0,0.1), colorbar_title="(m)", title="tv")
