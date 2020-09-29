###############################################################################
"""
    plt = plotsfgmax(fg::VisClaw.FixedGrid, fgmax::VisClaw.FGmax, var::Symbol; kwargs...)

    plotsfgmax!(plt::Plots.Plot, fg::VisClaw.FixedGrid, fgmax::VisClaw.FGmax, var::Symbol; kwargs...)

"""
function plotsfgmax!(plt, fg::VisClaw.FixedGrid, fgmax::VisClaw.FGmax, var::Symbol=:D; kwargs...)
    # parse keyword args
    kwdict = KWARG(kwargs)

	# get var
	val = copy(getfield(fgmax, var))
	# check
	isempty(val) && error("Empty: $var")

    # vector
	if fg.style == 0 || fg.style == 1 || fg.style == 3

		# correct
	    (var==:D) && (val = val + fgmax.topo)
		(var==:Dmin) && (val = val - fgmax.topo)

		# plot
	    plt = Plots.plot!(plt, fg.x, fg.y, val; kwdict...)

    elseif fg.style == 2
		seriestype, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_seriestype, :heatmap)

        x = collect(Float64, LinRange(fg.xlims[1], fg.xlims[end], fg.nx))
        y = collect(Float64, LinRange(fg.ylims[1], fg.ylims[end], fg.ny))

		# wet cells
		wet = fgmax.D .!= 0.0
		land = fgmax.topo .> 0.0

	    # correct
	    (var==:D) && (val[wet] = val[wet] + fgmax.topo[wet])
		(var==:Dmin) && (val[wet] = val[wet] - fgmax.topo[wet])
		(var==:Dmin) && (val[land] .= NaN)
		isa(val, AbstractArray{Dates.DateTime}) || (val[.!wet] .= NaN)
	    #val[.!wet] .= NaN

	    # plot
	    plt = Plots.plot!(plt, x, y, val; ratio=:equal, xlims=fg.xlims, ylims=fg.ylims, seriestype=seriestype, kwdict...)

	elseif fg.style == 4
		seriestype, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_seriestype, :heatmap)

		x = collect(Float64, LinRange(fg.xlims[1], fg.xlims[end], fg.nx))
        y = collect(Float64, LinRange(fg.ylims[1], fg.ylims[end], fg.ny))

		# correct
	    (var==:D) && (val = val + fgmax.topo)
		(var==:Dmin) && (val = val - fgmax.topo)

		var_vec = copy(val)
		if !isa(val, AbstractArray{Dates.DateTime})
		    val = NaN*zeros(Float64 ,(fg.ny, fg.nx))
		    val[fg.flag] = var_vec
		end
		val = reverse(val, dims=1)

		# plot
	    plt = Plots.plot!(plt, x, y, val; ratio=:equal, xlims=fg.xlims, ylims=fg.ylims, seriestype=seriestype, kwdict...)
    end

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
