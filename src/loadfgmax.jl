#################################
"""
    fgmax = loadfgmax(loaddir::String, fg::VisClaw.FixedGrid; nval_save::Int64=fg.nval)

Function: fgmaxXXXX.txt reader
"""
function loadfgmax(loaddir::String, fg::VisClaw.FixedGrid; nval_save::Int64=fg.nval)
    # check nval_save
    nval_save > fg.nval && (nval_save=fg.nval)

    # fgmaxXXXX.txt
    filename = "fgmax"*@sprintf("%04d",fg.id)*".txt"
    # load
    dat = readdlm(joinpath(loaddir, filename), Float64)
    dat[dat.<-1e10] .= NaN

    # assign
    ncol = 4 + 2(fg.nval) + 1
    valall = permutedims(reshape(dat, (fg.nx, fg.ny, ncol)), [2 1 3])
    topo = valall[:,:,4]
    D = valall[:,:,5]
    tD = valall[:,:,5+fg.nval]
    tarrival = valall[:,:,end]
    if fg.nval >= 2
        v = valall[:,:,6]
        tv = valall[:,:,6+fg.nval]
    end
    if fg.nval >= 5
        M = valall[:,:,7]
        tM = valall[:,:,7+fg.nval]
        Mflux = valall[:,:,8]
        tMflux = valall[:,:,8+fg.nval]
        hmin = valall[:,:,9]
        thmin = valall[:,:,9+fg.nval]
    end

    if nval_save == 1;     fgmax = VisClaw.FGmax(topo,D,tD,tarrival)
    elseif nval_save == 2; fgmax = VisClaw.FGmax(topo,D,v,tD,tv,tarrival)
    elseif nval_save == 5; fgmax = VisClaw.FGmax(topo,D,v,M,Mflux,hmin,tD,tv,tM,tMflux,thmin,tarrival)
    end

    # return
    return fgmax

end
#################################
