####################################################
"""
    gmttrack(track::VisClaw.Track; kwargs...)
    gmttrack!(track::VisClaw.Track; kwargs...)
"""
gmttrack(track::VisClaw.Track, index=1:length(track.lon); kwargs...) =
GMT.plot(track.lon[index], track.lat[index]; kwargs...)
####################################################
"""
$(@doc gmttrack)
"""
gmttrack!(track::VisClaw.Track, index=1:length(track.lon); kwargs...) =
GMT.plot!(track.lon[index], track.lat[index]; kwargs...)
####################################################
