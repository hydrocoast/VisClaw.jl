
####################################################
gaugexy2mat(gauges::Vector{VisClaw.Gauge}) = permutedims(hcat(getfield.(gauges, :loc)...), [2,1])

####################################################
"""
    gmtgaugelocation(gauge::VisClaw.Gauge; kwargs...)
    gmtgaugelocation(gauges::::Vector{VisClaw.Gauge}; kwargs...)
"""
gmtgaugelocation(gauge::VisClaw.Gauge; kwargs...) = GMT.plot([gauge.loc[1] gauge.loc[2]]; kwargs...)
####################################################
"""
    gmtgaugelocation!(gauge::VisClaw.Gauge; kwargs...)
    gmtgaugelocation!(gauges::::Vector{VisClaw.Gauge}; kwargs...)
"""
gmtgaugelocation!(gauge::VisClaw.Gauge; kwargs...) = GMT.plot!([gauge.loc[1] gauge.loc[2]]; kwargs...)
####################################################
gmtgaugelocation(gauges::Vector{VisClaw.Gauge}; kwargs...) = GMT.plot(gaugexy2mat(gauges); kwargs...)
gmtgaugelocation!(gauges::Vector{VisClaw.Gauge}; kwargs...) = GMT.plot!(gaugexy2mat(gauges); kwargs...)
