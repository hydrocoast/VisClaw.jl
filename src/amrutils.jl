######################################
function getlims(tiles::Vector{VisClaw.AMRGrid})
    x1 = minimum(getfield.(tiles, :xlow))
    y1 = minimum(getfield.(tiles, :ylow))
    x2 = maximum(round.(getfield.(tiles, :xlow) .+ getfield.(tiles, :mx).*getfield.(tiles, :dx), digits=4))
    y2 = maximum(round.(getfield.(tiles, :ylow) .+ getfield.(tiles, :my).*getfield.(tiles, :dy), digits=4))
    return x1, x2, y1, y2
end
######################################
"""
generate meshgrid in 1-column
"""
function meshline(tile::VisClaw.AMRGrid)
    ## set the boundary
    x = [tile.xlow, tile.xlow+tile.dx*tile.mx]
    y = [tile.ylow, tile.ylow+tile.dy*tile.my]
    ## grid info
    xline = collect(Float64, x[1]+0.5tile.dx:tile.dx:x[2]-0.5tile.dx+1e-4)
    yline = collect(Float64, y[1]+0.5tile.dy:tile.dy:y[2]-0.5tile.dy+1e-4)
    xvec = repeat(xline, inner=(tile.my,1)) |> vec
    yvec = repeat(yline, outer=(tile.mx,1)) |> vec

    ## return values
    return xvec, yvec
end
######################################
"""
generate meshgrid
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
Get the main property name from VisClaw.AMRGrid
"""
function keytile(tile::VisClaw.AMRGrid)
    # type check
    if isa(tile, VisClaw.SurfaceHeight)
        var = :eta
    elseif isa(tile, VisClaw.Velocity)
        var = :vel
    elseif isa(tile, VisClaw.Storm)
        var = :slp
    else
        error("Invalid input argument, type of VisClaw.AMRGrid")
    end
    # return value
    return var
end
##########################################################

##########################################################
"""
Get Z values of cells including their margins
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
Get Z values of cells at the grid lines
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
