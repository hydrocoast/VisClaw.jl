######################################
"""
    plt = plotsamr2d(tiles::AbstractVector{VisClaw.AMRGrid}, AMRlevel::AbstractVector; kwargs...)

    plotsamr2d!(plt::Plots.Plot, tiles::AbstractVector{VisClaw.AMRGrid}, AMRlevel::AbstractVector=[]; wind::Bool=false, kwargs...)

Function: plot values of AMR grids in two-dimension
"""
function plotsamr2d!(plt, tiles::AbstractVector{VisClaw.AMRGrid}, AMRlevel::AbstractVector=[];
                     wind::Bool=false, kwargs...)

    # check arg
    if isa(tiles[1], VisClaw.SurfaceHeight)
        var = :eta
    elseif isa(tiles[1], VisClaw.Velocity)
        var = :vel
    elseif isa(tiles[1], VisClaw.Storm)
        if wind
            var = :u
        else
            var = :slp
        end
    else
        error("Invalid argument")
    end

    # parse keyword args
    kwdict = KWARG(kwargs)
    # -----------------------------
    # linetype
    seriestype, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_seriestype, :heatmap)
    # -----------------------------
    # color
    seriescolor, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_seriescolor, :auto)
    # -----------------------------
    # color axis
    clims, kwdict = VisClaw.parse_clims(kwdict)
    if clims == nothing
        vals = getfield.(tiles, var)
        clims = (
                 minimum(minimum.(v->isnan(v) ?  Inf : v, vals)),
                 maximum(maximum.(v->isnan(v) ? -Inf : v, vals))
                 )
        #clims = (minimum(minimum.(filter.(!isnan, vals))),
        #         maximum(maximum.(filter.(!isnan, vals))))
    end
    # -----------------------------
    # background_color_inside
    bginside, kwdict =  VisClaw.kwarg_default(kwdict, VisClaw.parse_bgcolor_inside, Plots.RGB(.7,.7,.7))
    if seriestype == :surface; bginside = Plots.RGBA(0.0,0.0,0.0,0.0); end
    # -----------------------------
    # colorbar
    cb, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_colorbar, :none)
    # -----------------------------
    # colorbar_title
    cbtitle, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_colorbar_title, "")
    # -----------------------------
    # xlims, ylims
    xlims, kwdict = VisClaw.parse_xlims(kwdict)
    ylims, kwdict = VisClaw.parse_ylims(kwdict)
    # -----------------------------

    # Too fine grids are not plotted
    if isempty(AMRlevel) && xlims==nothing && ylims==nothing
        AMRlevel = 1:3
    end

    ## the number of tiles
    ntile = length(tiles)
    ##
    nplot_org = plt.n

    ## display each tile
    for i = 1:ntile

        ## skip when the AMR level of this tile doesn't match any designated level
        if !isempty(AMRlevel)
            if isempty(findall(tiles[i].AMRlevel .== AMRlevel)); continue; end
        end

        ## set the boundary
        x = [tiles[i].xlow, tiles[i].xlow+tiles[i].dx*tiles[i].mx]
        y = [tiles[i].ylow, tiles[i].ylow+tiles[i].dy*tiles[i].my]

        ## grid info
        xvec = collect(Float64, x[1]-0.5tiles[i].dx:tiles[i].dx:x[2]+0.5tiles[i].dx+1e-4)
        yvec = collect(Float64, y[1]-0.5tiles[i].dy:tiles[i].dy:y[2]+0.5tiles[i].dy+1e-4)

        ## check whether the tile is on the domain
        if xlims!=nothing
            if (xvec[end] < xlims[1]) | (xlims[2] < xvec[1]); continue; end
        end
        if ylims!=nothing
            if (yvec[end] < ylims[1]) | (ylims[2] < yvec[1]); continue; end
        end


        ## adjust data
        val = zeros(tiles[i].my+2,tiles[i].mx+2)
        if !wind
            val[2:end-1,2:end-1] = getfield(tiles[i], var)
        else
            val[2:end-1,2:end-1] = sqrt.(getfield(tiles[i], :u).^2 .+ getfield(tiles[i], :v).^2)
        end
        val[2:end-1,1] = val[2:end-1,2]
        val[2:end-1,end] = val[2:end-1,end-1]
        val[1,:] = val[2,:]
        val[end,:] = val[end-1,:]

        ## plot
        plt = Plots.plot!(plt, xvec, yvec, val, seriestype=seriestype, c=seriescolor, clims=clims, colorbar=false)

    end

    # check the number of added series
    if plt.n == nplot_org
        println("Nothing to be plotted. Check xlims and ylims you specified.")
        plt = Plots.plot!(plt, 0:5, 0:5, repeat([NaN], inner=(6,6)), label="", c=seriescolor, clims=clims, colorbar=cb)
        return plt
    end


    ## xlims, ylims
    x1, x2, y1, y2 = VisClaw.getlims(tiles)
    xrange = (x1, x2)
    yrange = (y1, y2)
    xlims = xlims==nothing ? xrange : xlims
    ylims = ylims==nothing ? yrange : ylims
    plt = Plots.plot!(plt, xlims=xlims, ylims=ylims)

    if !isempty(kwdict); plt = Plots.plot!(plt; kwdict...); end

    ## colorbar
    for i = nplot_org+1:plt.n; plt.series_list[i].plotattributes[:colorbar_entry] = false; end
    if (cb !== :none) && (cb !== false)
        plt.series_list[nplot_org+1].plotattributes[:colorbar_entry] = true
    end

    ## Appearance
    plt = Plots.plot!(plt, axis_ratio=:equal, grid=false, bginside=bginside, colorbar=cb, colorbar_title=cbtitle)

    ## return value
    return plt
end
######################################
"""
$(@doc plotsamr2d!)
"""
plotsamr2d(tiles, AMRlevel::AbstractVector=[]; kwargs...) =
plotsamr2d!(Plots.plot(), tiles, AMRlevel; kwargs...)
######################################
plotsamr2d!(plt, tiles, AMRlevel::Integer; kwargs...) = plotsamr2d!(plt, tiles, AMRlevel:AMRlevel; kwargs...)
######################################
plotsamr2d(tiles, AMRlevel::Integer; kwargs...) = plotsamr2d(tiles, AMRlevel:AMRlevel; kwargs...)
######################################



#######################################
"""
    gridnumber!(plt::Plots.Plot, tiles; AMRlevel::AbstractVector=[], font::Plots.Font=Plots.font(12, :hcenter, :black), xlims=(), ylims=())

Function: add the grid numbers of tiles
"""
function gridnumber!(plt, tiles; AMRlevel::AbstractVector=[],
                     font::Plots.Font=Plots.font(12, :hcenter, :black),
                     xlims=(), ylims=())

    # Too fine grids are not plotted
    if isempty(AMRlevel) && isempty(xlims) && isempty(ylims)
        AMRlevel = 1:3
    end

    # get current lims
    if plt.n != 0
        if isempty(xlims)
            xlims = Plots.xlims(plt)
        end
        if isempty(ylims)
            ylims = Plots.ylims(plt)
        end
    end

    ## the number of tiles
    ntile = length(tiles)
    for i = 1:ntile

        ## skip when the AMR level of this tile doesn't match any designated level
        if !isempty(AMRlevel)
            if isempty(findall(tiles[i].AMRlevel .== AMRlevel)); continue; end
        end

        ## set the boundary
        x = [tiles[i].xlow, tiles[i].xlow+tiles[i].dx*tiles[i].mx]
        y = [tiles[i].ylow, tiles[i].ylow+tiles[i].dy*tiles[i].my]
        ann = @sprintf("%02d", tiles[i].gridnumber)

        ## check whether the tile is on the domain
        if !isempty(xlims)
            if (mean(x) < xlims[1]) | (xlims[2] < mean(x)); continue; end
        end
        if !isempty(ylims)
            if (mean(y) < ylims[1]) | (ylims[2] < mean(y)); continue; end
        end

        ## annotations
        plt = Plots.plot!(plt, annotations=(mean(x),mean(y), Plots.text(ann, font)))
    end
    return plt
end
#######################################

#######################################
"""
    tilebound!(plt, tiles; AMRlevel=[], kwargs...)

Function: draw boundaries of tiles
"""
function tilebound!(plt, tiles; AMRlevel=[], kwargs...)

    # parse keyword args
    kwdict = KWARG(kwargs)

    # -----------------------------
    # linestyle
    linestyle, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_linestyle, :solid)
    # -----------------------------
    # linecolor
    linecolor, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_linecolor, :black)
    # -----------------------------
    # xlims, ylims
    xlims, kwdict = VisClaw.parse_xlims(kwdict)
    ylims, kwdict = VisClaw.parse_ylims(kwdict)
    # get current lims
    if plt.n != 0
        if xlims == nothing
            xlims = Plots.xlims(plt)
        end
        if ylims == nothing
            ylims = Plots.ylims(plt)
        end
    end
    # -----------------------------

    # Too fine grids are not plotted
    if isempty(AMRlevel) && xlims==nothing && ylims==nothing; AMRlevel = 1:3; end


    ## the number of tiles
    ntile = length(tiles)
    for i = 1:ntile

        ## skip when the AMR level of this tile doesn't match any designated level
        if !isempty(AMRlevel); if isempty(findall(tiles[i].AMRlevel .== AMRlevel)); continue; end; end

        ## set the boundary
        x = [tiles[i].xlow, tiles[i].xlow+tiles[i].dx*tiles[i].mx]
        y = [tiles[i].ylow, tiles[i].ylow+tiles[i].dy*tiles[i].my]

        ## check whether the tile is on the domain
        if xlims!=nothing
            if (x[2] < xlims[1]) | (xlims[2] < x[1]); continue; end
        end
        if ylims!=nothing
            if (y[2] < ylims[1]) | (ylims[2] < y[1]); continue; end
        end

        plt = Plots.plot!(plt,
              [x[1], x[1], x[2], x[2], x[1]],
              [y[1], y[2], y[2], y[1], y[1]];
              label="", linestyle=linestyle, linecolor=linecolor, kwdict...)
    end
    return plt
end
#######################################

#######################################
"""
    plts = plotsamr(amrs::VisClaw.AMR, AMRlevel::AbstractVector=[]; kwargs...)
    plts = plotsamr(amrs::VisClaw.AMR, AMRlevel::Integer; kwargs...)

Function: plot AMR data at designated times
"""
function plotsamr(amrs::VisClaw.AMR, AMRlevel::AbstractVector=[]; kwargs...)
    ## plot time-series
    plt = Array{Plots.Plot}(undef, amrs.nstep)
    for i = 1:amrs.nstep
        if isempty(amrs.amr[i]); plt[i] = Plots.plot(); continue; end
        plt[i] = VisClaw.plotsamr2d(amrs.amr[i], AMRlevel; kwargs...)
    end
    ## return plots
    return plt
end
#############################################
plotsamr(amrs::VisClaw.AMR, AMRlevel::Integer; kwargs...) = plotsamr(amrs::VisClaw.AMR, AMRlevel:AMRlevel; kwargs...)
