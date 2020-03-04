"""
Function: plot topography and bathymetry in 2D
"""
function plotstopo!(plt, geo::VisClaw.AbstractTopo; kwargs...)

    if isa(geo, VisClaw.Topo)
		z = geo.elevation
	elseif isa(geo, VisClaw.DTopo)
		z = geo.deform
	end

	# plot
	plt = Plots.plot!(plt, geo.x, geo.y, z;
	                  xlims=extrema(geo.x), ylims=extrema(geo.y),
	                  axis_ratio=:equal, kwargs...)

	# return
	return plt
end
####################################################
"""
Function: plot topography and bathymetry in 2D
"""
plotstopo(geo::VisClaw.AbstractTopo; kwargs...) = plotstopo!(Plots.plot(), geo; kwargs...)
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
