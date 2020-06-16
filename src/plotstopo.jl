####################################################
"""
    plt = plotstopo(topo::VisClaw.Topo; kwargs...)

    plotstopo!(plt::Plots.Plot, topo::VisClaw.Topo; kwargs...)

plot topography and bathymetry data using Plots
"""
function plotstopo!(plt, topo::VisClaw.Topo; kwargs...)
	# parse keyword args
    kwdict = KWARG(kwargs)
	seriestype, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_seriestype, :heatmap)
	xlims, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_xlims, extrema(topo.x))
	ylims, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_ylims, extrema(topo.y))

	# plot
    plt = Plots.plot!(plt, topo.x, topo.y, topo.elevation; seriestype=seriestype,
                      xlims=xlims, ylims=ylims, axis_ratio=:equal, kwdict...)
    # return
    return plt
end
####################################################
"""
$(@doc plotstopo!)
"""
plotstopo(topo::VisClaw.Topo; kwargs...) = plotstopo!(Plots.plot(), topo; kwargs...)

####################################################
"""
    plt = plotsdtopo(dtopo::VisClaw.DTopo, itime::Int64=0; kwargs...)

    plotsdtopo!(plt::Plots.Plot, dtopo::VisClaw.DTopo, itime::Int64=0; kwargs...)

plot dtopo data using Plots
"""
function plotsdtopo!(plt, dtopo::VisClaw.DTopo, itime::Int64=0; kwargs...)

    ( (itime < 0) || (dtopo.mt < itime) ) && error("Invalid time")

    if dtopo.mt==1;     z = dtopo.deform
    elseif  itime == 0; z = dtopo.deform[:,:,end]
    else;               z = dtopo.deform[:,:,itime]
    end

	# parse keyword args
    kwdict = KWARG(kwargs)
	seriestype, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_seriestype, :heatmap)

    # plot
    plt = Plots.plot!(plt, dtopo.x, dtopo.y, z; seriestype=seriestype,
                      xlims=extrema(dtopo.x), ylims=extrema(dtopo.y),
                      axis_ratio=:equal, kwdict...)
    # return
    return plt
end
####################################################
"""
$(@doc plotsdtopo!)
"""
plotsdtopo(dtopo::VisClaw.DTopo, itime::Int64=0; kwargs...) = plotsdtopo!(Plots.plot(), dtopo, itime; kwargs...)


####################################################
"""
    plt = plotstoporange(geo::VisClaw.AbstractTopo; kwargs...)

    plotstoporange!(plt::Plots.Plot, geo::VisClaw.AbstractTopo; kwargs...)

plot a range of topo/bath using Plots
"""
function plotstoporange!(plt, geo::VisClaw.AbstractTopo; kwargs...)
	# parse keyword args
    kwdict = KWARG(kwargs)
	label, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_label, "")

	xp = [geo.x[1],  geo.x[1]  , geo.x[end], geo.x[end], geo.x[1]]
	yp = [geo.y[1],  geo.y[end], geo.y[end], geo.y[1]  , geo.y[1]]

	# plot
	plt = Plots.plot!(plt, xp, yp; label=label, kwdict...)

	return plt
end
####################################################
"""
$(@doc plotstoporange!)
"""
plotstoporange(geo::VisClaw.AbstractTopo; kwargs...) = plotstoporange!(Plots.plot(), geo; kwargs...)
####################################################

####################################################
"""
    plt = plotscoastline(topo::VisClaw.Topo; kwargs...)
	plt = plotscoastline(topo::VisClaw.Topo, wetdry::VisClaw.Topo; kwargs...)

    plotscoastline!(plt::Plots.Plot, topo::VisClaw.Topo; kwargs...)
    plotscoastline!(plt::Plots.Plot, topo::VisClaw.Topo, wetdry::VisClaw.Topo; kwargs...)

plot coastlines from topography and bathymetry data using Plots
"""
function plotscoastline!(plt, topo::VisClaw.Topo; kwargs...)
	# parse keyword args
    kwdict = KWARG(kwargs)
	label, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_label, "")
	xlims, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_xlims, extrema(topo.x))
	ylims, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_ylims, extrema(topo.y))

	# plot
	plt = Plots.contour!(plt, topo.x, topo.y, topo.elevation; levels=[0], label=label,
	                     xlims=xlims, ylims=ylims, axis_ratio=:equal, kwdict...)
	return plt
end
####################################################
"""
$(@doc plotscoastline!)
"""
plotscoastline(topo::VisClaw.Topo; kwargs...) = plotscoastline!(Plots.plot(), topo; kwargs...)
####################################################


####################################################
function plotscoastline!(plt, topo::VisClaw.Topo, wetdry::VisClaw.Topo; kwargs...)
	## check args
	(size(topo.elevation) == size(wetdry.elevation)) || error("size of wetdry array should correspond to that of topo array.")

    ## make a new VisClaw.Topo for coastline plot
	dry = findall(convert(BitArray, wetdry.elevation))
    topotmp = copy(topo.elevation)
	topotmp[dry] .= 1e3
	topo_coastline = VisClaw.Topo(topo.ncols, topo.nrows, topo.x, topo.y, topo.dx, topo.dy, topotmp)

    ## plot
	plt = plotscoastline!(plt, topo_coastline; kwargs...)
	return plt
end
####################################################
plotscoastline(topo::VisClaw.Topo, wetdry::VisClaw.Topo; kwargs...) = plotscoastline!(Plots.plot(), topo, wetdry; kwargs...)
####################################################
