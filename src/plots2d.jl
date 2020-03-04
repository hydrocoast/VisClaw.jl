empI = empty([], Int64)
######################################
"""
Function: plot values of AMR grids in two-dimension
"""
function plotsamr2d!(plt, tiles::AbstractVector{VisClaw.AMRGrid}, AMRlevel::AbstractVector{Int64}=empI;
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
    seriestype, kwdict = VisClaw.parse_seriestype(kwdict)
    if seriestype == nothing; seriestype=:heatmap; end
    # -----------------------------
    # color
    seriescolor, kwdict = VisClaw.parse_seriescolor(kwdict)
    if seriescolor == nothing; seriescolor=:auto; end
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
    bginside, kwdict = VisClaw.parse_bgcolor_inside(kwdict)
    if bginside == nothing; bginside = Plots.RGB(.7,.7,.7); end
    if seriestype == :surface; bginside = Plots.RGBA(0.0,0.0,0.0,0.0); end
    # -----------------------------
    # colorbar_title
    cbtitle, kwdict = VisClaw.parse_colorbar_title(kwdict)
    if cbtitle==nothing; cbtitle=""; end
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
    plt.series_list[nplot_org+1].plotattributes[:colorbar_entry] = true

    ## Appearance
    plt = Plots.plot!(plt, axis_ratio=:equal, grid=false, bginside=bginside, colorbar=true, colorbar_title=cbtitle)

    ## return value
    return plt
end
######################################
plotsamr2d(tiles, AMRlevel::AbstractVector{Int64}=empI; kwargs...) =
plotsamr2d!(Plots.plot(), tiles, AMRlevel; kwargs...)
######################################



#######################################
"""
Function: add the grid numbers
"""
function gridnumber!(plt, tiles; AMRlevel::AbstractVector{Int64}=empI,
                     font::Plots.Font=Plots.font(12, :hcenter, :black),
                     xlims::Tuple=(),
                     ylims::Tuple=())

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
Function: draw boundaries
"""
function tilebound!(plt, tiles; AMRlevel::AbstractVector{Int64}=empI, kwargs...)

    # parse keyword args
    kwdict = KWARG(kwargs)

    # -----------------------------
    # linestyle
    linestyle, kwdict = VisClaw.parse_linestyle(kwdict)
    if linestyle == nothing; linestyle=:solid; end
    # -----------------------------
    # linecolor
    linecolor, kwdict = VisClaw.parse_linecolor(kwdict)
    if linecolor == nothing; linecolor=:black; end
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
    if isempty(AMRlevel) && xlims==nothing && ylims==nothing
        AMRlevel = 1:3
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
Function: plot time-series of AMR data
"""
function plotsamr(amrs::VisClaw.AMR, AMRlevel::AbstractVector{Int64}=empI; kwargs...)
    ## plot time-series
    plt = Array{Plots.Plot}(undef, amrs.nstep)
    for i = 1:amrs.nstep
        plt[i] = VisClaw.plotsamr2d(amrs.amr[i], AMRlevel; kwargs...)
    end
    ## return plots
    return plt
end
#############################################
