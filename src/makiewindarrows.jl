######################################
"""
    makiewindarrows!(ax, tiles::AbstractVector{VisClaw.AMRGrid}; AMRlevel=[], region="", kwargs...)

Function: variables of AMR grids in heatmap plot
Arguments:
- `ax`: the axis to plot on
- `AMRlevel`: the level of the AMR grid to plot
""" 
function makiewindarrows!(ax, tiles::AbstractVector{VisClaw.AMRGrid}, nskip=5; AMRlevel=[], region="", kwargs...)

    ## the number of tiles
    ntile = length(tiles)

    ## display each tile
    for i = 1:ntile
        ## skip when the AMR level of this tile doesn't match any designated level
        if !isempty(AMRlevel)
            if isempty(findall(tiles[i].AMRlevel .== AMRlevel)); continue; end
        end
        ## skip when the tile is not in the region
        if isa(region, VisClaw.AbstractTopo)
            if !VisClaw.inregion(tiles[i], region); continue; end
        elseif isa(region, VisClaw.Region)
            if !VisClaw.inregion(tiles[i], region); continue; end
        end

        ## set the boundary
        x = collect(LinRange(tiles[i].xlow, tiles[i].xlow+(tiles[i].mx-1)*tiles[i].dx, tiles[i].mx))
        y = collect(LinRange(tiles[i].ylow, tiles[i].ylow+(tiles[i].my-1)*tiles[i].dy, tiles[i].my))
        u = getfield(tiles[i], :u)
        v = getfield(tiles[i], :v)
        wm = sqrt.(getfield(tiles[i], :u).^2 .+ getfield(tiles[i], :v).^2)
        TFzero = wm .<= 1e-6
        u[TFzero] .= NaN
        v[TFzero] .= NaN

        u = u'
        v = v'
        wm = wm'
        
        #nskip = 5
        x = x[1:nskip:end]
        y = y[1:nskip:end]
        u = u[1:nskip:end, 1:nskip:end]
        v = v[1:nskip:end, 1:nskip:end]
        wm = wm[1:nskip:end, 1:nskip:end]

        #=
        if !haskey(kwargs, :arrowsize)
            kwargs = merge(kwargs, Dict(:arrowsize => vec(wm)))
        end
        if !haskey(kwargs, :arrowcolor)
            kwargs = merge(kwargs, Dict(:arrowcolor => vec(wm)))
        end
        if !haskey(kwargs, :linecolor)
            kwargs = merge(kwargs, Dict(:linecolor => vec(wm)))
        end
        =#

        ## plot
        CairoMakie.arrows!(ax, x, y, u', v'; kwargs...)

    end
    #return ax
end