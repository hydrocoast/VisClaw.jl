
####################################################
gaugexy2mat(gauges::Vector{VisClaw.Gauge}) = permutedims(hcat(getfield.(gauges, :loc)...), [2,1])

####################################################
"""
    gmtgaugelocation(gauge::VisClaw.Gauge; kwargs...)
    gmtgaugelocation!(gauge::VisClaw.Gauge; kwargs...)
    gmtgaugelocation(gauges::Vector{VisClaw.Gauge}; kwargs...)
    gmtgaugelocation!(gauges::Vector{VisClaw.Gauge}; kwargs...)
"""
gmtgaugelocation(gauge::VisClaw.Gauge; kwargs...) = GMT.scatter([gauge.loc[1] gauge.loc[2]]; kwargs...)
####################################################
"""
$(@doc gmtgaugelocation)
"""
gmtgaugelocation!(gauge::VisClaw.Gauge; kwargs...) = GMT.scatter!([gauge.loc[1] gauge.loc[2]]; kwargs...)
####################################################
gmtgaugelocation(gauges::Vector{VisClaw.Gauge}; kwargs...) = GMT.scatter(gaugexy2mat(gauges); kwargs...)
gmtgaugelocation!(gauges::Vector{VisClaw.Gauge}; kwargs...) = GMT.scatter!(gaugexy2mat(gauges); kwargs...)


####################################################
"""
    gmtgaugeannotation!(gauge::VisClaw.Gauge; kwargs...)
"""
gmtgaugeannotation!(gauge::VisClaw.Gauge, annot::AbstractString=gauge.label; R="", offset=(0.0,0.0), kwargs...) =
GMT.text!(GMT.text_record([gauge.loc[1]+offset[1] gauge.loc[2]+offset[2]], annot); R=R, kwargs...)
####################################################



####################################################
"""
    gmtgaugewaveform(gauge::VisClaw.Gauge; kwargs...)
    gmtgaugewaveform!(gauge::VisClaw.Gauge; kwargs...)
"""
gmtgaugewaveform(gauge::VisClaw.Gauge; kwargs...) = GMT.plot(gauge.time, gauge.eta; kwargs...)
####################################################
"""
$(@doc gmtgaugewaveform)
"""
gmtgaugewaveform!(gauge::VisClaw.Gauge; kwargs...) = GMT.plot!(gauge.time, gauge.eta; kwargs...)
####################################################
"""
    gmtgaugevelocity(gauge::VisClaw.Gauge; kwargs...)
    gmtgaugevelocity!(gauge::VisClaw.Gauge; kwargs...)
"""
gmtgaugevelocity(gauge::VisClaw.Gauge; kwargs...) = GMT.plot(gauge.time, sqrt.(gauge.u.^2 + gauge.v.^2); kwargs...)
####################################################
"""
$(@doc gmtgaugevelocity)
"""
gmtgaugevelocity!(gauge::VisClaw.Gauge; kwargs...) = GMT.plot!(gauge.time, sqrt.(gauge.u.^2 + gauge.v.^2); kwargs...)
####################################################
