###################################################
"""
Get x and y ranges of a tile in String
"""
function getR_tile(tile::VisClaw.AMRGrid)
    xs = tile.xlow
    ys = tile.ylow
    xe = round(tile.xlow + tile.mx*tile.dx, digits=4)
    ye = round(tile.ylow + tile.my*tile.dy, digits=4)
    xyrange="$xs/$xe/$ys/$ye"
    # return value
    return xyrange
end
###################################################
"""
Get x and y ranges in String for -R
"""
function getR(tiles::Vector{VisClaw.AMRGrid})
    xs, xe, ys, ye = VisClaw.getlims(tiles)
    return "$xs/$xe/$ys/$ye"
end
###################################################
"""
Get x and y ranges in String for -R
"""
function getR(topo::VisClaw.AbstractTopo)
    xs=topo.x[1]
    xe=topo.x[end]
    ys=topo.y[1]
    ye=topo.y[end]
    xyrange="$xs/$xe/$ys/$ye"
    return xyrange
end
###################################################
"""
Get height/width ratio
"""
function axesratio(tiles::Vector{VisClaw.AMRGrid})
    xs, xe, ys, ye = VisClaw.getlims(tiles)
    hwratio = (ye-ys)/(xe-xs)
    # return value
    return hwratio
end
###################################################
"""
Get height/width ratio
"""
function axesratio(topo::VisClaw.AbstractTopo)
    xs=topo.x[1]
    xe=topo.x[end]
    ys=topo.y[1]
    ye=topo.y[end]
    hwratio = (ye-ys)/(xe-xs)
    # return value
    return hwratio
end
###################################################

###################################################
"""
Generate grd data, VisClaw.Topo
"""
function geogrd(geo::VisClaw.Topo; kwargs...)

    Δ = geo.dx
    R = VisClaw.getR(geo)
    xvec = repeat(geo.x, inner=(geo.nrows,1))
    yvec = repeat(geo.y, outer=(geo.ncols,1))

    G = GMT.surface([xvec[:] yvec[:] geo.elevation[:]]; R=R, I=Δ, kwargs...)
    #G = GMT.surface([xvec[:] reverse(yvec[:]) geo.elevation[:]]; R=R, I=Δ, kwargs...)

    return G
end
###################################################
"""
Generate grd data, VisClaw.DTopo
"""
function geogrd(geo::VisClaw.DTopo; kwargs...)

    Δ = geo.dx
    R = VisClaw.getR(geo)
    xvec = repeat(geo.x, inner=(geo.my,1))
    yvec = repeat(geo.y, outer=(geo.mx,1))

    G = GMT.surface([xvec[:] yvec[:] geo.deform[:]]; R=R, I=Δ, kwargs...)
    #G = GMT.surface([xvec[:] reverse(yvec[:]) geo.deform[:]]; R=R, I=Δ, kwargs...)

    return G
end
###################################################

###################################################
"""
Correct J option
"""
#function getJ(geo; proj_base="X10d"::String)
function getJ(proj_base::String, hwratio::Real)
    # find projection specifier
    J1 = match(r"^([a-zA-Z]+)", proj_base)
    J2 = match(r"([a-zA-Z]+).+?([a-zA-Z]+)", proj_base)
    if J1 === nothing
        error("Invald argument proj_base: $proj_base")
    end

    # assign figure width
    # check whether variable proj_base contains any number
    regex = r"([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)"
    chkwidth = match(regex, proj_base)
    if chkwidth === nothing
        fwidth=10
    else
        fwidth = parse(Float64, chkwidth.captures[1])
    end
    # assign figure height
    # check whether variable proj_base contains the height
    regex = r"([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?).+?([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)"
    chkheight = match(regex, proj_base)
    if chkheight === nothing
        fheight = hwratio*fwidth
    else
        fheight = parse(Float64, chkheight.captures[2])
    end

    # generate J option
    if occursin("/",proj_base) && chkheight !== nothing
        proj = proj_base
    else
        if J2 === nothing
            proj=J1.captures[1]*"$fwidth"*"/$fheight"
        else
            proj=J1.captures[1]*"$fwidth"*J2.captures[2]*"/$fheight"*J2.captures[2]
        end
    end
    # return value
    return proj
end
###################################################
