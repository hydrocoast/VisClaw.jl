using VisClaw
using Printf

using Plots
gr() # this code is optimized for the GR backend
clibrary(:colorcet)

# directory
simdir = "your_simulation_path/_output"

# load
fg = fgmaxdata(simdir)
fg = loadfgmaxgrid.(fg)
fgmax = loadfgmax.(simdir, fg, nval_save=2)
replaceunit!.(fgmax, :hour)

# plot
plt_h = plotsfgmax(fg[1], fgmax[1], :h; linetype=:contourf, color=:heat, clims=(0.0, 2.0), colorbar_title="(m)", title="h")
plt_v = plotsfgmax(fg[1], fgmax[1], :v; linetype=:contourf, color=:rainbow, clims=(0.0, 0.2), colorbar_title="(m/s)", title="v")
plt_th = plotsfgmax(fg[1], fgmax[1], :th; linetype=:contourf, color=:darktest_r, colorbar_title=string(fgmax[1].unittime), title="th")
plt_tv = plotsfgmax(fg[1], fgmax[1], :tv; linetype=:contourf, color=:darktest_r, colorbar_title=string(fgmax[1].unittime), title="tv")

# subplot layout
plts = plot(plt_h, plt_v, plt_th, plt_tv, layout=(2,2), size=(800,600))
