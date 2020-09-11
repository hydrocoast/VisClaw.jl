######################################
"""
    x1, x2, y1, y2 = getlims(tiles::VisClaw.AMRGrid)

get min/max range of a tile
"""
function getlims(tile::VisClaw.AMRGrid)
    return tile.xlow, tile.xlow+(tile.mx-1)*tile.dx, tile.ylow, tile.ylow+(tile.my-1)*tile.dy
end
######################################
"""
    x1, x2, y1, y2 = getlims(tiles::Vector{VisClaw.AMRGrid})

get min/max range of tiles
"""
function getlims(tiles::Vector{VisClaw.AMRGrid})
    x1 = minimum(getfield.(tiles, :xlow))
    y1 = minimum(getfield.(tiles, :ylow))
    x2 = maximum(round.(getfield.(tiles, :xlow) .+ getfield.(tiles, :mx).*getfield.(tiles, :dx), digits=4))
    y2 = maximum(round.(getfield.(tiles, :ylow) .+ getfield.(tiles, :my).*getfield.(tiles, :dy), digits=4))
    return x1, x2, y1, y2
end
######################################
"""
    xmesh, ymesh = meshtile(tile::VisClaw.AMRGrid)

generate meshgrids of tile
"""
function meshtile(tile::VisClaw.AMRGrid)
    ## set the boundary
    x = [tile.xlow, tile.xlow+tile.dx*tile.mx]
    y = [tile.ylow, tile.ylow+tile.dy*tile.my]
    ## grid info
    xline = collect(Float64, x[1]+0.5tile.dx:tile.dx:x[2]-0.5tile.dx+1e-4)
    yline = collect(Float64, y[1]+0.5tile.dy:tile.dy:y[2]-0.5tile.dy+1e-4)
    xmesh = repeat(xline', outer=(tile.my,1))
    ymesh = repeat(yline,  outer=(1,tile.mx))

    ## return values
    return xmesh, ymesh
end
######################################

"""
    var = keytile(tile::VisClaw.AMRGrid)

Get the main property name from VisClaw.AMRGrid
"""
function keytile(tile::VisClaw.AMRGrid)
    # check
    !isa(tile, VisClaw.AMRGrid) && error("Invalid input argument. It must be a type of VisClaw.AMRGrid")
    # assign
    varset = [:eta, :vel, :slp]
    ind = map(T -> isa(tile, T), [VisClaw.SurfaceHeight, VisClaw.Velocity, VisClaw.Storm])
    # return value
    return varset[ind][1]
end
##########################################################

##########################################################
"""
    xvec, yvec, val = tilezmargin(tile::VisClaw.AMRGrid, var::Symbol; digits=4)

Get Z-values of cells including their margins
"""
function tilezmargin(tile::VisClaw.AMRGrid, var::Symbol; digits=4)
    ## set the boundary
    x = [tile.xlow, round(tile.xlow+tile.dx*tile.mx, digits=digits)]
    y = [tile.ylow, round(tile.ylow+tile.dy*tile.my, digits=digits)]

    ## grid info
    xvec = collect(LinRange(x[1]-0.5tile.dx, x[2]+0.5tile.dx, tile.mx+2));
    yvec = collect(LinRange(y[1]-0.5tile.dy, y[2]+0.5tile.dy, tile.my+2));
    xvec = round.(xvec, digits=digits)
    yvec = round.(yvec, digits=digits)
    ## adjust data
    val = zeros(tile.my+2,tile.mx+2)
    val[2:end-1,2:end-1] = getfield(tile, var)
    val[2:end-1,1] = val[2:end-1,2]
    val[2:end-1,end] = val[2:end-1,end-1]
    val[1,:] = val[2,:]
    val[end,:] = val[end-1,:]

    # return val
    return xvec, yvec, val
end
##########################################################

##########################################################
"""
    xvec, yvec, val = tilez(tile::VisClaw.AMRGrid, var::Symbol; digits=4)

Get Z-values of cells at the grid lines
"""
function tilez(tile::VisClaw.AMRGrid, var::Symbol; digits=4)
    xvec, yvec, val = VisClaw.tilezmargin(tile, var, digits=digits)
    itp = Interpolations.interpolate((yvec, xvec), val, Interpolations.Gridded(Interpolations.Linear()))

    ## set the boundary
    x = [tile.xlow, round(tile.xlow+tile.dx*tile.mx, digits=digits)]
    y = [tile.ylow, round(tile.ylow+tile.dy*tile.my, digits=digits)]

    xvec = collect(LinRange(x[1], x[2], tile.mx+1));
    yvec = collect(LinRange(y[1], y[2], tile.my+1));
    xvec = round.(xvec, digits=digits)
    yvec = round.(yvec, digits=digits)

    val = itp(yvec,xvec);

    # return val
    return xvec, yvec, val
end
############################################################
