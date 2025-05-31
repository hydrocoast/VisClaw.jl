#################################
"""
    fgout = loadfgout(outputdir::AbstractString, fg::VisClaw.FixedGrid)

Function: fgoutNNNN.qXXXX/fgoutNNNN.bXXXX reader
"""
function loadfgout(outputdir::AbstractString, fg::VisClaw.FixedGrid)
    ## check nval_save
    #nval_save > fg.nval && (nval_save=fg.nval)

    eta = zeros(fg.nx, fg.ny, fg.nout)
    if fg.output_format == 1
        for k = 1:fg.nout
            ## fgoutNNNN.qXXXX
            filename = "fgout"*@sprintf("%04d",fg.id)*".q"*@sprintf("%04d",k)
            ## load
            dat = readdlm(joinpath(outputdir, filename), Float64; skipstart=9)
            D = reshape(dat[:,1],(fg.nx, fg.ny))
            tmp = reshape(dat[:,4],(fg.nx, fg.ny))
            dry = D .< 1e-3
            tmp[dry] .= NaN
            eta[:,:,k] = tmp
        end
    else
        if fg.output_format == 2
            dtype = Float32
        elseif fg.output_format == 3
            dtype = Float64
        else
            error("output_format $(fg.output_format) is not supported yet.")
        end
        nall = fg.nval*fg.nx*fg.ny
        for k = 1:fg.nout
            ## fgoutNNNN.bXXXX
            filename = "fgout"*@sprintf("%04d",fg.id)*".b"*@sprintf("%04d",k)
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
            eta[:,:,k] = e
        end
    end
    eta = permutedims(eta, (2, 1, 3))  # Adjust dimensions to (ny, nx, nout)

    ## create FGout struct
    fgout = VisClaw.FGout(eta)

    ## return 
    return fgout

end
#################################
