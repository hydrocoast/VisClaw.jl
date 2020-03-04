# Read configration files

###################################
"""
Function: geoclaw.data reader
"""
function geodata(dirname::String)
    # definition of filename
    fname = joinpath(dirname,"geoclaw.data")
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
Function: surge.data reader
"""
function surgedata(dirname::String)
    # definition of filename
    fname = joinpath(dirname,"surge.data")
    # check whether exist
    if !isfile(fname); error("File $fname is not found."); end
    # read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end
    # parse parameters
    windindex = parse(Int64,split(txt[occursin.("wind_index",txt)][1],r"\s+")[1])
    slpindex = parse(Int64,split(txt[occursin.("pressure_index",txt)][1],r"\s+")[1])
    stormtype = parse(Int64,split(txt[occursin.("storm_type",txt)][1],r"\s+")[1])
    landfall = parse(Float64,split(txt[occursin.(" landfall ",txt)][1],r"\s+")[1])
    # instance
    surgedata = VisClaw.SurgeParam(windindex,slpindex,stormtype,landfall)
    # return values
    return surgedata
end
###################################

###################################
"""
Function: gauges.data reader
"""
function gaugedata(dirname::String)
    # definition of filename
    fname = joinpath(dirname,"gauges.data")
    # check whether exist
    if !isfile(fname); error("File $fname is not found."); end
    # read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end
    # parse parameters
    ngauges = parse(Int64, split(txt[occursin.("ngauges",txt)][1],r"\s+")[1])
    # preallocate
    gaugedata = Vector{VisClaw.Gauge}(undef,ngauges)

    # read gauge info
    baseline = findfirst(x->occursin("ngauges", x), txt)
    for i = 1:ngauges
        txtline = split(strip(txt[baseline+i]), r"\s+", keepempty=false)
        label = txtline[1]
        id = parse(Int64,txtline[1])
        loc = [parse(Float64,txtline[2]), parse(Float64,txtline[3])]
        time = [parse(Float64,txtline[4]), parse(Float64,txtline[5])]
        # instance
        gaugedata[i] = VisClaw.Gauge(label,id,0,loc,[],time,[])
    end

    # return values
    return gaugedata
end
###################################

###################################
"""
Function: fgmax.data reader
"""
function fgmaxdata(dirname::String)
    # definition of filename
    fname = joinpath(dirname,"fgmax.data")
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
