ms_default=8
an_default = Plots.font(10,:left,:top,0.0,:black)

###########################################
"""
    plt = plotsgaugelocation(gauge::VisClaw.Gauge; offset=(0,0), font::Plots.Font, annotation_str=@sprintf(" %s",gauge.id), kwargs...)

    plt = plotsgaugelocation(gauges::Vector{VisClaw.Gauge}; offset=(0,0), font::Plots.Font, annotation_str=" ", kwargs...)

    plotsgaugelocation!(plt::Plots.Plot, gauge::VisClaw.Gauge; offset=(0,0), font::Plots.Font, annotation_str=@sprintf(" %s",gauge.id), kwargs...)

    plotsgaugelocation!(plt, gauges::Vector{VisClaw.Gauge}; offset=(0,0), font::Plots.Font, annotation_str=" ", kwargs...)


Function: plot a gauge location (with scatter plot) using Plots
"""
function plotsgaugelocation!(plt, gauge::VisClaw.Gauge;
                             offset=(0,0), font::Plots.Font=an_default, annotation_str=@sprintf(" %s",gauge.id), kwargs...)
    # plot
    plt = Plots.scatter!(plt, [gauge.loc[1]], [gauge.loc[2]]; kwargs..., label="", ann=(gauge.loc[1]+offset[1], gauge.loc[2]+offset[2], Plots.text(annotation_str, font)) )

    # return
    return plt

end
###########################################
"""
$(@doc plotsgaugelocation!)
"""
plotsgaugelocation(gauge::VisClaw.Gauge; offset=(0,0), font::Plots.Font=an_default, annotation_str=@sprintf(" %s",gauge.id), kwargs...) =
plotsgaugelocation!(Plots.plot(), gauge; offset=(0,0), font=font, annotation_str=annotation_str, kwargs...)
###########################################
function plotsgaugelocation!(plt, gauges::Vector{VisClaw.Gauge};
                             offset=(0,0), font::Plots.Font=an_default,
                             annotation_str=" ", kwargs...)
    # get values in all gauges
    ngauges = length(gauges)
    loc_all = getfield.(gauges, :loc)
    loc = zeros(Float64, ngauges,2)
    for i=1:ngauges; loc[i,:] = loc_all[i]; end

    if (isa(annotation_str, Vector{String})) || (annotation_str==" ")
        if length(annotation_str) !== ngauges
            id_all = getfield.(gauges, :id)
            # annotation
            annotation_str = map(x -> @sprintf(" %s",x), id_all)
        end
    end
    if isa(annotation_str, String)
        annotation_str = fill(annotation_str, ngauges)
    end

    annotation_arg = Vector{Tuple}(undef,ngauges)
    for i=1:ngauges
        annotation_arg[i] = (loc_all[i][1]+offset[1], loc_all[i][2]+offset[2],
                             Plots.text(annotation_str[i], font))
    end
    # plot
    plt = Plots.scatter!(plt, loc[:,1], loc[:,2]; kwargs..., label="", ann=annotation_arg)

    # return
    return plt
end
###########################################
plotsgaugelocation(gauges::Vector{VisClaw.Gauge}; offset=(0,0), font::Plots.Font=an_default, annotation_str=" ", kwargs...) =
plotsgaugelocation!(Plots.plot(), gauges::Vector{VisClaw.Gauge}; offset=offset, font=font, annotation_str=annotation_str, kwargs...)
