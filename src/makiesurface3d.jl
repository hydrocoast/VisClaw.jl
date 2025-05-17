######################################
"""
    makiesurface3d!(ax, tiles::AbstractVector{VisClaw.AMRGrid}; AMRlevel=[], wind::Bool=false, region="", kwargs...)

Function: plot values of AMR grids in a 3D surface plot
Arguments:
- `ax`: the axis to plot on
- `AMRlevel`: the level of the AMR grid to plot
- `region`: the region to plot
""" 
function makiesurface3d!(ax, tiles::AbstractVector{VisClaw.AMRGrid}; AMRlevel=[], wind::Bool=false, region="", kwargs...)
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
        x = [tiles[i].xlow, tiles[i].xlow+tiles[i].dx*tiles[i].mx]
        y = [tiles[i].ylow, tiles[i].ylow+tiles[i].dy*tiles[i].my]

        ## grid info
        xvec = collect(Float64, x[1]-0.5tiles[i].dx:tiles[i].dx:x[2]+0.5tiles[i].dx+1e-4)
        yvec = collect(Float64, y[1]-0.5tiles[i].dy:tiles[i].dy:y[2]+0.5tiles[i].dy+1e-4)

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
        CairoMakie.surface!(ax, xvec, yvec, val'; kwargs...)

    end
    #return ax
end