###############################################################################
"""
    plt = plotsfgmax(fg::VisClaw.FixedGrid, fgmax::VisClaw.FGmax, var::Symbol; kwargs...)

    plotsfgmax!(plt::Plots.Plot, fg::VisClaw.FixedGrid, fgmax::VisClaw.FGmax, var::Symbol; kwargs...)

"""
function plotsfgmax!(plt, fg::VisClaw.FixedGrid, fgmax::VisClaw.FGmax, var::Symbol=:D; kwargs...)
    # parse keyword args
    kwdict = KWARG(kwargs)
	seriestype, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_seriestype, :heatmap)

    # vector
    x = collect(Float64, LinRange(fg.xlims[1], fg.xlims[end], fg.nx))
    y = collect(Float64, LinRange(fg.ylims[1], fg.ylims[end], fg.ny))

    # ocean grids
    ocean = fgmax.topo.<=0.0

    # get var
    val = copy(getfield(fgmax, var))
    # check
    isempty(val) && error("Empty: $var")

    # correct
    (var==:D) && (val[ocean] = val[ocean] + fgmax.topo[ocean])
	(var==:Dmin) && (val[ocean] = val[ocean] - fgmax.topo[ocean])
	#=
    elseif var==:Dmin
        val[ocean] = -val[ocean] + fgmax.topo[ocean]
    end
	=#

    val[.!ocean] .= NaN


    # plot
    plt = Plots.plot!(plt, x, y, val; ratio=:equal, xlims=fg.xlims, ylims=fg.ylims, seriestype=seriestype, kwdict...)

    # return
    return plt
end
###############################################################################
"""
$(@doc plotsfgmax!)
"""
plotsfgmax(fg::VisClaw.FixedGrid, fgmax::VisClaw.FGmax, var::Symbol=:D; kwargs...) =
plotsfgmax!(Plots.plot(), fg, fgmax, var; kwargs...)
###############################################################################
