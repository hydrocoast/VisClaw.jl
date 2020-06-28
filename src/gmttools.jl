###################################################
"""
    getR_tile = getR_tile(tile::VisClaw.AMRGrid; length_unit="")

Get x and y ranges of a tile in String for -R option in GMT
"""
function getR_tile(tile::VisClaw.AMRGrid; length_unit="")
    xs = tile.xlow
    ys = tile.ylow
    xe = round(tile.xlow + tile.mx*tile.dx, digits=4)
    ye = round(tile.ylow + tile.my*tile.dy, digits=4)
    xyrange="$xs/$xe/$ys/$ye"
    isempty(length_unit) || (xyrange = xyrange*"+u"*length_unit)
    # return value
    return xyrange
end
###################################################
"""
    xyrange = getR(tiles::Vector{VisClaw.AMRGrid}; length_unit="")
    xyrange = getR(topo::VisClaw.AbstractTopo; length_unit="")
    xyrange = getR(G::GMT.GMTgrid; length_unit="")

Get x and y ranges in String for -R option in GMT
"""
function getR(tiles::Vector{VisClaw.AMRGrid}; length_unit="")
    xs, xe, ys, ye = VisClaw.getlims(tiles)
    xyrange="$xs/$xe/$ys/$ye"
    isempty(length_unit) || (xyrange = xyrange*"+u"*length_unit)
    # return value
    return xyrange
end
###################################################
function getR(topo::VisClaw.AbstractTopo; length_unit="")
    xs=topo.x[1]
    xe=topo.x[end]
    ys=topo.y[1]
    ye=topo.y[end]
    xyrange="$xs/$xe/$ys/$ye"
    isempty(length_unit) || (xyrange = xyrange*"+u"*length_unit)
    return xyrange
end
###################################################
function getR(G::GMT.GMTgrid; length_unit="")
    x = extrema(G.x)
    y = extrema(G.y)
    xyrange="$(x[1])/$(x[2])/$(y[1])/$(y[2])"
    isempty(length_unit) || (xyrange = xyrange*"+u"*length_unit)
    return xyrange
end
###################################################
"""
    hwratio = axesratio(tiles::Vector{VisClaw.AMRGrid})
    hwratio = axesratio(topo::VisClaw.AbstractTopo)
    hwratio = axesratio(G::GMT.GMTgrid)

Get height/width ratio
"""
function axesratio(tiles::Vector{VisClaw.AMRGrid})
    xs, xe, ys, ye = VisClaw.getlims(tiles)
    hwratio = (ye-ys)/(xe-xs)
    # return value
    return hwratio
end
###################################################
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
function axesratio(G::GMT.GMTgrid)
    x = extrema(G.x)
    y = extrema(G.y)
    hwratio = (y[2]-y[1])/(x[2]-x[1])
    # return value
    return hwratio
end
###################################################


###################################################
"""
    G = geogrd(geo::VisClaw.Topo; kwargs...)
    G = geogrd(geo::VisClaw.DTopo, itime::Int64=0; kwargs...)

Generate grd (GMT) data
"""
function geogrd(geo::VisClaw.Topo; kwargs...)

    Δ = geo.dx
    R = VisClaw.getR(geo)
    xvec = repeat(geo.x, inner=(geo.nrows,1))
    yvec = repeat(geo.y, outer=(geo.ncols,1))

    G = GMT.surface([xvec[:] yvec[:] geo.elevation[:]]; R=R, I=Δ, kwargs...)

    return G
end
###################################################
function geogrd(geo::VisClaw.DTopo, itime::Int64=0; kwargs...)

    Δ = geo.dx
    R = VisClaw.getR(geo)
    xvec = repeat(geo.x, inner=(geo.my,1))
    yvec = repeat(geo.y, outer=(geo.mx,1))

    ( (itime < 0) || (geo.mt < itime) ) && error("Invalid time")
    if geo.mt == 1
        G = GMT.surface([xvec[:] yvec[:] geo.deform[:]]; R=R, I=Δ, kwargs...)
    elseif itime == 0
        G = GMT.surface([xvec[:] yvec[:] vec(geo.deform[:,:,end])]; R=R, I=Δ, kwargs...)
    else
        G = GMT.surface([xvec[:] yvec[:] vec(geo.deform[:,:,itime])]; R=R, I=Δ, kwargs...)
    end
    return G
end
###################################################

###################################################
"""
    proj = getJ(proj_base::String, hwratio::Real)

Correct J option
"""
function getJ(proj_base::String, hwratio::Real)
    # find projection specifier
    J1 = match(r"^([a-zA-Z]+)", proj_base)
    J2 = match(r"([a-zA-Z]+).+?([a-zA-Z]+)", proj_base)

    J1 === nothing && error("Invald argument proj_base: $proj_base")

    # assign figure width
    # check whether variable proj_base contains any number
    regex = r"([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)"
    chkwidth = match(regex, proj_base)

    fwidth = chkwidth === nothing ? fwidth=10 : parse(Float64, chkwidth.captures[1])

    # assign figure height
    # check whether variable proj_base contains the height
    regex = r"([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?).+?([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)"
    chkheight = match(regex, proj_base)

    fheight = chkheight === nothing ? hwratio*fwidth : parse(Float64, chkheight.captures[2])

    # generate J option
    if occursin("/",proj_base) && chkheight !== nothing
        proj = proj_base
    else
        proj = J2 === nothing ? J1.captures[1]*"$fwidth"*"/$fheight" : J1.captures[1]*"$fwidth"*J2.captures[2]*"/$fheight"*J2.captures[2]
    end
    # return value
    return proj
end
###################################################
getJ(proj_base::String, topo::VisClaw.Topo) = getJ(proj_base, VisClaw.axesratio(topo))
###################################################
getJ(proj_base::String, amr::Vector{VisClaw.AMRGrid}) = getJ(proj_base, VisClaw.axesratio(amr))
###################################################
