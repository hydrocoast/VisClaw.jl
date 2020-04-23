"""
    amr = loadfortq(filename::String, ncol::Int; vartype::Symbol=:surface,
                    params::VisClaw.GeoParam=VisClaw.GeoParam(), runup::Bool=true,
                    xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf),
                    AMRlevel=[])

Function: fort.qxxxx reader
"""
function loadfortq(filename::String, ncol::Int; vartype::Symbol=:surface,
                   params::VisClaw.GeoParam=VisClaw.GeoParam(), runup::Bool=true,
                   xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf),
                   AMRlevel=[])
    # check
    !any(map(sym -> vartype == sym, [:surface, :current, :storm])) && error("kwarg 'vartype' is invalid")

    ## file open
    f = open(filename,"r")
    txtorg = readlines(f)
    close(f) #close

    ## count the number of lines and grids
    nlineall = length(txtorg)
    idx = occursin.("grid_number",txtorg)
    ngrid = length(txtorg[idx])

    if vartype==:surface
        amr = Array{VisClaw.SurfaceHeight}(undef,ngrid) ## preallocate
    elseif vartype==:current
        amr = Array{VisClaw.Velocity}(undef,ngrid)
    elseif vartype==:storm
        amr = Array{VisClaw.Storm}(undef,ngrid)
    end

    l = 1
    i = 1
    while l < nlineall
        ## read header
        #header = txtorg[1:8]
        header = txtorg[l:l+7]
        header = map(strip,header)
        gridnumber = parse(Int64, split(header[1],r"\s+")[1])
        AMRlevel_load = parse(Int64, split(header[2],r"\s+")[1])
        mx = parse(Int64, split(header[3],r"\s+")[1])
        my = parse(Int64, split(header[4],r"\s+")[1])
        xlow = parse(Float64, split(header[5],r"\s+")[1])
        ylow = parse(Float64, split(header[6],r"\s+")[1])
        dx = parse(Float64, split(header[7],r"\s+")[1])
        dy = parse(Float64, split(header[8],r"\s+")[1])
        ## read variables
        body = txtorg[l+9:l+9+(mx+1)*my-1]

        # the next tile
        l = l+9+(mx+1)*my
        ## check AMRlevel
        if !isempty(AMRlevel); if isempty(findall(AMRlevel .== AMRlevel_load)); i += 1; continue; end; end

        ## check whether the tile is on the domain
        if (xlow+dx*mx < xlims[1]) | (xlims[2] < xlow); i += 1; continue; end
        if (ylow+dy*my < ylims[1]) | (ylims[2] < ylow); i += 1; continue; end

        if vartype==:surface
            elev = [parse(Float64, body[(i-1)*(mx+1)+j][26*(ncol-1)+1:26*ncol]) for i=1:my, j=1:mx]
            depth = [parse(Float64, body[(i-1)*(mx+1)+j][1:26]) for i=1:my, j=1:mx]
            # wet condition
            land = (elev-depth) .>= params.dmin

            # sea surface anomaly
            if params.eta0 != 0.0
                elev[.!land] = elev[.!land].-params.eta0
            end

            # inundation depth if wet
            if runup
                elev[land] = depth[land]
            end

            # NaN if dry
            elev[depth.<=0.0] .= NaN

            ## array
            amr[i] = VisClaw.SurfaceHeight(gridnumber,AMRlevel_load,mx,my,xlow,ylow,dx,dy,elev)

        elseif vartype==:current
            ucol = ncol
            vcol = ncol+1
            # read
            depth = [parse(Float64, body[(i-1)*(mx+1)+j][1:26]) for i=1:my, j=1:mx]
            u = [parse(Float64, body[(i-1)*(mx+1)+j][26*(ucol-1)+1:26*ucol]) for i=1:my, j=1:mx]
            v = [parse(Float64, body[(i-1)*(mx+1)+j][26*(vcol-1)+1:26*vcol]) for i=1:my, j=1:mx]
            # replace to NaN
            mask = depth.<=0.0
            depth[mask] .= NaN
            u[mask] .= NaN
            v[mask] .= NaN
            # calc
            u = u./depth
            v = v./depth
            vel = sqrt.(u.^2 .+ v.^2)
            ## array
            amr[i] = VisClaw.Velocity(gridnumber,AMRlevel_load,mx,my,xlow,ylow,dx,dy,u,v,vel)

        elseif vartype==:storm
            ucol = ncol
            vcol = ncol+1
            pcol = ncol+2
            u = [parse(Float64, body[(i-1)*(mx+1)+j][26*(ucol-1)+1:26*ucol]) for i=1:my, j=1:mx]
            v = [parse(Float64, body[(i-1)*(mx+1)+j][26*(vcol-1)+1:26*vcol]) for i=1:my, j=1:mx]
            p = [parse(Float64, body[(i-1)*(mx+1)+j][26*(pcol-1)+1:26*pcol]) for i=1:my, j=1:mx]
            p = p./1e+2

            # u[(abs.(u).<=1e-2) .& (abs.(v).<=1e-2)] .= NaN
            # v[(abs.(u).<=1e-2) .& (abs.(v).<=1e-2)] .= NaN

            ## array
            amr[i] = VisClaw.Storm(gridnumber,AMRlevel_load,mx,my,xlow,ylow,dx,dy,u,v,p)
        end
        ## print
        #@printf("%d, ",gridnumber)

        ## counter; go to the next grid
        i += 1
    end
    amr = amr[filter(i -> isassigned(amr, i), 1:length(amr))]
    ## return
    return amr
end
#################################
"""
    amr = loadforta(filename::String, ncol::Int;
                    xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[])

Function: fort.axxxx reader
"""
loadforta(filename::String, ncol::Int; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadfortq(filename, ncol; vartype=:storm, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#################################

#################################
"""
    timelaps = loadfortt(filename::String)

Function: fort.txxxx reader
"""
function loadfortt(filename::String)
    ## file open
    f = open(filename,"r")
    txtorg = readlines(f)
    close(f) #close
    ## parse timelaps from the 1st line
    timelaps = parse(Float64, txtorg[1][1:18])
    ## return
    return timelaps
end
#################################

#######################################
"""
    amrs = loadsurface(loaddir::String, filesequence::AbstractVector{Int64}; runup::Bool=true,
                       xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadsurface(loaddir::String, filestart::Int64, filend::Int64; runup::Bool=true,
                       xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadsurface(loaddir::String, fileid::Int64; runup::Bool=true,
                       xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadsurface(loaddir::String; runup::Bool=true,
                       xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

Function: loadfortq and loadfortt
          time-series of water surface
"""
function loadsurface(loaddir::String, filesequence::AbstractVector{Int64};
                     vartype::Symbol=:surface, runup::Bool=true,
                     xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf),
                     AMRlevel=[])

    # check
    !any(map(sym -> vartype == sym, [:surface, :current, :storm])) && error("kwarg 'vartype' is invalid")

    ## define the filepath & filename
    if vartype==:surface
        fnamekw = "fort.q0"
        col=4
    elseif vartype==:current
        fnamekw = "fort.q0"
        col=2
    elseif vartype==:storm
        fnamekw = "fort.a0"
        col=5
    end

    ## make a list
    if !isdir(loaddir); error("Directory $loaddir doesn't exist"); end
    flist = readdir(loaddir)
    idx = occursin.(fnamekw,flist)
    if sum(idx)==0; error("File named $fnamekw was not found"); end
    flist = flist[idx]

    # load geoclaw.data
    params = VisClaw.geodata(loaddir)

    ## the number of files
    nfile = length(flist)

    # file sequence to be loaded
    if filesequence==0:0; filesequence = 1:nfile; end
    (any(filesequence .< 1) || any(filesequence .> nfile)) && error("Incorrect file sequence was specified. (This must be from 1 to $nfile)")


    ## the number of files (to be loaded)
    nfile = length(filesequence)

    ## preallocate
    if vartype==:surface
        amr = Vector{AbstractVector{VisClaw.SurfaceHeight}}(undef,nfile)
    elseif vartype==:current
        amr = Vector{AbstractVector{VisClaw.Velocity}}(undef,nfile)
    elseif vartype==:storm
        amr = Vector{AbstractVector{VisClaw.Storm}}(undef,nfile)
    end

    ## load all files
    tlap = vec(zeros(nfile,1))
    cnt = 0
    for it = filesequence
        cnt += 1
        if vartype==:surface
            amr[cnt] = VisClaw.loadfortq(joinpath(loaddir,flist[it]), col, vartype=vartype, params=params, runup=runup, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
        elseif vartype==:current
            amr[cnt] = VisClaw.loadfortq(joinpath(loaddir,flist[it]), col, vartype=vartype, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
        elseif vartype==:storm
            amr[cnt] = VisClaw.loadforta(joinpath(loaddir,flist[it]), col, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
        end
        tlap[cnt] = VisClaw.loadfortt(joinpath(loaddir,replace(flist[it],r"\.." => ".t")))
    end

    ## AMR Array
    amrs = VisClaw.AMR(nfile,tlap,amr)

    ## return value
    return amrs
end
#######################################
loadsurface(loaddir::String, filestart::Int64, filend::Int64; runup::Bool=true, xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, filestart:filend; runup=runup, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
loadsurface(loaddir::String, fileid::Int64; runup::Bool=true, xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, fileid:fileid; runup=runup, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
loadsurface(loaddir::String; runup::Bool=true, xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, 0:0; runup=runup, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
######################################

######################################
"""
    amrs = loadstorm(loaddir::String, filesequence::AbstractVector{Int64}; xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadstorm(loaddir::String, filestart::Int64, filend::Int64; xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadstorm(loaddir::String, fileid::Int64; xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadstorm(loaddir::String; xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

Function: loadforta and loadfortt
          storm data
"""
loadstorm(loaddir::String, filesequence::AbstractVector{Int64}; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, filesequence, vartype=:storm, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
loadstorm(loaddir::String, filestart::Int64, filend::Int64; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, filestart:filend, vartype=:storm, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
loadstorm(loaddir::String, fileid::Int64; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, fileid:fileid, vartype=:storm, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
loadstorm(loaddir::String; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, 0:0, vartype=:storm, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
######################################

#######################################
"""
    amrs = loadcurrent(loaddir::String, filesequence::AbstractVector{Int64}; xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadcurrent(loaddir::String, filestart::Int64, filend::Int64; xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadcurrent(loaddir::String, fileid::Int64; xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

    amrs = loadcurrent(loaddir::String; xlims=(-Inf,Inf), ylims=(-Inf,Inf), AMRlevel=[])

Function: loadfortq and loadfortt
          ocean current data
"""
loadcurrent(loaddir::String, filesequence::AbstractVector{Int64}; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, filesequence, vartype=:current, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
loadcurrent(loaddir::String, filestart::Int64, filend::Int64; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, filestart:filend, vartype=:current, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
loadcurrent(loaddir::String, fileid::Int64; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, fileid:fileid, vartype=:current, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
loadcurrent(loaddir::String; xlims::Tuple{Number, Number}=(-Inf,Inf), ylims::Tuple{Number, Number}=(-Inf,Inf), AMRlevel=[]) =
loadsurface(loaddir, 0:0, vartype=:current, xlims=xlims, ylims=ylims, AMRlevel=AMRlevel)
#######################################
