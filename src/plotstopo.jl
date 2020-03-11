####################################################
"""
Function: plot topography and bathymetry in 2D
"""
function plotstopo!(plt, geo::VisClaw.Topo; kwargs...)
	z = geo.elevation
	# plot
    plt = Plots.plot!(plt, geo.x, geo.y, z;
                      xlims=extrema(geo.x), ylims=extrema(geo.y),
                      axis_ratio=:equal, kwargs...)
    # return
    return plt
end
####################################################
plotstopo(geo::VisClaw.Topo; kwargs...) = plotstopo!(Plots.plot(), geo; kwargs...)
####################################################
"""
Function: plot displacement of topography
"""
function plotstopo!(plt, geo::VisClaw.DTopo, itime::Int64=0; kwargs...)

    if (itime < 0) || (geo.mt < itime)
        error("Invalid time")
    end
    if geo.mt==1
        z = geo.deform
    elseif  itime == 0
        z = geo.deform[:,:,end]
    else
        z = geo.deform[:,:,itime]
    end

    # plot
    plt = Plots.plot!(plt, geo.x, geo.y, z;
                      xlims=extrema(geo.x), ylims=extrema(geo.y),
                      axis_ratio=:equal, kwargs...)
    # return
    return plt
end
####################################################
plotstopo(geo::VisClaw.DTopo, itime::Int64=0; kwargs...) = plotstopo!(Plots.plot(), geo, itime; kwargs...)
####################################################
const plotsdtopo = plotstopo
const plotsdtopo! = plotstopo!


####################################################
"""
Function: plot a range of topo/bath
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
Function: plot coastlines from topo
"""
function plotscoastline!(plt, geo::VisClaw.Topo; kwargs...)
	# plot
	plt = Plots.contour!(plt, geo.x, geo.y, geo.elevation; levels=[0], kwargs...)
	return plt
end
####################################################
plotscoastline(geo::VisClaw.Topo; kwargs...) = plotscoastline!(Plots.plot(), geo; kwargs...)
####################################################
