"""
Function: plot a waveform at a gauge
"""
function plotsgaugevelocity!(plt, gauge::VisClaw.Gauge; kwargs...)
    # keyword args
    d = KWARG(kwargs)
    # plot
    plt = Plots.plot!(plt, gauge.time, sqrt.(gauge.u.^2 .+ gauge.v.^2); label=gauge.label, d...)
    # return
    return plt
end
###########################################
plotsgaugevelocity(gauge::VisClaw.Gauge; kwargs...) =
plotsgaugevelocity!(Plots.plot(), gauge; kwargs...)
###########################################


###########################################
"""
Function: plot waveforms at gauges
"""
function plotsgaugevelocity!(plt, gauges::Vector{VisClaw.Gauge}; kwargs...)
    # keyword args
    d = KWARG(kwargs)
    # get values in all gauges
    time_all = getfield.(gauges, :time)
    u_all = getfield.(gauges, :u)
	v_all = getfield.(gauges, :v)
    label_all = getfield.(gauges, :label)
	# number of gauges
	ngauge = length(gauges)

	for i = 1:ngauge
        # plot
        plt = Plots.plot!(plt, time_all[i], sqrt.(u_all[i].^2 .+ v_all[i].^2);
		                  label=label_all[i], d...)
	end

    # return
    return plt
end
###########################################
plotsgaugevelocity(gauges::Vector{VisClaw.Gauge}; kwargs...) =
plotsgaugevelocity!(Plots.plot(), gauges; kwargs...)
###########################################
