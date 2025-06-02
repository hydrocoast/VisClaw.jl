######################################
"""
    makieheatmap!(ax, tiles::AbstractVector{VisClaw.AMRGrid}; AMRlevel=[], wind::Bool=false, region="", kwargs...)

Function: variables of AMR grids in heatmap plot
Arguments:
- `ax`: the axis to plot on
- `AMRlevel`: the level of the AMR grid to plot
- `region`: the region to plot
""" 
function makieheatmap!(ax, tiles::AbstractVector{VisClaw.AMRGrid}; AMRlevel=[], wind::Bool=false, region="", kwargs...)
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
        if !wind
            val = getfield(tiles[i], var)
        else
            val = sqrt.(getfield(tiles[i], :u).^2 .+ getfield(tiles[i], :v).^2)
        end

        ## plot
        CairoMakie.heatmap!(ax, x, y, val'; kwargs...)

    end
end



function makieheatmap!(ax, fg::VisClaw.FixedGrid, fgmax::VisClaw.FGmax; kwargs...)
    x = LinRange(fg.xlims[1], fg.xlims[2], fg.nx)
    y = LinRange(fg.ylims[1], fg.ylims[2], fg.ny)

    if fg.style == 2
        D = fgmax.D
        topo = fgmax.topo
        dry = D .< 1e-3
        eta = D .+ topo
        eta[dry] .= NaN
        CairoMakie.heatmap!(ax, x, y, eta'; kwargs...)
    else
        error("makieheatmap! for FixedGrid is not implemented for style $(fg.style)")
    end
end

function makieheatmap!(ax, fg::VisClaw.FixedGrid, fgout::AbstractArray, iout::Integer; kwargs...)
    x = LinRange(fg.xlims[1], fg.xlims[2], fg.nx)
    y = LinRange(fg.ylims[1], fg.ylims[2], fg.ny)
    if fg.style == 2
        CairoMakie.heatmap!(ax, x, y, permutedims(fgout[:,:,iout],(2,1)); kwargs...)
    else
        error("makieheatmap! for FixedGrid is not implemented for style $(fg.style)")
    end
end
function makieheatmap!(ax, fg::VisClaw.FixedGrid, fgout::Matrix; kwargs...)
    x = LinRange(fg.xlims[1], fg.xlims[2], fg.nx)
    y = LinRange(fg.ylims[1], fg.ylims[2], fg.ny)
    if fg.style == 2
        CairoMakie.heatmap!(ax, x, y, permutedims(fgout,(2,1)); kwargs...)
    else
        error("makieheatmap! for FixedGrid is not implemented for style $(fg.style)")
    end
end
