###################################
"""
    track = loadtrack("simlation/path/_output"::String)
    track = loadtrack("simlation/path/_output/fort.track"::String)

Function: fort.track reader
"""
function loadtrack(outdir::String)
    ## definition of filename
    fname = occursin("fort.track", basename(outdir)) ? outdir : joinpath(outdir, "fort.track")
    ## check
    isfile(fname) || error("File $fname is not found.")

    ## load
    datorg = readdlm(fname)
    datorg[datorg.>1e30] .= NaN

    ## return
    return VisClaw.Track(datorg[:,1], datorg[:,2], datorg[:,3], datorg[:,4])
end
