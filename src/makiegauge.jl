"""
    fig, ax = makiegaugewaveform(gauge::VisClaw.Gauge; kwargs...)
    makiegaugewaveform!(ax, gauge::VisClaw.Gauge; kwargs...)

Function: line plot of gauge data
Arguments:
- `ax`: the axis to plot on
- `gauge`: gauge data    
"""
makiegaugewaveform!(ax, gauge::VisClaw.Gauge; kwargs...) = CairoMakie.lines!(ax, gauge.time, gauge.eta; kwargs...)
##
function makiegaugewaveform!(ax, gauges::AbstractArray{VisClaw.Gauge}; kwargs...)
    for gauge in gauges; makiegaugewaveform!(ax, gauge; kwargs...); end
end


"""
$(@doc makiegaugewaveform!)
"""
function makiegaugewaveform(gauge::VisClaw.Gauge; kwargs...)
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1,1])
    makiegaugewaveform!(ax, gauge; kwargs...)
    return fig, ax
end
function makiegaugewaveform(gauges::AbstractArray{VisClaw.Gauge}; kwargs...)
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1,1])
    makiegaugewaveform!(ax, gauges; kwargs...)
    return fig, ax
end


"""
    fig, ax = makiegaugevelocity(gauge::VisClaw.Gauge; kwargs...)
    makiegaugevelocity!(ax, gauge::VisClaw.Gauge; kwargs...)
"""
makiegaugevelocity!(ax, gauge::VisClaw.Gauge; kwargs...) = CairoMakie.lines!(ax, gauge.time, sqrt.(gauge.u.^2 + gauge.v.^2); kwargs...)

"""
$(@doc makiegaugevelocity!)
"""
function makiegaugevelocity(gauge::VisClaw.Gauge; kwargs...)
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1,1])
    makiegaugevelocity!(ax, gauge; kwargs...)
    return fig, ax
end


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
makiegaugelocation!(ax, gauge::VisClaw.Gauge; kwargs...) = CairoMakie.scatter!(ax, gauge.loc[1], gauge.loc[2]; kwargs...)
makiegaugelocation!(ax, gauges::AbstractVector{VisClaw.Gauge}; kwargs...) = CairoMakie.scatter!(ax, first.(getfield.(gauges, :loc)), last.(getfield.(gauges, :loc)); kwargs...)


"""
$(@doc makiegaugelocation!)
"""
function makiegaugelocation(gauge::VisClaw.Gauge; kwargs...)
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1,1])
    makiegaugelocation!(ax, gauge; kwargs...)
    return fig, ax
end
"""
$(@doc makiegaugelocation!)
"""
function makiegaugelocation(gauges::AbstractVector{VisClaw.Gauge}; kwargs...)
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1,1])
    makiegaugelocation!(ax, gauges; kwargs...)
    return fig, ax
end