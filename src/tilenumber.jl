function tilenumber!(ax, tiles; AMRlevel::AbstractVector=[], xlims=(), ylims=(), kwargs...)

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

        CairoMakie.text!(ax, mean(x), mean(y), text=ann, kwargs...)
    end
end


function tilebound!(ax, tiles; AMRlevel::AbstractVector=[], xlims=(), ylims=(), kwargs...)
    ## the number of tiles
    ntile = length(tiles)
    for i = 1:ntile

        ## skip when the AMR level of this tile doesn't match any designated level
        if !isempty(AMRlevel); if isempty(findall(tiles[i].AMRlevel .== AMRlevel)); continue; end; end

        ## set the boundary
        x = [tiles[i].xlow, tiles[i].xlow+tiles[i].dx*tiles[i].mx]
        y = [tiles[i].ylow, tiles[i].ylow+tiles[i].dy*tiles[i].my]

        ## check whether the tile is on the domain
        if !isempty(xlims)
            if (x[2] < xlims[1]) | (xlims[2] < x[1]); continue; end
        end
        if !isempty(ylims)
            if (y[2] < ylims[1]) | (ylims[2] < y[1]); continue; end
        end

        xvertices = [x[1], x[1], x[2], x[2], x[1]]
        yvertices = [y[1], y[2], y[2], y[1], y[1]]
        CairoMakie.lines!(ax, xvertices, yvertices; kwargs...)
    end
end