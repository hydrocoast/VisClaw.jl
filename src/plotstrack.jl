####################################################
"""
    plt = plotstrack(track::VisClaw.Track; kwargs...)

    plotstrack!(plt::Plots.Plot, track::VisClaw.Track; kwargs...)

plot a typhoon/hurricane track using Plots
"""
function plotstrack!(plt, track::VisClaw.Track; kwargs...)
    # parse keyword args
    kwdict = KWARG(kwargs)
	label, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_label, "")

	# plot
	plt = Plots.plot!(plt, track.lon, track.lat; axis_ratio=:equal, label=label, kwdict...)
	return plt
end
####################################################
"""
$(@doc plotstrack!)
"""
plotstrack(track::VisClaw.Track; kwargs...) = plotstrack!(Plots.plot(), track; kwargs...)
####################################################
