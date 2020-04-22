"""

    plt = plotsgaugewaveform(gauge::VisClaw.Gauge; kwargs...)

	plt = plotsgaugewaveform(gauges::Vector{VisClaw.Gauge}; kwargs...)

    plotsgaugewaveform!(plt::Plots.Plot, gauge::VisClaw.Gauge; kwargs...)

    plotsgaugewaveform!(plt::Plots.Plot, gauges::Vector{VisClaw.Gauge}; kwargs...)

Function: plot waveforms of gauges
"""
function plotsgaugewaveform!(plt, gauge::VisClaw.Gauge; kwargs...)
    # keyword args
    d = KWARG(kwargs)
    # plot
    plt = Plots.plot!(plt, gauge.time, gauge.eta; label=gauge.label, d...)
    # return
    return plt
end
###########################################
"""
$(@doc plotsgaugewaveform!)
"""
plotsgaugewaveform(gauge::VisClaw.Gauge; kwargs...) =
plotsgaugewaveform!(Plots.plot(), gauge; kwargs...)
###########################################


###########################################
function plotsgaugewaveform!(plt, gauges::Vector{VisClaw.Gauge}; kwargs...)
    # keyword args
    d = KWARG(kwargs)
    # get values in all gauges
    time_all = getfield.(gauges, :time)
    eta_all = getfield.(gauges, :eta)
    label_all = getfield.(gauges, :label)
	# number of gauges
	ngauge = length(gauges)

	for i = 1:ngauge
        # plot
        plt = Plots.plot!(plt, time_all[i], eta_all[i]; label=label_all[i], d...)
	end

    # return
    return plt
end
###########################################
plotsgaugewaveform(gauges::Vector{VisClaw.Gauge}; kwargs...) =
plotsgaugewaveform!(Plots.plot(), gauges; kwargs...)
###########################################
