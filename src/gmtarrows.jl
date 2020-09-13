"""
    Gu, Gv = arrowscalegrd(xloc, yloc, uscale, vscale)

create u and v grd files for an arrow scale
"""
function arrowscalegrd(xloc, yloc, uscale, vscale)
    X = collect(-2:2) .+ xloc
    Y = collect(-2:2) .+ yloc
    U = zeros(Float64, 5,5)
    V = zeros(Float64, 5,5)
    U[3,3] = uscale
    V[3,3] = vscale

    Gu = GMT.surface([repeat(X,inner=(5,1)) repeat(Y,outer=(5,1)) vec(U)], I=1, R=[X[1],X[end],Y[1],Y[end]])
    Gv = GMT.surface([repeat(X,inner=(5,1)) repeat(Y,outer=(5,1)) vec(V)], I=1, R=[X[1],X[end],Y[1],Y[end]])

    return Gu, Gv
end


"""
    Gu, Gv = arrowgrd(tiles::Vector{VisClaw.AMRGrid}; cutoff=0.1, kwargs...)

create u and v grd files from AMR grid tiles
"""
function arrowgrd(tiles::Vector{VisClaw.AMRGrid}; cutoff=0.1, kwargs...)
    ## region
    region = VisClaw.getlims(tiles)

    ## number of tile
    ntile = length(tiles)

    ## preallocate
    xg = Vector{AbstractVector{Float64}}(undef,ntile)
    yg = Vector{AbstractVector{Float64}}(undef,ntile)
    ug = Vector{AbstractVector{Float64}}(undef,ntile)
    vg = Vector{AbstractVector{Float64}}(undef,ntile)

    ## make vectors of X, Y, U, V for all tiles
    for k = 1:ntile
        X, Y = VisClaw.meshtile(tiles[k])
        xg[k] = vec(X)
        yg[k] = vec(Y)
        ug[k] = vec(tiles[k].u)
        vg[k] = vec(tiles[k].v)
    end
    ## cat all tiles
    xg  = vcat(xg...)
    yg  = vcat(yg...)
    ug  = vcat(ug...)
    vg  = vcat(vg...)

    ## replace NaNs into 0.0
    V = @. sqrt(ug^2 + vg^2)
    ind = @. isnan(V) | (V<cutoff)
    xg[ind] .= 0.0
    yg[ind] .= 0.0
    ug[ind] .= 0.0
    vg[ind] .= 0.0

    ## makegrd
    Gu = GMT.xyz2grd([xg yg ug], I=tiles[1].dx, R=region, kwargs...)
    Gv = GMT.xyz2grd([xg yg vg], I=tiles[1].dy, R=region, kwargs...)

    ## return
    return Gu, Gv
end

arrowgrd(amrs::VisClaw.AMR, istep::Integer; cutoff=0.1, kwargs...) =
arrowgrd(amrs.amr[istep]; cutoff=cutoff, kwargs...)
