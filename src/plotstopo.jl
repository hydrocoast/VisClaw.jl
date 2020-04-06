####################################################
"""
    plotstopo(topo::VisClaw.Topo; kwargs...)
    plotstopo!(plt, topo::VisClaw.Topo; kwargs...)

plot topography and bathymetry data using Plots
"""
function plotstopo!(plt, topo::VisClaw.Topo; kwargs...)
	# plot
    plt = Plots.plot!(plt, topo.x, topo.y, topo.elevation;
                      xlims=extrema(topo.x), ylims=extrema(topo.y),
                      axis_ratio=:equal, kwargs...)
    # return
    return plt
end
####################################################
plotstopo(topo::VisClaw.Topo; kwargs...) = plotstopo!(Plots.plot(), topo; kwargs...)

####################################################
"""
    plotsdtopo(dtopo::VisClaw.DTopo, itime::Int64=0; kwargs...)
    plotsdtopo!(plt, dtopo::VisClaw.DTopo, itime::Int64=0; kwargs...)

plot dtopo data using Plots
"""
function plotsdtopo!(plt, dtopo::VisClaw.DTopo, itime::Int64=0; kwargs...)

    if (itime < 0) || (dtopo.mt < itime)
        error("Invalid time")
    end
    if dtopo.mt==1
        z = dtopo.deform
    elseif  itime == 0
        z = dtopo.deform[:,:,end]
    else
        z = dtopo.deform[:,:,itime]
    end

    # plot
    plt = Plots.plot!(plt, dtopo.x, dtopo.y, z;
                      xlims=extrema(dtopo.x), ylims=extrema(dtopo.y),
                      axis_ratio=:equal, kwargs...)
    # return
    return plt
end
####################################################
plotsdtopo(dtopo::VisClaw.DTopo, itime::Int64=0; kwargs...) = plotsdtopo!(Plots.plot(), dtopo, itime; kwargs...)


####################################################
"""
    plotstoporange(geo::VisClaw.AbstractTopo; kwargs...)
    plotstoporange!(plt, geo::VisClaw.AbstractTopo; kwargs...)

plot a range of topo/bath using Plots
"""
function plotstoporange!(plt, geo::VisClaw.AbstractTopo; kwargs...)

	xp = [geo.x[1],  geo.x[1]  , geo.x[end], geo.x[end], geo.x[1]]
	yp = [geo.y[1],  geo.y[end], geo.y[end], geo.y[1]  , geo.y[1]]

	# plot
	plt = Plots.plot!(plt, xp, yp; kwargs...)

	return plt
end
####################################################
plotstoporange(geo::VisClaw.AbstractTopo; kwargs...) = plotstoporange!(Plots.plot(), geo; kwargs...)
####################################################

####################################################
"""
    plotscoastline(topo::VisClaw.Topo; kwargs...)
    plotscoastline!(plt, topo::VisClaw.Topo; kwargs...)

plot coastlines from topography and bathymetry data using Plots
"""
function plotscoastline!(plt, topo::VisClaw.Topo; kwargs...)
	# plot
	plt = Plots.contour!(plt, topo.x, topo.y, topo.elevation; levels=[0], kwargs...)
	return plt
end
####################################################
plotscoastline(topo::VisClaw.Topo; kwargs...) = plotscoastline!(Plots.plot(), topo; kwargs...)
####################################################
