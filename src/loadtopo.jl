#################################
## Function: read topo.data
#################################
"""
Function: read topo.data
"""
function topodata(dirname::String)
    ## check args
    if !isdir(dirname); error("A directory $dirname is not found."); end;

    ## read ascdata
    filename = joinpath(dirname,"topo.data")
    f = open(filename,"r")
    ascdata = readlines(f)
    close(f)

    baseline = findfirst(x->occursin("ntopofiles", x), ascdata)
    ntopo = parse(Int64, split(ascdata[baseline], r"\s+", keepempty=false)[1])

    if ntopo == 1
        topofile = replace(ascdata[baseline+2], r"[\'\s]" => "")
        topotype = parse(Int64, split(ascdata[baseline+3], r"\s+", keepempty=false)[1])
    else
        # preallocate
        topofile = Vector{String}(undef, ntopo)
        topotype = Vector{Int64}(undef, ntopo)
        # filename
        for i = 1:ntopo
            topofile[i] = replace(ascdata[baseline-1+3i], r"[\'\s]" => "")
            topotype[i] = parse(Int64, split(ascdata[baseline+3i], r"\s+", keepempty=false)[1])
        end
    end

    # return
    return topofile, topotype, ntopo
end
#################################

#################################
## Function: read dtopo.data
#################################
"""
Function: read dtopo.data
"""
function dtopodata(dirname::String)
    ## check args
    if !isdir(dirname); error("A directory $dirname is not found."); end;

    ## read ascdata
    filename= joinpath(dirname,"dtopo.data")
    if !isfile(filename); error("File $filename is not found."); end
    f = open(filename,"r")
    ascdata = readlines(f)
    close(f)

    baseline = findfirst(x->occursin("mdtopofiles", x), ascdata)
    ndtopo = parse(Int64, split(ascdata[baseline], r"\s+", keepempty=false)[1])

    if ndtopo == 0
        println("No mdtopofile")
        return nothing, nothing, ndtopo

    elseif ndtopo == 1
        dtopofile = replace(ascdata[baseline+3], r"[\'\s]" => "")
        dtopotype = parse(Int64, split(ascdata[baseline+4], r"\s+", keepempty=false)[1])

    else
        # preallocate
        dtopofile = Vector{String}(undef, ndtopo)
        dtopotype = Vector{Int64}(undef, ndtopo)
        # filename
        for i = 1:ndtopo
            dtopofile[i] = replace(ascdata[baseline+3i], r"[\'\s]" => "")
            dtopotype[i] = parse(Int64, split(ascdata[baseline+3i+1], r"\s+", keepempty=false)[1])
        end
    end

    # return
    return dtopofile, dtopotype, ndtopo
end
#################################


#################################
## Function: load topography
#################################
"""
Function: load topography
"""
function loadtopo(filename::String, topotype=3::Int64)
    ## from _output directory
    if isdir(filename)
        topofile, topotype, ntopo = VisClaw.topodata(filename)
        return VisClaw.loadtopo.(topofile, topotype)
    end

    ## check args
    if !isfile(filename); error("file $filename is not found."); end;
    if (topotype!=2) & (topotype!=3); error("unsupported topotype"); end

    ## separator in regular expression
    regex = r"([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)"
    ## open topofile
    f = open(filename,"r")
        ## read header
        ncols = parse(Int64, match(regex, readline(f)).captures[1])
        nrows = parse(Int64, match(regex, readline(f)).captures[1])
        xll = parse(Float64, match(regex, readline(f)).captures[1])
        yll = parse(Float64, match(regex, readline(f)).captures[1])
        cellsize = parse(Float64, match(regex, readline(f)).captures[1])
        nodata = match(regex, readline(f)).captures[1]
        ## read topography in asc
        dataorg = readlines(f)
    ## close topofile
    close(f)

    ## meshgrid
    x = collect(Float64, LinRange(xll, round(xll+(ncols-1)*cellsize, digits=3), ncols))
    y = collect(Float64, LinRange(yll, round(yll+(nrows-1)*cellsize, digits=3), nrows))

    # check topotype
    tmp = replace(dataorg[1], r"^\s+|,?\s+$" => "")
    tmp = replace(tmp, "," => " ") # for csv data
    tmp = split(tmp, r"\s+",keepempty=false)
    tmp = parse.(Float64, tmp)
    # topotype 2?
    if length(tmp) == 1
        if topotype == 3
            println("topotype 2?")
        end
        topotype = 2
    end
    # topotype 3?
    if length(tmp) > 1
        if topotype == 2
            println("topotype 3?")
        end
        topotype = 3
    end

    ## assign topography
    if topotype == 2
        topo = parse.(Float64, dataorg)
        topo = reshape(topo, (ncols, nrows))
        topo = permutedims(topo,[2 1])
    elseif topotype == 3
        topo = zeros(nrows, ncols)
        for k = 1:nrows
            line = replace(dataorg[k], r"^\s+|,?\s+$" => "")
            line = replace(line, "," => " ") # for csv data
            line = split(line, r"\s+",keepempty=false)
            topo[k,:] = parse.(Float64, line)
        end
    end
    topo[topo.==nodata] .= NaN ## replace nodate to NaN
    topo = reverse(topo, dims=1) ## flip
    geo = VisClaw.Topo(ncols, nrows, x, y, cellsize, cellsize, topo)

    return geo
end
#################################


#########################################
## Function: load seafloor deformation
#########################################
"""
Function: load seafloor deformation (dtopo)
"""
function loaddeform(filename::String, topotype=3::Int64)
    ## from _output directory
    if isdir(filename)
        dtopofile, topotype, ntopo = VisClaw.dtopodata(filename)
        return VisClaw.loaddeform.(dtopofile, topotype)
    end

    ## check args
    if !isfile(filename); error("file $filename is not found."); end
    if (topotype!=2) & (topotype!=3); error("Invalid topotype"); end

    ## separator in regular expression
    regex = r"([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)"
    ## open topofile
    f = open(filename,"r")
        ## read header
        mx = parse(Int64, match(regex, readline(f)).captures[1])
        my = parse(Int64, match(regex, readline(f)).captures[1])
        mt = parse(Int64, match(regex, readline(f)).captures[1])
        xlow = parse(Float64, match(regex, readline(f)).captures[1])
        ylow = parse(Float64, match(regex, readline(f)).captures[1])
        t0 = parse(Float64, match(regex, readline(f)).captures[1])
        dx = parse(Float64, match(regex, readline(f)).captures[1])
        dy = parse(Float64, match(regex, readline(f)).captures[1])
        dt = parse(Float64, match(regex, readline(f)).captures[1])
        ## read topography in asc
        dataorg = readlines(f)
    ## close topofile
    close(f)

    ## meshgrid
    x = collect(Float64, LinRange(xlow, round(xlow+(mx-1)*dx, digits=3), mx))
    y = collect(Float64, LinRange(ylow, round(ylow+(my-1)*dy, digits=3), my))

    # check topotype
    tmp = replace(dataorg[1], r"^\s+|,?\s+$" => "") # equivalent to strip?
    tmp = replace(tmp, "," => " ") # for csv data
    tmp = split(tmp, r"\s+", keepempty=false)
    tmp = parse.(Float64, tmp)
    # topotype 2?
    if length(tmp) == 1
        if topotype == 3
            println("topotype 2?")
        end
        topotype = 2
    end
    # topotype 3?
    if length(tmp) > 1
        if topotype == 2
            println("topotype 3?")
        end
        topotype = 3
    end

    ## assign topography
    if topotype == 2
        deform = parse.(Float64, dataorg)
        deform = reshape(topo, (mx, my))
        deform = permutedims(topo,[2 1])
    elseif topotype == 3
        deform = zeros(my, mx)
        for k = 1:my
            line = replace(dataorg[k], r"^\s+|,?\s+$" => "")
            line = replace(line, "," => " ") # for csv data
            line = split(line, r"\s+",keepempty=false)
            deform[k,:] = parse.(Float64, line)
        end
    end
    deform = reverse(deform, dims=1) ## flip
    #deform[abs.(deform).<1e-2] .= NaN
    dtopo = VisClaw.DTopo(mx,my,x,y,dx,dy,mt,t0,dt,deform)

    return dtopo
end
#########################################
const loaddtopo = loaddeform
#########################################
