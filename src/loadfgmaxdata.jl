###################################
"""
    fgmaxgrids = fgmaxdata("simlation/path/_output"::AbstractString)
    fgmaxgrids = fgmaxdata("simlation/path/_output/fgmax_grids.data"::AbstractString)

Function: fgmax_grids.data reader
"""
function fgmaxdata(outdir::AbstractString)
    ## definition of filename
    fname = occursin("fgmax_grids.data", basename(outdir)) ? outdir : joinpath(outdir, "fgmax_grids.data")

    ## check
    isfile(fname) || error("File $fname is not found.")
    ## read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end

    ## parse parameters
    num_fgmax_val = parse(Int64, split(txt[occursin.("num_fgmax_val",txt)][1],r"\s+")[1])
    num_fgmax_grids = parse(Int64, split(txt[occursin.("num_fgmax_grids",txt)][1],r"\s+")[1])

    ## preallocate
    fg = Vector{VisClaw.FixedGrid}(undef, num_fgmax_grids)
    ## load
    global baseline = 10
    for i = 1:num_fgmax_grids
        ## basic parameters
        FGid = parse(Int64, split(strip(txt[baseline+1]), r"\s+")[1])
        point_style = parse(Int64, split(strip(txt[baseline+8]), r"\s+")[1])
        ## check point style
        (point_style > 4 || point_style < 0) && error("point_style $point_style is not supported yet.")

        ## 0
        if point_style == 0
            ## npts
            npts = parse(Int64, split(strip(txt[baseline+9]), r"\s+")[1])
            ## x, y
            if npts == 0
                fgmax_deffile = String(strip(txt[baseline+10])[2:end-1])
                open(fgmax_deffile,"r") do ff; global fgtxt = readlines(ff); end
                npts = parse(Int64, split(strip(fgtxt[1]), r"\s+")[1])
                x = zeros(Float64,npts)
                y = zeros(Float64,npts)
                for ip = 1:npts
                    x[ip], y[ip] = parse.(Float64, split(strip(fgtxt[1+ip]), r"\s+")[1:2])
                end
                baseline += 11
            else
                x = zeros(Float64,npts)
                y = zeros(Float64,npts)
                for ip = 1:npts
                    x[ip], y[ip] = parse.(Float64, split(strip(txt[baseline+9+ip]), r"\s+")[1:2])
                end
                baseline += 10 + npts
            end
            ## instance
            fg[i] = VisClaw.FixedGrid(FGid, point_style, num_fgmax_val, NaN, NaN, 1, npts, x, y)

        ## 1
        elseif point_style == 1
            npts = parse(Int64, split(strip(txt[baseline+9]), r"\s+")[1])
            x1, y1 = parse.(Float64, split(strip(txt[baseline+10]), r"\s+")[1:2])
            x2, y2 = parse.(Float64, split(strip(txt[baseline+11]), r"\s+")[1:2])
            x = LinRange(x1, x2, npts)
            y = LinRange(y1, y2, npts)
            # instance
            fg[i] = VisClaw.FixedGrid(FGid, point_style, num_fgmax_val, NaN, NaN, 1, npts, x, y)
            baseline += 12

        ## 2
        elseif point_style == 2
            nx, ny = parse.(Int64, split(strip(txt[baseline+9]), r"\s+")[1:2])
            x1, y1 = parse.(Float64, split(strip(txt[baseline+10]), r"\s+")[1:2])
            x2, y2 = parse.(Float64, split(strip(txt[baseline+11]), r"\s+")[1:2])
            # instance
            fg[i] = VisClaw.FixedGrid(FGid, point_style, num_fgmax_val,  NaN, NaN, 1, nx, ny, (x1,x2), (y1,y2))
            baseline += 12

        ## 3
        elseif point_style == 3
            error("point_style $point_style is not supported yet.")

        ## 4
        elseif point_style == 4
            fgmax_deffile = String(strip(txt[baseline+9])[2:end-1])
            topoflag = loadtopo(fgmax_deffile, 3)

            flag = findall(convert(BitArray, topoflag.elevation))
            X = repeat(topoflag.x', outer=(topoflag.nrows,1))
            Y = repeat(topoflag.y,  outer=(1,topoflag.ncols))
            x = vec(X[flag])
            y = vec(Y[flag])
            npts = length(x)

            ind = sortperm([flag[i][1] for i=1:npts], rev=true)
            flag = flag[ind]
            x = x[ind]
            y = y[ind]

            ## instance
            fg[i] = VisClaw.FixedGrid(FGid, point_style, num_fgmax_val, NaN, NaN, 1,
                                      topoflag.ncols, topoflag.nrows,
                                      extrema(topoflag.x), extrema(topoflag.y),
                                      npts, x, y, flag)
            baseline += 10
        end
    end

    ## return
    return fg
end
