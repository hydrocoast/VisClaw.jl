####################################################
"""
    gmttoporange!(geo::VisClaw.AbstractTopo; kwargs...)

plot a range of topo/bath using GMT
"""
function gmttoporange!(geo::VisClaw.AbstractTopo; kwargs...)
	# set square
	xp = [geo.x[1],  geo.x[1]  , geo.x[end], geo.x[end], geo.x[1]]
	yp = [geo.y[1],  geo.y[end], geo.y[end], geo.y[1]  , geo.y[1]]
	# plot
	GMT.plot!(xp, yp; marker=:none, kwargs...)
end
####################################################


####################################################
"""
    gmtcoastline!(topo::VisClaw.Topo; kwargs...)
	gmtcoastline!(G::GMT.GMTgrid; kwargs...)

plot coastlines from topography and bathymetry data using GMT
"""
gmtcoastline!(topo::VisClaw.Topo; kwargs...) =
GMT.grdcontour!(geogrd(topo); C="-1e10,0,1e10", kwargs...)
####################################################
"""
$(@doc gmtcoastline!)
"""
gmtcoastline!(G::GMT.GMTgrid; kwargs...) =
GMT.grdcontour!(G; C="-1e10,0,1e10", kwargs...)
####################################################
