"""
    ax = makiegaugewaveform(gauge::VisClaw.Gauge; kwargs...)
    makiegaugewaveform!(ax, gauge::VisClaw.Gauge; kwargs...)

Function: line plot of gauge data
Arguments:
- `ax`: the axis to plot on
- `gauge`: gauge data    
"""
function makiegaugewaveform!(ax, gauge::VisClaw.Gauge; kwargs...)
    # Create a line plot with the specified parameters
    CairoMakie.lines!(ax, gauge.time, gauge.eta; kwargs...)
    return ax
end
"""
$(@doc makiegaugewaveform!)
"""
makiegaugewaveform(gauge::VisClaw.Gauge; kwargs...) = 
makiegaugewaveform!(CairoMakie.Axis(CairoMakie.Figure()), gauge; kwargs...)


"""
    ax = makiegaugevelocity(gauge::VisClaw.Gauge; kwargs...)
    makiegaugevelocity!(ax, gauge::VisClaw.Gauge; kwargs...)
"""
function makiegaugevelocity!(ax, gauge::VisClaw.Gauge; kwargs...)
    # Create a line plot with the specified parameters
    CairoMakie.lines!(ax, gauge.time, sqrt.(gauge.u.^2 + gauge.v.^2); kwargs...)
    return ax
end

"""
$(@doc makiegaugevelocity!)
"""
makiegaugevelocity(gauge::VisClaw.Gauge; kwargs...) =
makiegaugevelocity!(CairoMakie.Axis(CairoMakie.Figure()), gauge; kwargs...)


"""
    ax = makiegaugaugelocation(gauge::VisClaw.Gauge; kwargs...)
    makiegaugelocation!(ax, gauge::VisClaw.Gauge; kwargs...)
    ax = makiegaugelocation(gauges::AbstractVector{VisClaw.Gauge}; kwargs...)
    makiegaugelocation!(ax, gauges::AbstractVector{VisClaw.Gauge}; kwargs...)
Function: scatter plot of gauge locations
Arguments:
- `ax`: the axis to plot on
- `gauge`: gauge data
- `gauges`: vector of gauge data
"""
function makiegaugelocation!(ax, gauge::VisClaw.Gauge; kwargs...)
    CairoMakie.scatter!(ax, gauge.loc[1], gauge.loc[2]; kwargs...)
    return ax
end
function makiegaugelocation!(ax, gauges::AbstractVector{VisClaw.Gauge}; kwargs...)
    CairoMakie.scatter!(ax, first.(getfield.(gauges, :loc)), last.(getfield.(gauges, :loc)); kwargs...)
    return ax
end


"""
$(@doc makiegaugelocation!)
"""
makiegaugelocation(gauge::VisClaw.Gauge; kwargs...) =
makiegaugelocation!(CairoMakie.Axis(CairoMakie.Figure()), gauge; kwargs...)
"""
$(@doc makiegaugelocation!)
"""
makiegaugelocation(gauges::AbstractVector{VisClaw.Gauge}; kwargs...) =
makiegaugelocation!(CairoMakie.Axis(CairoMakie.Figure()), gauges; kwargs...)