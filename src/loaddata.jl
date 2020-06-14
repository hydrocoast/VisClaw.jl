# Read configration files

###################################
"""
    params = geodata("simlation/path/_output"::String)
    params = geodata("simlation/path/_output/geoclaw.data"::String)

Function: geoclaw.data reader
"""
function geodata(outdir::String)
    # definition of filename
    fname = occursin("geoclaw.data", basename(outdir)) ? outdir : joinpath(outdir, "geoclaw.data")

    # check whether exist
    if !isfile(fname); error("File $fname is not found."); end
    # read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end
    # parse parameters
    # parameters (mandatory?)
    cs = parse(Float64,split(txt[occursin.("coordinate",txt)][1],r"\s+")[1])
    p0 = parse(Float64,split(txt[occursin.("ambient_pressure",txt)][1],r"\s+")[1])
    R = parse(Float64,split(txt[occursin.("earth_radius",txt)][1],r"\s+")[1])
    eta0 = parse(Float64,split(txt[occursin.("sea_level",txt)][1],r"\s+")[1])
    dmin = parse(Float64,split(txt[occursin.("dry_tolerance",txt)][1],r"\s+")[1])
    # parameters (optional?)
    if any(occursin.("manning_coefficient",txt))
        n = parse(Float64,split(txt[occursin.("manning_coefficient",txt)][1],r"\s+")[1])
    else
        n = 0.0
    end
    # instance
    params = VisClaw.GeoParam(cs,p0,R,eta0,n,dmin)
    # return values
    return params
end
###################################

###################################
"""
    surgeparams = surgedata("simlation/path/_output"::String)
    surgeparams = surgedata("simlation/path/_output/surge.data"::String)

Function: surge.data reader
"""
function surgedata(outdir::String)
    # definition of filename
    fname = occursin("surge.data", basename(outdir)) ? outdir : joinpath(outdir, "surge.data")

    # check whether exist
    if !isfile(fname); error("File $fname is not found."); end
    # read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end
    # parse parameters
    windindex = parse(Int64,split(txt[occursin.("wind_index",txt)][1],r"\s+")[1])
    slpindex = parse(Int64,split(txt[occursin.("pressure_index",txt)][1],r"\s+")[1])
    stormtype = parse(Int64,split(txt[occursin.("storm_specification_type",txt)][1],r"\s+")[1])
    # instance
    surgeparams = VisClaw.SurgeParam(windindex,slpindex,stormtype)
    # return values
    return surgeparams
end
###################################

###################################
"""
    gaugeinfo = gaugedata("simlation/path/_output"::String)
    gaugeinfo = gaugedata("simlation/path/_output/gauges.data"::String)

Function: gauges.data reader
"""
function gaugedata(outdir::String)
    # definition of filename
    fname = occursin("gauges.data", basename(outdir)) ? outdir : joinpath(outdir,"gauges.data")

    # check whether exist
    if !isfile(fname); error("File $fname is not found."); end
    # read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end
    # parse parameters
    ngauges = parse(Int64, split(txt[occursin.("ngauges",txt)][1],r"\s+")[1])
    # preallocate
    gaugeinfo = Vector{VisClaw.Gauge}(undef,ngauges)

    # read gauge info
    baseline = findfirst(x->occursin("ngauges", x), txt)
    for i = 1:ngauges
        txtline = split(strip(txt[baseline+i]), r"\s+", keepempty=false)
        label = txtline[1]
        id = parse(Int64,txtline[1])
        loc = [parse(Float64,txtline[2]), parse(Float64,txtline[3])]
        time = [parse(Float64,txtline[4]), parse(Float64,txtline[5])]
        # instance
        gaugeinfo[i] = VisClaw.Gauge(label,id,0,loc,[],time,[])
    end

    # return values
    return gaugeinfo
end
###################################

###################################
"""
    fgmaxgrids = fgmaxdata("simlation/path/_output"::String)
    fgmaxgrids = fgmaxdata("simlation/path/_output/fgmax.data"::String)

Function: fgmax_grids.data reader
"""
function fgmaxdata(outdir::String)
    ## definition of filename
    fname = occursin("fgmax_grids.data", basename(outdir)) ? outdir : joinpath(outdir, "fgmax_grids.data")

    # check
    isfile(fname) || error("File $fname is not found.")
    # read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end

    # parse parameters
    num_fgmax_val = parse(Int64, split(txt[occursin.("num_fgmax_val",txt)][1],r"\s+")[1])
    num_fgmax_grids = parse(Int64, split(txt[occursin.("num_fgmax_grids",txt)][1],r"\s+")[1])

    fg = Vector{VisClaw.FixedGrid}(undef, num_fgmax_grids)
    for i=1:num_fgmax_grids
        baseline = 10+12(i-1)

        point_style = parse(Int64, split(strip(txt[baseline+8]), r"\s+")[1])
        (point_style != 2) && error("point_style $point_style is not supported yet.")

        FGid = parse(Int64, split(strip(txt[baseline+1]), r"\s+")[1])
        nx, ny = parse.(Int64, split(strip(txt[baseline+9]), r"\s+")[1:2])
        x1, y1 = parse.(Float64, split(strip(txt[baseline+10]), r"\s+")[1:2])
        x2, y2 = parse.(Float64, split(strip(txt[baseline+11]), r"\s+")[1:2])
        # instance
        fg[i] = VisClaw.FixedGrid(FGid, point_style, num_fgmax_val, nx, ny, (x1,x2), (y1,y2))
    end

    # return
    return fg
end
#=
###################################
"""
    fgmaxgrids = fgmaxdata("simlation/path/_output"::String)
    fgmaxgrids = fgmaxdata("simlation/path/_output/fgmax.data"::String)

Function: fgmax.data reader
"""
function fgmaxdata(outdir::String)
    # definition of filename
    fname = occursin("fgmax.data", basename(outdir)) ? outdir : joinpath(outdir, "fgmax.data")

    # check whether exist
    if !isfile(fname); error("File $fname is not found."); end
    # read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end

    # parse parameters
    num_fgmax_val = parse(Int64, split(txt[occursin.("num_fgmax_val",txt)][1],r"\s+")[1])
    num_fgmax_grids = parse(Int64, split(txt[occursin.("num_fgmax_grids",txt)][1],r"\s+")[1])

    # preallocate
    #fgmax_files = Vector{String}(undef, num_fgmax_grids)
    fgmaxgrids = Vector{VisClaw.FGmaxGrid}(undef, num_fgmax_grids)

    if num_fgmax_grids==0
        println("fgmax grid is not specified")
        return num_fgmax_val, num_fgmax_grids, fgmax_files
    end

    # baseline in fgmax.data
    baseline = findfirst(x->occursin("num_fgmax_grids", x), txt)
    if baseline === nothing; error("Not found: fgmax_grids"); end

    for i = 1:num_fgmax_grids
        filename = strip(txt[baseline+2i+1])[2:end-1] # remove quotes \'
        fgmaxgrids[i] = VisClaw.FGmaxGrid(i, filename, num_fgmax_val)
    end

    # return
    return fgmaxgrids

end
###################################
=#
