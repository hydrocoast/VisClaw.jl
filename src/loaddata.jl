# Read configration files

###################################
"""
    params = geodata("simlation/path/_output"::AbstractString)
    params = geodata("simlation/path/_output/geoclaw.data"::AbstractString)

Function: geoclaw.data reader
"""
function geodata(outdir::AbstractString)
    ## set filename
    fname = occursin("geoclaw.data", basename(outdir)) ? outdir : joinpath(outdir, "geoclaw.data")

    ## check whether it exists
    if !isfile(fname); error("File $fname is not found."); end
    ## read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end
    ## parse parameters
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
    ## instance
    params = VisClaw.GeoParam(cs,p0,R,eta0,n,dmin)
    ## return values
    return params
end
###################################

###################################
"""
    surgeparams = surgedata("simlation/path/_output"::AbstractString)
    surgeparams = surgedata("simlation/path/_output/surge.data"::AbstractString)

Function: surge.data reader
"""
function surgedata(outdir::AbstractString)
    ## set filename
    fname = occursin("surge.data", basename(outdir)) ? outdir : joinpath(outdir, "surge.data")

    ## check whether it exists
    if !isfile(fname); error("File $fname is not found."); end
    ## read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end
    ## parse parameters
    windindex = parse(Int64,split(txt[occursin.("wind_index",txt)][1],r"\s+")[1])
    slpindex = parse(Int64,split(txt[occursin.("pressure_index",txt)][1],r"\s+")[1])
    stormtype = parse(Int64,split(txt[occursin.("storm_specification_type",txt)][1],r"\s+")[1])
    ## instance
    surgeparams = VisClaw.SurgeParam(windindex,slpindex,stormtype)
    ## return values
    return surgeparams
end
###################################

###################################
"""
    gaugeinfo = gaugedata("simlation/path/_output"::AbstractString)
    gaugeinfo = gaugedata("simlation/path/_output/gauges.data"::AbstractString)

Function: gauges.data reader
"""
function gaugedata(outdir::AbstractString)
    ## set filename
    fname = occursin("gauges.data", basename(outdir)) ? outdir : joinpath(outdir,"gauges.data")

    ## check whether it exists
    if !isfile(fname); error("File $fname is not found."); end
    ## read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end
    ## parse parameters
    ngauges = parse(Int64, split(txt[occursin.("ngauges",txt)][1],r"\s+")[1])
    ## preallocate
    gaugeinfo = Vector{VisClaw.Gauge}(undef,ngauges)

    ## read gauge info
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

    ## return values
    return gaugeinfo
end
###################################

###################################
"""
    amrparam = amrdata("simlation/path/_output"::AbstractString)
    amrparam = amrdata("simlation/path/_output/amr.data"::AbstractString)

Function: amr.data reader
"""
function amrdata(outdir::AbstractString)
    ## set filename
    fname = occursin("amr.data", basename(outdir)) ? outdir : joinpath(outdir, "amr.data")

    ## check whether it exists
    if !isfile(fname); error("File $fname is not found."); end
    ## read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end

    ## parse parameters
    maxlevel = parse(Int64,split(txt[occursin.("amr_levels_max",txt)][1],r"\s+")[1])
    ## instance
    amrparam = VisClaw.AMRParam(maxlevel)
    ## return values
    return amrparam
end
###################################

###################################
"""
    regions = regiondata("simlation/path/_output"::AbstractString)
    regions = regiondata("simlation/path/_output/region.data"::AbstractString)

Function: region.data reader
"""
function regiondata(outdir::AbstractString)
    ## set filename
    fname = occursin("regions.data", basename(outdir)) ? outdir : joinpath(outdir, "regions.data")

    ## check whether it exists
    if !isfile(fname); error("File $fname is not found."); end
    ## read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end

    ## parse parameters
    nregion = parse(Int64, split(txt[occursin.("num_regions",txt)][1],r"\s+")[1])
    ## preallocate
    regions = Vector{VisClaw.Region}(undef,nregion)

    ## read gauge info
    baseline = findfirst(x->occursin("num_regions", x), txt)
    for i = 1:nregion
        txtline = split(strip(txt[baseline+i]), r"\s+", keepempty=false)
        minlevel = parse(Int64,txtline[1])
        maxlevel = parse(Int64,txtline[2])
        tl = (parse(Float64,txtline[3]), parse(Float64,txtline[4]))
        xl = (parse(Float64,txtline[5]), parse(Float64,txtline[6]))
        yl = (parse(Float64,txtline[7]), parse(Float64,txtline[8]))
        ## instance
        regions[i] = VisClaw.Region(minlevel:maxlevel, tl, xl, yl)
    end

    return regions
end
###################################


###################################
"""
    clawparam = clawdata("simlation/path/_output"::AbstractString)
    clawparam = clawdata("simlation/path/_output/claw.data"::AbstractString)

Function: claw.data reader
"""
function clawdata(outdir::AbstractString)
    ## set filename
    fname = occursin("claw.data", basename(outdir)) ? outdir : joinpath(outdir, "claw.data")

    ## check whether it exists
    if !isfile(fname); error("File $fname is not found."); end
    ## read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end

    ## parse parameters
    num_dim = parse(Int64, split(txt[occursin.("num_dim",txt)][1],r"\s+")[1])
    lower = parse.(Float64, split(txt[occursin.("lower",txt)][1],r"\s+")[1:2])
    upper = parse.(Float64, split(txt[occursin.("upper",txt)][1],r"\s+")[1:2])
    num_cells = parse.(Int64, split(txt[occursin.("num_cells",txt)][1],r"\s+")[1:2])
    t0 = parse(Float64, split(txt[occursin.("t0",txt)][1],r"\s+")[1])
    tfinal = parse(Float64, split(txt[occursin.("tfinal",txt)][1],r"\s+")[1])
    output_format = parse(Int64, split(txt[occursin.("output_format",txt)][1],r"\s+")[1])
    num_ghost = parse(Int64, split(txt[occursin.("num_ghost",txt)][1],r"\s+")[1])

    xlims = (lower[1], upper[1])
    ylims = (lower[2], upper[2])
    nx = num_cells[1]
    ny = num_cells[2]
    ## check whether the number of dimensions is correct
    if num_dim != 2
        error("The number of dimensions must be 2, but got $num_dim.")
    end

    ## instance
    clawparam = VisClaw.ClawParam(num_dim, xlims, ylims, nx, ny, t0, tfinal, output_format, num_ghost)

    ## return values
    return clawparam
end
###################################
