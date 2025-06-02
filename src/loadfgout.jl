function loadfgout(outputdir::AbstractString, fg::VisClaw.FixedGrid, tout::Integer)
    if fg.output_format == 1
        dtype = Float64
    elseif fg.output_format == 2
        dtype = Float32
    elseif fg.output_format == 3
        dtype = Float64
    else
        error("output_format $(fg.output_format) is not supported yet.")
    end

    eta = zeros(dtype, fg.nx, fg.ny)
    if fg.output_format == 1
        ## fgoutNNNN.qXXXX
        filename = "fgout"*@sprintf("%04d",fg.id)*".q"*@sprintf("%04d",tout)
        ## load
        dat = readdlm(joinpath(outputdir, filename), Float64; skipstart=9)
        D = reshape(dat[:,1],(fg.nx, fg.ny))
        tmp = reshape(dat[:,4],(fg.nx, fg.ny))
        dry = D .< 1e-3
        tmp[dry] .= NaN
        eta = tmp
    else
        nall = fg.nval*fg.nx*fg.ny
        ## fgoutNNNN.bXXXX
        filename = "fgout"*@sprintf("%04d",fg.id)*".b"*@sprintf("%04d",tout)
        ## load
        dat = Vector{dtype}(undef, nall)
        # Read the data into arrays
        open(joinpath(outputdir, filename), "r") do io
            for k in 1:nall
                dat[k] = read(io, dtype)
            end
        end
        dat = reshape(dat, (fg.nval, fg.nx, fg.ny))
        D = dat[1, :, :]  # just take the first variable
        e = dat[4, :, :]  # just take the 4th variable
        dry = D .< 1e-3
        e[dry] .= NaN  # set dry cells to NaN
        eta = e
    end
    eta = permutedims(eta, (2, 1))  # Adjust dimensions to (ny, nx)

    ## return 
    return eta

end
#################################


#################################
"""
    eta = loadfgout(outputdir::AbstractString, fg::VisClaw.FixedGrid)

Function: fgoutNNNN.qXXXX/fgoutNNNN.bXXXX reader
"""
function loadfgout(outputdir::AbstractString, fg::VisClaw.FixedGrid)
    if fg.output_format == 1
        dtype = Float64
    elseif fg.output_format == 2
        dtype = Float32
    elseif fg.output_format == 3
        dtype = Float64
    else
        error("output_format $(fg.output_format) is not supported yet.")
    end
    eta = zeros(dtype, fg.ny, fg.nx, fg.nout)
    for k = 1:fg.nout
        eta[:,:,k] = loadfgout(outputdir, fg, k)
    end

    ## return
    return eta    
end
#################################


