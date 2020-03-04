ms_default=8
an_default = Plots.font(10,:left,:top,0.0,:black)

###########################################
"""
Function: plot a gauge location using Plots
"""
function plotsgaugelocation!(plt, gauge::VisClaw.Gauge;
                             offset=(0,0), font::Plots.Font=an_default, kwargs...)
    # keyword args
    d = KWARG(kwargs)
    # annotation
    annotation_str=" "*@sprintf("%s",gauge.id)

    # plot
    plt = Plots.scatter!(plt, [gauge.loc[1]], [gauge.loc[2]]; d...,
                         ann=(gauge.loc[1]+offset[1], gauge.loc[2]+offset[2], Plots.text(annotation_str, font)),
                         label="")

    # return
    return plt

end
###########################################
plotsgaugelocation(gauge::VisClaw.Gauge; offset=(0,0), font::Plots.Font=an_default, kwargs...) =
plotsgaugelocation!(Plots.plot(), gauge; offset=(0,0), font=font, kwargs...)
###########################################
function plotsgaugelocation!(plt, gauges::Vector{VisClaw.Gauge}; offset=(0,0), font::Plots.Font=an_default, kwargs...)
    # keyword args
    d = KWARG(kwargs)
    # get values in all gauges
    ngauges = length(gauges)
    loc_all = getfield.(gauges, :loc)
    loc = zeros(Float64, ngauges,2)
    for i=1:ngauges; loc[i,:] = loc_all[i]; end

    id_all = getfield.(gauges, :id)
    # annotation
    annotation_str = map(x -> " "*@sprintf("%s",x), id_all)

    annotation_arg = Vector{Tuple}(undef,ngauges)
    for i=1:ngauges
        annotation_arg[i] = (loc_all[i][1]+offset[1], loc_all[i][2]+offset[2],
                             Plots.text(annotation_str[i], font))
    end

    # plot
    plt = Plots.scatter!(plt, loc[:,1], loc[:,2]; d...,
                         ann=annotation_arg,
                         label="")

    # return
    return plt
end
###########################################
