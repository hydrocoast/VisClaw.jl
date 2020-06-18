####################################################
"""
    gmttrack(track::VisClaw.Track; kwargs...)
    gmttrack!(track::VisClaw.Track; kwargs...)
"""
gmttrack(track::VisClaw.Track; kwargs...) = GMT.plot(track.lon, track.lat; kwargs...)
####################################################
"""
$(@doc gmttrack)
"""
gmttrack!(track::VisClaw.Track; kwargs...) = GMT.plot!(track.lon, track.lat; kwargs...)
####################################################
