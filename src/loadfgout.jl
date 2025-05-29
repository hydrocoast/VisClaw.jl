#################################
"""
    fgout = loadfgout(outputdir::AbstractString, fg::VisClaw.FixedGrid)

Function: fgoutNNNN.qXXXX reader
"""
function loadfgout(outputdir::AbstractString, fg::VisClaw.FixedGrid)
    ## check nval_save
    #nval_save > fg.nval && (nval_save=fg.nval)

    eta = zeros(fg.nx, fg.ny, fg.nout)
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
    eta = permutedims(eta, (2, 1, 3))  # Adjust dimensions if necessary
    fgout = VisClaw.FGout(eta)
    return fgout

end
#################################
