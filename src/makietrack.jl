"""
    fig, ax = makietrack(track::VisClaw.Track, index::AbstractVector=1:length(track.lon); kwargs...)
    makietrack!(ax, track::VisClaw.Track, index::AbstractVector=1:length(track.lon); kwargs...)

Function: plot a typhoon/hurricane track using CairoMakie
ax: the axis to plot on
track: VisClaw.Track object containing the track data
index: indices of the track data to plot (default is all)
"""
function makietrack!(ax, track::VisClaw.Track, index::AbstractVector=1:length(track.lon); kwargs...)
    CairoMakie.lines!(ax, track.lon[index], track.lat[index]; kwargs...)
    return ax
end
"""
# $(@doc makietrack!)
"""
function makietrack(track::VisClaw.Track, index::AbstractVector=1:length(track.lon); kwargs...)
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1, 1])
    makietrack!(ax, track, index; kwargs...)
    return fig, ax
end
