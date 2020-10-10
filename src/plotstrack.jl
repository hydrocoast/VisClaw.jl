####################################################
"""
    plt = plotstrack(track::VisClaw.Track, index::AbstractVector=1:length(track.lon); kwargs...)

    plotstrack!(plt::Plots.Plot, track::VisClaw.Track, index::AbstractVector=1:length(track.lon); kwargs...)

plot a typhoon/hurricane track using Plots
"""
function plotstrack!(plt, track::VisClaw.Track, index::AbstractVector=1:length(track.lon); kwargs...)
    # parse keyword args
    kwdict = KWARG(kwargs)
	label, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_label, "")

	# plot
	plt = Plots.plot!(plt, track.lon[index], track.lat[index]; axis_ratio=:equal, label=label, kwdict...)
	return plt
end
####################################################
"""
$(@doc plotstrack!)
"""
plotstrack(track::VisClaw.Track, index::AbstractVector=1:length(track.lon); kwargs...) =
plotstrack!(Plots.plot(), track, index; kwargs...)
####################################################
