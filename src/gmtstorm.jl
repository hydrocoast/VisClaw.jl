
###################################################
function txtwind(tiles::Vector{VisClaw.AMRGrid}; skip=3::Int64,
                 offset1::Int64=0, offset2::Int64=offset1)

    # number of tile
    ntile = length(tiles)

    # preallocate
    x = Vector{AbstractVector{Float64}}(undef,ntile)
    y = Vector{AbstractVector{Float64}}(undef,ntile)
    u = Vector{AbstractVector{Float64}}(undef,ntile)
    v = Vector{AbstractVector{Float64}}(undef,ntile)

    for k=1:ntile
        X, Y = VisClaw.meshtile(tiles[k])

        st = 1+offset1
        Δ = skip*tiles[k].AMRlevel

        x[k] = vec(X[st:Δ:end-offset2, st:Δ:end-offset2])
        y[k] = vec(Y[st:Δ:end-offset2, st:Δ:end-offset2])
        u[k] = vec(tiles[k].u[st:Δ:end-offset2, st:Δ:end-offset2])
        v[k] = vec(tiles[k].v[st:Δ:end-offset2, st:Δ:end-offset2])
    end

    # cat all of tiles
    xall  = vcat(x...)
    yall  = vcat(y...)
    uall  = vcat(u...)
    vall  = vcat(v...)

    # filter: small value removed
    V = sqrt.(uall.^2 .+ vall.^2)
    ind = isnan.(V) .| (V.<1e-1)
    deleteat!(xall, ind)
    deleteat!(yall, ind)
    deleteat!(uall, ind)
    deleteat!(vall, ind)

    # output matrix
    np = size(xall, 1)
    outdat = hcat(xall, yall, uall, vall, repeat([0.0], inner=(np,3)))

    # output file
    txtfile="tmpvelo.txt"
    open(txtfile, "w") do file
        for i = 1:np
            @printf(file, "%10.4f %10.4f %10.4f %10.4f %4.1f %4.1f %4.1f\n", outdat[i,:]...)
        end
    end

    return txtfile
end
###################################################

###################################################
function txtwind_scale(x, y, u, v, label::String="")

    if isempty(label)
        label = @sprintf("%d", sqrt(u^2+v^2))*" m/s"
    end

    # output file
    txtfile="tmpvelo_scale.txt"

    open(txtfile, "w") do file
        @printf(file, "%10.4f %10.4f %10.4f %10.4f 0.0 0.0 0.0 ", x, y, u, v)
        print(file, label*"\n")
    end

    return txtfile
end
